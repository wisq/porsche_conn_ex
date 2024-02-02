defmodule PorscheConnEx.Struct.Summary do
  @moduledoc """
  Structure containing extremely basic information about a particular vehicle.

  This is the structure returned by `PorscheConnEx.Client.summary/2`.

  ## Fields

  - `model_description` (string) — the vehicle model description (e.g. "Taycan GTS")
  - `nickname` (string or `nil`) — the user-assigned nickname for the vehicle (if set)
  """
  use PorscheConnEx.Struct

  param do
    field(:model_description, :string, key: "modelDescription", required: true)
    field(:nickname, :string, key: "nickName")
  end

  @type t :: %__MODULE__{
          model_description: binary,
          nickname: binary
        }
end
