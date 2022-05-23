defmodule PowerYet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        # Start the Ecto repository
        PowerYet.Repo,
        # Start the Telemetry supervisor
        PowerYetWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: PowerYet.PubSub},
        # Start the Endpoint (http/https)
        PowerYetWeb.Endpoint
        # Start a worker by calling: PowerYet.Worker.start_link(arg)
        # {PowerYet.Worker, arg}
      ] ++ importer_children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PowerYet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PowerYetWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp config(name) do
    Application.fetch_env!(:power_yet, __MODULE__)
    |> Keyword.fetch!(name)
  end

  defp start?(name) do
    case config(:"start_#{name}") do
      :if_not_iex -> !iex_running?()
      value when is_boolean(value) -> value
    end
  end

  def importer_children() do
    if start?(:importer), do: [PowerYet.Importer.Worker], else: []
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) && IEx.started?()
  end
end
