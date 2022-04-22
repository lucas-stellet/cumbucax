# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :cumbucax,
  ecto_repos: [Cumbucax.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :cumbucax, CumbucaxWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: CumbucaxWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Cumbucax.PubSub,
  live_view: [signing_salt: "qK4k6/0y"]

config :cumbucax, CumbucaxWeb.Auth.Guardian,
  issuer: "cumbucax",
  ttl: {30, :minutes},
  secret_key:
    System.get_env(
      "GUARDIAN_SECRET",
      "UaE9J9jqkLcBcV46r+WihLKwNea5HLz+X2eo3ij4CYBuelnEQo3eXi1QEIp4PzC2"
    )

config :cumbucax, CumbucaxWeb.Auth.Pipeline,
  module: CumbucaxWeb.Auth.Guardian,
  error_handler: CumbucaxWeb.Auth.ErrorHandler

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Money default current configuration
config :money,
  default_currency: :BRL,
  separator: ".",
  delimiter: ","

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
