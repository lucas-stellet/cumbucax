defmodule Cumbucax.Transactions.Transaction do
  @doc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transaction" do
    field :amount, Money.Ecto.Amount.Type
    field :status, Ecto.Enum, values: [:pending, :failed, :refunded, :completed]
    field :beneficiary_account_id, :binary_id
    field :requester_account_id, :binary_id

    timestamps()
  end

  @creation_fields ~w(amount status beneficiary_account_id requester_account_id)a
  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @creation_fields)
    |> validate_required(@creation_fields)
  end

  @update_fields ~w(status)a
  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @update_fields)
    |> validate_required(@update_fields)
  end
end
