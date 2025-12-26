defmodule AirflightsWeb.Components.FlightSearch.FlightCard do
  use Phoenix.Component
  use Gettext, backend: AirflightsWeb.Gettext
  import AirflightsWeb.Components.FlightSearch.Utils
  import AirflightsWeb.Components.FlightSearch.FlightSegments

  attr(:offer, :map, required: true)
  attr(:index, :integer, default: nil)

  def flight_card(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto bg-white/10 backdrop-blur-lg rounded-3xl p-6 md:p-8 shadow-2xl border border-white/20 animate-fade-in">
      <%= if @index == 1 do %>
        <h2 class="text-xl md:text-2xl font-bold text-white mb-4 text-center">
          🎉 <%= gettext("Cheapest Flight Found!") %>
        </h2>
      <% else %>
        <div class="text-lg font-semibold text-purple-300 mb-4">
          Opción <%= @index %>
        </div>
      <% end %>

      <div class={[
        "rounded-2xl p-4 md:p-6 border",
        if(@index == 1, do: "bg-gradient-to-r from-green-500/20 to-emerald-500/20 border-green-500/30", else: "bg-white/5 border-white/10")
      ]}>
        <div class="text-center mb-6">
          <div class={[
            "text-4xl md:text-5xl font-bold",
            if(@index == 1, do: "text-green-400", else: "text-purple-400")
          ]}>
            {format_price(@offer.price)}
          </div>
          <div class={[
            "text-sm",
            if(@index == 1, do: "text-green-200", else: "text-purple-200")
          ]}>{@offer.currency}</div>
        </div>

        <div class="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4 text-white">
          <div class="bg-white/5 rounded-xl p-3 md:p-4">
            <div class="text-purple-300 text-xs md:text-sm"><%= gettext("Airline") %></div>
            <div class="text-base md:text-xl font-semibold truncate">{@offer.airline || @offer.airline_code || "N/A"}</div>
          </div>
          <div class="bg-white/5 rounded-xl p-3 md:p-4">
            <div class="text-purple-300 text-xs md:text-sm"><%= gettext("Stops") %></div>
            <div class="text-base md:text-xl font-semibold">
              <%= if @offer.stops == 0, do: gettext("Direct"), else: "#{@offer.stops} #{gettext("stop(s)")}" %>
            </div>
          </div>
          <div class="bg-white/5 rounded-xl p-3 md:p-4">
            <div class="text-purple-300 text-xs md:text-sm"><%= gettext("Duration") %></div>
            <div class="text-base md:text-xl font-semibold">{format_duration(@offer.duration)}</div>
          </div>
          <div class="bg-white/5 rounded-xl p-3 md:p-4">
            <div class="text-purple-300 text-xs md:text-sm"><%= gettext("Departure") %></div>
            <div class="text-base md:text-xl font-semibold">{format_datetime(@offer.departure_at)}</div>
          </div>
        </div>

        <.flight_segments segments={@offer.segments} />
      </div>
    </div>
    """
  end
end
