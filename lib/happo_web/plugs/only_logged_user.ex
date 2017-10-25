defmodule HappoWeb.OnlyLoggedUser do
  @moduledoc """
  Plug that only allows to continue the connection as longs as the user
  has been logged in. Otherwise the non logged user will be redirected
  to the login page.
  """

  import Plug.Conn
  alias Phoenix.Controller
  alias HappoWeb.Router.Helpers

  def init(opts \\ []), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_user] do
      %Happo.Registration.User{} ->
        conn
      _ ->
        conn
        |> Controller.put_flash(:error,
            "You need to be logged to view this page.")
        |> Controller.redirect(to: Helpers.session_path(conn, :new))
        |> halt()
    end
  end

end
