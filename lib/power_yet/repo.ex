defmodule PowerYet.Repo do
  use Ecto.Repo,
    otp_app: :power_yet,
    adapter: Ecto.Adapters.Postgres

  def create_schema(conn, expected_db) do
    sql = "CREATE SCHEMA IF NOT EXISTS public"

    PowerYet.Mutex.run(:create_schema, fn ->
      [[actual_db]] = Postgrex.query!(conn, "SELECT current_database()", []).rows

      if actual_db == expected_db do
        Postgrex.query!(conn, sql, [])
      end
    end)
  end
end
