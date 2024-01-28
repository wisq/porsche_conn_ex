defmodule PorscheConnEx.Test.DataFactory do
  def config(bypass, params \\ []) do
    %PorscheConnEx.Config{
      api_url: "http://localhost:#{bypass.port}",
      http_options: [
        max_retries: 0,
        receive_timeout: 200
      ]
    }
    |> struct!(params)
  end

  @vin_chars [?A..?Z, ?0..?9]
             |> Enum.flat_map(& &1)
             |> Enum.reject(&(&1 in [?O, ?I, ?Q]))
  @vin_length 17

  def random_vin do
    1..@vin_length
    |> Enum.map(fn _ -> Enum.random(@vin_chars) end)
    |> String.Chars.to_string()
  end

  @nickname_chars [?A..?Z, ?a..?z] |> Enum.flat_map(& &1)
  @nickname_length 1..24

  def random_nickname do
    1..Enum.random(@nickname_length)
    |> Enum.map(fn _ -> Enum.random(@nickname_chars) end)
    |> String.Chars.to_string()
  end

  # Taken from https://en.wikipedia.org/wiki/List_of_Volkswagen_Group_platforms
  # These are just guesses.  The only one I know for sure is used in the API is "J1".
  @models ~w{MLB MLP PL71 PL72 MMB J1 PPE}
  def random_model, do: @models |> Enum.random()

  def random_request_id do
    Enum.random(1_000_000_000..9_999_999_999)
    |> Integer.to_string()
  end

  # Arbitrary sampling.
  @timezones [
    "Etc/UTC",
    "America/Toronto",
    "America/Vancouver",
    "America/Regina",
    "Europe/Berlin",
    "Europe/London",
    "Asia/Tokyo",
    "Australia/Sydney"
  ]

  def random_timezone, do: @timezones |> Enum.random()
end
