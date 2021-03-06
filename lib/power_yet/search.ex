defmodule PowerYet.Search do
  import Ecto.Query, warn: false
  import Geo.PostGIS
  alias PowerYet.Repo
  alias PowerYet.Outage

  def search_outages_near({lat, long}, metres \\ 500)
      when is_number(lat) and is_number(long) and is_number(metres) do
    {lat, long}
    |> lat_long_to_point
    |> outages_near_point(metres)
    |> Enum.sort_by(fn {distance, _, outage} -> {distance, outage.name} end)
  end

  defp lat_long_to_point({lat, long}) do
    %Geo.Point{coordinates: {long, lat}, srid: 4326}
  end

  def outages_near_point(point, metres) do
    outages_near_point_query(point, metres)
    |> Repo.all()
  end

  defp outages_near_point_query(point, metres) do
    from(
      outage in Outage,
      where: outage.active,
      where: st_dwithin(outage.extent, ^point, ^metres),
      select: {
        st_distance_in_meters(outage.extent, ^point),
        fragment("degrees(ST_Azimuth(?, ST_ClosestPoint(extent::geometry, ?)))", ^point, ^point),
        outage
      }
    )
  end
end
