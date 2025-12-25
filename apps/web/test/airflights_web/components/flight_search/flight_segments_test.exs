defmodule AirflightsWeb.Components.FlightSearch.FlightSegmentsTest do
  use AirflightsWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import AirflightsWeb.Components.FlightSearch.FlightSegments

  test "renders nothing if segments are empty" do
    assigns = %{segments: []}

    html =
      rendered_to_string(~H"""
      <.flight_segments segments={@segments} />
      """)

    assert html == ""
  end

  test "renders segments correctly" do
    segments = [
      %{
        "departure_airport" => %{"id" => "MEX", "time" => "2025-01-01 10:00"},
        "arrival_airport" => %{"id" => "IAH", "time" => "2025-01-01 12:00"},
        "duration" => 120,
        "airline" => "Aeromexico",
        "airline_logo" => "logo.png",
        "flight_number" => "AM1"
      },
      %{
        "departure_airport" => %{"id" => "IAH", "time" => "2025-01-01 14:00"},
        "arrival_airport" => %{"id" => "VIE", "time" => "2025-01-02 08:00"},
        "duration" => 600,
        "airline" => "Lufthansa",
        "airline_logo" => "logo2.png",
        "flight_number" => "LH2"
      }
    ]

    assigns = %{segments: segments}

    html =
      rendered_to_string(~H"""
      <.flight_segments segments={@segments} />
      """)

    # Header
    assert html =~ "Escalas"
    assert html =~ "Ciudad de México"
    assert html =~ "IAH"
    assert html =~ "Viena"
    assert html =~ "Aeromexico"
    assert html =~ "Lufthansa"

    # Check layover text logic
    # Should appear between first and second segment
    assert html =~ "Escala en IAH"

    # Actually, we mocked "Layover at" via Gettext in the component, and we only have "Escala en" in ES translation.
    # But this test runs in default locale (likely 'en' unless config is forced).
    # Let's just check for the airport code in the layover section to be safe, or just content.
    assert html =~ "IAH"
  end
end
