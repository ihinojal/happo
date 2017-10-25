defmodule Happo.Registration do
  @moduledoc """
  Registration context to create or drop users from the database.
  Verify user login or log out an user. Manage user data like changing
  the user name, etc. Recovering user lost password tru email.
  """
  alias Happo.Registration.User
  alias Happo.Repo

  @doc """
  Returns a user changeset to track changes.

  ## Examples

      iex> change_user(%{"email" => "ivan@example.com"})
      %Ecto.Changeset{}
  """
  def change_user(params \\ %{}) do
    User.changeset(%User{}, params)
  end

  @doc """
  Try to create a new valid user in database. If succesful it will send
  an confirmation email to verify it is correct.

  ## Example

      iex> create_user(%{"email" => "u@d.com", ... })
      {:ok, %Happo.Registration.User{}}

      iex> create_user(%{email: "invalid", ... })
      {:error, %Ecto.Changeset{}}
  """
  def create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
    |> send_registration_email()
  end

  @doc """
  Get one user by a map of parameters
      iex> {:ok, %{id: _id} } = create_user(%{email: "ivan@dom.com"})
      iex> get_user_by(email: "ivan@dom.com")
      %Happo.Registration.User{email: "ivan@dom.com"}

      iex> get_user_by(%{email: "none@dom.com"})
      nil
  """
  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  @doc """
  Use email and password to find out if there is an user with that email
  and that password.

  Then the function returns {:ok, user} or {:error, message}. Note that
  the error message is meant to be used for logging purposes only; it
  should not be passed on to the end user.

  ## Example
      iex> {:ok, %{email: email, password: pass} } =
      ...>   create_user("email" => "i@d.com", "password" => "secr")
      iex> verify_credentials(email, pass)
      {:ok, %User{}}

      iex> credentials = %{email: "no@d.com", password: "fake!"}
      iex> verify_credentials(credentials.email, credentials.password)
      {:error, "invalid user-identifier" }
  """
  def verify_credentials(email, password) do
    get_user_by(%{email: email})
    # In case user is nil, the dummy_password is executed to waste time
    # and no resources
    |> Comeonin.Bcrypt.check_pass(password)
  end

  @doc """
  Get an user by its id.

  ## Examples
      iex> {:ok, %{id: id} } = create_user(email: "i@example.com")
      iex> get_user(id)
      %Happo.Registration.User{email: "i@example.com"}

      iex> get_user(0)
      nil
  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Deletes the user from the database. Returs the struct of the user as
  it was before deletion.

  ## Examples

      iex> user = Happo.get!(User, 42)
      iex> Happo.delete_user(user)
      %User{id: 42, email: "ivan@example.com", ...}

      iex> Happo.delete_user(43)
      %User{id: 43, email: "luisito@example.com", ...}

  """
  def delete_user!(%User{} = user), do: Repo.delete!(user)
  def delete_user!(id) when is_integer(id) do
    get_user(id) |> Repo.delete!()
  end

  #────────────────────────────────────────────────────────────────────
  # PRIVATE FUNCTIONS
  #────────────────────────────────────────────────────────────────────
  defp send_registration_email({:ok, %User{} = _user}=response) do
    #Email.sign_in(user) |> Mailer.deliver_later
    response
  end
  defp send_registration_email(response), do: response
end
