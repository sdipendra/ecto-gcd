defmodule Datastore.Dts.Key do
  @moduledoc false

  @derive {Jason.Encoder, only: [:partitionId, :path]}
  @enforce_keys [:partitionId, :path]
  defstruct [:partitionId, :path]

end
