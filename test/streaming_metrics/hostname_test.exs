defmodule StreamingMetrics.HostnameTest do
  use ExUnit.Case

  @hostname "foobar"

  setup_all do
    System.put_env("HOSTNAME", @hostname)
    {:ok, hostname} = StreamingMetrics.Hostname.start_link([])
    %{hostname: hostname}
  end

  test "agent gets the correct hostname", %{hostname: hostname} do
    hostname = StreamingMetrics.Hostname.get()
    assert hostname == @hostname
  end
end
