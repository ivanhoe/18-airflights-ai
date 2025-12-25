defmodule AirflightsWeb.Components.FlightSearch.FlightCardTest do
  use AirflightsWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import AirflightsWeb.Components.FlightSearch.FlightCard

  test "renders flight details" do
    offer = %Airflights.Flights.Offer{
      price: 1234.56,
      currency: "MXN",
      airline: "Lufthansa",
      airline_code: "LH",
      stops: 1,
      # minutes
      duration: 720,
      departure_at: ~U[2025-01-01 10:00:00Z],
      arrival_at: ~U[2025-01-01 22:00:00Z],
      # Empty for this test to focus on card
      segments: []
    }

    assigns = %{offer: offer}

    html =
      rendered_to_string(~H"""
      <.flight_card offer={@offer} />
      """)

    assert html =~ "$1,234.56"
    assert html =~ "MXN"
    assert html =~ "Lufthansa"
    # or translated variant
    assert html =~ "1 escala(s)"
    assert html =~ "12h 0m"
  end
end
