defmodule Cumbucax.Transactions.ListTransactionsFitersParams do
  @moduledoc false
  use Ecto.Schema

  import Cumbucax.Helpers
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :id, :binary_id
    field :requester_account_id, :binary_id
    field :beneficiary_account_id, :binary_id
    field :from, :binary
    field :to, :binary
  end

  @validate_fields ~w(id requester_account_id beneficiary_account_id from to )a

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @validate_fields)
    |> validate_required([:requester_account_id])
    |> convert_field_from()
    |> convert_field_to()
  end

  defp convert_field_from(%Ecto.Changeset{valid?: true, changes: %{from: from}} = changeset) do
    case NaiveDateTime.from_iso8601(from) do
      {:ok, converted_from} ->
        put_change(changeset, :from, converted_from)

      {:error, _error} ->
        add_error(changeset, :from, "invalid format. expected: '2022-01-01 00:00:00")
    end
  end

  defp convert_field_from(changeset), do: changeset

  defp convert_field_to(%Ecto.Changeset{valid?: true, changes: %{to: to}} = changeset) do
    case NaiveDateTime.from_iso8601(to) do
      {:ok, converted_to} ->
        put_change(changeset, :to, converted_to)

      {:error, _error} ->
        add_error(changeset, :to, "invalid format. expected: '2022-01-01 00:00:00")
    end
  end

  defp convert_field_to(changeset), do: changeset

  @doc false
  def validate_params(params) do
    case changeset(Enum.into(params, %{})) do
      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, transform_changeset_errors(changeset)}

      %Ecto.Changeset{valid?: true, changes: changes} ->
        {:ok, Map.to_list(changes)}
    end
  end
end
