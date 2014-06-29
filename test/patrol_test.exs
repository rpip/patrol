defmodule PatrolTest do
  use ExUnit.Case
  use Patrol


  setup do
    sb = %Sandbox{}

    {:ok, [sandbox: sb]}
  end

  test "create sandbox" do
    sb = Patrol.create_sandbox()
    assert(is_function(sb))
  end

  test "sandbox simple addition is true" do
    sb = Patrol.create_sandbox
    assert {:ok, 4} == sb.("1 + 3")
  end

  test "custom sandbox", ctx do
    assert {:ok, _version} = Patrol.eval("System.version", ctx[:sandbox])
  end

  test "sandbox use standard IO" do
    sb = %Sandbox{io: :stdio}
    assert Patrol.eval("IO.puts('Hello world from Patrol!')", sb)
  end

  test "redirect IO to a file" do
       io_file = "test/fixtures/stdio.txt"

       sb = %Sandbox{io: File.open!(io_file, [:write, :read])}
       msg = "Hello world from Patrol!"
       {:ok, :ok} = Patrol.eval("IO.puts('#{msg}')", sb)
       contents = File.read!(io_file)
       assert String.strip(contents) == msg
  end

  test "eval quoted expression" do
    sb = Patrol.create_sandbox
    contents = quote do: Enum.map(1..5, &(&1 + 1))
    assert {:ok, [2, 3, 4, 5, 6]} = sb.(contents)
  end

  test "timeout" do
    sb = %Sandbox{timeout: 6000}
    quoted_expr = quote do: Enum.map(1..9999999999, &(IO.puts &1))
    assert {:error, {:timeout, true}} = Patrol.eval(quoted_expr, sb)
  end

  test "undef local function call" do
    assert {:error, {:undef, {:local, _error_msg}}} =  Patrol.eval("foobar(:foo, :bar)")
  end

  test "undef remote function call" do
    assert {:error, {:undef, {:remote, _error_msg}}} =  Patrol.eval("File.bar(:foo, :bar)")
  end

end
