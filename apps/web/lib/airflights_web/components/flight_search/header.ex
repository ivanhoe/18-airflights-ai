defmodule AirflightsWeb.Components.FlightSearch.Header do
  use Phoenix.Component

  attr(:title, :string, required: true)
  attr(:subtitle, :string, required: true)

  def flight_header(assigns) do
    ~H"""
    <div class="text-center mb-12">
      <h1 class="text-5xl font-bold text-white mb-4">
        ✈️ {@title}
      </h1>
      <p class="text-xl text-purple-200">
        {@subtitle}
      </p>
    </div>
    """
  end
end
