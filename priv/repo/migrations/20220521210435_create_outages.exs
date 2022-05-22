defmodule PowerYet.Repo.Migrations.CreateOutages do
  use Ecto.Migration

  def change do
    create table(:outages) do
      timestamps()
      add :name, :string, null: false
      add :active, :boolean, null: false
      add :customers, :integer, null: false
      add :metadata, :jsonb, null: false
      add :extent, :"geometry(multipolygon,4326)", null: false
    end

    create(index(:outages, :name, unique: true))
  end
end
