defmodule Airflights.Adapters.SerpApi.Mapper do
  @moduledoc """
  Maps SerpApi Google Flights responses to domain entities.

  Transforms the nested Google Flights structure (best_flights, other_flights)
  into our simple Offer struct.
  """

  alias Airflights.Flights.Offer

  @doc """
  Transform SerpApi search results to domain Offer structs.
  """
  def to_offers(response) when is_map(response) do
    best_flights = Map.get(response, "best_flights", [])
    other_flights = Map.get(response, "other_flights", [])

    (best_flights ++ other_flights)
    |> Enum.map(&to_offer/1)
    |> Enum.reject(&is_nil/1)
  end

  def to_offers(_), do: []

  # --- Private Functions ---

  defp to_offer(flight_group) when is_map(flight_group) do
    flights = Map.get(flight_group, "flights", [])

    case flights do
      [] ->
        nil

      _ ->
        first_flight = List.first(flights)
        last_flight = List.last(flights)

        Offer.new(%{
          price: extract_price(flight_group),
          currency: "MXN",
          departure_at: parse_departure(first_flight),
          arrival_at: parse_arrival(last_flight),
          duration: format_duration(Map.get(flight_group, "total_duration")),
          stops: max(length(flights) - 1, 0),
          airline_code: get_airline_code(first_flight),
          airline: Map.get(first_flight, "airline"),
          segments: flights
        })
    end
  end

  defp to_offer(_), do: nil

  defp extract_price(flight_group) do
    case Map.get(flight_group, "price") do
      nil -> 0.0
      price when is_number(price) -> price * 1.0
      price when is_binary(price) -> String.to_float(price)
    end
  end

  defp get_airline_code(flight) do
    # Extract airline code from flight_number (e.g., "LH 498" -> "LH")
    case Map.get(flight, "flight_number") do
      nil ->
        nil

      flight_number ->
        flight_number
        |> String.split(" ")
        |> List.first()
    end
  end

  defp parse_departure(nil), do: nil

  defp parse_departure(flight) do
    case get_in(flight, ["departure_airport", "time"]) do
      nil -> nil
      time_str -> parse_time_string(time_str)
    end
  end

  defp parse_arrival(nil), do: nil

  defp parse_arrival(flight) do
    case get_in(flight, ["arrival_airport", "time"]) do
      nil -> nil
      time_str -> parse_time_string(time_str)
    end
  end

  defp parse_time_string(time_str) when is_binary(time_str) do
    # SerpApi returns times like "2025-02-15 08:30"
    case NaiveDateTime.from_iso8601(String.replace(time_str, " ", "T") <> ":00") do
      {:ok, naive} -> DateTime.from_naive!(naive, "Etc/UTC")
      _ -> nil
    end
  end

  defp parse_time_string(_), do: nil

  defp format_duration(nil), do: nil

  defp format_duration(minutes) when is_integer(minutes) do
    hours = div(minutes, 60)
    mins = rem(minutes, 60)
    "PT#{hours}H#{mins}M"
  end

  defp format_duration(_), do: nil
end
