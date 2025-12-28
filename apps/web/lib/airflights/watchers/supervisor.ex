defmodule Airflights.Watchers.Supervisor do
  @moduledoc """
  Supervisor for price watcher processes.

  This supervisor manages:
  - Registry for watcher processes
  - Dynamic supervisor for watcher monitors
  - Startup of active watchers on application boot
  """
  use Supervisor
  require Logger

  alias Airflights.Watchers

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      # Registry to track watcher processes by ID
      {Registry, keys: :unique, name: Airflights.WatcherRegistry},

      # Dynamic supervisor for watcher monitors
      {DynamicSupervisor, name: Airflights.WatcherDynamicSupervisor, strategy: :one_for_one},

      # Task to start active watchers after boot
      {Task, fn -> start_active_watchers() end}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp start_active_watchers do
    # Wait a bit for Repo to be ready
    Process.sleep(2000)

    Logger.info("[WatcherSupervisor] Starting active watchers...")

    case Watchers.list_active_watchers() do
      watchers when is_list(watchers) ->
        Enum.each(watchers, fn watcher ->
          case Watchers.WatcherMonitor.start_monitoring(watcher) do
            {:ok, _pid} ->
              Logger.info(
                "[WatcherSupervisor] Started: #{watcher.origin} → #{watcher.destination}"
              )

            {:error, reason} ->
              Logger.error(
                "[WatcherSupervisor] Failed to start #{watcher.id}: #{inspect(reason)}"
              )
          end
        end)

        Logger.info("[WatcherSupervisor] Started #{length(watchers)} watchers")

      _ ->
        Logger.warning("[WatcherSupervisor] Could not load active watchers")
    end
  end
end
