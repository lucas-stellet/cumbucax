defmodule CumbucaxWeb.Router do
  use CumbucaxWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CumbucaxWeb do
    pipe_through :api
  end
end
