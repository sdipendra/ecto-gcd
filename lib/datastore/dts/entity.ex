defmodule Datastore.Dts.Entity do
  @moduledoc false

  @derive {Jason.Encoder, only: [:key, :properties]}
  @enforce_keys [:key, :properties]
  defstruct [:key, :properties]

end
