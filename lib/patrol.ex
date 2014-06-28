defmodule Patrol do
  @moduledoc """
  This module contains helpers for creating a sandbox environment
  for safely executing untrusted Elixir code.

  ## Creating a sandbox

  You can create multiple sandboxes for code execution.

  This is useful for implementing a different user access level sandboxes.

      iex> sb_users = %Sandbox{allowed_locals: []}
      iex> sb_root = %Sandbox{}
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

  alias Patrol.Sandbox
  alias Patrol.Policy

  @io_device "/dev/null"
  @rand_min  17
  @rand_max  8765432369987654
  @memory_check_interval 1000

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
    true
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

      iex> use Patrol
      iex> sb_users = %Sandbox{allowed_locals: []}
      iex> sb_root = %Sandbox{}
      iex> Patrol.eval("System.cmd('cat /etc/passwd')"), sb_root)
      MySQL Server,,,:/nonexistent:/bin/false:/jenkins:x:117:128:Jenkins....

      iex> Patrol.eval("Enum.map(File.ls("/"), &(File.rm!(&1)))", sb_user)
      ** (Patrol.PermissionError) You tripped the alarm! File.rm/1 is not allowed
  """
  def create_sandbox(sandbox \\ %Sandbox{}) when is_map(sandbox) do
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
  def eval(code, sandbox) when is_binary(code) do
    case Code.string_to_quoted(code) do
      { :ok, forms } ->
        # proceed to actual code evaluation
        do_eval(forms, sandbox)

      { :error, { line, error, token } } ->
        :elixir_errors.parse(line, "patrol", error, token)
    end
  end

  # when passed a quoted expression
  def eval(code, sandbox) when is_tuple(code) do
    do_eval(code, sandbox)
  end

  defp do_eval(forms, sandbox) do
    unless is_safe?(forms, sandbox) do
      raise Patrol.PermissionError, Macro.to_string(forms)
    end

    {pid, ref} = {self, make_ref}
    child_pid = create_eval_process(forms, sandbox, pid, ref)
    handle_eval_process(child_pid, sandbox, ref)
  end

  defp handle_eval_process(child_pid, sandbox, ref) do
    receive do
      {:ok, ^ref, {result, _ctx}} ->
        Process.exit(child_pid, :kill)
        unless nil?(sandbox.transform) do
          {:ok, sandbox.transform.(result)}
        else
          {:ok, result}
        end
      error ->
        {:error, error}
    after
      sandbox.timeout ->
        # kill the child process and return
        {:error, {:timeout, Process.exit(child_pid, :kill)}}
    end
  end

  defp create_eval_process(forms, sandbox, parent_pid, ref) do
    proc = fn ->
                cond do
                  is_pid(sandbox.io) && Process.alive?(sandbox.io) ->
                    Process.group_leader(self, sandbox.io)
                  nil?(sandbox.io) ->
                    # redirect all IO to the default IO ("/dev/null")
                    io_device = File.open!(@io_device, [:write, :read])
                    Process.group_leader(self, io_device)
                  sandbox.io == :stdio ->
                    nil
                  true ->
                    raise """
                          Expected a live process or :stdio as sandbox IO device,
                          but got '#{sandbox.io}'.
                          """
                end

                # eval code
                send(parent_pid, {:ok, ref, Code.eval_quoted(forms, sandbox.context, __ENV__)})
           end
    # spawn process and return the pid
    spawn(proc)
  end

end
