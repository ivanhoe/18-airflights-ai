defmodule AirflightsWeb.Components.FlightSearch.Utils do
  use Phoenix.Component
  use Gettext, backend: AirflightsWeb.Gettext

  def format_duration(nil), do: "N/A"

  def format_duration(duration) when is_binary(duration) do
    # ISO 8601 duration format: PT12H30M
    duration
    |> String.replace("PT", "")
    |> String.replace("H", "h ")
    |> String.replace("M", "m")
  end

  def format_duration(minutes) when is_integer(minutes) do
    hours = div(minutes, 60)
    mins = rem(minutes, 60)
    "#{hours}h #{mins}m"
  end

  def format_datetime(nil), do: "N/A"

  def format_datetime(%DateTime{} = dt) do
    month = month_name(dt.month)
    day = dt.day
    # Format time manually to ensure 2 digits
    hour = dt.hour |> Integer.to_string() |> String.pad_leading(2, "0")
    minute = dt.minute |> Integer.to_string() |> String.pad_leading(2, "0")

    "#{month} #{day}, #{hour}:#{minute}" |> String.upcase()
  end

  def month_name(1), do: gettext("Jan")
  def month_name(2), do: gettext("Feb")
  def month_name(3), do: gettext("Mar")
  def month_name(4), do: gettext("Apr")
  def month_name(5), do: gettext("May")
  def month_name(6), do: gettext("Jun")
  def month_name(7), do: gettext("Jul")
  def month_name(8), do: gettext("Aug")
  def month_name(9), do: gettext("Sep")
  def month_name(10), do: gettext("Oct")
  def month_name(11), do: gettext("Nov")
  def month_name(12), do: gettext("Dec")

  def get_city_name("MEX"), do: "Ciudad de México"
  def get_city_name("AMS"), do: "Amsterdam"
  def get_city_name("VIE"), do: "Viena"
  def get_city_name("DFW"), do: "Dallas"
  def get_city_name("LHR"), do: "Londres"
  def get_city_name("MAD"), do: "Madrid"
  def get_city_name("CUN"), do: "Cancún"
  def get_city_name("MTY"), do: "Monterrey"
  def get_city_name("GDL"), do: "Guadalajara"
  def get_city_name("JFK"), do: "New York"
  def get_city_name("MIA"), do: "Miami"
  def get_city_name(code), do: code

  def format_price(price) when is_float(price) or is_integer(price) do
    # Format number like 7057.0 -> $7,057.00
    price
    # Ensure float
    |> Kernel.+(0.0)
    |> :erlang.float_to_binary(decimals: 2)
    |> String.split(".")
    |> then(fn [int, dec] ->
      formatted_int =
        int
        |> String.reverse()
        |> to_charlist()
        |> Enum.chunk_every(3)
        |> Enum.join(",")
        |> String.reverse()

      "$#{formatted_int}.#{dec}"
    end)
  end

  def format_time(time_str) do
    # Format "2026-02-22 17:50" -> "17:50"
    case String.split(time_str, " ") do
      [_, time] -> time
      _ -> time_str
    end
  end
end
