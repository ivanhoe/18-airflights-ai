defmodule AirflightsWeb.FlightSearchLive do
  @moduledoc """
  LiveView for searching flights.

  This is a "driving adapter" in hexagonal architecture terms -
  it receives user input and drives the application core.
  """

  use AirflightsWeb, :live_view

  alias Airflights.Flights

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
        <!-- Header -->
        <div class="text-center mb-12">
          <h1 class="text-5xl font-bold text-white mb-4">
            ✈️ <%= gettext("Flight Tracker") %>
          </h1>
          <p class="text-xl text-purple-200">
            <%= gettext("Find the cheapest flights from Mexico City to Vienna") %>
          </p>
        </div>

        <!-- Search Card -->
        <div class="max-w-2xl mx-auto">
          <div class="bg-white/10 backdrop-blur-lg rounded-3xl p-8 shadow-2xl border border-white/20">
            <!-- Route Display -->
            <div class="flex items-center justify-center gap-6 mb-8">
              <div class="text-center">
                <div class="text-4xl font-bold text-white">{@origin}</div>
                <div class="text-purple-300 text-sm"><%= gettext("Mexico City") %></div>
              </div>
              <div class="text-purple-400 text-3xl">→</div>
              <div class="text-center">
                <div class="text-4xl font-bold text-white">{@destination}</div>
                <div class="text-purple-300 text-sm"><%= gettext("Vienna") %></div>
              </div>
            </div>

            <!-- Search Form -->
            <form phx-submit="search" class="space-y-6">
              <div>
                <label class="block text-purple-200 text-sm font-medium mb-2">
                  <%= gettext("Departure Date") %>
                </label>
                <input
                  type="date"
                  name="date"
                  value={@date_string}
                  min={Date.to_iso8601(Date.utc_today())}
                  class="w-full px-4 py-3 bg-white/10 border border-white/30 rounded-xl text-white placeholder-purple-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                />
              </div>

              <button
                type="submit"
                disabled={@loading}
                class="w-full py-4 px-6 bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white font-bold text-lg rounded-xl shadow-lg transform transition hover:scale-[1.02] disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100"
              >
                <%= if @loading do %>
                  <span class="inline-flex items-center gap-2">
                    <svg class="animate-spin h-5 w-5" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"/>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
                    </svg>
                    <%= gettext("Searching...") %>
                  </span>
                <% else %>
                  🔍 <%= gettext("Find Cheapest Flight") %>
                <% end %>
              </button>
            </form>

            <!-- Error Message -->
            <%= if @error do %>
              <div class="mt-6 p-4 bg-red-500/20 border border-red-500/50 rounded-xl text-red-200">
                ⚠️ {@error}
              </div>
            <% end %>
          </div>

          <!-- Results Card -->
          <%= if @offer do %>
            <div class="mt-8 bg-white/10 backdrop-blur-lg rounded-3xl p-8 shadow-2xl border border-white/20 animate-fade-in">
              <h2 class="text-2xl font-bold text-white mb-6 text-center">
                🎉 <%= gettext("Cheapest Flight Found!") %>
              </h2>

              <div class="bg-gradient-to-r from-green-500/20 to-emerald-500/20 rounded-2xl p-6 border border-green-500/30">
                <!-- Price -->
                <div class="text-center mb-6">
                  <div class="text-5xl font-bold text-green-400">
                    ${Float.round(@offer.price, 2)}
                  </div>
                  <div class="text-green-200 text-sm">{@offer.currency}</div>
                </div>

                <!-- Flight Details -->
                <div class="grid grid-cols-2 gap-4 text-white">
                  <div class="bg-white/5 rounded-xl p-4">
                    <div class="text-purple-300 text-sm"><%= gettext("Airline") %></div>
                    <div class="text-xl font-semibold">{@offer.airline_code || "N/A"}</div>
                  </div>
                  <div class="bg-white/5 rounded-xl p-4">
                    <div class="text-purple-300 text-sm"><%= gettext("Stops") %></div>
                    <div class="text-xl font-semibold">
                      <%= if @offer.stops == 0, do: gettext("Direct"), else: "#{@offer.stops} #{gettext("stop(s)")}" %>
                    </div>
                  </div>
                  <div class="bg-white/5 rounded-xl p-4">
                    <div class="text-purple-300 text-sm"><%= gettext("Duration") %></div>
                    <div class="text-xl font-semibold">{format_duration(@offer.duration)}</div>
                  </div>
                  <div class="bg-white/5 rounded-xl p-4">
                    <div class="text-purple-300 text-sm"><%= gettext("Departure") %></div>
                    <div class="text-xl font-semibold">{format_datetime(@offer.departure_at)}</div>
                  </div>
                </div>

                <!-- Segments Breakdown -->
                <%= if @offer.segments && length(@offer.segments) > 0 do %>
                  <div class="mt-8 pt-6 border-t border-white/10 space-y-6">
                    <h3 class="text-white font-semibold text-lg border-b border-white/10 pb-2"><%= gettext("Flight Segments") %></h3>
                    <%= for {segment, index} <- Enum.with_index(@offer.segments) do %>
                      <div class="bg-black/20 rounded-xl p-4 text-white">
                        <div class="flex justify-between items-start mb-2">
                          <div>
                            <span class="font-bold text-lg"><%= segment["departure_airport"]["id"] %></span>
                            <span class="text-purple-300 text-sm ml-2"><%= format_time(segment["departure_airport"]["time"]) %></span>
                          </div>
                          <div class="text-sm text-purple-200">
                             <%= format_duration(segment["duration"]) %>
                          </div>
                          <div class="text-right">
                             <span class="text-purple-300 text-sm mr-2"><%= format_time(segment["arrival_airport"]["time"]) %></span>
                             <span class="font-bold text-lg"><%= segment["arrival_airport"]["id"] %></span>
                          </div>
                        </div>
                        <div class="flex justify-between items-center text-sm text-gray-400">
                           <div class="flex items-center gap-2">
                             <img src={segment["airline_logo"]} class="h-6 w-6 object-contain bg-white rounded-full" alt="logo" />
                             <span><%= segment["airline"] %></span>
                           </div>
                           <span><%= gettext("Flight") %> <%= segment["flight_number"] %></span>
                        </div>
                      </div>

                      <%= if index < length(@offer.segments) - 1 do %>
                        <div class="flex items-center justify-center gap-2 text-purple-300 text-xs py-2">
                          <div class="h-px w-12 bg-purple-500/30"></div>
                          <span><%= gettext("Layover at") %> <%= segment["arrival_airport"]["id"] %></span>
                          <div class="h-px w-12 bg-purple-500/30"></div>
                        </div>
                      <% end %>
                    <% end %>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>

        <!-- Footer -->
        <div class="text-center mt-12 text-purple-300 text-sm">
          <%= gettext("Powered by SerpApi (Google Flights) • Built with Elixir & Phoenix LiveView") %>
        </div>
      </div>
    </div>
    """
  end

  defp format_duration(nil), do: "N/A"

  defp format_duration(duration) when is_binary(duration) do
    # ISO 8601 duration format: PT12H30M
    duration
    |> String.replace("PT", "")
    |> String.replace("H", "h ")
    |> String.replace("M", "m")
  end

  defp format_duration(minutes) when is_integer(minutes) do
    hours = div(minutes, 60)
    mins = rem(minutes, 60)
    "#{hours}h #{mins}m"
  end

  defp format_datetime(nil), do: "N/A"

  defp format_datetime(%DateTime{} = dt) do
    Calendar.strftime(dt, "%b %d, %H:%M")
  end

  defp format_time(time_str) do
    # Format "2026-02-22 17:50" -> "17:50"
    case String.split(time_str, " ") do
      [_, time] -> time
      _ -> time_str
    end
  end
end
