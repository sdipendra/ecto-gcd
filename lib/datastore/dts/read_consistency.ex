defmodule Datastore.Dts.ReadConsistency do
  @moduledoc false

  @enum %{
    strong: "STRONG",
    eventual: "EVENTUAL"
  }

  def enum(key) do
    case @enum do
      %{^key => value} -> {:ok, value}
      _ -> {:error, "Key not found"}
    end
  end

end
