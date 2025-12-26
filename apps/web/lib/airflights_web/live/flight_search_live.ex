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
    default_return = Date.add(default_date, 7)

    socket =
      socket
      |> assign(:origin, @default_origin)
      |> assign(:destination, @default_destination)
      |> assign(:date, default_date)
      |> assign(:date_string, Date.to_iso8601(default_date))
      |> assign(:round_trip, false)
      |> assign(:return_date, default_return)
      |> assign(:return_date_string, Date.to_iso8601(default_return))
      |> assign(:offer, nil)
      |> assign(:all_offers, [])
      |> assign(:loading, false)
      |> assign(:error, nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("search", params, socket) do
    origin = Map.get(params, "origin", socket.assigns.origin)
    destination = Map.get(params, "destination", socket.assigns.destination)
    date_string = Map.get(params, "date", socket.assigns.date_string)
    round_trip = Map.get(params, "round_trip") == "true"
    return_date_string = Map.get(params, "return_date", socket.assigns.return_date_string)

    socket = assign(socket, :loading, true)

    with {:ok, date} <- Date.from_iso8601(date_string),
         {:ok, return_date} <- parse_optional_date(return_date_string, round_trip) do
      socket =
        socket
        |> assign(:origin, origin)
        |> assign(:destination, destination)
        |> assign(:date, date)
        |> assign(:date_string, date_string)
        |> assign(:round_trip, round_trip)
        |> assign(:return_date, return_date)
        |> assign(:return_date_string, return_date_string)

      send(self(), :do_search)
      {:noreply, socket}
    else
      {:error, _} ->
        socket =
          socket
          |> assign(:loading, false)
          |> assign(:error, gettext("Invalid date format"))

        {:noreply, socket}
    end
  end

  defp parse_optional_date(_date_string, false), do: {:ok, nil}
  defp parse_optional_date(date_string, true), do: Date.from_iso8601(date_string)

  @impl true
  def handle_info(:do_search, socket) do
    %{origin: origin, destination: destination, date: date} = socket.assigns

    socket =
      case Flights.search_all(origin, destination, date) do
        {:ok, offers} when is_list(offers) and length(offers) > 0 ->
          top_offers = Enum.take(offers, 5)
          
          socket
          |> assign(:offer, List.first(top_offers))
          |> assign(:all_offers, top_offers)
          |> assign(:error, nil)
          |> assign(:loading, false)

        {:ok, []} ->
          socket
          |> assign(:offer, nil)
          |> assign(:all_offers, [])
          |> assign(:error, "No flights found for this date")
          |> assign(:loading, false)

        {:error, reason} ->
          socket
          |> assign(:offer, nil)
          |> assign(:all_offers, [])
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
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex flex-col">
      <div class="container mx-auto px-4 py-12 flex-1 flex flex-col">
        <.flight_header title={gettext("Flight Tracker")} subtitle={gettext("Find the cheapest flights from Mexico City to Vienna")} />

        <.search_form
          origin={@origin}
          destination={@destination}
          date_string={@date_string}
          round_trip={@round_trip}
          return_date_string={@return_date_string}
          loading={@loading}
          error={@error}
        />

        <%= if @loading do %>
          <div class="flex flex-col items-center justify-center py-12 space-y-4">
            <div class="animate-spin rounded-full h-16 w-16 border-4 border-purple-500 border-t-transparent"></div>
            <p class="text-purple-200 text-lg animate-pulse"><%= gettext("Searching for the best flights...") %></p>
          </div>
        <% end %>

        <%= if @all_offers != [] && !@loading do %>
          <div class="space-y-4 mt-8">
            <%= for {offer, index} <- Enum.with_index(@all_offers, 1) do %>
              <.flight_card offer={offer} index={index} />
            <% end %>
          </div>
        <% end %>

        <div class="flex-1"></div>

        <.footer />
      </div>
    </div>
    """
  end
end
