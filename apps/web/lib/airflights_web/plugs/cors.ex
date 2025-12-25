defmodule AirflightsWeb.CORS do
  @moduledoc """
  CORS plug to allow cross-origin requests from the Tauri/Vue mobile app.

  In development, allows requests from localhost:1420 (Vite dev server).
  In production, this should be configured more restrictively.
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_header("access-control-allow-origin", allowed_origin(conn))
    |> put_resp_header("access-control-allow-methods", "GET, POST, PUT, DELETE, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "content-type, authorization")
    |> put_resp_header("access-control-max-age", "3600")
    |> handle_preflight()
  end

  defp allowed_origin(_conn) do
    # In production, this should be more restrictive
    # For now, allow the Tauri/Vue dev server
    "*"
  end

  defp handle_preflight(%{method: "OPTIONS"} = conn) do
    conn
    |> send_resp(204, "")
    |> halt()
  end

  defp handle_preflight(conn), do: conn
end
