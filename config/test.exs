import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :power_yet, PowerYet.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "power_yet_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  types: PowerYet.PostgresTypes,
  after_connect: {PowerYet.Repo, :create_schema, ["power_yet_test"]}

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :power_yet, PowerYetWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Iu+IGYeRiD0SVZqlryWiBa2uI7QixwIIOemo7HFm1VqyQwffUs/dMr60a8w/qYJb",
  server: false

config :power_yet, google_maps_client_key: "dummy"
