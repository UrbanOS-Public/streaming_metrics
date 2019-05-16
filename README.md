[![Master](https://travis-ci.org/smartcitiesdata/streaming_metrics.svg?branch=master)](https://travis-ci.org/smartcitiesdata/streaming_metrics)
[![Hex.pm Version](http://img.shields.io/hexpm/v/streaming_metrics.svg?style=flat)](https://hex.pm/packages/streaming_metrics)

# Steaming Metrics

## Description

A library that interfaces with several metric recording backends.

## Installation

To add to your mix dependencies, add the following block to your mix.exs deps:

```elixir
def deps do
  [
    {:streaming_metrics, "~> 2.1.6"}
  ]
end
```

## Usage

This library can record metrics to AWS CloudWatch, Prometheus, or to the console. To specify this, put something like the below in your environment config file.
```
config :my_app,
  metric_collector: StreamingMetrics.ConsoleMetricCollector
```
or

```
config :my_app,
  metric_collector: StreamingMetrics.PrometheusMetricCollector
```

or

```
config :my_app,
  metric_collector: StreamingMetrics.AwsMetricCollector
```

Each collector implementation has two functions: 

- `record_metrics/2` takes an array of metrics and a namespace.
 - `count_metrics/3` takes an integer, a namespace, an optional array of dimensions (ex: `[{"DimensionName", "some dimension value"}]`), and an optional timestamp.

 ## License

SmartCity is released under the Apache 2.0 license - see the license at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)