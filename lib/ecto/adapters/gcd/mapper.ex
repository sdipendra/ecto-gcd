defmodule Ecto.Adapters.Gcd.Mapper do
  @moduledoc false

  alias Ecto.Query
  alias Ecto.Adapter
  alias GoogleApi.Datastore.V1.Model

  require Logger

  # todo: Put steps to test code using dialyzer for typespecs
  # todo: Put struct type check
  # todo: Implement this
  def distinct_to_property_reference(%{}) do
    %Model.PropertyReference{}
  end

  def order_bys_to_property_order(%{}) do

  end

  @spec build_kind_expression(term()) :: Model.KindExpression.t()
  def build_kind_expression(
        %Query.FromExpr{
          as: nil,
          hints: [],
          prefix: nil,
          source: {kind, _schema}
        }
      ) do
    %Model.KindExpression{
      name: kind
    }
  end

  @spec build_projection(atom) :: Model.Projection.t
  def build_projection(field) when is_atom(field) do
    Logger.debug("build_projection called!")
    Logger.debug("field: #{inspect field}")

    %Model.Projection{
      property: %Model.PropertyReference{
        name: Atom.to_string(field)
      }
    }
  end

  @spec build_filter(list(term())) :: Model.Filter.t()
  def build_filter(wheres) when is_list(wheres) do
    [
      %Ecto.Query.BooleanExpr{
        expr: {:==, [], [{{:., [], [{:&, [], [0]}, :username]}, [], []}, {:^, [], [0]}]},
        file: "/home/dipendra/IdeaProjects/straight_forward_vpn/deps/ecto/lib/ecto/repo/queryable.ex",
        line: 418,
        op: :and,
        params: nil,
        subqueries: []
      }
    ]
    %Model.Filter{

    }
  end

  # todo: See what to do in default case and what's the format for other values and how to map them to ecto
  @spec get_field_value(Model.Value.t) :: String.t
  defp get_field_value(
         %Model.Value{
           arrayValue: arrayValue,
           blobValue: blobValue,
           booleanValue: booleanValue,
           doubleValue: doubleValue,
           entityValue: entityValue,
           excludeFromIndexes: _excludeFromIndexes,
           geoPointValue: geoPointValue,
           integerValue: integerValue,
           keyValue: keyValue,
           meaning: _meaning,
           nullValue: nullValue,
           stringValue: stringValue,
           timestampValue: timestampValue
         } = value
       ) do
    cond do
      arrayValue -> arrayValue
      blobValue -> blobValue
      booleanValue -> booleanValue
      doubleValue -> doubleValue
      entityValue -> entityValue
      geoPointValue -> geoPointValue
      integerValue -> integerValue
      keyValue -> keyValue
      nullValue -> nullValue
      stringValue -> stringValue
      timestampValue -> timestampValue
    end
  end

  @spec parse_property(%{optional(String.t) => Model.Value.t}) :: Keyword.t
  defp parse_property(properties) do
    properties
    |> Enum.map(fn {field, value} -> {field, get_field_value(value)} end)
    |> Map.new
  end

  @spec build_result(Model.EntityResult.t, Adapter.Schema.fields) :: [Ecto.Adapter.Queryable.selected]
  def build_result(
        %Model.EntityResult{
          cursor: _cursor,
          entity: %Model.Entity{
            key: %Model.Key{} = key,
            properties: properties
          } = entity
        } = entity_result,
        fields
      ) do
    Logger.debug("build_result called!")
    Logger.debug("entity_result: #{inspect entity_result}")
    Logger.debug("fields: #{inspect fields}")

    # todo: replace with a resultset
    values = parse_property(properties)

    # todo: Remove this after debugging
    Logger.debug("values: #{inspect values}")

    result = fields
             |> Enum.map(fn field -> values[Atom.to_string(field)] end)

    # todo: Remove after debugging
    Logger.debug("result: #{inspect result}")

    result
  end
end
