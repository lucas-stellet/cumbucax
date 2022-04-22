defmodule Cumbucax.Transfer do
  @moduledoc false
  use Ecto.Schema

  import Cumbucax.Helpers
  import Ecto.Changeset

  embedded_schema do
    field :requester_account_id, :binary_id
    field :branch, :string
    field :number, :string
    field :digit, :string
    field :amount, :string
  end

  @validate_fields ~w(requester_account_id branch number digit amount)a

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @validate_fields)
    |> validate_required(@validate_fields)
    |> validate_change(:amount, fn :amount, amount ->
      case Money.parse(amount) do
        :error ->
          [amount: "invalid amount format"]

        {:ok, _value} ->
          []
      end
    end)
    |> convert_amount_to_money()
  end

  defp convert_amount_to_money(
         %Ecto.Changeset{valid?: true, changes: %{amount: amount}} = changeset
       ) do
    change(changeset, amount: Money.parse!(amount))
  end

  defp convert_amount_to_money(changeset), do: changeset

  @doc false
  def validate_params(params) do
    case changeset(params) do
      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, transform_changeset_errors(changeset)}

      %Ecto.Changeset{valid?: true, changes: changes} ->
        {:ok, changes}
    end
  end
end
