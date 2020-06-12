defmodule Datastore.Dts.Mutation do
  @moduledoc false

  # todo: Add typespecs
  def build(:insert, entity) do
    %{
      insert: entity
    }
  end

end
