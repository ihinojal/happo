defmodule Happo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, comment: "Users of the website, including clients and doctors") do
      add :email, :string, null: false,
        comment: "Email of this user to send notifications and to find the user login"
      add :first_name, :string,
        comment: "name of the user Ex: 'Ivan'"
      add :last_name, :string,
        comment: "last name of the user."
      add :password_hash, :string,
        comment: "A hash of the provided plain password by the user"<>
        " when he registered his account."<>
        " If nil the user can be never login"
      add :profile_type, :string,
        comment: "The type of account of this user. Ex: 'doctor'."<>
        "If nil then is considered a normal user"

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
