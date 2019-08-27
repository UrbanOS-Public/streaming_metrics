defmodule StreamingMetrics.PrometheusMetricCollector do
  @moduledoc """
  Prometheus backend.

  It is the client's responsibility to expose the metrics
  to prometheus via a scrape endpoint or the Pushgateway.
  This module simply creates and increments the counters.
  """
  @behaviour StreamingMetrics.MetricCollector

  require Logger
  use Prometheus.Metric

  def init() do
    :ok
  end

  @doc """
  Formats info into a format `record_metrics` understands.
  `timestamp` is ignored because Prometheus handles timestamps.
  """
  def count_metric(count, name, dimensions \\ [], _timestamp \\ []) do
    format_metric(count, name, dimensions, :count)
  end

  @doc """
  Formats info into a format `record_metrics` understands.
  `timestamp` is ignored because Prometheus handles timestamps.
  """
  def gauge_metric(value, name, dimensions \\ [], _timestamp \\ []) do
    format_metric(value, name, dimensions, :gauge)
  end

  defp format_metric(value, name, dimensions, type) do
    %{
      name: name,
      value: value,
      dimensions: dimensions,
      type: type
    }
  end

  @doc """
  Declares Prometheus metrics, if they doesn't exist, and records them for the provided type.
  Metrics are recorded in Prometheus in the following format.
  `{namespace}_{metric.name}`
  Spaces are replaced with underscores for compatibility with Prometheus.
  """
  def record_metrics(metrics, namespace) do
    metrics
    |> Enum.map(fn metric -> record_metric(metric, namespace) end)
    |> Enum.reduce({:ok, []}, &prometheus_to_collector_reducer/2)
  end

  defp record_metric(%{type: :count} = metric, namespace) do
    record_metric(metric, namespace, Counter, :inc)
  end

  defp record_metric(%{type: :gauge} = metric, namespace) do
    record_metric(metric, namespace, Gauge, :set)
  end

  defp record_metric(metric, namespace, prometheus_module, prometheus_func) do
    prometheus_metric_name = prometheus_metric_name(namespace, metric.name)

    declare_metric(prometheus_metric_name, metric.dimensions, prometheus_module)

    try do
      apply(prometheus_module, prometheus_func, [
        [name: prometheus_metric_name, labels: Keyword.values(metric.dimensions)],
        metric.value
      ])
    rescue
      e -> {:error, e}
    end
  end

  defp prometheus_metric_name(namespace, name) do
    (namespace <> "_" <> name)
    |> String.replace(" ", "_")
  end

  defp declare_metric(name, dimensions, prometheus_module) do
    apply(prometheus_module, :declare, [[name: name, labels: Keyword.keys(dimensions), help: ""]])
  end

  defp prometheus_to_collector_reducer(:ok, {:ok, term}) do
    {:ok, term}
  end

  defp prometheus_to_collector_reducer({:error, reason}, _acc) do
    {:error, reason}
  end

  defp prometheus_to_collector_reducer(_result, acc) do
    acc
  end
end
