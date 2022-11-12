defmodule PowerYetWeb.LayoutView do
  use PowerYetWeb, :view
  alias Timex.Format.DateTime.Formatters.Relative

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def last_import_at do
    PowerYet.Status.get().last_import_at
    |> format_timestamp()
  end

  defp format_timestamp(nil), do: nil

  defp format_timestamp(%DateTime{} = time) do
    delta = Timex.diff(DateTime.utc_now(), time, :hour)
    abs_format = "at {h24}:{m}"
    abs_format = if delta >= 12, do: "on {YYYY}-{0M}-{0D} #{abs_format}", else: abs_format
    abs = Timex.format!(time, abs_format)
    rel = Relative.format!(time, "{relative}")

    "#{rel}, #{abs}"
  end
end
