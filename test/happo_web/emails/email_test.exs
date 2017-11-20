defmodule HappoWeb.EmailTest do
  use ExUnit.Case, async: false # Asyncronouse b/c mocks
  import Mock

  alias Happo.Registration.User

  @secret_token "SECRET.EXAMPLE.TOKEN.ABCD123456789"

  # To make easier the tests when secret token is called return just
  # `SECRETTOKEN`
  setup_with_mocks([{Happo.Registration, [], [get_secret_token:
    fn(_user, :email_verification)-> @secret_token end ]} ]) do
    :ok
  end

  describe "registration" do
    test "When sending email secret token is present" do
      user = %User{id: 123, email: "ivan@example.com"}
      email = HappoWeb.Email.registration(user)
      assert email.html_body =~ @secret_token
    end
  end
end
