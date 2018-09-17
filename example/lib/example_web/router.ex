defmodule ExampleWeb.Router do
  use ExampleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExampleWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    post "/u2f/register", U2fController, :register
    post "/u2f/sign", U2fController, :sign
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExampleWeb do
  #   pipe_through :api
  # end
end
