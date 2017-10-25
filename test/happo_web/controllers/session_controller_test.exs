defmodule HappoWeb.SesssionControllerTest do
  use HappoWeb.ConnCase,
    # Using sincronous because we are using mock
    async: false

  import Mock

  describe "new" do
    test "returns susccesful", %{conn: conn} do
      conn = get conn, session_path(conn, :new)
      assert html_response(conn, 200)
    end
  end

  describe "create" do
    test "if credentials are correct redirect with msg", %{conn: conn} do
      with_mock Happo.Registration, [verify_credentials:
        fn(_email, _pass) ->
          {:ok, %Happo.Registration.User{id: 123, first_name: "Ivan"}}
      end] do
        conn = post conn, session_path(conn, :create),
          session: %{"email" => "i@exa.com", "password" => "pass"}
        assert get_session(conn, :user_id) == 123
        assert get_flash(conn, :notice)
        assert html_response(conn, 302)
      end
    end
    test "if credentials are wrong render error with msg", %{conn: conn} do
      with_mock Happo.Registration, [verify_credentials:
        fn(_email, _pass) -> {:error, "error msg"}
      end] do
        conn = post conn, session_path(conn, :create),
          session: %{"email" => "i@exa.com", "password" => "pass"}
        assert get_flash(conn, :error)
        assert html_response(conn, 200)
      end

    end
  end

end
