defmodule Datastore.Dts.PathElement do
  @moduledoc false

  @derive {Jason.Encoder, only: [:kind, :name]}
  @enforce_keys [:kind, :name]
  defstruct [:kind, :name]

end
