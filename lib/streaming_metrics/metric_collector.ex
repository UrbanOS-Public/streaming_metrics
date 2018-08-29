defmodule StreamingMetrics.MetricCollector do
  @type metric :: term

  @callback init() :: :ok | {:error, term}
  @callback count_metric(integer, String.t(), [{String.t(), String.t()}], DateTime.t()) :: metric
  @callback record_metrics([metric], String.t()) :: {:ok, term} | {:error, term}
end
