import Config

config :demo, Demo.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warn

config :junit_formatter,
  report_file: "junit.xml",
  report_dir: "/tmp",
  print_report_file: true,
  include_filename?: true,
  include_file_line?: true
