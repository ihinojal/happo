defmodule Happo.Registration.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Happo.Registration.User


  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password_hash, :string
    # Temporal variable to calculate the hashed password from it
    field :password, :string, virtual: true
    field :terms_of_service, :boolean, virtual: true
    # nil value means normal
    field :profile_type, :string

    timestamps()
  end

  @doc false
  # Registration changeset
  def changeset(%User{} = user, attrs) do
    user
    # These parameters are whitelisted
    |> cast(attrs, [:email, :first_name, :last_name, :password])
    # These parameters are required
    |> validate_required([:email, :first_name, :password])
    # Validate that email has an email format
    |> validate_format(:email, ~r/@/)
    # Ensures the terms of service are accepted
    |> validate_acceptance(:terms_of_service)
    # Ensure password and password_confirmation are the same
    # "email_confirmation" does not need to be added as a virtual field
    |> validate_confirmation(:password)
    # If DB complains about duplicated email, show a nice formated error
    |> unique_constraint(:email)
    |> validate_length(:password, min: 8, max: 64)
    # If still valid, populate `password_hash` virtual field
    |> put_pass_hash()
  end

  #────────────────────────────────────────────────────────────────────
  # PRIVATE FUNCTIONS
  #────────────────────────────────────────────────────────────────────
  # Genereate the field `password_hash` using the plain text `password`
  # This is because we don't want to store plain text passwords in the
  # database. Hashes will be used to ensure that if DB is leaked the
  # attacker can't use it to gain passwords.
  defp put_pass_hash(%Ecto.Changeset{valid?: true,
    changes: %{password: password}} = changeset) do
    changeset
    # `add_hash` returns `password_hash: $01F_passwd_hashed_hRa3$`
    # Note: `add_hash` function sets password to nil
    |> change(Comeonin.Bcrypt.add_hash(password))
    # Uncomment if you prefer to have the password field intact. Won't
    # be stored in DB after all
    #|> put_change(:password, password)
  end
  defp put_pass_hash(changeset) do
    changeset
  end

end
