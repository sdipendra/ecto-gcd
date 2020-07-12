defmodule EctoGcd.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_gcd,
      description: "Ecto adapter for Google Cloud Datastore",
      version: "0.3.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      maintainers: ["Dipendra Singh"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/sdipendra/ecto-gcd"}
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
      {:ecto, "~> 3.4.5"},
      {:httpoison, "~> 1.7.0"},
      {:jason, "~> 1.2.1"},
      {:ex_doc, "~> 0.22.1"},
      {:google_api_datastore, "~> 0.15.0"},
    # todo: see if you can get rid of goth as it's third party I don't trust it
      {:goth, "~> 1.2.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
