defmodule StreamingMetrics.HostnameTest do
  use ExUnit.Case

  @hostname "foobar"

  setup_all do
    Agent.update(StreamingMetrics.Hostname, fn hostname -> @hostname end)
  end

  test "agent gets the correct hostname" do
    hostname = StreamingMetrics.Hostname.get()
    assert hostname == @hostname
  end
end
