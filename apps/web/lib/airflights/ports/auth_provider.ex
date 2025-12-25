defmodule Airflights.Ports.AuthProvider do
  @moduledoc """
  Port (behaviour) defining the contract for authentication providers.

  This abstracts the authentication mechanism, allowing different
  implementations (OAuth2, API keys, etc.) to be swapped without
  changing the core application logic.
  """

  @doc """
  Get a valid access token for API authentication.

  Implementations should handle token caching and return a cached
  token if still valid, or fetch a new one if expired.

  ## Returns
    - `{:ok, token}` - Valid access token string
    - `{:error, reason}` - Error with reason
  """
  @callback get_access_token() :: {:ok, String.t()} | {:error, term()}

  @doc """
  Force refresh the access token.

  Use this when a request fails due to an expired token
  and you need to get a fresh one.

  ## Returns
    - `{:ok, token}` - New access token string
    - `{:error, reason}` - Error with reason
  """
  @callback refresh_token() :: {:ok, String.t()} | {:error, term()}
end
