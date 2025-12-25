defmodule AirflightsWeb.Router do
  use AirflightsWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {AirflightsWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", AirflightsWeb do
    pipe_through(:browser)

    live("/", FlightSearchLive)
  end

  # REST API for Tauri mobile app
  scope "/api", AirflightsWeb.Api do
    pipe_through(:api)

    post("/flights/cheapest", FlightController, :cheapest)
    post("/flights/search", FlightController, :search)
  end
end
