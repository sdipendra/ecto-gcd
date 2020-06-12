defmodule Datastore.Request.Commit do
  @moduledoc false

  require Logger

  alias Datastore.Dts

  def build(mode, mutations) do
    %{
      "mode" => mode,
      "mutations" => mutations
    }
  end

  # todo: Do better handling and follow language conventions when passing and returning values from functions
  def create(project_id, kind, fields) do
    # todo: Maybe convert this into transactional
    {:ok, mode} = Dts.Mode.enum(:non_transactional)
    # todo: See if namespaceId should be added
    partition_id_0 = %Dts.PartitionId{projectId: project_id}
    path_element_0_0 = %Dts.PathElement{kind: kind, name: Keyword.get(fields, :name)}
    path = [path_element_0_0]
    key_0 = %Dts.Key{partitionId: partition_id_0, path: path}

    # todo: Implement something generic for properties
    # properties_0 = %{"password_hash" => %{"stringValue" => Keyword.get(fields, :password_hash)}}
    properties_0 = Dts.Properties.construct(fields)
    Logger.debug("properties_0: #{inspect properties_0}")

    entity_0 = %Dts.Entity{key: key_0, properties: properties_0}
    mutation_0 = Dts.Mutation.build(:insert, entity_0)
    mutations = [mutation_0]

    request = build(mode, mutations)

    {:ok, request}
  end
end
