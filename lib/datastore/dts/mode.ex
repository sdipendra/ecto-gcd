defmodule Datastore.Dts.Mode do
  @moduledoc false

  @enum %{
    transactional: "TRANSACTIONAL",
    non_transactional: "NON_TRANSACTIONAL"
  }

  def enum(key) do
    case @enum do
      %{^key => value} -> {:ok, value}
      _ -> {:error, "Key not found"}
    end
  end
end
