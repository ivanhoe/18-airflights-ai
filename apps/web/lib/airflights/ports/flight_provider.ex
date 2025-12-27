defmodule Airflights.Ports.FlightProvider do
  @moduledoc """
  Port (behaviour) defining the contract for flight search providers.

  This follows the Dependency Inversion Principle - the core application
  depends on this abstraction, not on concrete implementations like SerpApi.

  Any adapter (SerpApi, Skyscanner, Kiwi, etc.) must implement this behaviour.
  """

  alias Airflights.Flights.Offer

  @doc """
  Search for flight offers between two airports on a given date.

  ## Parameters
    - `origin` - IATA airport code (e.g., "MEX")
    - `destination` - IATA airport code (e.g., "VIE")
    - `date` - Travel date
    - `opts` - Optional parameters (adults, children, cabin class, etc.)

  ## Returns
    - `{:ok, [Offer.t()]}` - List of flight offers
    - `{:error, term()}` - Error with reason
  """
  @callback search_offers(
              origin :: String.t(),
              destination :: String.t(),
              date :: Date.t(),
              opts :: keyword()
            ) :: {:ok, [Offer.t()]} | {:error, term()}

  @doc """
  Get the cheapest flight offer for a given route and date.

  ## Parameters
    - `origin` - IATA airport code (e.g., "MEX")
    - `destination` - IATA airport code (e.g., "VIE")
    - `date` - Travel date

  ## Returns
    - `{:ok, Offer.t()}` - The cheapest flight offer
    - `{:error, :no_offers}` - No flights found
    - `{:error, term()}` - Other error with reason
  """
  @callback get_cheapest(
              origin :: String.t(),
              destination :: String.t(),
              date :: Date.t()
            ) :: {:ok, Offer.t()} | {:error, term()}
end
