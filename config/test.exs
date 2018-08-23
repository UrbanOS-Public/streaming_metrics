use Mix.Config

config :ex_aws,
  access_key_id: "x",
  secret_access_key: "y",
  debug_requests: true

config :ex_aws, :monitoring,
  scheme: "http",
  host: "localhost",
  port: 4582

config :ex_aws, :retries,
  max_attempts: 30,
  base_backoff_in_ms: 1_000,
  max_backoff_in_ms: 1_000

