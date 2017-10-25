defmodule HappoWeb.UserController do
  use HappoWeb, :controller
  alias Happo.Registration

  plug :redirect_if_logged when action in [:new, :create]
  plug HappoWeb.OnlyLoggedUser when action in [:delete]

  @doc """
  Create a new account
  """
  def new(conn, _params) do
    changeset = Registration.change_user()
    render conn, "new.html", changeset: changeset
  end

  @doc """
  Try to create a new account using provided data.
  """
  def create(conn, %{"user" => params}) do
    case Registration.create_user(params) do
      {:ok, user} ->
        # Send registration email with verification code.
        HappoWeb.Email.registration(user) |> Happo.Mailer.deliver_later()
        # Show message and redirect to login page.
        conn
        |> put_flash(:notice, "Please check your mail to log in")
        |> redirect(to: page_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Please review the errors")
        |> render("new.html", changeset: changeset)
    end
  end

  @doc """
  Delete user account and remove all its appointments
  """
  def delete(conn, _params) do
    Registration.delete_user!(conn.assigns.current_user)

    conn
    |> redirect(to: page_path(conn, :index))
    |> put_flash(:notice, "Hope to see you again soon!")
    # Clears the entire session. This function removes every key from
    # the session, clearing the session.
    |> clear_session()
  end

  # private ────────────────────────────────────────────────────────────
  defp redirect_if_logged(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> put_flash(:error, "You already have been logged")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    else
      conn
    end
  end
end
