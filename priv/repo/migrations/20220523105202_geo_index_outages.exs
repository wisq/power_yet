defmodule PowerYet.Repo.Migrations.GeoIndexOutages do
  use Ecto.Migration

  def change do
    alter table("outages") do
      modify :extent,
             :"geography(multipolygon,4326)",
             from: :"geometry(multipolygon,4326)"
    end

    create(index(:outages, :extent, using: "GIST", where: "active"))
  end
end
