defmodule Airflights.Adapters.SerpApi.FlightProvider do
  @moduledoc """
  SerpApi adapter implementing the FlightProvider behaviour.

  Uses Google Flights via SerpApi to search for flight offers.
  This is a scraping-based approach that returns real Google Flights data.
  """

  @behaviour Airflights.Ports.FlightProvider

  alias Airflights.Adapters.SerpApi.{Client, Mapper}

  @impl Airflights.Ports.FlightProvider
  def search_offers(origin, destination, date, opts \\ []) do
    case Client.search_flights(origin, destination, date, opts) do
      {:ok, response} ->
        offers = Mapper.to_offers(response)
        {:ok, offers}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl Airflights.Ports.FlightProvider
  def get_cheapest(origin, destination, date) do
    case search_offers(origin, destination, date) do
      {:ok, []} ->
        {:error, :no_offers}

      {:ok, offers} ->
        cheapest = Enum.min_by(offers, & &1.price)
        {:ok, cheapest}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
