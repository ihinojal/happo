defmodule HappoWeb.UserController do
  use HappoWeb, :controller
  alias Happo.Registration

  plug :redirect_if_logged when action in [:new, :create, :verify]
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

  @doc """
  Verify the user email. This will allow the user to login in the
  website, as we know that the email is valid and belongs to that user.
  """
  def verify(conn,
    %{"id" => id, "email_verification_token" => token}) do
    user = Registration.get_user(id)
    case Registration.verify_secret_token(token, user, :email_verification) do
      {:ok, user} ->
        # TODO: Update field in user to make it verified
        conn
        |> put_flash(:notice, "Your email has been verified. You can now login")
        |> redirect(to: session_path(conn, :new))
      {:error, :expired} ->
        conn
        |> put_flash(:error, "The verification link has expired, request a new one")
        |> render("verify.html", email: user.email)
     {:error, _reason} ->
        conn
        |> put_flash(:error, "Verification code is not valid")
        |> render("verify.html")
    end
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
