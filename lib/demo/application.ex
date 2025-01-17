defmodule Demo.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      Demo.Repo
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
