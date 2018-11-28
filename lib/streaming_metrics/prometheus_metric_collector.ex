defmodule StreamingMetrics.PrometheusMetricCollector do
  @moduledoc false
  @behaviour StreamingMetrics.MetricCollector

  require Logger

  def init() do
    :ok
  end

  def count_metric(count, name, dimensions \\ [], _timestamp \\ []) do
    %{
      name: name,
      value: count,
      dimensions: dimensions
    }
  end

  def record_metrics(metrics, namespace) do
    metrics =
      metrics
      |> Enum.map(&Map.put(&1, :name, prometheus_metric_name(namespace, &1.name)))

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
