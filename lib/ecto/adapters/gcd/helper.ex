defmodule Ecto.Adapters.Gcd.Helper do
  @moduledoc false

  alias Ecto.Query

  require Logger

  @spec get_fields(term()) :: [atom()]
  def get_fields(
        %Query.SelectExpr{
          expr: expr,
          fields: fields,
          file: _file,
          line: _line,
          params: nil,
          take: %{}
        }
      ) when is_list(fields) do
    fields
    |> Enum.map(&extract_fields/1)
    |> List.flatten()
  end

  # todo: Put typespec everywhere
  defp extract_fields(field) when is_atom(field) do
    Logger.debug("extract_fields(field) when is_atom(field) called!")
    Logger.debug("field: #{inspect field}")
    [field]
  end

  defp extract_fields({:&, [], [0]}) do
    Logger.debug("extract_fields({:&, [], [0]}) called!")
    []
  end

  defp extract_fields({:., [], fields}) when is_list(fields) do
    Logger.debug("extract_fields({:., [], fields}) when is_list(fields) called!")
    Logger.debug("fields: #{inspect fields}")
    for field <- fields, into: [] do
      extract_fields(field)
    end
  end

  defp extract_fields({expr, types, fields}) do
    Logger.debug("extract_fields {expr, types, fields} called!")
    Logger.debug("expr: #{inspect expr}")
    Logger.debug("types: #{inspect types}")
    Logger.debug("fields: #{inspect fields}")

    extract_fields(expr) ++ for field <- fields, into: [] do
      extract_fields(field)
    end
  end
end
