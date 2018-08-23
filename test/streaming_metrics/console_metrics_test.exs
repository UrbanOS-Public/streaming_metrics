defmodule ConsoleMetricCollectorTest do
  use ExUnit.Case
  alias StreamingMetrics.ConsoleMetricCollector, as: MetricCollector

  describe "init" do
    test "always returns :ok" do
      assert :ok == MetricCollector.init()
    end
  end

  describe "record_metrics" do
    test "returns {:ok, metrics}" do
      {:ok, _metrics} = MetricCollector.record_metrics(["some metric"], "some namespace")
    end
  end
end

