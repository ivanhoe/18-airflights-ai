defmodule Airflights.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AirflightsWeb.Telemetry,
      Airflights.Repo,
      {DNSCluster, query: Application.get_env(:airflights, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Airflights.PubSub},
      # Price Watcher processes
      Airflights.Watchers.Supervisor,
      # Start to serve requests, typically the last entry
      AirflightsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Airflights.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AirflightsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
