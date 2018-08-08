defmodule U2fEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :u2f_ex,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      description: description(),
      package: package()
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
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
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
      licenses: ["LGPL"],
      links: %{"Github" => "https://github.com/GrappigPanda/u2f_ex"}
    ]
  end
end
