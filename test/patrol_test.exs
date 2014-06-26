defmodule PatrolTest do
  use ExUnit.Case
  use Patrol

  test "create sandbox module" do
    sb = Patrol.create_sandbox()
    sb.("System.halt")
  end
end
