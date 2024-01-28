defmodule PorscheConnEx.Config do
  @moduledoc """
  Configures the region and behaviour of the API session.

  ## Fields

  - `language` (default `de`) - a two-letter language code
  - `country` (default `DE`) - a two-letter country code
  - `timezone` (default `Etc/UTC`) - a [timezone identifier](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
  - `api_url` (default `https://api.porsche.com`) - the base URL to access the Porsche Connect API
  - `http_options` (default `[]`) - a list of options accepted by `Req.new/1`

  ## Locales

  The `language` and `country` fields, when put together, should form a valid [locale name](https://en.wikipedia.org/wiki/Locale_(computer_software)).

  The chosen locale may affect various aspects of the API.  The most obvious
  effect is to choose the units used (metric versus imperial).  Note that this
  library was designed and tested using `de_DE`, on the assumption that German
  would be the most compatible locale for a German car.

  The following locales are known to work:

  - `de_DE` (Germany) - metric units
  - `en_US` (United States) - imperial units

  The following locales are known to **NOT** work.

  - `en_CA` (Canada)

  When choosing an unsupported locale, the initial authentication will succeed,
  but most other requests will fail with `{:error, :not_found}`.
  """
  alias __MODULE__

  defstruct(
    language: "de",
    country: "DE",
    timezone: "Etc/UTC",
    api_url: "https://api.porsche.com",
    http_options: []
  )

  @doc """
  Creates a new configuration object.

  `opts` can be a `Keyword` list, a `Map`, or any other enumerable containing
  key-value tuples.

  It can also be an existing `PorscheConnEx.Config` structure, which will be
  returned verbatim.
  """
  def new(opts)
  def new(%Config{} = config), do: config
  def new(opts), do: struct!(__MODULE__, opts)

  @doc false
  def locale(%Config{language: language, country: country}) do
    "#{String.downcase(language)}_#{String.upcase(country)}"
  end

  @doc false
  def url_country(%Config{country: country}), do: String.downcase(country)
  @doc false
  def url_language(%Config{} = config), do: locale(config)

  @doc false
  def url(%Config{} = config) do
    "#{url_country(config)}/#{locale(config)}"
  end

  @doc false
  def ui_locales(%Config{language: language, country: country}) do
    "#{String.downcase(language)}-#{String.upcase(country)}"
  end
end
