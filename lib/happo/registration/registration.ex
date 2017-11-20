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
  Same that get_user_by, but raises error if no element is found
  """
  def get_user_by!(params), do: Repo.get_by!(User, params)

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

  @doc """
  Get a signed token. This signed token is a jiberish letters and
  numbers (in base64) matching the following scheme:

      "<hashing_method>.<payload>.<signature>"

  It's tipically used to send it to the user using a secure channel
  (email) so he can later give it back via unsecure channel (website) so
  we can verify the identity of an user (assuming the secure channel is
  not compromised).

  The parameter `reason` will namespace the token, to have several
  tokens of different things. It can be any string or atom. Tipically
  the reason is what is the secret for. For example:

   - For email verification
   - Recover a lost password
   - Unsubscribe from a mailing list.

  Options are the same that function `Phoenix.Token.sign/4`.

      iex> get_secret_token(%User{id: 123}, :email_vrf)
      "SFMyNTY.g3QAAAZE0WnYoL34V18B.gc8ojDvFvUtzTqMiNHv8"
  """
  def get_secret_token(%{id: id}, reason, opts \\ []) do
    Phoenix.Token.sign(
      HappoWeb.Endpoint, # Use secret key from endpoint
      to_string(reason), # used to namespace this token
      id, # Use something diferent for each user/entity
      opts
    )
  end

  @doc """
  Verify if a token coming from an user is valid or not. Posible causes
  if is not valid: timeout, content tampered, code for another user.

      iex> token = "SFMyNTY.g3QAAAZE0WnYoL34V18B.gc8ojDvFvUtzTqMiNHv8"
      iex> user = %User{id: 123}
      iex> verify_secret_token(token, user, :email_vrf)
      {:ok, %User{id: 123}}
      iex> verify_secret_token("invalid_token", user, :email_vrf)
      {:error, :invalid}
      iex> verify_secret_token(token, user, :another_reason)
      {:error, :invalid}

  It allows any option from `Phoenix.Token.verify/3`. `max_age` option
  allow to expire tokens some time (measured in seconds) after
  generation.

      iex> verify_secret_token(token, user, :email_vrf, max_age: 100)
      {:error, :expired}

  If user is binary, retrieve the user id if available.

      iex> verify_secret_token(token, "123", :email_vrf)
      {:ok, %User{id: 123}}
  """
  def verify_secret_token(token, %{id: id} = user, reason, opts \\ []) do
    options = Enum.into(opts, [max_age: 3600])
    case Phoenix.Token.verify(
      HappoWeb.Endpoint, # Use secret key from endpoint
      to_string(reason), # used an atom to namespace this token
      token, # The signed token to be verified
      options) # Any additional option
    do
      {:ok, ^id} -> {:ok, user}
      {:ok, _another_id} -> {:error, :belongs_to_other}
      result -> result
    end
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
