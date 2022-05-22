defmodule PowerYet.RepoPostGIS do
  Postgrex.Types.define(
    PowerYet.PostgresTypes,
    [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions()
  )
end
