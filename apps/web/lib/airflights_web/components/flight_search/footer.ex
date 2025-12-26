defmodule AirflightsWeb.Components.FlightSearch.Footer do
  use Phoenix.Component
  use Gettext, backend: AirflightsWeb.Gettext

  def footer(assigns) do
    ~H"""
    <div class="text-center py-8 text-purple-300 text-sm">
      <%= gettext("Powered by SerpApi (Google Flights) • Built with Elixir & Phoenix LiveView") %>
    </div>
    """
  end
end
