defmodule HappoWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import HappoWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint HappoWeb.Endpoint

      # Factories with build a create elements
      alias HappoWeb.Factory
    end
  end


  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Happo.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Happo.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn()

    #───────────────────────────────────────────────────────────────────
    # @tag [:logged_user]
    #
    # Creates an user and assign to connection to make it as logged
    #───────────────────────────────────────────────────────────────────
    user = cond do
      tags[:logged_user] -> HappoWeb.Factory.create!(:user)
      true -> nil
    end
    # Set variable @current_user to the logged user or nil
    conn = Plug.Conn.assign(conn, :current_user, user)

    {:ok, conn: conn, user: user}
  end

end
