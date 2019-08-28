defmodule StreamingMetrics.AwsMetricCollector do
  @moduledoc """
  A module for collecting metrics and sending them to AWS Cloudwatch.
  """
  @behaviour StreamingMetrics.MetricCollector

  require Logger

  def init() do
    set_region_if_running_on_aws()
    :ok
  end

  @doc """
  Create the metrics that will later be sent to AWS Cloudwatch.
  """
  def count_metric(count, name, dimensions \\ [], timestamp \\ DateTime.utc_now()) do
    format_metric(count, name, dimensions, "Count", timestamp)
  end

  @doc """
  Create the metrics that will later be sent to AWS Cloudwatch.
  """
  def gauge_metric(value, name, dimensions \\ [], unit \\ "None", timestamp \\ DateTime.utc_now()) do
    format_metric(value, name, dimensions, unit, timestamp)
  end

  defp format_metric(value, name, dimensions, unit, timestamp) do
    %{
      metric_name: name,
      value: value,
      unit: unit,
      timestamp: timestamp,
      dimensions: dimensions
    }
  end

  @doc """
  Persist metrics to AWS Cloudwatch
  """
  def record_metrics(metrics, namespace) do
    metrics
    |> ExAws.Cloudwatch.put_metric_data(namespace)
    |> ExAws.request()
  end

  defp set_region_if_running_on_aws() do
    default_region = Application.get_env(:ex_aws, :region)

    case HTTPoison.get("http://169.254.169.254/latest/meta-data/placement/availability-zone/") do
      {:ok, %HTTPoison.Response{status_code: 200, body: availability_zone}} ->
        availability_zone
        |> remove_last_char
        |> set_aws_region

      {:ok, %HTTPoison.Response{status_code: error_code}} ->
        Logger.warn(
          failed_to_obtain_aws_region_message("HTTP Status: #{error_code}", default_region)
        )

      {:error, reason} ->
        Logger.warn(
          failed_to_obtain_aws_region_message("Reason: #{inspect(reason)}", default_region)
        )
    end
  end

  defp set_aws_region(region) do
    Application.put_env(:ex_aws, :region, region)
  end

  defp remove_last_char(string) do
    string |> String.slice(0..-2)
  end

  defp failed_to_obtain_aws_region_message(message, default_region) do
    "Failed to obtain AWS region. #{message}. Defaulting to #{default_region}."
  end
end
