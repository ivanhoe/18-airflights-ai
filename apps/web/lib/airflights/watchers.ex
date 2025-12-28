defmodule Airflights.Watchers do
  @moduledoc """
  Context module for managing price watchers and alerts.

  This module provides the public API for creating, querying, and managing
  price watchers and their associated alerts.
  """
  import Ecto.Query, warn: false
  alias Airflights.Repo
  alias Airflights.Watchers.{PriceWatcher, PriceAlert, PriceHistory}
  alias Airflights.Watchers.WatcherMonitor

  # ============================================================================
  # PRICE WATCHERS
  # ============================================================================

  @doc """
  Creates a new price watcher and starts monitoring.
  """
  def create_watcher(attrs) do
    %PriceWatcher{}
    |> PriceWatcher.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, watcher} ->
        # Start the monitor GenServer for this watcher
        WatcherMonitor.start_monitoring(watcher)
        {:ok, watcher}

      error ->
        error
    end
  end

  @doc """
  Lists all watchers for a user.
  """
  def list_watchers(user_identifier) do
    PriceWatcher
    |> where([w], w.user_identifier == ^user_identifier)
    |> order_by([w], desc: w.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a watcher by ID.
  """
  def get_watcher(id), do: Repo.get(PriceWatcher, id)

  @doc """
  Updates a watcher.
  """
  def update_watcher(%PriceWatcher{} = watcher, attrs) do
    watcher
    |> PriceWatcher.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Pauses a watcher (stops monitoring).
  """
  def pause_watcher(id) do
    case get_watcher(id) do
      nil ->
        {:error, :not_found}

      watcher ->
        WatcherMonitor.stop_monitoring(id)
        update_watcher(watcher, %{is_active: false})
    end
  end

  @doc """
  Resumes a watcher (restarts monitoring).
  """
  def resume_watcher(id) do
    case get_watcher(id) do
      nil ->
        {:error, :not_found}

      watcher ->
        {:ok, updated} = update_watcher(watcher, %{is_active: true})
        WatcherMonitor.start_monitoring(updated)
        {:ok, updated}
    end
  end

  @doc """
  Deletes a watcher and all associated data.
  """
  def delete_watcher(id) do
    case get_watcher(id) do
      nil ->
        {:error, :not_found}

      watcher ->
        WatcherMonitor.stop_monitoring(id)
        Repo.delete(watcher)
    end
  end

  @doc """
  Lists all active watchers (for supervisor to restart on boot).
  """
  def list_active_watchers do
    PriceWatcher
    |> where([w], w.is_active == true)
    |> Repo.all()
  end

  # ============================================================================
  # PRICE ALERTS
  # ============================================================================

  @doc """
  Creates a price alert when target is reached.
  """
  def create_alert(watcher, old_price, new_price) do
    %PriceAlert{}
    |> PriceAlert.changeset(%{
      watcher_id: watcher.id,
      old_price: old_price,
      new_price: new_price,
      triggered_at: DateTime.utc_now()
    })
    |> Repo.insert()
  end

  @doc """
  Gets unread alerts for a user.
  """
  def get_unread_alerts(user_identifier) do
    from(a in PriceAlert,
      join: w in assoc(a, :watcher),
      where: w.user_identifier == ^user_identifier and a.is_read == false,
      order_by: [desc: a.triggered_at],
      preload: [:watcher]
    )
    |> Repo.all()
  end

  @doc """
  Gets all alerts for a user.
  """
  def list_alerts(user_identifier) do
    from(a in PriceAlert,
      join: w in assoc(a, :watcher),
      where: w.user_identifier == ^user_identifier,
      order_by: [desc: a.triggered_at],
      preload: [:watcher]
    )
    |> Repo.all()
  end

  @doc """
  Marks alerts as read.
  """
  def mark_alerts_read(alert_ids) when is_list(alert_ids) do
    from(a in PriceAlert, where: a.id in ^alert_ids)
    |> Repo.update_all(set: [is_read: true])
  end

  def mark_alert_read(alert_id) do
    case Repo.get(PriceAlert, alert_id) do
      nil ->
        {:error, :not_found}

      alert ->
        alert
        |> Ecto.Changeset.change(is_read: true)
        |> Repo.update()
    end
  end

  # ============================================================================
  # PRICE HISTORY
  # ============================================================================

  @doc """
  Records a price check.
  """
  def record_price_check(watcher, price) do
    # Update watcher with last price
    update_watcher(watcher, %{
      last_price: price,
      last_checked_at: DateTime.utc_now()
    })

    # Record in history
    %PriceHistory{}
    |> PriceHistory.changeset(%{
      watcher_id: watcher.id,
      price: price,
      checked_at: DateTime.utc_now()
    })
    |> Repo.insert()
  end

  @doc """
  Gets price history for a watcher.
  """
  def get_price_history(watcher_id, limit \\ 50) do
    from(h in PriceHistory,
      where: h.watcher_id == ^watcher_id,
      order_by: [desc: h.checked_at],
      limit: ^limit
    )
    |> Repo.all()
  end
end
