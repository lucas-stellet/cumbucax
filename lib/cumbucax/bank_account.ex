defmodule Cumbucax.BankAccount do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :cpf, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string, virtual: true
    field :balance, :string
  end

  @validate_fields ~w(cpf first_name last_name password balance)a

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @validate_fields)
    |> validate_required(@validate_fields)
    |> convert_balance_to_money()
  end

  defp convert_balance_to_money(
         %Ecto.Changeset{valid?: true, changes: %{balance: balance}} = changeset
       ) do
    change(changeset, balance: Money.parse!(balance))
  end

  defp convert_balance_to_money(changeset), do: changeset

  @doc false
  def validate_params(params) do
    case changeset(params) do
      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, changeset}

      %Ecto.Changeset{valid?: true, changes: changes} ->
        {:ok, changes}
    end
  end
end
