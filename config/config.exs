import Config

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :demo, ecto_repos: [Demo.Repo]

config :demo, Demo.Repo,
  database: "demo",
  username: "postgres",
  password: System.get_env("POSTGRES_PASSWORD"),
  hostname: "localhost"

import_config "#{Mix.env()}.exs"
