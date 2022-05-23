defmodule PowerYetWeb.PageController do
  use PowerYetWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
