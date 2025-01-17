defmodule Demo.MixProject do
  use Mix.Project

  def project do
    [
      app: :demo,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Demo.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:sweet_xml, "~> 0.6.0"},
      {:ecto, "~> 3.8"},
      {:ecto_sql, "~> 3.8"},
      {:postgrex, "~> 0.16.5"},
      {:paginator, "~> 0.6.0"},
      {:sobelow, "~> 0.8", only: :dev},
      {:credo, "~> 1.6", runtime: false, only: :dev},
      {:dialyxir, "~> 1.2", runtime: false, only: :dev},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false},
      {:junit_formatter, "~> 3.1", only: [:test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    []
  end
end
