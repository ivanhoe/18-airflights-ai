defmodule AirflightsWeb.Components.FlightSearch.SearchFormTest do
  use AirflightsWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import AirflightsWeb.Components.FlightSearch.SearchForm

  test "renders form with route info" do
    assigns = %{
      origin: "MEX",
      destination: "VIE",
      date_string: "2025-01-01",
      loading: false,
      error: nil
    }

    html =
      rendered_to_string(~H"""
      <.search_form
        origin={@origin}
        destination={@destination}
        date_string={@date_string}
        loading={@loading}
        error={@error}
      />
      """)

    assert html =~ "MEX"
    assert html =~ "VIE"
    # City names derived from Utils
    assert html =~ "Ciudad de México"
    assert html =~ "Viena"
    assert html =~ "2025-01-01"
  end

  test "shows loading state" do
    assigns = %{
      origin: "MEX",
      destination: "VIE",
      date_string: "2025-01-01",
      # Loading active
      loading: true,
      error: nil
    }

    html =
      rendered_to_string(~H"""
      <.search_form
        origin={@origin}
        destination={@destination}
        date_string={@date_string}
        loading={@loading}
        error={@error}
      />
      """)

    assert html =~ "Buscando..."
    refute html =~ "Find Cheapest Flight"
    assert html =~ "disabled"
  end

  test "shows error message" do
    assigns = %{
      origin: "MEX",
      destination: "VIE",
      date_string: "2025-01-01",
      loading: false,
      error: "Something went wrong"
    }

    html =
      rendered_to_string(~H"""
      <.search_form
        origin={@origin}
        destination={@destination}
        date_string={@date_string}
        loading={@loading}
        error={@error}
      />
      """)

    assert html =~ "Something went wrong"
  end
end
