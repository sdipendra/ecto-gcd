defmodule Ecto.Adapters.Gcd do
  @moduledoc """
  Documentation for `Ecto.Adpaters.Gcd`.
  """

  @behaviour Ecto.Adapter
  @behaviour Ecto.Adapter.Schema
  @behaviour Ecto.Adapter.Queryable

  require Logger

  # todo: Remove this once not required
  alias Ecto.Adapters.Gcd.Mapper
  alias Ecto.Adapters.Gcd.Helper

  alias Datastore.GoogleApis.Client
  alias Datastore.Request

  alias GoogleApi.Datastore.V1.Api
  alias GoogleApi.Datastore.V1.Connection
  alias GoogleApi.Datastore.V1.Model

  @name __MODULE__
  @datastore_auth_scope "https://www.googleapis.com/auth/datastore"

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
  # todo: Maybe acquire token and tesla connection in this function
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

  @spec get_primary_key(atom) :: atom
  defp get_primary_key(schema) do
    Logger.debug("get_primary_key called!")
    Logger.debug("schema: #{inspect schema}")

    case schema.__schema__(:primary_key) do
      [primary_key] -> {:ok, primary_key}
      [] -> {:error, :undefined_primary_key}
      _ -> {:error, :multiple_primary_keys}
    end
  end

  @spec get_field_value(Schema.fields, atom) :: any
  defp get_field_value(fields, field) do
    case Keyword.fetch(fields, field) do
      {:ok, value} -> {:ok, value}
      :error -> {:error, :missing_field}
    end
  end

  @spec build_property(atom, atom, any) :: Model.Value.t
  defp build_property(schema, field, value) do
    #todo[IMPORTANT]: Support other types as well
    # todo: check whether these values are getting parsed and stored properly
    # todo: Maybe use dumpers for this
    case value do
      nil -> %Model.Value{nullValue: nil}
      _ -> case schema.__schema__(:type, field) do
             :boolean -> %Model.Value{booleanValue: value}
             :float -> %Model.Value{doubleValue: value}
             :integer -> %Model.Value{integerValue: Integer.to_string(value)}
             :string -> %Model.Value{stringValue: value}
             :utc_datetime -> %Model.Value{timestampValue: value}
             :utc_datetime_usec -> %Model.Value{timestampValue: value}
           end
    end
  end

  @spec build_properties(atom, Schema.fields) :: %{optional(String.t) => Model.Value.t}
  defp build_properties(schema, fields) do
    Enum.map(fields, fn {field, value} -> {field, build_property(schema, field, value)} end)
    |> Map.new()
  end

  @spec build_entity(atom, Schema.fields, String.t) :: Model.Entity.t
  defp build_entity(schema, fields, project_id) do
    Logger.debug("build_entity called!")
    Logger.debug("schema: #{inspect schema}")
    Logger.debug("fields: #{inspect fields}")
    Logger.debug("project_id: #{inspect project_id}")

    with {:ok, primary_key} <- get_primary_key(schema),
         :string <- schema.__schema__(:type, primary_key),
         {:ok, primary_value} <- get_field_value(fields, primary_key),
         source <- schema.__schema__(:source) do
      {
        :ok,
        %Model.Entity{
          key: %Model.Key{
            partitionId: %Model.PartitionId{
              projectId: project_id
            },
            path: %Model.PathElement{
              kind: source,
              name: primary_value
            }
          },
          properties: build_properties(schema, fields)
        }
      }
    else
      {:error, error} -> {:error, error}
      debug_error ->
        Logger.debug("debug_error: #{inspect debug_error}")
        {:error, :unknown_error_build_entity}
    end
  end

  @impl Ecto.Adapter.Schema
  def insert(
        %{
          datastore_host: datastore_host,
          datastore_project_id: datastore_project_id
        } = adapter_meta,
        %{source: kind, schema: schema} = schema_meta,
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

    # todo: Force google api to use Jason somehow
    # todo: Harden security of Tesla the underlying http client
    # todo[IMPORTANT]: Rollback transaction if some error happens
    with  {:ok, entity} <- build_entity(schema, fields, datastore_project_id),
          {:ok, goth_token} <- Goth.Token.for_scope(@datastore_auth_scope),
          conn <- Connection.new(goth_token.token),
          {
            :ok,
            %Model.BeginTransactionResponse{transaction: transaction}
          } <- Api.Projects.datastore_projects_begin_transaction(conn, datastore_project_id),
          Logger.debug("transaction: #{inspect transaction}"),
          {:ok, response} <- Api.Projects.datastore_projects_commit(
            conn,
            datastore_project_id,
            [
              body: %Model.CommitRequest{
                mode: "TRANSACTIONAL",
                mutations: [
                  %Model.Mutation{
                    insert: entity
                  }
                ],
                transaction: transaction
              }
            ]
          ) do
      Logger.debug("response: #{inspect response}")
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

  # todo: See if connection pooling is required
  # todo: Add documentation
  # todo: Clean up and put checking of typespecs
  # todo: understand what is quote and unquote as that can help you process the below queries better
  # todo: Undertand how typespec handles overloaded functions and how to write typespecs for overloaded functions
  @impl Ecto.Adapter.Queryable
  @spec prepare(atom :: :all | :update_all | :delete_all, query :: Ecto.Query.t) ::
          {:nocache, {:lookup, list(Model.Key.t)}}
  def prepare(
        :all,
        # todo: See what to do about startCursor, endCursor and offset.(https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#Query)
        # todo: Implement special case for LookupRequest
        # Map to "query"
        # https://hexdocs.pm/google_api_datastore/GoogleApi.Datastore.V1.Model.Query.html
        # https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#Query
        %Ecto.Query{
          aliases: aliases,
          assocs: assocs,
          combinations: combinations,
          # Map to "distinctOn"
          # https://hexdocs.pm/google_api_datastore/GoogleApi.Datastore.V1.Model.PropertyReference.html
          # https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#PropertyReference
          distinct: distinct,
          # Map to "kind"
          # https://hexdocs.pm/google_api_datastore/GoogleApi.Datastore.V1.Model.KindExpression.html
          # https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#KindExpression
          from: %Ecto.Query.FromExpr{source: {source_name, schema}} = from,
          group_bys: group_bys,
          havings: havings,
          joins: joins,
          # Map to "limit"
          # integer()
          # number
          limit: limit,
          lock: lock,
          offset: offset,
          # Map to "order"
          # https://hexdocs.pm/google_api_datastore/GoogleApi.Datastore.V1.Model.PropertyOrder.html
          # https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#PropertyOrder
          order_bys: order_bys,
          prefix: prefix,
          preloads: preloads,
          # Map to "projection"
          # https://hexdocs.pm/google_api_datastore/GoogleApi.Datastore.V1.Model.Projection.html
          # https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#Projection
          select: %Ecto.Query.SelectExpr{fields: fields} = select,
          sources: sources,
          updates: updates,
          # Map to "filter"
          # https://hexdocs.pm/google_api_datastore/GoogleApi.Datastore.V1.Model.Filter.html
          # https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#Filter
          wheres: [
            %Ecto.Query.BooleanExpr{
              expr: {:==, [], [{{:., [], [{:&, [], [0]}, primary_key]}, [], []}, {:^, [], [0]}]},
              file: _file,
              line: _line,
              op: :and,
              params: nil,
              subqueries: []
            }
          ] = wheres,
          windows: windows,
          with_ctes: with_ctes,
        } = query
        # ) when schema.__schema__(:primary_key) == [primary_key] do
      ) do
    # todo: remove after debugging
    Logger.debug("prepare :all :lookup called!")
    Logger.debug("aliases: #{inspect aliases}")
    Logger.debug("assocs: #{inspect assocs}")
    Logger.debug("combinations: #{inspect combinations}")
    Logger.debug("distinct: #{inspect distinct}")
    Logger.debug("from: #{inspect from}")
    Logger.debug("group_bys: #{inspect group_bys}")
    Logger.debug("havings: #{inspect havings}")
    Logger.debug("joins: #{inspect joins}")
    Logger.debug("limit: #{inspect limit}")
    Logger.debug("lock: #{inspect lock}")
    Logger.debug("offset: #{inspect offset}")
    Logger.debug("order_bys: #{inspect order_bys}")
    Logger.debug("prefix: #{inspect prefix}")
    Logger.debug("preloads: #{inspect preloads}")
    Logger.debug("select: #{inspect select}")
    Logger.debug("sources: #{inspect sources}")
    Logger.debug("updates: #{inspect updates}")
    Logger.debug("wheres: #{inspect wheres}")
    Logger.debug("windows: #{inspect windows}")
    Logger.debug("with_ctes: #{inspect with_ctes}")

    # Check that query doesn't have unsupported attributes
    cond do
      aliases != %{} -> raise Ecto.QueryError, [message: "aliases not supported", query: query]
      assocs != [] -> raise Ecto.QueryError, [message: "assocs not supported", query: query]
      combinations != [] -> raise Ecto.QueryError, [message: "combinations not supported", query: query]
      # distinct == -> raise Ecto.QueryError, [message: "assocs not supported", query: query]
      # from ==  -> raise Ecto.QueryError, [message: "assocs not supported", query: query]
      group_bys != [] -> raise Ecto.QueryError, [message: "group_bys not supported", query: query]
      havings != [] -> raise Ecto.QueryError, [message: "havings not supported", query: query]
      joins != [] -> raise Ecto.QueryError, [message: "joins not supported", query: query]
      lock != nil -> raise Ecto.QueryError, [message: "lock not supported", query: query]
      offset != nil -> raise Ecto.QueryError, [message: "offset not supported", query: query]
      # order_bys ==  -> raise Ecto.QueryError, [message: "assocs not supported", query: query]
      prefix != nil -> raise Ecto.QueryError, [message: "prefix not supported", query: query]
      preloads != [] -> raise Ecto.QueryError, [message: "preloads not supported", query: query]
      # select ==  -> raise Ecto.QueryError, [message: "assocs not supported", query: query]
      # sources ==  -> raise Ecto.QueryError, [message: "assocs not supported", query: query]
      updates != [] -> raise Ecto.QueryError, [message: "updates not supported", query: query]
      # wheres ==  -> raise Ecto.QueryError, [message: "wheres not supported", query: query]
      windows != [] -> raise Ecto.QueryError, [message: "windows not supported", query: query]
      with_ctes != nil -> raise Ecto.QueryError, [message: "with_ctes not supported", query: query]
      true -> :ok
    end

    # todo: Build request

    # todo: See what to do in case of multiple keys
    path = case schema.__schema__(:type, primary_key) do
      :integer -> :ok
      :string -> :ok
    end

    # todo: See if project id is accessible in this method
    {
      :nocache,
      {
        :lookup,
        # todo: namespaceId can be used to support multi tenancy
        [
          %Model.Key{
            partitionId: %Model.PartitionId{
              namespaceId: nil,
              # todo: Fill in execute
              projectId: nil
            },
            path: %Model.PathElement{
              # id: ""
              kind: source_name,
              name: nil
            }
          }
        ]
      }
    }
  end

  # todo: understand what is quote and unquote as that can help you process the below queries better
  @impl Ecto.Adapter.Queryable
  @spec prepare(atom :: :all | :update_all | :delete_all, query :: Ecto.Query.t()) ::
          {:nocache, Model.RunQueryRequest.t}
  def prepare(
        :all,
        # todo: See what to do about startCursor, endCursor and offset.(https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#Query)
        # todo: Implement special case for LookupRequest
        # Map to "query"
        # https://hexdocs.pm/google_api_datastore/GoogleApi.Datastore.V1.Model.Query.html
        # https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#Query
        %Ecto.Query{
          aliases: aliases,
          assocs: assocs,
          combinations: combinations,
          # Map to "distinctOn"
          # https://hexdocs.pm/google_api_datastore/GoogleApi.Datastore.V1.Model.PropertyReference.html
          # https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#PropertyReference
          distinct: distinct,
          # Map to "kind"
          # https://hexdocs.pm/google_api_datastore/GoogleApi.Datastore.V1.Model.KindExpression.html
          # https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#KindExpression
          from: %Ecto.Query.FromExpr{source: {name, schema}} = from,
          group_bys: group_bys,
          havings: havings,
          joins: joins,
          # Map to "limit"
          # integer()
          # number
          limit: limit,
          lock: lock,
          offset: offset,
          # Map to "order"
          # https://hexdocs.pm/google_api_datastore/GoogleApi.Datastore.V1.Model.PropertyOrder.html
          # https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#PropertyOrder
          order_bys: order_bys,
          prefix: prefix,
          preloads: preloads,
          # Map to "projection"
          # https://hexdocs.pm/google_api_datastore/GoogleApi.Datastore.V1.Model.Projection.html
          # https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#Projection
          select: %Ecto.Query.SelectExpr{fields: fields} = select,
          sources: sources,
          updates: updates,
          # Map to "filter"
          # https://hexdocs.pm/google_api_datastore/GoogleApi.Datastore.V1.Model.Filter.html
          # https://cloud.google.com/datastore/docs/reference/data/rest/v1/projects/runQuery#Filter
          wheres: wheres,
          windows: windows,
          with_ctes: with_ctes,
        } = query
      ) do
    # todo: remove after debugging
    Logger.debug("prepare :all :query called!")
    Logger.debug("aliases: #{inspect aliases}")
    Logger.debug("assocs: #{inspect assocs}")
    Logger.debug("combinations: #{inspect combinations}")
    Logger.debug("distinct: #{inspect distinct}")
    Logger.debug("from: #{inspect from}")
    Logger.debug("group_bys: #{inspect group_bys}")
    Logger.debug("havings: #{inspect havings}")
    Logger.debug("joins: #{inspect joins}")
    Logger.debug("limit: #{inspect limit}")
    Logger.debug("lock: #{inspect lock}")
    Logger.debug("offset: #{inspect offset}")
    Logger.debug("order_bys: #{inspect order_bys}")
    Logger.debug("prefix: #{inspect prefix}")
    Logger.debug("preloads: #{inspect preloads}")
    Logger.debug("select: #{inspect select}")
    Logger.debug("sources: #{inspect sources}")
    Logger.debug("updates: #{inspect updates}")
    Logger.debug("wheres: #{inspect wheres}")
    Logger.debug("windows: #{inspect windows}")
    Logger.debug("with_ctes: #{inspect with_ctes}")

    # Check that query doesn't have unsupported attributes
    cond do
      aliases != %{} -> raise Ecto.QueryError, [message: "aliases not supported", query: query]
      assocs != [] -> raise Ecto.QueryError, [message: "assocs not supported", query: query]
      combinations != [] -> raise Ecto.QueryError, [message: "combinations not supported", query: query]
      # distinct == -> raise Ecto.QueryError, [message: "assocs not supported", query: query]
      # from ==  -> raise Ecto.QueryError, [message: "assocs not supported", query: query]
      group_bys != [] -> raise Ecto.QueryError, [message: "group_bys not supported", query: query]
      havings != [] -> raise Ecto.QueryError, [message: "havings not supported", query: query]
      joins != [] -> raise Ecto.QueryError, [message: "joins not supported", query: query]
      lock != nil -> raise Ecto.QueryError, [message: "lock not supported", query: query]
      offset != nil -> raise Ecto.QueryError, [message: "offset not supported", query: query]
      # order_bys ==  -> raise Ecto.QueryError, [message: "assocs not supported", query: query]
      prefix != nil -> raise Ecto.QueryError, [message: "prefix not supported", query: query]
      preloads != [] -> raise Ecto.QueryError, [message: "preloads not supported", query: query]
      # select ==  -> raise Ecto.QueryError, [message: "assocs not supported", query: query]
      # sources ==  -> raise Ecto.QueryError, [message: "assocs not supported", query: query]
      updates != [] -> raise Ecto.QueryError, [message: "updates not supported", query: query]
      # wheres ==  -> raise Ecto.QueryError, [message: "wheres not supported", query: query]
      windows != [] -> raise Ecto.QueryError, [message: "windows not supported", query: query]
      with_ctes != nil -> raise Ecto.QueryError, [message: "with_ctes not supported", query: query]
      true -> :ok
    end

    # todo: Build request

    # todo: Remove this after debugging
    # Repo.get(User, "test1")
    %Ecto.Query.SelectExpr{
      expr: {:&, [], [0]},
      fields: [
        {{:., [], [{:&, [], [0]}, :username]}, [], []},
        {{:., [], [{:&, [], [0]}, :password_hash]}, [], []}
      ],
      file: "/home/dipendra/IdeaProjects/straight_forward_vpn/deps/ecto/lib/ecto/query/planner.ex",
      line: 848,
      params: nil,
      take: %{}
    }
    %Ecto.Query.FromExpr{
      as: nil,
      hints: [],
      prefix: nil,
      source: {"users", StraightForwardVpn.Accounts.User}
    }
    {
      {"users", StraightForwardVpn.Accounts.User, nil}
    }
    [
      %Ecto.Query.BooleanExpr{
        expr: {
          :==,
          [],
          [
            {
              {:., [], [{:&, [], [0]}, :username]},
              [],
              []
            },
            {:^, [], [0]}
          ]
        },
        file: "/home/dipendra/IdeaProjects/straight_forward_vpn/deps/ecto/lib/ecto/repo/queryable.ex",
        line: 418,
        op: :and,
        params: nil,
        subqueries: []
      }
    ]


    # Repo.all(User)
    %Ecto.Query.SelectExpr{
      expr: {:&, [], [0]},
      fields: [{{:., [], [{:&, [], [0]}, :username]}, [], []}, {{:., [], [{:&, [], [0]}, :password_hash]}, [], []}],
      file: "/home/dipendra/IdeaProjects/straight_forward_vpn/deps/ecto/lib/ecto/query/planner.ex",
      line: 848,
      params: nil,
      take: %{}
    }

    # query = from u in "users", select: u.username
    # StraightForwardVpn.Repo.all(query)
    %Ecto.Query.SelectExpr{
      expr: {{:., [type: :any], [{:&, [], [0]}, :username]}, [], []},
      fields: [{{:., [type: :any], [{:&, [], [0]}, :username]}, [], []}],
      file: "iex",
      line: 34,
      params: nil,
      take: %{}
    }
    %Ecto.Query.FromExpr{
      as: nil,
      hints: [],
      prefix: nil,
      source: {"users", nil}
    }
    {
      {"users", nil, nil}
    }
    []


    # query = from u in "users", select: [:username, :password_hash]
    # StraightForwardVpn.Repo.all(query)
    %Ecto.Query.SelectExpr{
      expr: {:&, [], [0]},
      fields: [{{:., [], [{:&, [], [0]}, :username]}, [], []}, {{:., [], [{:&, [], [0]}, :password_hash]}, [], []}],
      file: "iex",
      line: 30,
      params: nil,
      take: %{
        0 => {:any, [:username, :password_hash]}
      }
    }
    %Ecto.Query.FromExpr{
      as: nil,
      hints: [],
      prefix: nil,
      source: {"users", nil}
    }
    {
      {"users", nil, nil}
    }
    []


    # query = from u in "users", where: u.username == type(^test1, :string) or u.password_hash > type(^test2, :string), select: u.username
    # StraightForwardVpn.Repo.all(query)
    %Ecto.Query.SelectExpr{
      expr: {{:., [type: :any], [{:&, [], [0]}, :username]}, [], []},
      fields: [{{:., [type: :any], [{:&, [], [0]}, :username]}, [], []}],
      file: "iex",
      line: 16,
      params: nil,
      take: %{}
    }
    %Ecto.Query.FromExpr{
      as: nil,
      hints: [],
      prefix: nil,
      source: {"users", nil}
    }
    {
      {"users", nil, nil}
    }

    [
      %Ecto.Query.BooleanExpr{
        expr: {
          :or,
          [],
          [
            {
              :==,
              [],
              [
                {{:., [], [{:&, [], [0]}, :username]}, [], []},
                %Ecto.Query.Tagged{tag: :string, type: :string, value: {:^, [], [0]}}
              ]
            },
            {
              :>,
              [],
              [
                {{:., [], [{:&, [], [0]}, :password_hash]}, [], []},
                %Ecto.Query.Tagged{tag: :string, type: :string, value: {:^, [], [1]}}
              ]
            }
          ]
        },
        file: "iex",
        line: 16,
        op: :and,
        params: nil,
        subqueries: []
      }
    ]

    # query = from u in StraightForwardVpn.Accounts.User, select: {u.username, u.password_hash}
    # StraightForwardVpn.Repo.all(query)
    %Ecto.Query.SelectExpr{
      expr: {
        :{},
        [],
        [
          {{:., [type: :string], [{:&, [], [0]}, :username]}, [], []},
          {{:., [type: :string], [{:&, [], [0]}, :password_hash]}, [], []}
        ]
      },
      fields: [
        {{:., [type: :string], [{:&, [], [0]}, :username]}, [], []},
        {{:., [type: :string], [{:&, [], [0]}, :password_hash]}, [], []}
      ],
      file: "iex",
      line: 40,
      params: nil,
      take: %{}
    }
    %Ecto.Query.FromExpr{
      as: nil,
      hints: [],
      prefix: nil,
      source: {"users", StraightForwardVpn.Accounts.User}
    }
    {
      {"users", StraightForwardVpn.Accounts.User, nil}
    }
    []

    # query = from u in StraightForwardVpn.Accounts.User, select: u.username |> coalesce(u.password_hash) |> coalesce(0)
    # StraightForwardVpn.Repo.all(query)
    %Ecto.Query.SelectExpr{
      expr: {
        :coalesce,
        [],
        [
          {
            :coalesce,
            [],
            [
              {{:., [type: :string], [{:&, [], [0]}, :username]}, [], []},
              {{:., [type: :string], [{:&, [], [0]}, :password_hash]}, [], []}
            ]
          },
          0
        ]
      },
      fields: [
        {
          :coalesce,
          [],
          [
            {
              :coalesce,
              [],
              [
                {{:., [type: :string], [{:&, [], [0]}, :username]}, [], []},
                {{:., [type: :string], [{:&, [], [0]}, :password_hash]}, [], []}
              ]
            },
            0
          ]
        }
      ],
      file: "iex",
      line: 18,
      params: nil,
      take: %{}
    }
    %Ecto.Query.FromExpr{as: nil, hints: [], prefix: nil, source: {"users", StraightForwardVpn.Accounts.User}}
    {{"users", StraightForwardVpn.Accounts.User, nil}}
    []

    fields = select |> Helper.get_fields()
    # projection = fields |> Enum.map(&Mapper.build_projection(&1))

    # Logger.debug("projection: #{inspect projection}")

    {
      :nocache,
      {
        :query,
        fields,
        %Model.Query{
          # projection: projection,
          kind: [Mapper.build_kind_expression(from)]
        }
      }
    }
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
        %{datastore_project_id: datastore_project_id} = _adapter_meta,
        _query_meta,
        {:nocache, {:query, fields, %Model.Query{} = query}} = _query_cache,
        params,
        _options
      ) do
    Logger.debug("execute called! :query !!")
    Logger.debug("query: #{inspect query}")
    Logger.debug("params: #{inspect params}")

    with {:ok, goth_token} <- Goth.Token.for_scope(@datastore_auth_scope),
         conn <- Connection.new(goth_token.token),
         {
           :ok,
           %Model.BeginTransactionResponse{transaction: transaction}
         } <- Api.Projects.datastore_projects_begin_transaction(conn, datastore_project_id),
         {
           :ok,
           %Model.RunQueryResponse{
             batch: %Model.QueryResultBatch{
               entityResults: entity_results
             },
             # todo: Remove this later
             query: query
           }
         } <- Api.Projects.datastore_projects_run_query(
           conn,
           datastore_project_id,
           [
             body: %Model.RunQueryRequest{
               partitionId: %Model.PartitionId{
                 projectId: datastore_project_id
               },
               query: query,
               readOptions: %Model.ReadOptions{
                 transaction: transaction
               }
             }
           ]
         ),
         Logger.debug("entity_results: #{inspect entity_results}"),
         resultset <- Enum.map(entity_results, fn entity_result -> Mapper.build_result(entity_result, fields) end) do
      Logger.debug("query: #{inspect query}")
      Logger.debug("resultset: #{inspect resultset}")
      {:ok, resultset}
    else
      {:error, error} -> {:error, error}
    end
  end

  @impl Ecto.Adapter.Queryable
  def execute(
        %{datastore_project_id: datastore_project_id} = _adapter_meta,
        %{
          select: %{
            from: {:any, {:source, {_kind, _}, _, fields}}
          }
        } = _query_meta,
        {:nocache, {:lookup, keys}} = _query_cache,
        [temp_param_value] = _params,
        _options
      ) do
    Logger.debug("execute called!")
    Logger.debug("adapter_meta: #{inspect _adapter_meta}")
    Logger.debug("query_meta: #{inspect _query_meta}")
    Logger.debug("query_cache: #{inspect _query_cache}")
    Logger.debug("params: #{inspect _params}")
    Logger.debug("options: #{inspect _options}")

    Logger.debug("datastore_project_id: #{inspect datastore_project_id}")

    with {:ok, goth_token} <- Goth.Token.for_scope(@datastore_auth_scope),
         conn <- Connection.new(goth_token.token),
         {
           :ok,
           %Model.BeginTransactionResponse{transaction: transaction}
         } <- Api.Projects.datastore_projects_begin_transaction(conn, datastore_project_id),
         {:ok, %Model.LookupResponse{found: found}} <- Api.Projects.datastore_projects_lookup(
           conn,
           datastore_project_id,
           [
             body: %Model.LookupRequest{
               keys: Enum.map(
                 keys,
                 fn key ->
                   %Model.Key{
                     partitionId: %Model.PartitionId{
                       key.partitionId |
                       projectId: datastore_project_id
                     },
                     path: %Model.PathElement{
                       key.path |
                       name: temp_param_value
                     }
                   }
                 end
               ),
               readOptions: %Model.ReadOptions{
                 transaction: transaction
               }
             }
           ]
         ),
         field_list <- fields |> Enum.map(fn {name, type} -> name end),
         resultset <- Enum.map(found, &Mapper.build_result(&1, field_list)) do
      Logger.debug("resultset: #{inspect resultset}")
      {:ok, resultset}
    else
      {:error, error} -> {:error, error}
    end
  end
end