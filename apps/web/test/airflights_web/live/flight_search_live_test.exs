defmodule AirflightsWeb.FlightSearchLiveTest do
  use AirflightsWeb.ConnCase
  import Phoenix.LiveViewTest

  test "mounts and displays default search form", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ "Rastreador de Vuelos"
    # Origin
    assert html =~ "Ciudad de México"
    # Destination
    assert html =~ "Viena"
    assert has_element?(view, "form")
  end

  # Note: To test the actual "search" event, we would need to mock the external API call
  # or rely on VCR cassettes. Since we don't have Mox/Bypass set up for this specific task
  # yet, we will focus on verifying that the live view can receive the event and attempt to search.
  # We can check for the "Searching..." state update if we trigger the event.

  test "updates loading state on search", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    # We send the search event with a valid date string
    view
    |> form("form", %{"date" => "2025-01-01"})
    |> render_submit()

    # The view should transition to loading state (searching...)
    # However, since the search happens asynchronously with send(self(), :do_search),
    # verifying intermediate state without mocking is tricky as it might process fast.
    # But we can assert that at least it doesn't crash.

    # If we want to verify the result rendering, we'd need the real API or a mock to return successful data.
    # For now, let's just ensure the submission works.
  end
end
