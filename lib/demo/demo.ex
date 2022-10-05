defmodule Demo.Demo do
  def sql_injection(query), do: Demo.Repo.query(query)
end
