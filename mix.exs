defmodule PorscheConnEx.MixProject do
  use Mix.Project

  @github_url "https://github.com/wisq/porsche_conn_ex"

  def project do
    [
      app: :porsche_conn_ex,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :dev,
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps(),
      source_url: @github_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    PorscheConnEx is a library for connecting to the Porsche Connect API, to
    monitor and control your Porsche vehicle.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "LICENSE"],
      maintainers: ["Adrian Irving-Beer"],
      licenses: ["MIT"],
      links: %{GitHub: @github_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "CHANGELOG.md"
      ],
      groups_for_modules: [
        "API client": [
          PorscheConnEx.Client,
          PorscheConnEx.Client.PendingRequest,
          PorscheConnEx.Config,
          PorscheConnEx.Session,
          PorscheConnEx.Session.RequestData
        ],
        "Data structures": ~r/^PorscheConnEx\.Struct\./
      ],
      nest_modules_by_prefix: [
        PorscheConnEx,
        PorscheConnEx.Struct
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:req, "~> 0.4.0"},
      {:cookie_jar, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:parameter, "~> 0.13"},
      {:timex, "~> 3.7"},
      {:bypass, "~> 2.1", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:ex_git_test, "~> 0.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
