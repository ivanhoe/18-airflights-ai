defmodule Airflights.Repo.Migrations.CreatePriceWatchers do
  use Ecto.Migration

  def change do
    create table(:price_watchers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_identifier, :string, null: false  # Device ID or user email
      add :origin, :string, null: false, size: 3
      add :destination, :string, null: false, size: 3
      add :travel_date, :date, null: false
      add :target_price, :decimal, null: false, precision: 10, scale: 2
      add :currency, :string, default: "MXN", size: 3
      add :is_active, :boolean, default: true
      add :last_checked_at, :utc_datetime
      add :last_price, :decimal, precision: 10, scale: 2

      timestamps(type: :utc_datetime)
    end

    create index(:price_watchers, [:user_identifier])
    create index(:price_watchers, [:is_active])
    create index(:price_watchers, [:origin, :destination, :travel_date])
  end
end
