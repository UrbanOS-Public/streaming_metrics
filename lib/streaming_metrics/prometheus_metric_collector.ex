defmodule StreamingMetrics.PrometheusMetricCollector do
  @moduledoc """
  Prometheus backend.

  It is the client's responsibility to expose the metrics
  to prometheus via a scrape endpoint or the Pushgateway.
  This module simply creates and increments the counters.
  """
  @behaviour StreamingMetrics.MetricCollector

  require Logger

  def init() do
    :ok
  end

  @doc """
  Formats info into a format `record_metrics` understands.
  `timestamp` is ignored because Prometheus handles timestamps.
  """
  def count_metric(count, name, dimensions \\ [], _timestamp \\ []) do
    %{
      name: name,
      value: count,
      dimensions: dimensions
    }
  end

  @doc """
  Declares Prometheus counter metrics, if it doesn't exist, and increments them.
  Metrics are recorded in Prometheus in the following format.
  `{namespace}_{metric.name}`
  Spaces are replaced with underscores for compatibility with Prometheus.
  """
  def record_metrics(metrics, namespace) do
    metrics
    |> Enum.map(fn metric -> record_metric(metric, namespace) end)
    |> Enum.reduce({:ok, []}, &prometheus_to_collector_reducer/2)
  end

  defp record_metric(metric, namespace) do
    prometheus_metric = Map.put(metric, :name, prometheus_metric_name(namespace, metric.name))

    :prometheus_counter.declare(
      name: prometheus_metric.name,
      labels: Keyword.keys(prometheus_metric.dimensions),
      help: ""
    )

    increment_counter(prometheus_metric)
  end

  defp prometheus_metric_name(namespace, name) do
    (namespace <> "_" <> name)
    |> String.replace(" ", "_")
  end

  defp increment_counter(metric) do
    try do
      labels = Keyword.values(metric.dimensions)
      :prometheus_counter.inc(metric.name, labels, metric.value)
    rescue
      e in ErlangError -> {:error, e}
    end
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
