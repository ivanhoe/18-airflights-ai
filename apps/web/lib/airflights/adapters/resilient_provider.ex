defmodule Airflights.Adapters.ResilientProvider do
  @moduledoc """
  Resilient flight provider that chains multiple providers with fallback.

  If the primary provider fails, automatically tries the next one in the chain.
  This ensures high availability with graceful degradation.

  ## Configuration

  Providers are tried in order. Configure via:

      config :airflights, Airflights.Adapters.ResilientProvider,
        providers: [
          Airflights.Adapters.SerpApi.FlightProvider
        ]
  """

  @behaviour Airflights.Ports.FlightProvider

  require Logger

  @default_providers [
    Airflights.Adapters.SerpApi.FlightProvider
  ]

  @impl Airflights.Ports.FlightProvider
  def search_offers(origin, destination, date, opts \\ []) do
    try_providers(providers(), fn provider ->
      provider.search_offers(origin, destination, date, opts)
    end)
  end

  @impl Airflights.Ports.FlightProvider
  def get_cheapest(origin, destination, date) do
    try_providers(providers(), fn provider ->
      provider.get_cheapest(origin, destination, date)
    end)
  end

  # --- Private Functions ---

  defp try_providers([], _fun) do
    Logger.error("[ResilientProvider] All flight providers failed")
    {:error, :all_providers_failed}
  end

  defp try_providers([provider | rest], fun) do
    Logger.debug("[ResilientProvider] Trying provider: #{inspect(provider)}")

    try do
      case fun.(provider) do
        {:ok, result} ->
          Logger.debug("[ResilientProvider] Success with: #{inspect(provider)}")
          {:ok, result}

        {:error, reason} ->
          Logger.warning(
            "[ResilientProvider] Provider #{inspect(provider)} failed: #{inspect(reason)}. Trying next..."
          )

          try_providers(rest, fun)
      end
    rescue
      exception ->
        Logger.warning(
          "[ResilientProvider] Provider #{inspect(provider)} crashed: #{Exception.message(exception)}. Trying next..."
        )

        try_providers(rest, fun)
    catch
      :exit, reason ->
        Logger.warning(
          "[ResilientProvider] Provider #{inspect(provider)} exited: #{inspect(reason)}. Trying next..."
        )

        try_providers(rest, fun)
    end
  end

  defp providers do
    Application.get_env(:airflights, __MODULE__, [])
    |> Keyword.get(:providers, @default_providers)
  end
end
