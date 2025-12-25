defmodule AirflightsWeb.Components.FlightSearch.FlightSegments do
  use Phoenix.Component
  use Gettext, backend: AirflightsWeb.Gettext
  import AirflightsWeb.Components.FlightSearch.Utils

  attr(:segments, :list, default: [])

  def flight_segments(assigns) do
    ~H"""
    <%= if @segments && length(@segments) > 0 do %>
      <div class="mt-8 pt-6 border-t border-white/10 space-y-6">
        <h3 class="text-white font-semibold text-lg border-b border-white/10 pb-2"><%= gettext("Flight Segments") %></h3>
        <%= for {segment, index} <- Enum.with_index(@segments) do %>
          <div class="bg-black/20 rounded-xl p-4 text-white">
            <div class="flex justify-between items-start mb-2">
              <div>
                <span class="font-bold text-lg"><%= get_city_name(segment["departure_airport"]["id"]) %></span>
                <span class="text-purple-300 text-sm ml-2"><%= format_time(segment["departure_airport"]["time"]) %></span>
              </div>
              <div class="text-sm text-purple-200">
                 <%= format_duration(segment["duration"]) %>
              </div>
              <div class="text-right">
                 <span class="text-purple-300 text-sm mr-2"><%= format_time(segment["arrival_airport"]["time"]) %></span>
                 <span class="font-bold text-lg"><%= get_city_name(segment["arrival_airport"]["id"]) %></span>
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

          <%= if index < length(@segments) - 1 do %>
            <div class="flex items-center justify-center gap-2 text-purple-300 text-xs py-2">
              <div class="h-px w-12 bg-purple-500/30"></div>
              <span><%= gettext("Layover at") %> <%= get_city_name(segment["arrival_airport"]["id"]) %></span>
              <div class="h-px w-12 bg-purple-500/30"></div>
            </div>
          <% end %>
        <% end %>
      </div>
    <% end %>
    """
  end
end
