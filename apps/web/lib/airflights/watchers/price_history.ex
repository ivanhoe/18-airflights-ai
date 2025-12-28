defmodule Airflights.Watchers.PriceHistory do
  @moduledoc """
  Schema for price check history.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @foreign_key_type :binary_id

  schema "price_history" do
    field(:price, :decimal)
    field(:checked_at, :utc_datetime)

    belongs_to(:watcher, Airflights.Watchers.PriceWatcher)
  end

  def changeset(history, attrs) do
    history
    |> cast(attrs, [:watcher_id, :price, :checked_at])
    |> validate_required([:watcher_id, :price, :checked_at])
    |> foreign_key_constraint(:watcher_id)
  end
end
