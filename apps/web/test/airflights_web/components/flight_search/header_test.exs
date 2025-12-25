defmodule AirflightsWeb.Components.FlightSearch.HeaderTest do
  use AirflightsWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import AirflightsWeb.Components.FlightSearch.Header

  test "renders title and subtitle" do
    assigns = %{title: "My Title", subtitle: "My Subtitle"}

    html =
      rendered_to_string(~H"""
      <.flight_header title={@title} subtitle={@subtitle} />
      """)

    assert html =~ "My Title"
    assert html =~ "My Subtitle"
  end
end
