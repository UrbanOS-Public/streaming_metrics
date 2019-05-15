defmodule StreamingMetrics.ConsoleMetricCollector do
  @moduledoc """
  A module for collecting metrics and logging to the console.
  """
  @behaviour StreamingMetrics.MetricCollector

  require Logger

  def init(), do: :ok

  @doc """
  Create the metrics that will later be logged to the console
  """
  def count_metric(count, name, dimensions \\ [], timestamp \\ DateTime.utc_now()) do
    %{
      metric_name: name,
      value: count,
      unit: "Count",
      timestamp: timestamp,
      dimensions: dimensions
    }
  end

  @doc """
  Simply log the metrics to the console
  """
  def record_metrics(metrics, namespace) do
    wrapper = %{
      namespace: namespace,
      metrics: metrics
    }

    Logger.info("#{inspect(wrapper)}")
    {:ok, wrapper}
  end
end
