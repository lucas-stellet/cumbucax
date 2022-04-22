defmodule CumbucaxWeb.Auth.Pipeline do
  @moduledoc false

  use Guardian.Plug.Pipeline, otp_app: :cumbucax

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
