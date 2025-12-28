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

    # Flights
    post("/flights/cheapest", FlightController, :cheapest)
    post("/flights/search", FlightController, :search)
    get("/flights/defaults", FlightController, :defaults)

    # Price Watchers
    resources("/watchers", WatcherController, only: [:create, :index, :delete])
    post("/watchers/:id/pause", WatcherController, :pause)
    post("/watchers/:id/resume", WatcherController, :resume)
    get("/watchers/:id/history", WatcherController, :history)

    # Alerts
    get("/alerts", WatcherController, :alerts)
    post("/alerts/:id/read", WatcherController, :mark_read)
    post("/alerts/mark-all-read", WatcherController, :mark_all_read)
  end
end
