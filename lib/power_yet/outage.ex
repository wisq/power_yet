defmodule PowerYet.Outage do
  use Ecto.Schema

  schema "outages" do
    timestamps()
    field(:name, :string)
    field(:active, :boolean)
    field(:customers, :integer)
    field(:metadata, Ecto.JSON)
    field(:extent, Geo.PostGIS.Geometry)
  end
end
