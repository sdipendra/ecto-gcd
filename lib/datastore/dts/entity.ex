defmodule Datastore.Dts.Entity do
  @moduledoc false

  # todo: Remove this entire module once done.
  @derive {Jason.Encoder, only: [:key, :properties]}
  @enforce_keys [:key, :properties]
  defstruct [:key, :properties]

end
