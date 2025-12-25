# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :airflights,
  ecto_repos: [Airflights.Repo],
  generators: [timestamp_type: :utc_datetime],
  # Dependency injection: use resilient provider with fallback chain
  flight_provider: Airflights.Adapters.ResilientProvider

# Resilient provider configuration - order matters (primary -> fallback)
config :airflights, Airflights.Adapters.ResilientProvider,
  providers: [
    Airflights.Adapters.Amadeus.FlightProvider,
    Airflights.Adapters.SerpApi.FlightProvider
  ]

# Amadeus API configuration (override with env vars in runtime.exs)
config :airflights, :amadeus,
  api_key: nil,
  api_secret: nil,
  base_url: "https://test.api.amadeus.com"

# SerpApi (Google Flights) configuration (override with env vars in runtime.exs)
config :airflights, :serpapi, api_key: nil

# LiveVue configuration
config :live_vue,
  vite_host: "http://localhost:5173",
  ssr: false

# Configures the endpoint
config :airflights, AirflightsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: AirflightsWeb.ErrorHTML, json: AirflightsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Airflights.PubSub,
  live_view: [signing_salt: "ITCNdyuX"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  airflights: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  airflights: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
