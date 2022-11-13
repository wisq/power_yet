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
    time = time |> to_local()
    now = DateTime.utc_now() |> to_local()

    abs_f = "at {h24}:{m}"
    abs_f = if delta_hours(time, now) >= 12, do: "on {YYYY}-{0M}-{0D} #{abs_f}", else: abs_f
    abs_f = if same_tz(time, now), do: abs_f, else: "#{abs_f} {Zabbr}"

    abs = Timex.format!(time, abs_f)
    rel = Relative.format!(time, "{relative}")

    "#{rel}, #{abs}"
  end

  defp to_local(time), do: Timex.Timezone.convert(time, "America/Toronto")
  defp delta_hours(time, now), do: Timex.diff(now, time, :hour)
  defp same_tz(t1, t2), do: t1.zone_abbr == t2.zone_abbr
end
