defmodule EctoGcd.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_gcd,
      description: "Ecto adapter for Google Cloud Datastore",
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
      package: [
                 ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.4.4"},
      {:httpoison, "~> 1.6.2"},
      {:jason, "~> 1.2.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
