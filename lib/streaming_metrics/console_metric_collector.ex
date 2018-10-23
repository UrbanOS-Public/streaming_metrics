defmodule StreamingMetrics.ConsoleMetricCollector do
  @moduledoc false
  @behaviour StreamingMetrics.MetricCollector

  require Logger

  def init(), do: :ok

  def count_metric(count, name, dimensions \\ [], timestamp \\ DateTime.utc_now()) do
    # Stealing the AWS implementation for convenience,
    # but other MetricCollectors (grafana, google cloud, etc.)
    # are likely to require a different data structure.
    %{
      metric_name: name,
      value: count,
      unit: "Count",
      timestamp: timestamp,
      dimensions: dimensions
    }
  end

  def record_metrics(metrics, namespace) do
    wrapper = %{
      namespace: namespace,
      metrics: metrics
    }

    Logger.info("#{inspect(wrapper)}")
    {:ok, wrapper}
  end
end
