defmodule Airflights.Adapters.Amadeus.Client do
  @moduledoc """
  Low-level HTTP client for Amadeus API.

  Handles raw HTTP communication using Req. This module is responsible
  only for making HTTP requests - it follows the Single Responsibility Principle.
  """

  @base_url "https://test.api.amadeus.com"

  @doc """
  Make an authenticated request to the Amadeus API.

  ## Parameters
    - `method` - HTTP method (:get, :post, etc.)
    - `path` - API path (e.g., "/v2/shopping/flight-offers")
    - `token` - Bearer access token
    - `opts` - Request options (params, body, etc.)
  """
  def request(method, path, token, opts \\ []) do
    base_url = get_config(:base_url, @base_url)
    url = base_url <> path

    req_opts =
      [
        method: method,
        url: url,
        headers: [
          {"authorization", "Bearer #{token}"},
          {"accept", "application/json"}
        ]
      ]
      |> Keyword.merge(opts)

    case Req.request(req_opts) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:api_error, status, body}}

      {:error, reason} ->
        {:error, {:http_error, reason}}
    end
  end

  @doc """
  Authenticate and get an access token using OAuth2 client credentials.
  """
  def authenticate do
    base_url = get_config(:base_url, @base_url)
    url = base_url <> "/v1/security/oauth2/token"

    api_key = get_config(:api_key) || raise "AMADEUS_API_KEY not configured"
    api_secret = get_config(:api_secret) || raise "AMADEUS_API_SECRET not configured"

    case Req.post(url,
           form: [
             grant_type: "client_credentials",
             client_id: api_key,
             client_secret: api_secret
           ],
           headers: [{"content-type", "application/x-www-form-urlencoded"}]
         ) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body["access_token"], body["expires_in"]}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:auth_error, status, body}}

      {:error, reason} ->
        {:error, {:http_error, reason}}
    end
  end

  defp get_config(key, default \\ nil) do
    Application.get_env(:airflights, :amadeus, [])
    |> Keyword.get(key, default)
  end
end
