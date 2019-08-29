defmodule AwsMetricCollectorTest do
  use ExUnit.Case, async: false
  import Mock
  alias StreamingMetrics.AwsMetricCollector, as: MetricCollector

  @inbound_records "Inbound Records"

  describe("count_metric") do
    test "Has MetricName of 'Inbound Records'" do
      %{metric_name: name} = MetricCollector.count_metric(1, @inbound_records)
      assert "Inbound Records" == name
    end

    test "Specifies the record count" do
      expected_count = 32
      %{value: actual_count} = MetricCollector.count_metric(expected_count, @inbound_records)
      assert expected_count == actual_count
    end

    test "Specifies the dimensions" do
      expected_dimensions = [{Foo, "bar"}]

      %{dimensions: actual_dimensions} =
        MetricCollector.count_metric(12, @inbound_records, expected_dimensions)

      assert expected_dimensions == actual_dimensions
    end

    test "Specifies the date" do
      expected_timestamp = DateTime.from_iso8601("2018-08-09T13:18:20Z")

      %{timestamp: actual_timestamp} =
        MetricCollector.count_metric(12, @inbound_records, [], expected_timestamp)

      assert expected_timestamp == actual_timestamp
    end

    test "Has a unit of 'Count'" do
      %{unit: unit} = MetricCollector.count_metric(27, @inbound_records)
      assert "Count" == unit
    end
  end

  describe("gauge_metric") do
    test "returns the expected mapped values" do
      expected_timestamp = DateTime.from_iso8601("2018-08-09T13:18:20Z")
      expected_dimensions = [{Foo, "bar"}]
      expected_unit = "Pies"

      actual =
        MetricCollector.gauge_metric(
          12,
          @inbound_records,
          expected_dimensions,
          expected_unit,
          expected_timestamp
        )

      expected = %{
        metric_name: @inbound_records,
        value: 12,
        unit: expected_unit,
        timestamp: expected_timestamp,
        dimensions: expected_dimensions
      }

      assert expected == actual
    end

    test "provides reasonable defaults" do
      %{unit: unit, timestamp: timestamp, dimensions: dimensions} =
        MetricCollector.gauge_metric(12, @inbound_records)

      assert "None" == unit
      assert %DateTime{} = timestamp
      assert [] == dimensions
    end
  end

  describe "record_metrics" do
    test "returns {:ok, ExAws.request_result}" do
      response = {
        :ok,
        %{
          body: %{request_id: "string of chars"},
          headers: [],
          status_code: 200
        }
      }

      with_mock ExAws, request: fn _op_query -> response end do
        metric = MetricCollector.count_metric(3, "Foo Count")
        assert MetricCollector.record_metrics([metric], "some namespace") == response
      end
    end

    test "returns {:error, {:http_error, reason}}" do
      response = {:error, {:http_error, "reason"}}

      with_mock ExAws, request: fn _op_query -> response end do
        metric = MetricCollector.count_metric(3, "Foo Count")
        assert MetricCollector.record_metrics([metric], "some namespace") == response
      end
    end
  end

  describe "init" do
    @url "http://169.254.169.254/latest/meta-data/placement/availability-zone/"

    test "when the instance metadata is available, use it" do
      with_mocks([
        {HTTPoison, [],
         [
           get: fn _url ->
             {:ok,
              %HTTPoison.Response{
                body: "us-west-2b",
                status_code: 200
              }}
           end
         ]}
      ]) do
        MetricCollector.init()
        assert called(HTTPoison.get(@url))
        assert Application.get_env(:ex_aws, :region) == "us-west-2"
      end
    end

    test "when instance metadata gives a non-200 response, use default region" do
      with_mocks([
        {HTTPoison, [],
         [
           get: fn _url ->
             {:ok,
              %HTTPoison.Response{
                body: "not found",
                status_code: 404
              }}
           end
         ]}
      ]) do
        region_before_init = Application.get_env(:ex_aws, :region)

        MetricCollector.init()

        assert called(HTTPoison.get(@url))
        assert region_before_init == Application.get_env(:ex_aws, :region)
      end
    end

    test "when instance metadata gives an error tuple, use default region" do
      with_mocks([
        {
          HTTPoison,
          [],
          [
            get: fn _url -> {:error, %HTTPoison.Error{id: nil, reason: :connect_timeout}} end
          ]
        }
      ]) do
        region_before_init = Application.get_env(:ex_aws, :region)

        MetricCollector.init()

        assert called(HTTPoison.get(@url))
        assert region_before_init == Application.get_env(:ex_aws, :region)
      end
    end
  end
end
