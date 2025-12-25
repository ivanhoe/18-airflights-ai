defmodule AirflightsWeb.Components.FlightSearch.FlightCard do
  use Phoenix.Component
  use Gettext, backend: AirflightsWeb.Gettext
  import AirflightsWeb.Components.FlightSearch.Utils
  import AirflightsWeb.Components.FlightSearch.FlightSegments

  attr(:offer, :map, required: true)

  def flight_card(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto mt-8 bg-white/10 backdrop-blur-lg rounded-3xl p-8 shadow-2xl border border-white/20 animate-fade-in">
      <h2 class="text-2xl font-bold text-white mb-6 text-center">
        🎉 <%= gettext("Cheapest Flight Found!") %>
      </h2>

      <div class="bg-gradient-to-r from-green-500/20 to-emerald-500/20 rounded-2xl p-6 border border-green-500/30">
        <!-- Price -->
        <div class="text-center mb-6">
          <div class="text-5xl font-bold text-green-400">
            {format_price(@offer.price)}
          </div>
          <div class="text-green-200 text-sm">{@offer.currency}</div>
        </div>

        <!-- Flight Details -->
        <div class="grid grid-cols-2 gap-4 text-white">
          <div class="bg-white/5 rounded-xl p-4">
            <div class="text-purple-300 text-sm"><%= gettext("Airline") %></div>
            <div class="text-xl font-semibold">{@offer.airline || @offer.airline_code || "N/A"}</div>
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
        <.flight_segments segments={@offer.segments} />
      </div>
    </div>
    """
  end
end
