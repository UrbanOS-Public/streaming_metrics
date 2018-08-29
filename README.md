# Metrics

## Description

A metric recording library.

## Installation

To add to your mix dependencies, add the following block to your mix.exs deps:
```
      {:streaming_metrics,
       {:streaming_metrics, path: "./streaming-metrics"},
       sha: "master",
       app: false}
```

## Usage

This library can record metrics either to AWS CloudWatch or to the console. To specify this, put either
```
config :my_app,
  metric_collector: StreamingMetrics.ConsoleMetricCollector
```

or

```
config :my_app,
  metric_collector: StreamingMetrics.AwsMetricCollector
```

in your environment config file. It has two functions, `record_metrics/2`, which takes an array of metrics and a namespace, and `count_metrics/3`, which takes an integer, a namespace, an optional array of dimensions (ex: `[{"DimensionName", "some dimension value"}]`), and an optional timestamp.