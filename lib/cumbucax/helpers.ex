defmodule Cumbucax.Helpers do
  @moduledoc false

  alias Cumbucax.Accounts

  alias Cumbucax.Repo

  def transform_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  @spec handle_multi_result({:ok, map()} | {:error, map()}, fun() | atom()) ::
          {:ok, map()} | {:error, Ecto.Changeset.t()}
  def handle_multi_result({:ok, multi_result}, func) when is_function(func),
    do: func.(multi_result)

  def handle_multi_result({:ok, multi_result}, step_name),
    do: {:ok, Map.get(multi_result, step_name)}

  def handle_multi_result({:error, _operation, changeset, _changes}, _step_name),
    do: {:error, changeset}

  def convert_money_to_string(money), do: Money.to_string(money, separator: ".", delimiter: ",")
end
