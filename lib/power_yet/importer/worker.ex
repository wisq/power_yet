defmodule PowerYet.Importer.Worker do
  use GenServer

  # Update every 5 minutes:
  @timeout 5 * 60 * 1000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  @impl true
  def init(_) do
    {:ok, nil, @timeout}
  end

  @impl true
  def handle_info(:timeout, _state) do
    PowerYet.Importer.import()
    {:noreply, nil, @timeout}
  end
end
