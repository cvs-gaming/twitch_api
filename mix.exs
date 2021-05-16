defmodule TwitchApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :twitch_api,
      version: "0.1.5",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
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
      {:httpoison, "~> 1.7"},
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/cvs-gaming/twitch_api",
      },
      description: "Twitch API library"
    ]
  end
end
