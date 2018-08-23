# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger,
  backends: [:console],
  level: :info,
  compile_time_purge_level: :info

config :ex_aws,
  region: "us-east-2"

import_config "test.exs"
