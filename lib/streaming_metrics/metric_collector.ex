defmodule StreamingMetrics.MetricCollector do
  @moduledoc """
  All modules implementing a MetricCollector must define the callbacks specified in this module.
  """

  @type metric :: term
  @type metric_name :: String.t()
  @type dimensions :: keyword(String.t())
  @type unit :: String.t()
  @type namespace :: String.t()

  @callback init() :: :ok | {:error, term}
  @callback count_metric(integer, metric_name, dimensions, DateTime.t()) :: metric
  @callback gauge_metric(number, metric_name, dimensions, unit, DateTime.t()) :: metric
  @callback record_metrics([metric], namespace) :: {:ok, term} | {:error, term}
end
