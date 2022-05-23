import Config

# Configure your database
config :power_yet, PowerYet.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "power_yet_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  types: PowerYet.PostgresTypes,
  after_connect: {PowerYet.Repo, :create_schema, ["power_yet_dev"]}

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :power_yet, PowerYetWeb.Endpoint,
  http: [port: 4000],
  check_origin: false,
  debug_errors: true,
  secret_key_base: "9gsYZGObSlfwOUm8Kczn9XxowxsOfxVrJwSx0w5pl6Laa9Yc07ezgAM9Thi/RE3t"

if System.get_env("ENDPOINT_MODE") != "docker" do
  # Enable live reloader:
  config :power_yet, PowerYetWeb.Endpoint,
    code_reloader: true,
    watchers: [
      # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
      esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]}
    ],
    live_reload: [
      patterns: [
        ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
        ~r"lib/power_yet_web/(live|views)/.*(ex)$",
        ~r"lib/power_yet_web/templates/.*(eex)$"
      ]
    ]
end
