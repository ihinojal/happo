defmodule HappoWeb.LoadUserTest do
  use HappoWeb.ConnCase
  alias HappoWeb.LoadUser

  setup [:prepare_session_and_flash]

  describe "If the `user_id` session variable is NOT present" do
    test "sets current user to nil", %{conn: conn} do
      conn = LoadUser.call(conn, [])
      assert conn.assigns.current_user == nil
    end
  end

  describe "If the `user_id` session variable is present" do
    setup [:set_user_id]
    test "make the `current_user` variable present", %{conn: conn, user: user} do
      conn = LoadUser.call(conn, [])
      assert conn.assigns.current_user.id == user.id 
    end
  end

  #─────────────────────────────────────────────────────────────────────
  # Put the user_id with the id of a just create user
  defp set_user_id(%{conn: conn}=ctx) do
    user = HappoWeb.Factory.create!(:user)
    ctx = ctx
    |> Map.put(:conn, put_session(conn, :user_id, user.id)) 
    |> Map.put(:user, user)

    {:ok, ctx}
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
