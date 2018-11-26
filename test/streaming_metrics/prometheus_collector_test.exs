defmodule PrometheusMetricCollectorTest do
  use ExUnit.Case
  require Logger

  alias StreamingMetrics.PrometheusMetricCollector, as: MetricCollector

  setup do
    metric_name = "MetricName"

    on_exit(fn ->
      :prometheus_gauge.deregister(metric_name)
    end)

    [metric_name: metric_name]
  end

  describe("count_metric") do
    test "Has MetricName of 'MetricName'", context do
      %{metric_name: name} = MetricCollector.count_metric(1, context.metric_name)
      assert context.metric_name == name
    end

    test "Specifies the record count", context do
      %{value: value} = MetricCollector.count_metric(42, context.metric_name)
      assert 42 == value
    end

    test "Specifies the dimensions", context do
      expected_dimensions = [foo: "bar"]

      %{dimensions: actual_dimensions} =
        MetricCollector.count_metric(12, context.metric_name, expected_dimensions)

      assert expected_dimensions == actual_dimensions
    end
  end

  describe("record_metrics") do
    setup do
      [namespace: "some_namespace"]
    end

    test "returns {:ok, []}", context do
      metric = MetricCollector.count_metric(3, context.metric_name)
      assert {:ok, []} = MetricCollector.record_metrics([metric], context.namespace)
    end

    test "Label is created for the namespace", context do
      metric = MetricCollector.count_metric(3, context.metric_name)
      {:ok, []} = MetricCollector.record_metrics([metric], context.namespace)

      assert 3 == :prometheus_gauge.value(metric[:metric_name], [context.namespace])
    end

    test "Uses dimensions as Prometheus labels", context do
      metric = MetricCollector.count_metric(5, context.metric_name, somelabel: "blue")
      {:ok, []} = MetricCollector.record_metrics([metric], context.namespace)

      assert 5 == :prometheus_gauge.value(metric[:metric_name], [context.namespace, "blue"])
    end

    test "when value is not a number, returns {:error, reason}", context do
      metric = %{
        metric_name: "FooCount",
        value: :nan,
        dimensions: []
      }

      {:error, _reason} = MetricCollector.record_metrics([metric], context.namespace)
    end

    test "when one metric is okay, but another is not returns {:error, reason}", context do
      metrics = [
        MetricCollector.count_metric(3, "FooCount"),
        %{
          metric_name: "FooCount",
          value: :nan,
          dimensions: []
        }
      ]

      {:error, _reason} = MetricCollector.record_metrics(metrics, context.namespace)
    end
  end

  describe("init") do
    test "no ops" do
      :ok = MetricCollector.init()
    end
  end
end
