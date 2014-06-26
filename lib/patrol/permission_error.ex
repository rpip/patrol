defmodule Patrol.PermissionError do
  @moduledoc """
  Exception to be thrown when a code contains a restricted code
  """
  defexception [:message]

  def exception(value) do
    msg = "You tripped the alarm! \n #{Macro.to_string value} is not allowed"
    %Patrol.PermissionError{message: msg}
  end
end
