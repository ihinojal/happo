defmodule HappoWeb.LoadUser do
  @moduledoc """
  This plug will load and assign the `user` to be always available during
  the connection if the `user_id` session variable is present.

  The user who is logged will be available in views as:

      @current_user

  or in controller as:

      conn.assigns[:current_user]
  """

  import Plug.Conn
  alias Happo.Registration

  # Init will be executed at compile time. Its output will be received
  # by the second argument of call.
  def init(opts \\ []), do: opts

  # This function will be called every time the plug is called with the
  # connection
  def call(conn, _opts) do
    cond do
      _user = conn.assigns[:current_user] ->
        conn
      true ->
        user_id = get_session(conn, :user_id)
        current_user = user_id && Registration.get_user(user_id)
        assign(conn, :current_user, current_user)
    end
  end

end
