defmodule HappoWeb.EmailsTest do
  # You don’t need any special functions to unit test emails.
  use ExUnit.Case

  test "registration email" do
    user = %Happo.Registration.User{name: "Ivan",
      email: "ivan@example.com"}

    email = HappoWeb.Email.registration(user)

    assert email.to == user.email
    assert email.subject =~ "Registration"
    assert email.html_body =~ "Welcome"
  end

end
