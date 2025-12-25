defmodule Airflights.Flights.Offer do
  @moduledoc """
  Domain entity representing a flight offer.

  This is a pure data structure with no external dependencies,
  following the Single Responsibility Principle.
  """

  @type t :: %__MODULE__{
          price: float(),
          currency: String.t(),
          departure_at: DateTime.t() | nil,
          arrival_at: DateTime.t() | nil,
          duration: String.t() | nil,
          stops: non_neg_integer(),
          airline: String.t() | nil,
          airline_code: String.t() | nil,
          segments: list(map())
        }

  defstruct [
    :price,
    :currency,
    :departure_at,
    :arrival_at,
    :duration,
    :stops,
    :airline,
    :airline_code,
    segments: []
  ]

  @doc """
  Creates a new Offer struct from a map of attributes.
  """
  def new(attrs) when is_map(attrs) do
    struct(__MODULE__, attrs)
  end
end
