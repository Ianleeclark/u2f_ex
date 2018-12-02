defmodule ExampleWeb.Router do
  use ExampleWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ExampleWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    resources("/users", UserController)
    post("/u2f/start_registration", U2FController, :start_registration)
    post("/u2f/finish_registration", U2FController, :finish_registration)
    post("/u2f/start_authentication", U2FController, :start_authentication)
    post("/u2f/finish_authentication", U2FController, :finish_authentication)
  end
end
