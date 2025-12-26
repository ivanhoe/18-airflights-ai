defmodule AirflightsWeb.Api.FlightController do
  @moduledoc """
  REST API controller for flight search.

  This endpoint is designed to be consumed by Tauri mobile app.
  Follows hexagonal architecture - this is a "driving adapter" for the API layer.
  """

  use AirflightsWeb, :controller

  alias Airflights.Flights

  @doc """
  Search for the cheapest flight between two airports.

  POST /api/flights/cheapest

  Body:
    - origin: IATA airport code (default: "MEX")
    - destination: IATA airport code (default: "VIE")
    - date: ISO8601 date string (e.g., "2025-02-15")
  """
  def cheapest(conn, params) do
    origin = Map.get(params, "origin", "MEX")
    destination = Map.get(params, "destination", "VIE")
    # Accept both "date" and "departure_date" for compatibility
    date_string = Map.get(params, "date") || Map.get(params, "departure_date")

    with {:ok, date} <- parse_date(date_string),
         {:ok, offer} <- Flights.search_cheapest(origin, destination, date) do
      conn
      |> put_status(:ok)
      |> json(%{
        success: true,
        data: offer_to_json(offer)
      })
    else
      {:error, :invalid_date} ->
        conn
        |> put_status(:bad_request)
        |> json(%{success: false, error: "Invalid date format. Use ISO8601 (YYYY-MM-DD)"})

      {:error, :no_offers} ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "No flights found for this route and date"})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{success: false, error: format_error(reason)})
    end
  end

  @doc """
  Search for all flight offers between two airports.

  POST /api/flights/search

  Body:
    - origin: IATA airport code (default: "MEX")
    - destination: IATA airport code (default: "VIE")
    - date: ISO8601 date string
    - adults: number of adult passengers (default: 1)
  """
  def search(conn, params) do
    origin = Map.get(params, "origin", "MEX")
    destination = Map.get(params, "destination", "VIE")
    # Accept both "date" and "departure_date" for compatibility
    date_string = Map.get(params, "date") || Map.get(params, "departure_date")
    adults = Map.get(params, "adults", 1)

    with {:ok, date} <- parse_date(date_string),
         {:ok, offers} <- Flights.search_all(origin, destination, date, adults: adults) do
      conn
      |> put_status(:ok)
      |> json(%{
        success: true,
        data: Enum.map(offers, &offer_to_json/1)
      })
    else
      {:error, :invalid_date} ->
        conn
        |> put_status(:bad_request)
        |> json(%{success: false, error: "Invalid date format. Use ISO8601 (YYYY-MM-DD)"})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{success: false, error: format_error(reason)})
    end
  end

  @doc """
  Get default suggested searches (Top 5 cheapest MEX -> VIE).

  GET /api/flights/defaults
  """
  def defaults(conn, params) do
    # Default: 30 days from now using "date" from params or calculated default
    date =
      case Map.get(params, "date") do
        nil -> Date.add(Date.utc_today(), 30)
        d -> Date.from_iso8601!(d)
      end

    origin = "MEX"
    destination = "VIE"

    case Flights.search_all(origin, destination, date) do
      {:ok, offers} ->
        top_5_cheapest =
          offers
          |> Enum.sort_by(& &1.price, :asc)
          |> Enum.take(5)
          |> Enum.map(&offer_to_json/1)

        conn
        |> put_status(:ok)
        |> json(%{
          success: true,
          data: top_5_cheapest
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{success: false, error: format_error(reason)})
    end
  end

  # --- Private Helpers ---

  defp parse_date(nil), do: {:error, :invalid_date}

  defp parse_date(date_string) when is_binary(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> {:ok, date}
      {:error, _} -> {:error, :invalid_date}
    end
  end

  defp offer_to_json(offer) do
    %{
      price: offer.price,
      currency: offer.currency,
      departure_at: offer.departure_at && DateTime.to_iso8601(offer.departure_at),
      arrival_at: offer.arrival_at && DateTime.to_iso8601(offer.arrival_at),
      duration: offer.duration,
      stops: offer.stops,
      airline: offer.airline,
      airline_code: offer.airline_code,
      segments: offer.segments || []
    }
  end

  defp format_error({:api_error, status, body}) do
    message = get_in(body, ["error_description"]) || "API error"
    "API error (#{status}): #{message}"
  end

  defp format_error({:auth_error, _status, body}) do
    message = get_in(body, ["error_description"]) || "Authentication failed"
    "Authentication error: #{message}"
  end

  defp format_error(reason) when is_binary(reason), do: reason
  defp format_error(reason), do: inspect(reason)
end
