defmodule Airflights.Watchers.PriceWatcher do
  @moduledoc """
  Schema for price watcher configurations.

  A price watcher monitors a specific route and notifies when the price
  drops below the target threshold.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "price_watchers" do
    field(:user_identifier, :string)
    field(:origin, :string)
    field(:destination, :string)
    field(:travel_date, :date)
    field(:target_price, :decimal)
    field(:currency, :string, default: "MXN")
    field(:is_active, :boolean, default: true)
    field(:last_checked_at, :utc_datetime)
    field(:last_price, :decimal)

    has_many(:alerts, Airflights.Watchers.PriceAlert, foreign_key: :watcher_id)
    has_many(:price_history, Airflights.Watchers.PriceHistory, foreign_key: :watcher_id)

    timestamps(type: :utc_datetime)
  end

  @required_fields [:user_identifier, :origin, :destination, :travel_date, :target_price]
  @optional_fields [:currency, :is_active, :last_checked_at, :last_price]

  def changeset(watcher, attrs) do
    watcher
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:origin, is: 3)
    |> validate_length(:destination, is: 3)
    |> validate_number(:target_price, greater_than: 0)
    |> upcase_airports()
  end

  defp upcase_airports(changeset) do
    changeset
    |> update_change(:origin, &String.upcase/1)
    |> update_change(:destination, &String.upcase/1)
  end
end
