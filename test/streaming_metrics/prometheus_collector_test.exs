defmodule PrometheusMetricCollectorTest do
  use ExUnit.Case
  require Logger
  use Prometheus.Metric

  alias StreamingMetrics.PrometheusMetricCollector, as: MetricCollector

  setup do
    namespace = "some_namespace"
    metric_name = "MetricName"
    metric_dimensions = [foo: "bar"]
    prometheus_metric_name = namespace <> "_" <> metric_name

    on_exit(fn ->
      Prometheus.Registry.clear()
    end)

    [
      namespace: namespace,
      metric_name: metric_name,
      metric_dimensions: metric_dimensions,
      prometheus_metric_name: prometheus_metric_name
    ]
  end

  describe("count_metric") do
    test "Has MetricName of 'MetricName'", context do
      %{name: name} = MetricCollector.count_metric(1, context.metric_name)
      assert context.metric_name == name
    end

    test "Specifies the record count", context do
      %{value: value} = MetricCollector.count_metric(42, context.metric_name)
      assert 42 == value
    end

    test "Specifies the dimensions", context do
      %{dimensions: actual_dimensions} =
        MetricCollector.count_metric(12, context.metric_name, context.metric_dimensions)

      assert context.metric_dimensions == actual_dimensions
    end

    test "has the correct type", context do
      %{type: type} = MetricCollector.count_metric(1, context.metric_name)
      assert :count == type
    end
  end

  describe("gauge_metric") do
    test "has the expected metric name", context do
      %{name: name} = MetricCollector.gauge_metric(1, context.metric_name)
      assert context.metric_name == name
    end

    test "has the expected gauge value", context do
      %{value: value} = MetricCollector.gauge_metric(42, context.metric_name)
      assert 42 == value
    end

    test "has the expected dimensions", context do
      %{dimensions: actual_dimensions} =
        MetricCollector.gauge_metric(12, context.metric_name, context.metric_dimensions)

      assert context.metric_dimensions == actual_dimensions
    end

    test "has the correct type", context do
      %{type: type} = MetricCollector.gauge_metric(1, context.metric_name)
      assert :gauge == type
    end
  end

  describe("record_metrics") do
    test "returns {:ok, []}", context do
      metric = MetricCollector.count_metric(3, context.metric_name)
      assert {:ok, []} = MetricCollector.record_metrics([metric], context.namespace)
    end

    test "Replaces spaces in metric.name with underscores", context do
      # This is for compatability with prometheus
      # Prometheus metric names must match the following regex
      # ^[a-zA-Z_:][a-zA-Z0-9_:]*$

      metric = MetricCollector.count_metric(37, "Metric Name")
      {:ok, []} = MetricCollector.record_metrics([metric], context.namespace)

      assert 37 == Counter.value(name: "some_namespace_Metric_Name")
    end

    test "Replaces spaces in namespace with underscores", context do
      metric = MetricCollector.count_metric(42, context.metric_name)
      {:ok, []} = MetricCollector.record_metrics([metric], "some namespace")

      assert 42 == Counter.value(name: context.prometheus_metric_name)
    end

    test "Namespace is prepended to the metric name", context do
      metric = MetricCollector.count_metric(3, context.metric_name)
      {:ok, []} = MetricCollector.record_metrics([metric], context.namespace)

      assert 3 == Counter.value(name: context.prometheus_metric_name)
    end

    test "Uses dimensions as Prometheus labels", context do
      metric = MetricCollector.count_metric(5, context.metric_name, somelabel: "blue")
      {:ok, []} = MetricCollector.record_metrics([metric], context.namespace)

      assert 5 == Counter.value(name: context.prometheus_metric_name, labels: ["blue"])
    end

    test "when value is not a number, returns {:error, reason}", context do
      metric = MetricCollector.count_metric(:nan, context.metric_name)

      {:error, _reason} = MetricCollector.record_metrics([metric], context.namespace)
    end

    test "when one metric is okay, but another is not returns {:error, reason}", context do
      metrics = [
        MetricCollector.count_metric(3, "FooCount"),
        MetricCollector.count_metric(:nan, "FooCount")
      ]

      {:error, _reason} = MetricCollector.record_metrics(metrics, context.namespace)
    end

    test "gauge metric is set via the prometheus gauge API", context do
      metric =
        MetricCollector.gauge_metric(56_789_456, context.metric_name, context.metric_dimensions)

      {:ok, []} = MetricCollector.record_metrics([metric], context.namespace)

      assert 56_789_456 ==
               Gauge.value(
                 name: context.prometheus_metric_name,
                 labels: Keyword.values(context.metric_dimensions)
               )
    end

    test "mixed metrics are recorded via their respective APIs", context do
      count_metric =
        MetricCollector.count_metric(1, context.metric_name, context.metric_dimensions)

      gauge_metric =
        MetricCollector.gauge_metric(32.3333, context.metric_name, context.metric_dimensions)

      {:ok, []} = MetricCollector.record_metrics([gauge_metric, count_metric], context.namespace)

      assert 1 ==
               Counter.value(
                 name: context.prometheus_metric_name,
                 labels: Keyword.values(context.metric_dimensions)
               )

      assert 32.3333 ==
               Gauge.value(
                 name: context.prometheus_metric_name,
                 labels: Keyword.values(context.metric_dimensions)
               )
    end
  end

  describe("init") do
    test "no ops" do
      :ok = MetricCollector.init()
    end
  end
end
