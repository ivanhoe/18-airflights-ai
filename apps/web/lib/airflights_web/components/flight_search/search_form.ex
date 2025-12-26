defmodule AirflightsWeb.Components.FlightSearch.SearchForm do
  use Phoenix.Component
  use Gettext, backend: AirflightsWeb.Gettext

  @airports [
    {"MEX", "Ciudad de México"},
    {"MTY", "Monterrey"},
    {"GDL", "Guadalajara"},
    {"CUN", "Cancún"},
    {"TIJ", "Tijuana"},
    {"VIE", "Viena"},
    {"MAD", "Madrid"},
    {"LHR", "Londres"},
    {"JFK", "New York"},
    {"MIA", "Miami"},
    {"AMS", "Amsterdam"},
    {"DFW", "Dallas"}
  ]

  attr(:origin, :string, required: true)
  attr(:destination, :string, required: true)
  attr(:date_string, :string, required: true)
  attr(:round_trip, :boolean, default: false)
  attr(:return_date_string, :string, default: nil)
  attr(:loading, :boolean, required: true)
  attr(:error, :any, default: nil)

  def search_form(assigns) do
    assigns = assign(assigns, :airports, @airports)

    ~H"""
    <div class="max-w-4xl mx-auto">
      <form phx-submit="search" class="space-y-4">
        <div class="flex flex-wrap items-center gap-2 md:gap-3 text-sm">
          <div class="flex items-center gap-2 px-4 md:px-6 py-3 bg-slate-800/80 border border-slate-600/50 rounded-lg">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-400 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
            </svg>
            <select name="round_trip" class="bg-transparent text-slate-200 text-sm focus:outline-none cursor-pointer">
              <option value="true" selected={@round_trip} class="bg-slate-800"><%= gettext("Round trip") %></option>
              <option value="false" selected={!@round_trip} class="bg-slate-800"><%= gettext("One way") %></option>
            </select>
          </div>

          <div class="flex items-center gap-2 px-4 md:px-6 py-3 bg-slate-800/80 border border-slate-600/50 rounded-lg">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-400 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
            <span class="text-slate-200">1</span>
          </div>

          <div class="px-4 md:px-6 py-3 bg-slate-800/80 border border-slate-600/50 rounded-lg">
            <span class="text-slate-200 text-sm"><%= gettext("Economy") %></span>
          </div>
        </div>

        <div class="flex flex-col md:flex-row md:items-center bg-slate-800/90 rounded-xl border border-slate-600/50 overflow-hidden gap-0">

          <div class="flex items-center gap-2 px-4 py-3 border-b md:border-b-0 md:border-r border-slate-600/50 flex-1 min-w-0">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-400 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <circle cx="12" cy="12" r="3" stroke-width="2"/>
            </svg>
            <select
              name="origin"
              class="bg-transparent text-white text-sm focus:outline-none flex-1 min-w-0 cursor-pointer"
            >
              <%= for {code, name} <- @airports do %>
                <option value={code} selected={code == @origin} class="bg-slate-800">{name}</option>
              <% end %>
            </select>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-500 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
          </div>

          <button type="button" class="px-6 py-3 border-b md:border-b-0 md:border-r border-slate-600/50 hover:bg-slate-700/50 transition-colors flex items-center justify-center">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
            </svg>
          </button>

          <div class="flex items-center gap-2 px-4 py-3 border-b md:border-b-0 md:border-r border-slate-600/50 flex-1 min-w-0">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-400 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <select
              name="destination"
              class="bg-transparent text-white text-sm focus:outline-none flex-1 min-w-0 cursor-pointer"
            >
              <%= for {code, name} <- @airports do %>
                <option value={code} selected={code == @destination} class="bg-slate-800">{name}</option>
              <% end %>
            </select>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-500 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
          </div>

          <div class="flex items-center gap-2 px-4 py-3 border-b md:border-b-0 md:border-r border-slate-600/50">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-slate-400 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            <input
              type="date"
              name="date"
              value={@date_string}
              min={Date.to_iso8601(Date.utc_today())}
              class="bg-transparent text-white text-sm focus:outline-none w-full md:w-28"
            />
          </div>

          <div class="flex items-center gap-2 px-4 py-3">
            <input
              type="date"
              name="return_date"
              value={@return_date_string}
              min={@date_string}
              class="bg-transparent text-white text-sm focus:outline-none w-full md:w-28"
            />
          </div>
        </div>

        <!-- Search Button -->
        <div class="flex justify-center pt-2">
          <button
            type="submit"
            disabled={@loading}
            class="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium rounded-full shadow-lg transform transition hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100 flex items-center gap-2"
          >
            <%= if @loading do %>
              <svg class="animate-spin h-4 w-4" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"/>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
              </svg>
              <%= gettext("Searching...") %>
            <% else %>
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
              <%= gettext("Explore") %>
            <% end %>
          </button>
        </div>
      </form>

      <!-- Error Message -->
      <%= if @error do %>
        <div class="mt-4 p-3 bg-red-500/20 border border-red-500/50 rounded-xl text-red-200 text-center text-sm">
          ⚠️ {@error}
        </div>
      <% end %>
    </div>
    """
  end
end
