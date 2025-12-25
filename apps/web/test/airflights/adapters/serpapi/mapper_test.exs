defmodule Airflights.Adapters.SerpApi.MapperTest do
  use ExUnit.Case, async: true
  alias Airflights.Adapters.SerpApi.Mapper
  alias Airflights.Flights.Offer

  test "maps successful response correctly" do
    serpapi_response = %{
      "best_flights" => [
        %{
          "flights" => [
            %{
              "airline" => "Lufthansa",
              "departure_airport" => %{
                "id" => "MEX",
                "time" => "2025-01-01 10:00"
              },
              "arrival_airport" => %{
                "id" => "VIE",
                "time" => "2025-01-01 22:00"
              },
              "duration" => 720,
              "flight_number" => "LH123",
              "airline_logo" => "logo.png"
            }
          ],
          "layovers" => [],
          "total_duration" => 720,
          "price" => 15000
        }
      ]
    }

    assert [%Offer{} = offer] = Mapper.to_offers(serpapi_response)

    assert offer.price == 15000
    # Forced by mapper
    assert offer.currency == "MXN"
    assert offer.airline == "Lufthansa"
    # format_duration returns ISO string in mapper
    assert offer.duration == "PT12H0M"
    assert offer.stops == 0
    assert length(offer.segments) == 1

    # Check date parsing
    # ~U[2025-01-01 10:00:00Z] is expected if mapper assumes local/UTC or similar parsing
    assert offer.departure_at.year == 2025
    assert offer.departure_at.month == 1
    assert offer.departure_at.day == 1
  end

  test "returns empty list if no flights found" do
    response = %{"other_flights" => []}
    assert Mapper.to_offers(response) == []

    response_empty = %{}
    assert Mapper.to_offers(response_empty) == []
  end
end
