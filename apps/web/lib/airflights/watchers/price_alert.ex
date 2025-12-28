defmodule Airflights.Watchers.PriceAlert do
  @moduledoc """
  Schema for price alerts triggered when price drops below target.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "price_alerts" do
    field(:old_price, :decimal)
    field(:new_price, :decimal)
    field(:is_read, :boolean, default: false)
    field(:triggered_at, :utc_datetime)

    belongs_to(:watcher, Airflights.Watchers.PriceWatcher)

    timestamps(type: :utc_datetime)
  end

  def changeset(alert, attrs) do
    alert
    |> cast(attrs, [:watcher_id, :old_price, :new_price, :is_read, :triggered_at])
    |> validate_required([:watcher_id, :old_price, :new_price, :triggered_at])
    |> foreign_key_constraint(:watcher_id)
  end
end
