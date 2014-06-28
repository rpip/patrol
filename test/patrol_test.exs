defmodule PatrolTest do
  use ExUnit.Case
  use Patrol


  setup do
    sb = Patrol.create_sandbox()

    {:ok, [sandbox: sb]}
  end

  test "create sandbox", ctx do
    assert(is_function(ctx[:sandbox]))
  end

  test "sandbox simple addition is true", ctx do
    assert {:ok, 4} == ctx[:sandbox].("1 + 3")
  end

  test "custom sandbox" do
    sb = %Patrol.Sandbox{}
    assert {:ok, _version} = Patrol.eval("System.version", sb)
  end

  test "sandbox use standard IO" do
    sb = %Patrol.Sandbox{io: :stdio}
    assert Patrol.eval("IO.puts('Hello world from Patrol!')", sb)
  end

  test "redirect IO to a file" do
       io_file = "test/fixtures/stdio.txt"

       sb = %Patrol.Sandbox{io: File.open!(io_file, [:write, :read])}
       msg = "Hello world from Patrol!"
       {:ok, :ok} = Patrol.eval("IO.puts('#{msg}')", sb)
       contents = File.read!(io_file)
       assert contents = msg
  end

  test "eval quoted expression", ctx do
    contents = quote do: Enum.map(1..5, &(&1 + 1))
    assert {:ok, [2, 3, 4, 5, 6]} = ctx[:sandbox].(contents)
  end

end
