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

  require Patrol.Policy

  @timeout 5000
  @memory_limit 5 * 1_024_000 # 5MB
  @range_min 0
  @range_max 1000

  defstruct policy:    %Patrol.Policy{},
            timeout:   @timeout,
            transform: nil,
            io:        nil,
            memory:    @memory_limit,
            range_min: @range_min,
            range_max: @range_max,
            context:   []


  @doc """
  Returns the default memory limit
  """
  def memory_limit, do: @memory_limit

end