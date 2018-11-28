defmodule StreamingMetrics.PrometheusMetricCollector do
  @moduledoc false
  @behaviour StreamingMetrics.MetricCollector

  require Logger

  def init() do
    :ok
  end

  def count_metric(count, name, dimensions \\ [], _timestamp \\ []) do
    %{
      metric_name: name,
      value: count,
      dimensions: dimensions
    }
  end

  def record_metrics(metrics, namespace) do
    metrics
    |> Enum.map(fn metric ->
      :prometheus_counter.declare(
        name: prometheus_metric_name(namespace, metric[:metric_name]),
        labels: Keyword.keys(metric[:dimensions]),
        help: ""
      )
    end)

    metrics
    |> Enum.map(&increment_counter(&1, namespace))
    |> Enum.reduce(
      {:ok, []},
      fn result, acc ->
        with {:ok, term} <- acc,
             :ok <- result,
             do: {:ok, term},
             else: (err -> err)
      end
    )
  end

  defp increment_counter(metric, namespace) do
    try do
      metric_name = prometheus_metric_name(namespace, metric[:metric_name])
      labels = Keyword.values(metric[:dimensions])

      :prometheus_counter.inc(metric_name, labels, metric[:value])
    rescue
      e in ErlangError -> {:error, e}
    end
  end

  defp prometheus_metric_name(namespace, name) do
    namespace <> "_" <> name
    |> String.replace(" ", "_")
  end
end
