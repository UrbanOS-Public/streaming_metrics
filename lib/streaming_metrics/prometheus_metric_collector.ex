defmodule StreamingMetrics.PrometheusMetricCollector do
  @moduledoc """
  Prometheus backend.

  It is the client's responsibility to expose the metrics
  to prometheus via a scrape endpoint or the Pushgateway.
  This module simply creates and increments the counters.
  """
  @behaviour StreamingMetrics.MetricCollector

  require Logger

  @doc """
  Always returns `:ok`
  """
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
    metrics =
      metrics
      |> Enum.map(fn metric ->
        Map.put(metric, :name, prometheus_metric_name(namespace, metric.name))
      end)

    metrics
    |> Enum.each(
      &:prometheus_counter.declare(
        name: &1.name,
        labels: Keyword.keys(&1.dimensions),
        help: ""
      )
    )

    metrics
    |> Enum.map(&increment_counter(&1, namespace))
    |> Enum.reduce({:ok, []}, &prometheus_to_collector_reducer/2)
  end

  defp prometheus_metric_name(namespace, name) do
    (namespace <> "_" <> name)
    |> String.replace(" ", "_")
  end

  defp increment_counter(metric, namespace) do
    try do
      labels = Keyword.values(metric.dimensions)
      :prometheus_counter.inc(metric.name, labels, metric.value)
    rescue
      e in ErlangError -> {:error, e}
    end
  end

  defp prometheus_to_collector_reducer(result, acc) do
    # Translates prometheus results to StreamingMetrics.MetricCollector results
    with {:ok, term} <- acc,
         :ok <- result,
         do: {:ok, term}
  end
end
