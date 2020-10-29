defmodule U2fEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :u2f_ex,
      version: "0.4.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      description: description(),
      package: package(),
      preferred_cli_env: [testall: :test]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {U2FEx.App, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:credo, "~> 1.5.0", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.1"},
      {:x509, "~> 0.8.1"},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      testall: ["credo", "test"]
    ]
  end

  defp description do
    "A server-side Elixir implementation of the U2F (Universal 2nd Factor) protocol."
  end

  defp package do
    [
      name: "u2f_ex",
      files: ["lib", "mix.exs", "LICENSE"],
      maintainers: ["Ian Lee Clark"],
      licenses: ["BSD 3-clause"],
      links: %{"Github" => "https://github.com/GrappigPanda/u2f_ex"}
    ]
  end
end
