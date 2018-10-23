defmodule StreamingMetrics do
  @moduledoc false
  use Application

  def start(_type, _args) do
    Application.get_env(:streaming_metrics, :collector, StreamingMetrics.ConsoleMetricCollector).init()  

    children = [
      StreamingMetrics.Hostname
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
