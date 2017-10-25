defmodule Happo.RegistrationTest do
  use Happo.DataCase

  import Happo.Registration
  alias Happo.Registration.User

  @valid_user_attrs %{ "email" => "ivan@example.com",
    "terms_of_service" => "true", "first_name" => "Ivan",
    "last_name" => "H.", "password" => "mysecret"}
  @invalid_user_attrs %{ "email" => "noemail.com",
    "terms_of_service" => "false", "first_name" => nil,
    "last_name" => nil, "password" => "short"}

  #doctest Happo.Registration, import: true

  describe "change_user()" do
    test "returns a changeset" do
      assert %Ecto.Changeset{valid?: true} =
        change_user(@valid_user_attrs)
      assert %Ecto.Changeset{valid?: false} =
        change_user(@invalid_user_attrs)
    end
  end

  describe "create_user()" do
    test "if valid creates an user" do
      assert {:ok, %User{}} = create_user(@valid_user_attrs)
    end
    test "if params not valid returns changeset" do
      assert {:error, %Ecto.Changeset{}} =
        create_user(@invalid_user_attrs)
    end
  end

  describe "get_user_by(params)" do
    test "if match, returns user" do
      {:ok, %{email: email} } = create_user(@valid_user_attrs)
      assert %User{email: ^email} = get_user_by(email: email)
    end
    test "if params don't match returns nil" do
      assert nil == get_user_by(%{email: "none@dom.com"})
    end
  end

  describe "verify credentials" do
    setup do
      {:ok, user} = create_user(@valid_user_attrs)
      # Returns {:ok, context}
      {:ok, %{user: user}}
    end
    test "if email and password match a user with that password", _ctx do
      assert {:ok, %User{}} =
        verify_credentials(@valid_user_attrs["email"],
                           @valid_user_attrs["password"])
    end
    test "if user with that email is not present", _ctx do
      assert {:error, "invalid user-identifier"} =
        verify_credentials("noexist@domain.com",
                           @valid_user_attrs["password"])
    end
    test "if user with that email is present, but incorrect password", _ctx do
      assert {:error, "invalid password"} =
        verify_credentials(@valid_user_attrs["email"],
                           "anincorrectpassword")
    end
  end

  describe "get_user(id)" do
    setup do
      {:ok, user} = create_user(@valid_user_attrs)
      {:ok, %{user: user}}
    end
    test "if user is present, returns user", %{user: user} do
      assert %User{} = get_user(user.id)
    end
    test "if user is not present, returns nil", %{user: _user} do
      assert nil == get_user(0)
    end
  end

end
