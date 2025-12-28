defmodule Airflights.Repo.Migrations.CreatePriceAlerts do
  use Ecto.Migration

  def change do
    create table(:price_alerts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :watcher_id, references(:price_watchers, type: :binary_id, on_delete: :delete_all), null: false
      add :old_price, :decimal, null: false, precision: 10, scale: 2
      add :new_price, :decimal, null: false, precision: 10, scale: 2
      add :is_read, :boolean, default: false
      add :triggered_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:price_alerts, [:watcher_id])
    create index(:price_alerts, [:is_read])
    create index(:price_alerts, [:triggered_at])
  end
end
