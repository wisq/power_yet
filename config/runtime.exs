import Config
alias PowerYet.Secrets

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

if config_env() != :test do
  config :power_yet, google_maps_client_key: Secrets.fetch!("GOOGLE_MAPS_CLIENT_KEY")
end

if config_env() == :prod do
  config :power_yet, PowerYet.Repo,
    username: Secrets.fetch!("DB_USERNAME"),
    password: Secrets.fetch!("DB_PASSWORD"),
    database: Secrets.fetch!("DB_NAME"),
    # hostname is configured below
    pool_size: 10,
    types: PowerYet.PostgresTypes

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("WEB_HOST") || "ismypowerbackyet.com"
  port = String.to_integer(System.get_env("WEB_PORT") || "4000")

  config :power_yet, PowerYetWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end

case System.fetch_env("APP_MODE") do
  {:ok, mode} ->
    # Running inside Docker
    config :power_yet, PowerYetWeb.Endpoint, server: mode == "web"
    config :power_yet, PowerYet.Application, start_importer: mode == "web"
    config :power_yet, PowerYet.Repo, hostname: Secrets.fetch!("DB_HOST")

  :error ->
    if config_env() == :prod, do: raise("Must set APP_MODE in production environment")
end
