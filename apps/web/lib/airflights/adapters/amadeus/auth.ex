defmodule Airflights.Adapters.Amadeus.Auth do
  @moduledoc """
  GenServer that manages Amadeus OAuth2 tokens.

  Implements the `AuthProvider` behaviour. Caches tokens and
  automatically refreshes them before expiry.

  This follows the Open/Closed Principle - the token management
  logic is encapsulated here and can be extended without modification.
  """

  use GenServer
  @behaviour Airflights.Ports.AuthProvider

  alias Airflights.Adapters.Amadeus.Client

  # Refresh token 60 seconds before expiry
  @refresh_buffer_seconds 60

  # --- Client API ---

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl Airflights.Ports.AuthProvider
  def get_access_token do
    GenServer.call(__MODULE__, :get_token)
  end

  @impl Airflights.Ports.AuthProvider
  def refresh_token do
    GenServer.call(__MODULE__, :refresh_token)
  end

  # --- Server Callbacks ---

  @impl GenServer
  def init(_opts) do
    state = %{
      token: nil,
      expires_at: nil
    }

    {:ok, state}
  end

  @impl GenServer
  def handle_call(:get_token, _from, state) do
    case get_valid_token(state) do
      {:ok, token, new_state} ->
        {:reply, {:ok, token}, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl GenServer
  def handle_call(:refresh_token, _from, state) do
    case fetch_new_token() do
      {:ok, token, expires_at} ->
        new_state = %{state | token: token, expires_at: expires_at}
        {:reply, {:ok, token}, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  # --- Private Functions ---

  defp get_valid_token(%{token: token, expires_at: expires_at} = state) do
    now = System.system_time(:second)

    if token && expires_at && now < expires_at - @refresh_buffer_seconds do
      {:ok, token, state}
    else
      case fetch_new_token() do
        {:ok, new_token, new_expires_at} ->
          new_state = %{state | token: new_token, expires_at: new_expires_at}
          {:ok, new_token, new_state}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp fetch_new_token do
    case Client.authenticate() do
      {:ok, token, expires_in} ->
        expires_at = System.system_time(:second) + expires_in
        {:ok, token, expires_at}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
