defmodule Datastore.Request.Lookup do
  @moduledoc false

  alias Datastore.Dts

  # todo: Modify this
  def build(read_options, keys) do
    %{readOptions: read_options,
      keys: keys}
  end

  # todo: Do better handling and follow language conventions when passing and returning values from functions
  # todo: Implement this
  def create(project_id, kind, params) do
    # todo: Maybe convert this into transactional
    {:ok, read_consistency} = Dts.ReadConsistency.enum(:eventual)
    read_options = %Dts.ReadOptions{readConsistency: read_consistency}
    # todo: See if namespaceId should be added
    partition_id_0 = %Dts.PartitionId{projectId: project_id}
    [name | params] = params
    path_element_0_0 = %Dts.PathElement{kind: kind, name: name}
    path = [path_element_0_0]
    key_0 = %Dts.Key{partitionId: partition_id_0, path: path}
    keys = [key_0]

    request_body = build(read_options, keys)

    {:ok, request_body}
  end

  defp parse_entities(entities) do
    for entity_object <- entities, into: [] do
      with %{"entity" => entity} <- entity_object,
           %{"properties" => properties} <- entity,
           result <- Dts.Properties.deconstruct(properties) do
        result
      end
    end
  end

  def parse(response_body) do
    with {:ok, %{"found" => found} = response_body_map} <- Jason.decode(response_body),
         resultset <- parse_entities(found) do
      {:ok, resultset}
    else
      _ -> {:error, "Response body parsing error!"}
    end
  end
end
