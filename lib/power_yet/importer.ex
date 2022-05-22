defmodule PowerYet.Importer do
  alias Geo.{Polygon, MultiPolygon}
  alias Ecto.Multi
  import Ecto.Query, only: [from: 2]

  alias PowerYet.Outage
  alias PowerYet.Repo

  def import(data \\ get_ottawa_json()) do
    data
    |> parse()
    |> Enum.reduce(Multi.new(), &import_multi/2)
    |> Multi.merge(&multi_delete_unused/1)
    |> Repo.transaction()
  end

  @unique_fields [:name]
  @replace_fields [:active, :customers, :metadata, :extent]

  defp import_multi(%Outage{} = outage, %Multi{} = multi) do
    multi
    |> Multi.insert(outage.name, outage,
      conflict_target: @unique_fields,
      on_conflict: {:replace, @replace_fields}
    )
  end

  defp multi_delete_unused(changes) do
    names = Map.keys(changes)
    query = from(o in Outage, where: o.name not in ^names)

    Multi.new()
    |> Multi.delete_all(:unused, query)
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
    |> Map.fetch!(:body)
    |> Poison.decode!()
  end

  defp crs_to_srid("urn:ogc:def:crs:OGC:1.3:CRS84"), do: 4326

  defp merge_outage({name, areas}, srid) do
    %Outage{
      name: name,
      active: true,
      customers: areas |> Enum.map(&customer_count/1) |> Enum.sum(),
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
end
