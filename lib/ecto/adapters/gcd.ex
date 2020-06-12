defmodule Ecto.Adapters.Gcd do
  @moduledoc """
  Documentation for `Ecto.Adpaters.Gcd`.
  """

  @behaviour Ecto.Adapter
  @behaviour Ecto.Adapter.Schema
  @behaviour Ecto.Adapter.Queryable

  require Logger

  alias Datastore.GoogleApis.Client
  alias Datastore.Request

  @name __MODULE__

  def start_link(config) do
    Logger.debug("start_link called!")
    Logger.debug("config: #{inspect config}")
    children = []
    opts = [strategy: :one_for_one, name: Ecto.Adapters.Gcd.Supervisor]

    Supervisor.start_link(children, opts)
  end

  # todo[IMPORTANT]: 1. Implement connection pooling
  # todo[IMPORTANT]: 2. Implement lazy connection pooling

  @impl Ecto.Adapter
  defmacro __before_compile__(env) do
    Logger.debug("__before_compile__ called!")
    Logger.debug("env: #{inspect env}")
    # todo: implement this
#    quote do
#      require Logger
#
#      def get!(queryable, name) do
#        Logger.debug("get! called!")
#        Logger.debug("queryable: #{inspect queryable}")
#        Logger.debug("name: #{name}")
#        kind = queryable.__schema__(:source)
#        Logger.debug("kind: #{inspect kind}")
#      end
#    end
  end

  @impl Ecto.Adapter
  def init(config) do
    # todo: Implement this
    Logger.debug("init called!")
    Logger.debug("config: #{inspect config}")

    # todo: See anything else should be added to child spec
    child_spec = %{
      id: @name,
      start: {__MODULE__, :start_link, [config]},
      type: :supervisor
    }

    datastore_host = Keyword.get(config, :datastore_host)
    datastore_project_id = Keyword.get(config, :datastore_project_id)
    adapter_meta = %{
      datastore_host: datastore_host,
      datastore_project_id: datastore_project_id
    }

    {:ok, child_spec, adapter_meta}
  end

  # todo: remove underscore from the variable name when you use it
  @impl Ecto.Adapter
  def checkout(adapter_meta, config, function) do
    # todo: Implement this
    Logger.debug("checkout called!")
    Logger.debug("adapter_meta: #{inspect adapter_meta}")
    Logger.debug("config: #{inspect config}")
    Logger.debug("function: #{inspect function}")
  end

  defp string_encode(input), do: {:ok, input}

  @impl Ecto.Adapter
  def dumpers(:string, type) do
    # todo: Implement this
    Logger.debug("dumpers called!")
    Logger.debug("type: #{inspect type}")
    [type, &string_encode/1]
  end

  @impl Ecto.Adapter
  def dumpers(primitive_type, ecto_type) do
    # todo: Implement this
    Logger.debug("dumpers called!")
    Logger.debug("primitive_type: #{inspect primitive_type}")
    Logger.debug("ecto_type: #{inspect ecto_type}")
  end

  @impl Ecto.Adapter
  def ensure_all_started(config, type) do
    # todo: Implement this
    Logger.debug("ensure_all_started called!")
    Logger.debug("config: #{inspect config}")
    Logger.debug("type: #{inspect type}")
  end

  # todo: Define loaders for types you want to support
  @impl Ecto.Adapter
  def loaders(primitive_type, type) do
    Logger.debug("loaders called!")

    Logger.debug("primitive_type: #{inspect primitive_type}")
    Logger.debug("type: #{inspect type}")

    # todo: return something meaningful
    [type]
  end

  @impl Ecto.Adapter.Schema
  def autogenerate(field_type) do
    Logger.debug("autogenerate called!")
    Logger.debug("field_type: #{inspect field_type}")
    # todo: Implement this
    nil
  end

  @impl Ecto.Adapter.Schema
  def delete(adapter_meta, schema_meta, filters, options) do
    Logger.debug("delete called!")
    Logger.debug("adapter_meta: #{inspect adapter_meta}")
    Logger.debug("schema_meta: #{inspect schema_meta}")
    Logger.debug("filters: #{inspect filters}")
    Logger.debug("options: #{inspect options}")
    # todo: implement this
  end

  @impl Ecto.Adapter.Schema
  def insert(
        %{datastore_host: datastore_host,
          datastore_project_id: datastore_project_id} = adapter_meta,
        %{source: kind} = schema_meta,
        fields,
        on_conflict,
        returning,
        options
      ) do
    Logger.debug("insert called!")
    Logger.debug("adapter_meta: #{inspect adapter_meta}")
    Logger.debug("schema_meta: #{inspect schema_meta}")
    Logger.debug("fields: #{inspect fields}")
    Logger.debug("on_conflict: #{inspect on_conflict}")
    Logger.debug("returning: #{inspect returning}")
    Logger.debug("options: #{inspect options}")
    # todo: Implement this

    # todo: Convert this into a with chain of operations
    headers = [{"Content-type", "application/json"}]
    endpoint_url = datastore_host <> "/v1/projects/" <> datastore_project_id <> ":commit"

    # todo: Decode response and see if it is right
    with  {:ok, request_body_struct} <- Request.Commit.create(datastore_project_id, kind, fields),
          {:ok, request_body} <- Jason.encode(request_body_struct),
          {:ok, %{body: response_body, status_code: 200} = response} <- HTTPoison.post(endpoint_url, request_body, headers, []) do
      Logger.debug("response: #{inspect response}")
      Logger.debug("response_body: #{inspect response_body}")
      Logger.debug("fields: #{inspect fields}")
      {:ok, []}
    else
      {:ok, %{status_code: 409}} -> {:invalid, [unique: "PRIMARY"]}
      {:error, error} -> {:invalid, [error: "#{inspect error}"]}
      error -> {:invalid, [unknown_error: "#{inspect error}"]}
    end
  end

  @impl Ecto.Adapter.Schema
  def insert_all(adapter_meta, schema_meta, header, list, on_conflict, returning, options) do
    Logger.debug("insert_all called!")
    Logger.debug("insert called!")
    Logger.debug("adapter_meta: #{inspect adapter_meta}")
    Logger.debug("schema_meta: #{inspect schema_meta}")
    Logger.debug("header: #{inspect header}")
    Logger.debug("list: #{inspect list}")
    Logger.debug("on_conflict: #{inspect on_conflict}")
    Logger.debug("returning: #{inspect returning}")
    Logger.debug("options: #{inspect options}")
    # todo: Implement this
  end

  @impl Ecto.Adapter.Schema
  def update(adapter_meta, schema_meta, fields, filters, returning, options) do
    Logger.debug("update called!")
    Logger.debug("adapter_meta: #{inspect adapter_meta}")
    Logger.debug("schema_meta: #{inspect schema_meta}")
    Logger.debug("fields: #{inspect fields}")
    Logger.debug("filters: #{inspect filters}")
    Logger.debug("returning: #{inspect returning}")
    Logger.debug("options: #{inspect options}")
    # todo: Implement this
  end

  @impl Ecto.Adapter.Queryable
  def prepare(:all, query) do
    Logger.debug("prepare :all called!")
    Logger.debug("query: #{inspect query}")

    # todo: Implement this
    {:nocache, {:all, query}}
  end

  defp build_resultset(result_list, fields) do
    resultset = for result <- result_list, into: [] do
      for {name, type} <- fields, into: [] do
        result[Atom.to_string(name)]
      end
    end
    {:ok, resultset}
  end

  @impl Ecto.Adapter.Queryable
  def execute(
        %{datastore_host: datastore_host,
          datastore_project_id: datastore_project_id} = adapter_meta,
        %{select: %{from: {:any, {:source, {kind, _}, _, fields}}}} = query_meta,
        query_cache,
        params,
        options
      ) do
    Logger.debug("execute called!")
    Logger.debug("adapter_meta: #{inspect adapter_meta}")
    Logger.debug("query_meta: #{inspect query_meta}")
    Logger.debug("query_cache: #{inspect query_cache}")
    Logger.debug("params: #{inspect params}")
    Logger.debug("options: #{inspect options}")

    Logger.debug("datastore_host: #{inspect datastore_host}")
    Logger.debug("datastore_project_id: #{inspect datastore_project_id}")
    Logger.debug("kind: #{inspect kind}")

    # todo: Convert this into a with chain of operations
    headers = [{"Content-type", "application/json"}]
    endpoint_url = datastore_host <> "/v1/projects/" <> datastore_project_id <> ":lookup"

    # todo: Decode response and see if it is right
    with  {:ok, request_body_struct} <- Request.Lookup.create(datastore_project_id, kind, params),
          {:ok, request_body} <- Jason.encode(request_body_struct),
          {:ok, %{body: response_body, status_code: 200} = response} <- HTTPoison.post(endpoint_url, request_body, headers, []),
          {:ok, result_list} <- Request.Lookup.parse(response_body),
          {:ok, resultset} <- build_resultset(result_list, fields) do
      Logger.debug("response: #{inspect response}")
      Logger.debug("response_body: #{inspect response_body}")
      Logger.debug("result_list: #{inspect result_list}")
      Logger.debug("resultset: #{inspect resultset}")
      # todo: Properly format found into a resultset

      {length(resultset), resultset}
    else
      # todo: use suitable errors for lookup
      error -> {:invalid, [unknown_error: "#{inspect error}"]}
    end
  end
end
