defmodule PowerYetWeb.PageView do
  use PowerYetWeb, :view

  def google_maps_client_key do
    Application.get_env(:power_yet, :google_maps_client_key)
  end
end
