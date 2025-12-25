defmodule AirflightsWeb.Components.FlightSearch.UtilsTest do
  use ExUnit.Case, async: true
  alias AirflightsWeb.Components.FlightSearch.Utils

  # We need to set the locale for Gettext tests if we want to test translations explicitly,
  # but here we'll test the output.

  describe "format_price/1" do
    test "formats integer correctly" do
      assert Utils.format_price(7057) == "$7,057.00"
    end

    test "formats float correctly" do
      assert Utils.format_price(1234.56) == "$1,234.56"
    end

    test "formats zero" do
      assert Utils.format_price(0) == "$0.00"
    end

    test "formats large numbers" do
      assert Utils.format_price(1_000_000) == "$1,000,000.00"
    end
  end

  describe "format_duration/1" do
    test "handles nil" do
      assert Utils.format_duration(nil) == "N/A"
    end

    test "formats ISO string" do
      assert Utils.format_duration("PT12H30M") == "12h 30m"
    end

    test "formats minutes integer" do
      assert Utils.format_duration(90) == "1h 30m"
      assert Utils.format_duration(60) == "1h 0m"
      assert Utils.format_duration(45) == "0h 45m"
    end
  end

  describe "get_city_name/1" do
    test "maps known codes" do
      cities = %{
        "MEX" => "Ciudad de México",
        "AMS" => "Amsterdam",
        "VIE" => "Viena",
        "DFW" => "Dallas",
        "LHR" => "Londres",
        "MAD" => "Madrid",
        "CUN" => "Cancún",
        "MTY" => "Monterrey",
        "GDL" => "Guadalajara",
        "JFK" => "New York",
        "MIA" => "Miami"
      }

      for {code, name} <- cities do
        assert Utils.get_city_name(code) == name
      end
    end

    test "returns code for unknown cities" do
      assert Utils.get_city_name("XYZ") == "XYZ"
    end
  end

  describe "month_name/1" do
    test "maps all months correctly" do
      # Note: These assertions expect the Spanish translations ("Ene", etc.)
      # if the locale is set to "es". If running simple mix test defaults,
      # it might be "Ene" because of the default.po modifications we made.
      # or "Jan" if no translation found
      assert Utils.month_name(1) =~ "Ene"
      assert Utils.month_name(2) =~ "Feb"
      assert Utils.month_name(3) =~ "Mar"
      assert Utils.month_name(4) =~ "Abr" || Utils.month_name(4) =~ "Apr"
      assert Utils.month_name(5) =~ "May"
      assert Utils.month_name(6) =~ "Jun"
      assert Utils.month_name(7) =~ "Jul"
      assert Utils.month_name(8) =~ "Ago" || Utils.month_name(8) =~ "Aug"
      assert Utils.month_name(9) =~ "Sep"
      assert Utils.month_name(10) =~ "Oct"
      assert Utils.month_name(11) =~ "Nov"
      assert Utils.month_name(12) =~ "Dic" || Utils.month_name(12) =~ "Dec"
    end
  end

  describe "format_time/1" do
    test "extracts time from date-time string" do
      assert Utils.format_time("2026-02-22 17:50") == "17:50"
    end

    test "returns original if format doesn't match" do
      assert Utils.format_time("17:50") == "17:50"
    end
  end
end
