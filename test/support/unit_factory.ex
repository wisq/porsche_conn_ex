defmodule PorscheConnEx.Test.UnitFactory do
  alias PorscheConnEx.Struct
  alias PorscheConnEx.Struct.Unit

  def distance_km_to_km(value) do
    %Unit.Distance{
      value: value,
      unit: :km,
      original_value: value,
      original_unit: :km,
      km: value
    }
  end

  def distance_km_to_miles(km, mi) do
    %Unit.Distance{
      value: mi,
      unit: :mi,
      original_value: km,
      original_unit: :km,
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
      current: %Unit.Pressure{value: current, unit: :bar},
      optimal: %Unit.Pressure{value: optimal, unit: :bar},
      difference: %Unit.Pressure{value: diff, unit: :bar},
      status: status
    }
  end

  def charge_rate(km_per_minute, km_per_hour) do
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

  def fuel_consumption_km(value) do
    %Unit.Consumption.Fuel{
      value: value,
      unit: :litres_per_100km,
      litres_per_100km: value
    }
  end

  def energy_consumption_km(value) do
    %Unit.Consumption.Energy{
      value: value,
      unit: :kwh_per_100km,
      kwh_per_100km: value
    }
  end
end
