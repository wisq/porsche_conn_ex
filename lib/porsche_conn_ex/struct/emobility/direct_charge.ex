defmodule PorscheConnEx.Struct.Emobility.DirectCharge do
  use PorscheConnEx.Struct

  param do
    field(:disabled?, :boolean, key: "disabled", required: true)
    field(:active?, :boolean, key: "isActive", required: true)
  end
end
