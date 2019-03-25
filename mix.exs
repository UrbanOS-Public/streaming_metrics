defmodule StreamingMetrics.MixProject do
  use Mix.Project

  def project do
    [
      app: :streaming_metrics,
      version: "2.1.4",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/SmartColumbusOS"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {StreamingMetrics, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.5.0"},
      {:mock, "~> 0.3.1", only: :test, runtime: false},
      {:ex_aws_cloudwatch, "~> 2.0.4"},
      {:ex_aws, "~> 2.0.0"},
      {:prometheus_ex, "~> 3.0"},
      {:credo, "~> 0.10", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    "A metrics recording library"
  end

  defp package do
    [
      organization: "smartcolumbus_os",
      licenses: ["AllRightsReserved"],
      links: %{
        "GitHub" => "https://github.com/SmartColumbusOS/streaming-metrics"
      }
    ]
  end
end
