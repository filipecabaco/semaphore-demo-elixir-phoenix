defmodule Demo.Demo do
  @moduledoc false
  def sql_injection(query), do: Demo.Repo.query(query)
  def bad_atom(string), do: String.to_atom(string)
end
