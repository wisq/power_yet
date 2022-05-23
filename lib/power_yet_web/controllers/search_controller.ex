defmodule PowerYetWeb.SearchController do
  use PowerYetWeb, :controller
  alias PowerYet.Search

  def search(conn, %{"latitude" => lat, "longitude" => long, "formatted" => formatted}) do
    {at, near} =
      {
        String.to_float(lat),
        String.to_float(long)
      }
      |> Search.search_outages_near()
      |> Enum.split_with(fn {dist, _} -> dist == 0.0 end)

    render(conn, "search.html", outages_at: at, outages_near: near, location: formatted)
  end
end
