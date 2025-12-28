defmodule Airflights.Watchers.WatcherMonitor do
  @moduledoc """
  GenServer that monitors flight prices for a specific watcher.

  Each watcher gets its own GenServer process that:
  - Checks the price at regular intervals
  - Records price history
  - Creates alerts when price drops below target

  The check interval is configurable via application config.
  """
  use GenServer
  require Logger

  alias Airflights.{Flights, Watchers}
  alias Airflights.Watchers.PriceWatcher

  # Default: 1 hour (3600 seconds)
  # For demo: 30 seconds
  @default_check_interval_ms :timer.seconds(30)

  # ============================================================================
  # PUBLIC API
  # ============================================================================

  @doc """
  Starts monitoring a watcher.
  """
  def start_monitoring(%PriceWatcher{} = watcher) do
    name = via_tuple(watcher.id)

    case GenServer.start_link(__MODULE__, watcher, name: name) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      error -> error
    end
  end

  @doc """
  Stops monitoring a watcher.
  """
  def stop_monitoring(watcher_id) do
    name = via_tuple(watcher_id)

    case GenServer.whereis(name) do
      nil -> :ok
      pid -> GenServer.stop(pid, :normal)
    end
  end

  @doc """
  Checks if a watcher is being monitored.
  """
  def monitoring?(watcher_id) do
    name = via_tuple(watcher_id)
    GenServer.whereis(name) != nil
  end

  @doc """
  Forces an immediate price check (useful for testing).
  """
  def check_now(watcher_id) do
    name = via_tuple(watcher_id)
    GenServer.cast(name, :check_price)
  end

  # ============================================================================
  # GENSERVER CALLBACKS
  # ============================================================================

  @impl true
  def init(%PriceWatcher{} = watcher) do
    Logger.info("[WatcherMonitor] Started: #{watcher.origin} → #{watcher.destination}")

    # Schedule first check immediately
    send(self(), :check_price)

    state = %{
      watcher_id: watcher.id,
      origin: watcher.origin,
      destination: watcher.destination,
      travel_date: watcher.travel_date,
      target_price: watcher.target_price,
      currency: watcher.currency,
      check_interval: get_check_interval()
    }

    {:ok, state}
  end

  @impl true
  def handle_info(:check_price, state) do
    check_and_schedule(state)
    {:noreply, state}
  end

  @impl true
  def handle_cast(:check_price, state) do
    do_price_check(state)
    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info(
      "[WatcherMonitor] Stopped #{state.origin} → #{state.destination}: #{inspect(reason)}"
    )

    :ok
  end

  # ============================================================================
  # PRIVATE FUNCTIONS
  # ============================================================================

  defp via_tuple(watcher_id) do
    {:via, Registry, {Airflights.WatcherRegistry, watcher_id}}
  end

  defp get_check_interval do
    Application.get_env(:airflights, :watcher_check_interval_ms, @default_check_interval_ms)
  end

  defp check_and_schedule(state) do
    do_price_check(state)
    schedule_next_check(state.check_interval)
  end

  defp schedule_next_check(interval) do
    Process.send_after(self(), :check_price, interval)
  end

  defp do_price_check(state) do
    Logger.debug("[WatcherMonitor] Checking #{state.origin} → #{state.destination}")

    # Reload watcher from DB to get current state
    case Watchers.get_watcher(state.watcher_id) do
      nil ->
        Logger.warning("[WatcherMonitor] Watcher not found, stopping")
        GenServer.stop(self(), :normal)

      watcher ->
        if watcher.is_active do
          fetch_and_process_price(watcher, state)
        else
          Logger.debug("[WatcherMonitor] Watcher paused, skipping")
        end
    end
  end

  defp fetch_and_process_price(watcher, state) do
    date_string = Date.to_iso8601(state.travel_date)

    case Flights.search_all(state.origin, state.destination, date_string) do
      {:ok, flights} when is_list(flights) and length(flights) > 0 ->
        cheapest = Enum.min_by(flights, & &1.price)
        process_price(watcher, cheapest.price, state)

      {:ok, []} ->
        Logger.warning(
          "[WatcherMonitor] No flights found for #{state.origin} → #{state.destination}"
        )

      {:error, reason} ->
        Logger.error("[WatcherMonitor] Price check failed: #{inspect(reason)}")
    end
  end

  defp process_price(watcher, current_price, state) do
    Logger.info("[WatcherMonitor] #{state.origin} → #{state.destination}: $#{current_price}")

    # Record in history
    Watchers.record_price_check(watcher, current_price)

    # Check if price dropped below target
    target = Decimal.to_float(state.target_price)

    if current_price < target do
      old_price =
        if watcher.last_price, do: Decimal.to_float(watcher.last_price), else: current_price

      Logger.info(
        "[WatcherMonitor] 🎉 Price alert! #{state.origin} → #{state.destination}: $#{current_price} (target: $#{target})"
      )

      # Create alert
      Watchers.create_alert(watcher, old_price, current_price)

      # Broadcast to PubSub for any connected clients
      Phoenix.PubSub.broadcast(
        Airflights.PubSub,
        "alerts:#{watcher.user_identifier}",
        {:price_alert,
         %{
           watcher_id: watcher.id,
           route: "#{state.origin} → #{state.destination}",
           old_price: old_price,
           new_price: current_price,
           target_price: target
         }}
      )
    end
  end
end
