defmodule HappoWeb.PageController do
  use HappoWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
