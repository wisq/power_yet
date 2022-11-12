defmodule PowerYet.Repo.Migrations.CreateStatus do
  defmodule Status do
    use Ecto.Schema
    import Ecto.Changeset

    alias __MODULE__

    schema "status" do
      field(:last_import_at, :utc_datetime)

      timestamps()
    end

    def row do
      %Status{last_import_at: nil}
    end
  end

  use Ecto.Migration

  def change do
    create table(:status, primary_key: false) do
      add :id, :smallint, null: false, default: 0
      timestamps()
      add :last_import_at, :utc_datetime, null: true
    end

    create(
      constraint(
        :status,
        :status_id_check,
        check: "id = 0"
      )
    )

    create(index(:status, :id, unique: true))

    execute(&execute_up/0, &execute_down/0)
  end

  defp execute_up, do: Status.row() |> repo().insert!()
  defp(execute_down, do: :noop)
end
