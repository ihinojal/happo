defmodule HappoWeb.SessionController do
  use HappoWeb, :controller
  alias Happo.Registration

  # Login screen
  def new(conn, _params) do
    render conn, "new.html"
  end

  # process login
  def create(conn, %{"session" =>
    %{"email"=> email, "password" => password}}) do
    case Registration.verify_credentials(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        # Renew session to avoid fixation attack:
        #  https://en.wikipedia.org/wiki/Session_fixation
        |> configure_session(renew: true)
        |> put_flash(:notice, "Welcome #{user.first_name || "user"}")
        |> redirect(to: page_path(conn, :index))
      {:error, _error} ->
        conn
        |> put_flash(:error, "Either email or password are incorrect.")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: page_path(conn, :index))
  end
end
