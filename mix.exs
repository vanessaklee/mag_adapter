defmodule MagAdapter.MixProject do
  use Mix.Project

  def project do
    [
      app: :mag_adapter,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:ecto_sql, "~> 3.0"},
      {:contex, "~> 0.3.0"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.2"},
      {:csv, "~> 2.4"},
      {:sweet_xml, "~> 0.6.5"}
    ]
  end
end
