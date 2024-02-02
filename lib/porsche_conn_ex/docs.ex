defmodule PorscheConnEx.Docs do
  @moduledoc false

  @header_regex ~r/^\#+ [ ]+ (?<header>[\w ]+) [ ]*$/x

  def section(docs, header) do
    docs
    |> String.split("\n")
    |> Enum.drop_while(fn line ->
      Regex.named_captures(@header_regex, line) != %{"header" => header}
    end)
    |> Enum.drop(1)
    |> Enum.take_while(fn line -> !(line =~ @header_regex) end)
    |> Enum.join("\n")
    |> String.trim()
  end

  def indent(docs, levels \\ 1) do
    padding = 1..levels//1 |> Enum.map(fn _ -> "  " end) |> Enum.join()

    docs
    |> String.trim()
    |> String.replace("\n", "\n#{padding}")
  end

  def type(module) do
    short_name =
      case module |> Module.split() do
        ["PorscheConnEx", "Struct", "Unit" | rest] -> rest
        ["PorscheConnEx", "Struct" | rest] -> rest
        ["PorscheConnEx" | rest] -> rest
      end
      |> Enum.join(".")

    "[`#{short_name}`](`#{module}`)"
  end

  def count_fields(module) do
    module.__struct__()
    |> Map.from_struct()
    |> Enum.count()
  end
end
