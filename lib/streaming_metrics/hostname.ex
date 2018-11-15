defmodule StreamingMetrics.Hostname do
  @moduledoc """
  This module retrieves the node host's hostname.
  """

  use Agent

  def start_link(_opts) do
    hostname = System.get_env("HOSTNAME")
    Agent.start_link(fn -> hostname end, name: __MODULE__)
  end

  def get() do
    Agent.get(__MODULE__, fn name -> name end)
  end
end
