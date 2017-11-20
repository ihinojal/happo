defmodule HappoWeb.UserControllerTest do
  use HappoWeb.ConnCase
  use Bamboo.Test
  import Mock

  describe ":new, show register page /users/new" do
    test "returns succesful", %{conn: conn} do
      conn = get conn, user_path(conn, :new)
      assert html_response(conn, 200)
    end

    @tag :logged_user
    test "redirects if user alreday logged", %{conn: conn} do
      conn = get conn, user_path(conn, :new)
      assert get_flash(conn, :error)
      assert html_response(conn, 302)
      assert conn.halted
    end
  end

  describe ":create, process register page POST /users/" do
    @valid_registration_params %{
      "email" =>                 "user@example.com",
      "terms_of_service" =>      "true",
      "first_name" =>            "Ivan",
      "last_name" =>             "H.",
      "password" =>              "mysecretpassword",
      "password_confirmation" => "mysecretpassword",
    }
    test "if succesful redirects with message", %{conn: conn} do
      with_mock Happo.Registration, [
        create_user: fn(_params) ->
          {:ok, %Happo.Registration.User{id: 123, first_name: "Ivan",
            email: "user@example.com"}}
        end,
        get_secret_token: fn(_usr, :email_verification) ->
          "mysecrettoken"
        end
      ] do
        conn = post conn, user_path(conn, :create), user: %{}
        assert get_flash(conn, :notice)
        assert html_response(conn, 302)
        assert_delivered_email HappoWeb.Email.registration(
          %{id: 123, first_name: "Ivan", email: "user@example.com"})
      end
    end

    test "if unsuccesful render with message", %{conn: conn} do
      conn = post conn, user_path(conn, :create),
        user: %{ "email" => "noemail" }
      assert get_flash(conn, :error)
      assert html_response(conn, 200)
    end

    @tag :logged_user
    test "if user logged redirect with error", %{conn: conn} do
      conn = post conn, user_path(conn, :create),
        user: @valid_registration_params
      assert get_flash(conn, :error)
      assert html_response(conn, 302)
      assert conn.halted
    end
  end

  describe ":delete" do
    test "if user is not logged redirect with error", %{conn: conn} do
      conn = delete conn, user_path(conn, :delete)
      assert html_response(conn, 302)
      assert get_flash(conn, :error)
    end
    @tag :logged_user
    test "if logged remove current_user, redirect and show msg", %{conn: conn} do
      conn = delete conn, user_path(conn, :delete)
      assert html_response(conn, 302)
      assert get_flash(conn, :notice)
    end
  end

  describe ":verify" do
    @tag :logged_user
    test "if logged redirect with error", %{conn: conn} do
      conn = get conn, user_path(conn, :verify, "123", "SECRETTOKEN")
      assert html_response(conn, 302)
      assert get_flash(conn, :error)
    end

  end

end
