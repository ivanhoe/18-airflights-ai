defmodule AirflightsWeb.Components.FlightSearch.FooterTest do
  use AirflightsWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import AirflightsWeb.Components.FlightSearch.Footer

  test "renders footer content" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.footer />
      """)

    assert html =~ "Desarrollado por SerpApi"
  end
end
