defmodule Patrol do
  @moduledoc """
  This module contains helpers for creating a sandbox environment
  for safely executing untrusted code.

  ## Creating a sandbox

  You can create multiple sandboxes for code execution.

  This is useful for implementing a different user access level sandboxes.

      iex> sb_users = %Patrol.Sandbox{allowed_locals: []}
      iex> sb_root = %Patrol.Sandbox{}
      iex> Patrol.eval("Enum.map(1..5, &(&1 + 3))", sb_root)
      [4, 5, 6, 7, 8]
      iex> Patrol.eval("Enum.map(File.ls("/"), &(File.rm!(&1)))", sb_user)
      ** (Patrol.PermissionError) You tripped the alarm! File.ls/1 is not allowed

  ## Creating self-contained sandboxed environments

  These self-contained sandboxes are anonymous functions that can run multiple
  codes with the same configuration.

  In most cases,especially for simplicity, this what you should use.

      iex> use Patrol
      iex> sb = Patrol.create_sandbox()
      iex> sb.('File.mkdir_p("/media/foo")')
      ** (Patrol.PermissionError) You tripped the alarm! File.mkdir_p/1 is not allowed

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

  ## Creating a self-contained sandbox

      iex> use Patrol
      iex> policy = %Policy{allowed_non_local: [Bitwise: :all, System: [:version]]}
      iex> sb = Patrol.create_sandbox([policy: policy, timeout: 2000])
      iex> sb.(System.version)
      { :ok, "0.14.2-dev" }


      iex> sb.eval("Code.loaded_files")
      ** (Patrol.PermissionError) You tripped the alarm! Code.loaded_files() is not allowed


  ## To run the same code in multiple sandboxes

      iex> sb_users = %Patrol.Sandbox{allowed_locals: []}
      iex> sb_root = %Patrol.Sandbox{}
      iex> Patrol.eval("System.cmd('cat /etc/passwd')"), sb_root)
      MySQL Server,,,:/nonexistent:/bin/false:/jenkins:x:117:128:Jenkins....

      iex> Patrol.eval("Enum.map(File.ls("/"), &(File.rm!(&1)))", sb_user)
      ** (Patrol.PermissionError) You tripped the alarm! File.rm/1 is not allowed
  """
  def create_sandbox(sandbox \\ %Patrol.Sandbox{}) when is_map(sandbox) do
      fn code -> eval(code, sandbox) end
  end

  @doc """
  Evaluate the code within the sandbox

  ## Examples

      iex> use Patrol
      iex> sb = Patrol.create_sandbox()
      iex> sb.('File.mkdir_p("/media/foo")')
      ** (Patrol.PermissionError) You tripped the alarm! File.mkdir_p/1 is not allowed
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
