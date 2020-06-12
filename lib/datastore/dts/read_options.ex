defmodule Datastore.Dts.ReadOptions do
  @moduledoc false

  @derive {Jason.Encoder, only: [:readConsistency]}
  defstruct [:readConsistency]

end
