defmodule PorscheConnEx.Struct.Emobility.Timer do
  use PorscheConnEx.Struct

  enum Frequency do
    value(:single, key: "SINGLE")
    value(:repeating, key: "CYCLIC")
  end

  defmodule Weekdays do
    @days ~w{MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY SATURDAY SUNDAY}
          |> Enum.with_index(1)
          |> Map.new()

    def load(map) when is_map(map) do
      map
      |> Enum.flat_map_reduce(:ok, fn
        {day, true}, :ok ->
          case @days |> Map.fetch(day) do
            {:ok, number} -> {[number], :ok}
            :error -> {:halt, {:error, "Unknown weekday: #{inspect(day)}"}}
          end

        {_, false}, :ok ->
          {[], :ok}
      end)
      |> then(fn
        {list, :ok} -> {:ok, Enum.sort(list)}
        {_, {:error, _} = err} -> err
      end)
    end

    def load(other), do: {:error, "Unknown type: #{inspect(other)}"}
  end

  defmodule DepartTime do
    # Local time, not UTC, despite the Z.
    # Always rounded to the minute.
    def load(str), do: Timex.parse(str, "{YYYY}-{0M}-{0D}T{h24}:{m}:00.000Z")
  end

  alias __MODULE__.Frequency

  param do
    field(:id, :integer, key: "timerID", required: true)
    field(:depart_time, DepartTime, key: "departureDateTime", required: true)

    field(:preferred_charging_time_enabled?, :boolean,
      key: "preferredChargingTimeEnabled",
      required: true
    )

    field(:preferred_charging_start_time, :any, key: "preferredChargingStartTime")
    field(:preferred_charging_end_time, :any, key: "preferredChargingEndTime")
    field(:frequency, Frequency, required: true)
    field(:climate?, :boolean, key: "climatised", required: true)
    field(:charge?, :boolean, key: "chargeOption", required: true)
    field(:weekdays, Weekdays, key: "weekDays")
    field(:active?, :boolean, key: "active", required: true)
    field(:target_charge, :integer, key: "targetChargeLevel", required: true)

    # These two fields don't seem to be used:
    #
    #  - climatisationTimer: 
    #    - doesn't actually seem to affect timer type / climatisation option
    #    - sometimes true, sometimes false, even amongst climatisation timers
    #    - if it did what it sounds like, it would be a duplicate of `climatised`
    #  - e3_CLIMATISATION_TIMER_ID
    #    - always 4
    #
    # I'm leaving them out to avoid confusion with other fields.
  end
end
