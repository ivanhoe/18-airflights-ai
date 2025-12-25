defmodule Airflights.Adapters.SerpApi.Client do
  @moduledoc """
  HTTP client for SerpApi Google Flights API.

  Simple GET request with query parameters. No session/polling required.
  Returns structured JSON with flight results.
  """

  @base_url "https://serpapi.com/search"

  @doc """
  Search for flights using Google Flights via SerpApi.

  Returns structured flight data from Google Flights.
  """
  def search_flights(origin, destination, date, opts \\ []) do
    with {:ok, api_key} <- get_api_key() do
      do_search(api_key, origin, destination, date, opts)
    end
  end

  defp do_search(api_key, origin, destination, date, _opts) do
    params = [
      engine: "google_flights",
      departure_id: origin,
      arrival_id: destination,
      outbound_date: Date.to_iso8601(date),
      currency: "USD",
      hl: "en",
      # One-way flight
      type: "2",
      api_key: api_key
    ]

    case Req.get(@base_url, params: params) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        error_message = get_in(body, ["error"]) || "API error"
        {:error, {:api_error, status, error_message}}

      {:error, reason} ->
        {:error, {:http_error, reason}}
    end
  end

  defp get_api_key do
    case get_config(:api_key) do
      nil -> {:error, :missing_api_key}
      "" -> {:error, :missing_api_key}
      key -> {:ok, key}
    end
  end

  defp get_config(key) do
    Application.get_env(:airflights, :serpapi, [])
    |> Keyword.get(key)
  end
end
