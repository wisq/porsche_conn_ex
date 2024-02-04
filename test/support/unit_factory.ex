defmodule PorscheConnEx.Test.UnitFactory do
  alias PorscheConnEx.Struct
  alias PorscheConnEx.Struct.Unit

  def distance_km(value) do
    %Unit.Distance{
      value: value,
      unit: :km,
      km: value
    }
  end

  def distance_miles(mi, km) do
    %Unit.Distance{
      value: mi,
      unit: :mi,
      km: km
    }
  end

  def time(value, unit) when unit in [:day] do
    %Unit.Time{
      value: value,
      unit: unit
    }
  end

  def battery_level(value) do
    %Unit.BatteryLevel{
      value: value,
      unit: :percent
    }
  end

  def tire_pressure(current, optimal, diff, status) do
    %Struct.Overview.TirePressure{
      current: %Unit.Pressure{value: current, unit: :bar, bar: current},
      optimal: %Unit.Pressure{value: optimal, unit: :bar, bar: optimal},
      difference: %Unit.Pressure{value: diff, unit: :bar, bar: diff},
      status: status
    }
  end

  def tire_pressure_psi(current, optimal, diff, status) do
    %Struct.Overview.TirePressure{
      current: %Unit.Pressure{value: current, unit: :psi, bar: psi_to_bar(current)},
      optimal: %Unit.Pressure{value: optimal, unit: :psi, bar: psi_to_bar(optimal)},
      difference: %Unit.Pressure{value: diff, unit: :psi, bar: psi_to_bar(diff)},
      status: status
    }
  end

  defp psi_to_bar(psi) do
    # Original storage value is bar with one decimal place.
    # Normally I'd specify bar equivalents as part of the assertion, but
    # there's so many values that it's pretty ugly, and this works fine.
    Float.round(psi * 0.689476) / 10
  end

  def charge_rate_km(km_per_minute, km_per_hour) do
    %Unit.ChargeRate{
      value: km_per_minute,
      unit: :km_per_minute,
      km_per_hour: km_per_hour
    }
  end

  def charge_rate_miles(mi_per_minute, km_per_hour) do
    %Unit.ChargeRate{
      value: mi_per_minute,
      unit: :mi_per_minute,
      km_per_hour: km_per_hour
    }
  end

  def temperature(dk, celsius) do
    %Unit.Temperature{
      decikelvin: dk,
      celsius: celsius
    }
  end

  def speed_kmh(kmh) do
    %Unit.Speed{
      value: kmh,
      unit: :km_per_hour,
      km_per_hour: kmh
    }
  end

  def speed_mph(mph, kmh) do
    %Unit.Speed{
      value: mph,
      unit: :mi_per_hour,
      km_per_hour: kmh
    }
  end

  def fuel_consumption_km(value) do
    %Unit.Consumption.Fuel{
      value: value,
      unit: :litres_per_100km,
      litres_per_100km: value
    }
  end

  def fuel_consumption_mpg(mpg, lp100km) do
    %Unit.Consumption.Fuel{
      value: mpg,
      unit: :miles_per_gallon,
      litres_per_100km: lp100km
    }
  end

  def energy_consumption_km(value) do
    %Unit.Consumption.Energy{
      value: value,
      unit: :kwh_per_100km,
      kwh_per_100km: value
    }
  end

  def energy_consumption_mi(mi, km) do
    %Unit.Consumption.Energy{
      value: mi,
      unit: :miles_per_kwh,
      kwh_per_100km: km
    }
  end
end
