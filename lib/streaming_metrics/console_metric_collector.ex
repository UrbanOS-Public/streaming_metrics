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
  def count_metric(value, name, dimensions \\ [], timestamp \\ DateTime.utc_now()) do
    format_metric(value, name, dimensions, "Count", timestamp)
  end

  @doc """
  Create the metrics that will later be logged to the console
  """
  def gauge_metric(value, name, dimensions \\ [], unit \\ "None", timestamp \\ DateTime.utc_now()) do
    format_metric(value, name, dimensions, unit, timestamp)
  end

  defp format_metric(value, name, dimensions, unit, timestamp) do
    %{
      metric_name: name,
      value: value,
      unit: unit,
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
