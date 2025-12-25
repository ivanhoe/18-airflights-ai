defmodule Airflights.Flights do
  @moduledoc """
  Application service for flight operations.

  This is the main entry point for the domain. It orchestrates
  flight search operations by delegating to the configured
  flight provider adapter.

  The provider is injected via configuration, following the
  Dependency Inversion Principle - this module depends on
  the FlightProvider abstraction, not concrete implementations.
  """

  alias Airflights.Flights.Offer

  @doc """
  Search for the cheapest flight between two airports.

  ## Parameters
    - `origin` - IATA airport code (e.g., "MEX")
    - `destination` - IATA airport code (e.g., "VIE")
    - `date` - Travel date

  ## Returns
    - `{:ok, Offer.t()}` - The cheapest flight offer
    - `{:error, reason}` - Error with reason

  ## Example

      iex> Airflights.Flights.search_cheapest("MEX", "VIE", ~D[2025-02-15])
      {:ok, %Airflights.Flights.Offer{price: 850.50, ...}}
  """
  @spec search_cheapest(String.t(), String.t(), Date.t()) ::
          {:ok, Offer.t()} | {:error, term()}
  def search_cheapest(origin, destination, date) do
    provider().get_cheapest(origin, destination, date)
  end

  @doc """
  Search for all flight offers between two airports.

  ## Parameters
    - `origin` - IATA airport code (e.g., "MEX")
    - `destination` - IATA airport code (e.g., "VIE")
    - `date` - Travel date
    - `opts` - Optional parameters:
      - `:adults` - Number of adult passengers (default: 1)

  ## Returns
    - `{:ok, [Offer.t()]}` - List of flight offers
    - `{:error, reason}` - Error with reason
  """
  @spec search_all(String.t(), String.t(), Date.t(), keyword()) ::
          {:ok, [Offer.t()]} | {:error, term()}
  def search_all(origin, destination, date, opts \\ []) do
    provider().search_offers(origin, destination, date, opts)
  end

  # Inject provider via configuration (Dependency Injection)
  defp provider do
    Application.get_env(:airflights, :flight_provider, Airflights.Adapters.SerpApi.FlightProvider)
  end
end
