defmodule PowerYet.Importer do
  require Logger

  alias Geo.{Polygon, MultiPolygon}
  alias Ecto.Multi
  import Ecto.Query, only: [from: 2]

  alias PowerYet.Outage
  alias PowerYet.Repo
  alias PowerYet.Status

  def import(data \\ get_ottawa_json()) do
    multi =
      Multi.new()
      |> Multi.run(:max_id, &multi_select_max_id/2)

    {:ok, results} =
      data
      |> parse()
      |> Enum.reduce(multi, &import_multi/2)
      |> Multi.merge(&multi_deactivate_unused/1)
      |> Multi.append(status_multi = Status.multi_update_last_import_at())
      |> Repo.transaction()

    {max_id, results} = Map.pop!(results, :max_id)
    {{deactivated, _}, results} = Map.pop!(results, :unused)
    results = drop_multi_results(results, status_multi)

    outages = Map.values(results)
    added = outages |> Enum.count(&(&1.id > max_id))
    updated = outages |> Enum.count(&(&1.id <= max_id))

    Logger.info(
      "Imported outage data: #{added} added, #{updated} updated, #{deactivated} deactivated."
    )

    outages
  end

  @unique_fields [:name]
  @replace_fields [:active, :customers, :metadata, :extent]

  defp multi_select_max_id(repo, _) do
    case from(o in Outage, order_by: [desc: o.id], select: o.id, limit: 1) |> repo.one() do
      nil -> {:ok, -1}
      n when is_integer(n) -> {:ok, n}
    end
  end

  defp import_multi(%Outage{} = outage, %Multi{} = multi) do
    multi
    |> Multi.insert(outage.name, outage,
      conflict_target: @unique_fields,
      on_conflict: {:replace, @replace_fields}
    )
  end

  defp multi_deactivate_unused(changes) do
    names = Map.keys(changes) |> Enum.filter(&is_binary/1)
    query = from(o in Outage, where: o.active and o.name not in ^names)

    Multi.new()
    |> Multi.update_all(:unused, query, set: [active: false, updated_at: DateTime.utc_now()])
  end

  def parse(data) do
    %{"crs" => %{"type" => "name", "properties" => %{"name" => crs}}} = data
    srid = crs_to_srid(crs)

    data
    |> Geo.JSON.decode!()
    |> Map.fetch!(:geometries)
    |> Enum.group_by(fn %{properties: %{"Name" => n}} -> n end)
    |> Enum.map(&merge_outage(&1, srid))
  end

  defp get_ottawa_json do
    "https://outages.hydroottawa.com/geojson/outage_polygons_public.json"
    |> HTTPoison.get!()
    |> extract_body()
    |> Poison.decode!()
  end

  defp extract_body(%{headers: head, body: body}) do
    head = head |> Map.new(fn {k, v} -> {String.downcase(k), v} end)
    ctype = Map.get(head, "content-type")
    cenc = Map.get(head, "content-encoding")

    cond do
      ctype == "application/octet-stream" && cenc == "gzip" ->
        {:ok, stream} = body |> StringIO.open()

        stream
        |> IO.binstream(4096)
        |> StreamGzip.gunzip()
        |> Enum.join("")

      true ->
        raise "not implemented: #{inspect({ctype, cenc})}"
    end
  end

  defp crs_to_srid("urn:ogc:def:crs:OGC:1.3:CRS84"), do: 4326

  defp merge_outage({name, areas}, srid) do
    %Outage{
      name: name,
      active: true,
      customers: areas |> Enum.map(&customer_count/1) |> merge_customer_counts(),
      metadata: areas |> merge_properties(),
      extent: areas |> merge_geometries(srid)
    }
  end

  defp customer_count(%{properties: %{"OUTAGE_CUSTOMERS" => n}}), do: String.to_integer(n)

  defp merge_properties(features) do
    features
    |> Enum.reduce(%{}, fn %{properties: props2}, props1 ->
      Map.merge(props1, props2, fn
        _k, v, v -> v
        _k, _v1, _v2 -> :multiple
      end)
    end)
    |> Map.reject(fn
      {_, :multiple} -> true
      {_, _} -> false
    end)
  end

  defp merge_geometries(features, srid) do
    %MultiPolygon{
      coordinates: features |> Enum.map(fn %Polygon{coordinates: c} -> c end),
      srid: srid
    }
  end

  defp drop_multi_results(results, multi) do
    Map.drop(results, multi |> Multi.to_list() |> Keyword.keys())
  end

  defp merge_customer_counts(list) do
    case Enum.uniq(list) do
      [value] ->
        value

      uniq ->
        Logger.warn("Multiple values for customer counts: #{inspect(uniq)}")
        Enum.max(uniq)
    end
  end
end
