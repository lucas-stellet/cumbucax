defmodule Cumbucax.Helpers do
  @moduledoc """
  Contains helper functions.
  """

  def transform_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  def handle_multi_result(multi_result, func), do: func.(multi_result)

  def convert_money_to_string(money), do: Money.to_string(money, separator: ".", delimiter: ",")
end
