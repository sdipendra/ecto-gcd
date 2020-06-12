defmodule Datastore.Dts.Properties do
  @moduledoc false

  # todo[IMPORTANT]: See how to support other types
  def construct(fields) do
    for {k, v} <- fields, into: %{}, do: {k, %{stringValue: v}}
  end

  # todo[IMPORTANT]: See how to support other types
  def deconstruct(properties) do
    for {k, %{"stringValue" => v}} <- properties, into: %{}, do: {k, v}
  end
end
