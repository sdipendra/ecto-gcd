defmodule Datastore.Dts.PartitionId do
  @moduledoc false

  @derive {Jason.Encoder, only: [:projectId, :namespaceId]}
  @enforce_keys [:projectId]
  defstruct [:projectId, :namespaceId]

end
