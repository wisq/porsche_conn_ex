defmodule PorscheConnEx.Config do
  alias __MODULE__

  defstruct(
    language: "de",
    country: "DE",
    timezone: "Etc/UTC",
    api_url: "https://api.porsche.com",
    status_delay: 1_000,
    max_status_checks: 120,
    max_retries: 1,
    receive_timeout: 15_000
  )

  def new(%Config{} = config), do: config
  def new(opts), do: struct!(__MODULE__, opts)

  def locale(%Config{language: language, country: country}) do
    "#{String.downcase(language)}_#{String.upcase(country)}"
  end

  def url_country(%Config{country: country}), do: String.downcase(country)
  def url_language(%Config{} = config), do: locale(config)

  def url(%Config{} = config) do
    "#{url_country(config)}/#{locale(config)}"
  end

  def ui_locales(%Config{language: language, country: country}) do
    "#{String.downcase(language)}-#{String.upcase(country)}"
  end
end
