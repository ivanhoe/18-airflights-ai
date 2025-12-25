defmodule AirflightsWeb.Components.FlightSearch.SearchForm do
  use Phoenix.Component
  use Gettext, backend: AirflightsWeb.Gettext
  import AirflightsWeb.Components.FlightSearch.Utils

  attr(:origin, :string, required: true)
  attr(:destination, :string, required: true)
  attr(:date_string, :string, required: true)
  attr(:loading, :boolean, required: true)
  attr(:error, :any, default: nil)

  def search_form(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto">
      <div class="bg-white/10 backdrop-blur-lg rounded-3xl p-8 shadow-2xl border border-white/20">
        <!-- Route Display -->
        <div class="flex items-center justify-center gap-6 mb-8">
          <div class="text-center">
            <div class="text-4xl font-bold text-white">{@origin}</div>
            <div class="text-purple-300 text-sm"><%= get_city_name(@origin) %></div>
          </div>
          <div class="text-purple-400 text-3xl">→</div>
          <div class="text-center">
            <div class="text-4xl font-bold text-white">{@destination}</div>
            <div class="text-purple-300 text-sm"><%= get_city_name(@destination) %></div>
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
    </div>
    """
  end
end
