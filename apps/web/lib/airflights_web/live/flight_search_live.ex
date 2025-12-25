defmodule AirflightsWeb.FlightSearchLive do
  @moduledoc """
  LiveView for searching flights.

  This is a "driving adapter" in hexagonal architecture terms -
  it receives user input and drives the application core.
  """

  use AirflightsWeb, :live_view

  alias Airflights.Flights
  import AirflightsWeb.Components.FlightSearch.Header
  import AirflightsWeb.Components.FlightSearch.SearchForm
  import AirflightsWeb.Components.FlightSearch.FlightCard
  import AirflightsWeb.Components.FlightSearch.Footer

  @default_origin "MEX"
  @default_destination "VIE"

  @impl true
  def mount(_params, _session, socket) do
    # Default date: 30 days from now
    default_date = Date.add(Date.utc_today(), 30)

    socket =
      socket
      |> assign(:origin, @default_origin)
      |> assign(:destination, @default_destination)
      |> assign(:date, default_date)
      |> assign(:date_string, Date.to_iso8601(default_date))
      |> assign(:offer, nil)
      |> assign(:all_offers, [])
      |> assign(:loading, false)
      |> assign(:error, nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("search", %{"date" => date_string}, socket) do
    socket = assign(socket, :loading, true)

    case Date.from_iso8601(date_string) do
      {:ok, date} ->
        socket = assign(socket, :date, date)
        socket = assign(socket, :date_string, date_string)
        send(self(), :do_search)
        {:noreply, socket}

      {:error, _} ->
        socket =
          socket
          |> assign(:loading, false)
          |> assign(:error, "Invalid date format")

        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:do_search, socket) do
    %{origin: origin, destination: destination, date: date} = socket.assigns

    socket =
      case Flights.search_cheapest(origin, destination, date) do
        {:ok, offer} ->
          socket
          |> assign(:offer, offer)
          |> assign(:error, nil)
          |> assign(:loading, false)

        {:error, :no_offers} ->
          socket
          |> assign(:offer, nil)
          |> assign(:error, "No flights found for this date")
          |> assign(:loading, false)

        {:error, reason} ->
          socket
          |> assign(:offer, nil)
          |> assign(:error, format_error(reason))
          |> assign(:loading, false)
      end

    {:noreply, socket}
  end

  defp format_error({:api_error, status, body}) do
    message = get_in(body, ["error_description"]) || "API error"
    "API error (#{status}): #{message}"
  end

  defp format_error({:auth_error, _status, body}) do
    message = get_in(body, ["error_description"]) || "Authentication failed"
    "Authentication error: #{message}"
  end

  defp format_error(reason) when is_binary(reason), do: reason
  defp format_error(reason), do: inspect(reason)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      <div class="container mx-auto px-4 py-12">
        <.flight_header title={gettext("Flight Tracker")} subtitle={gettext("Find the cheapest flights from Mexico City to Vienna")} />

        <.search_form
          origin={@origin}
          destination={@destination}
          date_string={@date_string}
          loading={@loading}
          error={@error}
        />

        <%= if @offer do %>
          <.flight_card offer={@offer} />
        <% end %>

        <.footer />
      </div>
    </div>
    """
  end
end
