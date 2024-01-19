defmodule PorscheConnEx.Struct.Summary do
  use PorscheConnEx.Struct

  param do
    field(:model_description, :string, key: "modelDescription", required: true)
    field(:nickname, :string, key: "nickName")
  end
end
