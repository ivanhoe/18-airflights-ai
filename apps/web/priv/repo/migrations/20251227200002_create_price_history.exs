defmodule Airflights.Repo.Migrations.CreatePriceHistory do
  use Ecto.Migration

  def change do
    create table(:price_history) do
      add(:watcher_id, references(:price_watchers, type: :binary_id, on_delete: :delete_all),
        null: false
      )

      add(:price, :decimal, null: false, precision: 10, scale: 2)
      add(:checked_at, :utc_datetime, null: false)
    end

    create(index(:price_history, [:watcher_id]))
    create(index(:price_history, [:checked_at]))
  end
end
