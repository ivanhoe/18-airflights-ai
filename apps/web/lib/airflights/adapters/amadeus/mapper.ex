defmodule Airflights.Adapters.Amadeus.Mapper do
  @moduledoc """
  Maps Amadeus API responses to domain entities.

  This module follows the DRY principle - all transformation logic
  is centralized here, avoiding duplication across the codebase.

  It also follows Single Responsibility - this module only handles
  data transformation, nothing else.
  """

  alias Airflights.Flights.Offer

  @doc """
  Transform a list of Amadeus flight offers to domain Offer structs.
  """
  def to_offers(%{"data" => offers}) when is_list(offers) do
    Enum.map(offers, &to_offer/1)
  end

  def to_offers(_), do: []

  @doc """
  Transform a single Amadeus flight offer to a domain Offer struct.
  """
  def to_offer(offer) when is_map(offer) do
    price = get_price(offer)
    currency = get_currency(offer)
    itinerary = get_first_itinerary(offer)
    segments = get_segments(itinerary)

    Offer.new(%{
      price: price,
      currency: currency,
      departure_at: get_departure_time(segments),
      arrival_at: get_arrival_time(segments),
      duration: get_in(itinerary, ["duration"]),
      stops: max(length(segments) - 1, 0),
      airline_code: get_airline_code(segments),
      airline: get_airline_code(segments),
      segments: segments
    })
  end

  # --- Private Helpers ---

  defp get_price(offer) do
    case get_in(offer, ["price", "total"]) do
      nil -> 0.0
      price when is_binary(price) -> String.to_float(price)
      price when is_number(price) -> price
    end
  end

  defp get_currency(offer) do
    get_in(offer, ["price", "currency"]) || "USD"
  end

  defp get_first_itinerary(offer) do
    case get_in(offer, ["itineraries"]) do
      [first | _] -> first
      _ -> %{}
    end
  end

  defp get_segments(itinerary) do
    get_in(itinerary, ["segments"]) || []
  end

  defp get_departure_time(segments) do
    case segments do
      [first | _] ->
        parse_datetime(get_in(first, ["departure", "at"]))

      _ ->
        nil
    end
  end

  defp get_arrival_time(segments) do
    case List.last(segments) do
      nil -> nil
      last -> parse_datetime(get_in(last, ["arrival", "at"]))
    end
  end

  defp get_airline_code(segments) do
    case segments do
      [first | _] -> get_in(first, ["carrierCode"])
      _ -> nil
    end
  end

  defp parse_datetime(nil), do: nil

  defp parse_datetime(datetime_string) do
    case DateTime.from_iso8601(datetime_string) do
      {:ok, datetime, _offset} -> datetime
      _ -> parse_naive_datetime(datetime_string)
    end
  end

  defp parse_naive_datetime(datetime_string) do
    case NaiveDateTime.from_iso8601(datetime_string) do
      {:ok, naive} -> DateTime.from_naive!(naive, "Etc/UTC")
      _ -> nil
    end
  end
end
