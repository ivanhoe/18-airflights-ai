# apps/web/test_api.exs

# Mock the context to avoid full application start if needed,
# but better to use the actual modules if possible.
# Since we are running with `mix run`, the app should be loaded.

alias Airflights.Flights
alias AirflightsWeb.Api.FlightController

# We need to simulate a request or just call the context directly
# and check if the result has segments.

# 1. Search Cheapest
IO.puts("--- Testing Flights.search_cheapest ---")

case Flights.search_cheapest("MEX", "VIE", Date.add(Date.utc_today(), 30)) do
  {:ok, offer} ->
    IO.puts("Offer found via Context:")
    IO.inspect(offer.segments, label: "Segments (Context)")

    if length(offer.segments) > 0 do
      IO.puts("✅ Segments found in Context result")
    else
      IO.puts("❌ Segments EMPTY in Context result")
    end

    # Simulate Controller Serialization
    json = %{
      price: offer.price,
      segments: offer.segments || []
    }

    IO.inspect(json.segments, label: "Segments (JSON)")

  {:error, reason} ->
    IO.puts("❌ Search failed: #{inspect(reason)}")
end
