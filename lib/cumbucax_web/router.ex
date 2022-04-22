defmodule CumbucaxWeb.Router do
  use CumbucaxWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug CumbucaxWeb.Auth.Pipeline
  end

  pipeline :bodyguard do
    plug CumbucaxWeb.BodyGuard
  end

  scope "/api", CumbucaxWeb do
    pipe_through :api

    post "/register", CumbucaxController, :register
    post "/login", CumbucaxController, :login
  end

  scope "/api", CumbucaxWeb do
    pipe_through [:api, :auth, :bodyguard]

    post "/transactions", CumbucaxController, :transfer
    get "/transactions", CumbucaxController, :list
    patch "/transactions/refund", CumbucaxController, :refund
  end
end
