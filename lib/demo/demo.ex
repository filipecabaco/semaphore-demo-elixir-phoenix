defmodule BadCredo do
  @moduledoc false
  def bad_atom(string), do: String.to_atom(string)
  def leaky(executable, arguments), do: System.cmd(executable, arguments)
  def bad_exec, do: :os.cmd("ls")
end
