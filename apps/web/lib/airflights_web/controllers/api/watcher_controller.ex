defmodule AirflightsWeb.Api.WatcherController do
  @moduledoc """
  REST API controller for price watchers and alerts.

  Provides endpoints for the mobile app to:
  - Create/list/manage price watchers
  - Query alerts
  - Get price history
  """
  use AirflightsWeb, :controller

  alias Airflights.Watchers

  # ============================================================================
  # WATCHERS
  # ============================================================================

  @doc """
  POST /api/watchers
  Creates a new price watcher.
  """
  def create(conn, params) do
    attrs = %{
      user_identifier: params["user_identifier"],
      origin: params["origin"],
      destination: params["destination"],
      travel_date: parse_date(params["travel_date"]),
      target_price: params["target_price"],
      currency: params["currency"] || "MXN"
    }

    case Watchers.create_watcher(attrs) do
      {:ok, watcher} ->
        conn
        |> put_status(:created)
        |> json(%{
          success: true,
          data: serialize_watcher(watcher)
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          success: false,
          error: format_errors(changeset)
        })
    end
  end

  @doc """
  GET /api/watchers
  Lists watchers for a user.
  """
  def index(conn, %{"user_identifier" => user_id}) do
    watchers = Watchers.list_watchers(user_id)

    json(conn, %{
      success: true,
      data: Enum.map(watchers, &serialize_watcher/1)
    })
  end

  @doc """
  DELETE /api/watchers/:id
  Deletes a watcher.
  """
  def delete(conn, %{"id" => id}) do
    case Watchers.delete_watcher(id) do
      {:ok, _} ->
        json(conn, %{success: true})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "Watcher not found"})
    end
  end

  @doc """
  POST /api/watchers/:id/pause
  Pauses a watcher.
  """
  def pause(conn, %{"id" => id}) do
    case Watchers.pause_watcher(id) do
      {:ok, watcher} ->
        json(conn, %{success: true, data: serialize_watcher(watcher)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "Watcher not found"})
    end
  end

  @doc """
  POST /api/watchers/:id/resume
  Resumes a watcher.
  """
  def resume(conn, %{"id" => id}) do
    case Watchers.resume_watcher(id) do
      {:ok, watcher} ->
        json(conn, %{success: true, data: serialize_watcher(watcher)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "Watcher not found"})
    end
  end

  # ============================================================================
  # ALERTS
  # ============================================================================

  @doc """
  GET /api/alerts
  Gets alerts for a user.
  """
  def alerts(conn, %{"user_identifier" => user_id} = params) do
    alerts =
      if params["unread_only"] == "true" do
        Watchers.get_unread_alerts(user_id)
      else
        Watchers.list_alerts(user_id)
      end

    json(conn, %{
      success: true,
      data: Enum.map(alerts, &serialize_alert/1),
      unread_count: Enum.count(alerts, &(not &1.is_read))
    })
  end

  @doc """
  POST /api/alerts/:id/read
  Marks an alert as read.
  """
  def mark_read(conn, %{"id" => id}) do
    case Watchers.mark_alert_read(id) do
      {:ok, alert} ->
        json(conn, %{success: true, data: serialize_alert(alert)})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "Alert not found"})
    end
  end

  @doc """
  POST /api/alerts/mark-all-read
  Marks multiple alerts as read.
  """
  def mark_all_read(conn, %{"alert_ids" => ids}) do
    {count, _} = Watchers.mark_alerts_read(ids)
    json(conn, %{success: true, marked_count: count})
  end

  # ============================================================================
  # PRICE HISTORY
  # ============================================================================

  @doc """
  GET /api/watchers/:id/history
  Gets price history for a watcher.
  """
  def history(conn, %{"id" => watcher_id} = params) do
    limit = String.to_integer(params["limit"] || "50")
    history = Watchers.get_price_history(watcher_id, limit)

    json(conn, %{
      success: true,
      data: Enum.map(history, &serialize_history/1)
    })
  end

  # ============================================================================
  # PRIVATE HELPERS
  # ============================================================================

  defp parse_date(nil), do: nil

  defp parse_date(date_string) when is_binary(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> date
      _ -> nil
    end
  end

  defp serialize_watcher(watcher) do
    %{
      id: watcher.id,
      origin: watcher.origin,
      destination: watcher.destination,
      travel_date: Date.to_iso8601(watcher.travel_date),
      target_price: Decimal.to_float(watcher.target_price),
      currency: watcher.currency,
      is_active: watcher.is_active,
      last_checked_at: watcher.last_checked_at && DateTime.to_iso8601(watcher.last_checked_at),
      last_price: watcher.last_price && Decimal.to_float(watcher.last_price),
      created_at: DateTime.to_iso8601(watcher.inserted_at)
    }
  end

  defp serialize_alert(alert) do
    %{
      id: alert.id,
      watcher_id: alert.watcher_id,
      route: "#{alert.watcher.origin} → #{alert.watcher.destination}",
      old_price: Decimal.to_float(alert.old_price),
      new_price: Decimal.to_float(alert.new_price),
      is_read: alert.is_read,
      triggered_at: DateTime.to_iso8601(alert.triggered_at)
    }
  end

  defp serialize_history(entry) do
    %{
      id: entry.id,
      price: Decimal.to_float(entry.price),
      checked_at: DateTime.to_iso8601(entry.checked_at)
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {field, errors} -> "#{field}: #{Enum.join(errors, ", ")}" end)
    |> Enum.join("; ")
  end
end
