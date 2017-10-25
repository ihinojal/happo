defmodule HappoWeb.Router do
  use HappoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # If session variable `user_id` is present load current user in
    # variable @current_user
    plug HappoWeb.LoadUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HappoWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    # Register user
    resources "/users", UserController,
      only: [:new, :create, :delete], singleton: true
    resources "/session", SessionController,
      only: [:new, :create, :delete], singleton: true
  end

  # Other scopes may use custom stacks.
  # scope "/api", HappoWeb do
  #   pipe_through :api
  # end
end
