defmodule PowerYetWeb.PageControllerTest do
  use PowerYetWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "<h1>Is My Power Back Yet?</h1>"
  end
end
