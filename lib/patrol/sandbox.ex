defmodule Patrol.Sandbox do
  @moduledoc """
  Sandbox for code execution

  Sandbox struct fields:

  * timeout

    Default is 10000 MS or 10 seconds. If the expression evaluated in the sandbox
    takes longer than the timeout, an error will be thrown and the thread running the code
    will be stopped.

  * transform

    A function to call on the result returned from the sandboxed code, before
    returning it, while still within the timeout context.

  * context

    Hashmap of values to inject into the code context
  """

  @timeout 5000
  @memory_limit 5 * 1_024_000 # 5MB

  defstruct policy:    nil,
            timeout:   @timeout,
            transform: nil,
            io:        nil,
            memory:    @memory_limit,
            context:   []


  @doc """
  Returns the default memory limit
  """
  def memory_limit, do: @memory_limit

end