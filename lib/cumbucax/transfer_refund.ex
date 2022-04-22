defmodule Cumbucax.TransferRefund do
  @moduledoc false
  use Ecto.Schema

  import Cumbucax.Helpers
  import Ecto.Changeset

  embedded_schema do
    field :transaction_id, :binary_id
    field :requester_account_id, :binary_id
  end

  @validate_fields ~w(requester_account_id transaction_id )a

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @validate_fields)
    |> validate_required(@validate_fields)
  end

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
