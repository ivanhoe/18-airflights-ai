defmodule Airflights.Adapters.Amadeus.FlightProvider do
  @moduledoc """
  Amadeus adapter implementing the FlightProvider behaviour.

  This adapter translates calls from the application core to
  Amadeus-specific API calls. It follows the Liskov Substitution
  Principle - it can be replaced by any other adapter implementing
  the FlightProvider behaviour.
  """

  @behaviour Airflights.Ports.FlightProvider

  alias Airflights.Adapters.Amadeus.{Auth, Client, Mapper}

  @impl Airflights.Ports.FlightProvider
  def search_offers(origin, destination, date, opts \\ []) do
    adults = Keyword.get(opts, :adults, 1)

    with {:ok, token} <- Auth.get_access_token(),
         {:ok, response} <- do_search(token, origin, destination, date, adults) do
      offers = Mapper.to_offers(response)
      {:ok, offers}
    end
  end

  @impl Airflights.Ports.FlightProvider
  def get_cheapest(origin, destination, date) do
    case search_offers(origin, destination, date, adults: 1) do
      {:ok, []} ->
        {:error, :no_offers}

      {:ok, offers} ->
        cheapest = Enum.min_by(offers, & &1.price)
        {:ok, cheapest}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # --- Private Functions ---

  defp do_search(token, origin, destination, date, adults) do
    params = [
      originLocationCode: origin,
      destinationLocationCode: destination,
      departureDate: Date.to_iso8601(date),
      adults: adults,
      nonStop: false,
      currencyCode: "USD",
      max: 50
    ]

    Client.request(:get, "/v2/shopping/flight-offers", token, params: params)
  end
end
