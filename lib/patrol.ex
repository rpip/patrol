defmodule Patrol do
  @moduledoc """
  This module contains helpers for creating a sandbox environment
  for safely executing untrusted code.
  """
  @rand_min  17
  @rand_max  8765432369987654

  defmacro __using__(_opts \\ []) do
    quote do
      require Patrol
      alias Patrol.Policy
      alias Patrol.Sandbox
      alias Patrol.PermissionError
    end
  end

  @doc """
  Walk the bytecode AST and catch blacklisted function calls
  """
  def is_safe?(forms, _sandbox) do
    nil
  end

  @doc """
  Convenience wrapper function around %Patrol.Sandbox{} for creating a sandboxed
  environment. It returns a self-contained module with an **eval** method for code
  evaluation

  ## Examples

      iex> use Patrol
      iex> policy = %Policy{allowed_non_local: [Bitwise: :all, System: [:version]]}
      iex> sb = sandbox([policy: policy, timeout: 2000])
      iex> sb.eval(System.version)
      { :ok, result }


      iex> sb.eval(Code.loaded_files)
      ** (Patrol.Exception) You tripped the alarm! Code.loaded_files() is not allowed


  ### To run the same code in multiple sandboxes

      iex> sb_users = %Patrol.Sandbox{allowed_locals: []}
      iex> sb_root = %Patrol.Sandbox{}
      iex> Patrol.eval(Enum.map(1..5, &(&1 + 3)))
      [4, 5, 6, 7, 8]
  """
  def create_sandbox(sandbox \\ %Patrol.Sandbox{}) when is_map(sandbox) do
      fn code -> eval(code, sandbox) end
  end

  @doc """
  Evaluate the
  """
  def eval(code_str, sandbox) do
    case Code.string_to_quoted(code_str) do
      { :ok, forms } ->
        unless is_safe?(forms, sandbox) do
          raise Patrol.PermissionError, code_str
        end

        # proceed to actual code evaluation
        do_eval(forms, sandbox)

      { :error, { line, error, token } } ->
        :elixir_errors.parse(line, "patrol", error, token)
    end
  end

  defp do_eval(form, sandbox) do
    []
  end

end
