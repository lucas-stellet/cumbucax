defmodule Cumbucax.Repo do
  use Ecto.Repo,
    otp_app: :cumbucax,
    adapter: Ecto.Adapters.Postgres
end
