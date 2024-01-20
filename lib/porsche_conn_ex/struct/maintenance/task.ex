defmodule PorscheConnEx.Struct.Maintenance.Task do
  use PorscheConnEx.Struct

  defmodule Description do
    use PorscheConnEx.Struct

    param do
      field(:short_name, :string, key: "shortName", required: true)
      field(:long_name, :string, key: "longName", required: false)
      field(:criticality, :string, key: "criticalityText", required: true)
      field(:notification, :string, key: "notificationText", required: false)
    end
  end

  defmodule Values do
    use PorscheConnEx.Struct

    # I've only seen one value for all these enums so far.
    # If you've seen different values, please let me know!

    enum ModelState do
      value(:active, key: "active")
    end

    enum ModelVisibility do
      value(:visible, key: "visible")
    end

    enum Source do
      value(:vehicle, key: "Vehicle")
    end

    enum Event do
      value(:cyclic, key: "CYCLIC")
    end

    alias __MODULE__.{ModelState, ModelVisibility, Source, Event}

    param do
      field(:model_id, :string, key: "modelId", required: true)
      field(:model_state, ModelState, key: "modelState", required: true)
      field(:model_name, :string, key: "modelName", required: true)
      field(:model_visibility, ModelVisibility, key: "modelVisibilityState", required: true)
      field(:source, Source, required: true)
      field(:event, Event, required: true)
      field(:odometer_last_reset, :integer, key: "odometerLastReset", required: true)
      field(:criticality, :integer, required: true)
      field(:warnings, {:map, :integer}, required: true)
    end

    def load(params) when is_map(params) do
      {warnings, params} =
        params
        |> Map.split_with(fn
          {"WarnID" <> _, _} -> true
          {_, _} -> false
        end)

      warnings =
        warnings
        |> Map.new(fn {"WarnID" <> id, value} ->
          {String.to_integer(id), value}
        end)

      params
      |> Map.put("warnings", warnings)
      |> super()
    end
  end

  param do
    field(:id, :string, required: true)
    field(:criticality, :integer, required: true)
    field(:description, Description, required: true)
    # These are all null for me, so I won't try to guess the datatype yet.
    field(:remaining_days, :any, key: "remainingLifeTimeInDays")
    field(:remaining_km, :any, key: "remainingLifeTimeInKm")
    field(:remaining_percent, :any, key: "remainingLifeTimePercentage")
    field(:values, Values, required: true)
  end
end
