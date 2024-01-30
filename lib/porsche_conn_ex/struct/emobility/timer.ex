defmodule PorscheConnEx.Struct.Emobility.Timer do
  @moduledoc """
  Structure containing information about vehicle timers.

  Timers are used to schedule charging, and/or to climatise (preheat/cool) the
  vehicle, e.g. in preparation for an upcoming trip.

  ## API calls

  - To create or update a timer, use `PorscheConnEx.Client.put_timer/4`.
  - To delete a timer, use `PorscheConnEx.Client.delete_timer/4`.

  ## Fields

  - `id` (integer) — the ID (slot number) of the timer (1 to 5)
  - `enabled?` (boolean) — whether the timer can trigger or not
  - `depart_time` (`NaiveDateTime`) — the local time the user intends to depart
    - For repeating timers, this will be the next upcoming occurrence.
  - `repeating?` (boolean) — whether the event is a one-off (`false`) or repeats (`true`)
  - `weekdays` (list of integers, or `nil`) — a list indicating [ISO weekday numbers](`t:Calendar.ISO.day_of_week/0`)
    - Repeating timers will occur at `NaiveDateTime.to_time(depart_time)` on every listed day.
    - Non-repeating timers will have this set to `nil`.
  - `climate?` (boolean) — whether the timer will engage preheating / cooling
  - `charge?` (boolean) — whether the timer will charge the vehicle
  - `target_charge` (integer) — the target charge percentage (0 to 100)
    - The official UIs limit you to 5% increments, but the API allows any value.

  Note that `depart_time` is the **end time** of charging / climatisation, and
  **not** the start time.  All activity will occur in the minutes prior to
  `depart_time`, on the assumption that this is when the user will actually want
  a fully charged / climatised vehicle.

  The actual start time will depend on several factors, including current
  battery charge, current temperature, etc.  In particular, testing so far
  seems to indicates that climatisation timers will start sooner (i.e.
  preheat/cool for longer) if the vehicle is plugged in, since the vehicle is
  more willing to spend wall power than battery power.  (It may even charge
  the battery while doing so, ignoring any charge targets or preferred charging
  hours.)

  ## Charging behaviour

  For timers with `charge?` set to `true`, if the vehicle current charge level
  is below `target_charge` percent, it will attempt to bring the vehicle up to
  `target_charge` in time for `depart_time`.

  The actual timing of the charge depends on the current [charging
  profile](`PorscheConnEx.Struct.Emobility.ChargingProfile`), but in general,
  the vehicle will wait until as late as possible to charge.

  This means that if you have preferred charging hours set in your profile, and
  the timer is outside of those hours, then charging will occur at the tail end
  of the those hours (for the block of hours immediately prior to
  `depart_time`).

  Otherwise, charging will occur immediately before `depart_time`.  (This may
  also occur if you use the car and drain the battery between the preferred
  charging hours and the timer, but I have not confirmed this.)
  """

  use PorscheConnEx.Struct

  enum Repeating do
    value(false, key: "SINGLE")
    value(true, key: "CYCLIC")
  end

  defmodule Weekdays do
    @moduledoc false
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
    @moduledoc false
    # Local time, not UTC, despite the Z.
    # Always rounded to the minute.
    @format "{YYYY}-{0M}-{0D}T{h24}:{m}:00.000Z"
    def load(str), do: Timex.parse(str, @format)
    def dump(ndt), do: Timex.format(ndt, @format)
  end

  param do
    field(:id, :integer, key: "timerID", required: true)
    field(:enabled?, :boolean, key: "active", required: true)
    field(:depart_time, DepartTime, key: "departureDateTime", required: true)

    field(:repeating?, Repeating, key: "frequency", required: true)
    field(:weekdays, Weekdays, key: "weekDays")

    field(:climate?, :boolean, key: "climatised", required: true)
    field(:charge?, :boolean, key: "chargeOption", required: true)
    field(:target_charge, :integer, key: "targetChargeLevel", required: true)

    # These fields don't seem to be used, so I'm leaving them out to avoid confusion:
    #
    #  - climatisationTimer: 
    #    - doesn't actually seem to affect timer type / climatisation option
    #    - sometimes true, sometimes false, even amongst climatisation timers
    #    - if it did what it sounds like, it would be a duplicate of `climatised`
    #  - e3_CLIMATISATION_TIMER_ID
    #    - always 4
    #  - preferredChargingTimeEnabled
    #  - preferredChargingStartTime
    #  - preferredChargingEndTime
    #    - these fields seem to duplicate behaviour from charging profiles
    #    - they aren't accessible in the car / app UI
    #    - not sure if it's safe to use them
    #
  end
end
