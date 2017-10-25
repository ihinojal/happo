defmodule HappoWeb.Email do
  @moduledoc """

    # To send email inmediately
    iex> Email.sign_up_email |> Mailer.deliver_now

    # You can also deliver emails ASAP in the background with
    # `Mailer.deliver_later`
    iex> Email.sign_up_email |> Mailer.deliver_later
  """
  # More info at: https://hexdocs.pm/bamboo/Bamboo.Phoenix.html
  use Bamboo.Phoenix, view: HappoWeb.EmailView

  def registration(user) do
    base_email()
    |> to(user.email)
    |> subject("Registration email!")
    # Make @user available in templates
    |> assign(:user, user)
    # Renders and combine both html and text version
    |> render(:registration)
  end

  #─────────────────────────────────────────────────────────────────────
  defp base_email do
    new_email()
    |> from("Rob Ot<robot@example.com>")
    |> put_header("Reply-To", "ivan@example.com")
    # This will use the `email.html.eex` file as a layout when rendering
    # html emails.  Plain text emails will not use a layout unless you
    # use `put_text_layout` or `put_layout`
    |> put_html_layout({HappoWeb.LayoutView, "email.html"})
  end

end
