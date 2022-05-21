defmodule PowerYet.Repo do
  use Ecto.Repo,
    otp_app: :power_yet,
    adapter: Ecto.Adapters.Postgres
end
