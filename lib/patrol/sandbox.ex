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

  @timeout 50000

  defstruct policy:    nil,
            timeout:   @timeout,
            transform: nil,
            io:        nil,
            context:   []
end