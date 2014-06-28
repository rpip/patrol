defmodule Patrol.PermissionError do
  @moduledoc """
  Exception to be thrown when a code contains a restricted code
  """

  defexception [:message]

  def exception(code) do
    msg = "You tripped the alarm! \n #{code} is not allowed"
    %Patrol.PermissionError{message: msg}
  end
end
