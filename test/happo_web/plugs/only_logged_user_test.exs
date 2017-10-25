defmodule HappoWeb.OnlyLoggedUserTest do
  use HappoWeb.ConnCase
  alias HappoWeb.OnlyLoggedUser

  setup [:prepare_session_and_flash]

  describe "When user is not logged" do
    test "redirect with error and halt", %{conn: conn} do
      conn = OnlyLoggedUser.call(conn, [])
      assert html_response(conn, 302)
      assert get_flash(conn, :error)
      assert conn.halted
    end
  end

  describe "When user is logged" do
    @tag :logged_user
    test "return connection as normal", %{conn: conn} do
      assert conn == OnlyLoggedUser.call(conn, [])
    end
  end

  #─────────────────────────────────────────────────────────────────────
  defp prepare_session_and_flash(%{conn: conn}=ctx) do
    conn = conn
    # The `bypass_through` helper that ConnCase provides allows you to
    # send a connection through the endpoint, router, and desired
    # pipelines but bypass the route dispatch. This approach gives you a
    # connection wired up with all the transformations your specific
    # tests require, such as fetching the session and adding flash
    # messages.
    |> bypass_through(HappoWeb.Router, [:browser])
    |> get("/")

    {:ok, Map.put(ctx, :conn, conn)}
  end

end
