defmodule Cumbucax.Accounts.Account do
  @moduledoc """
  Schema for account.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :balance, Money.Ecto.Amount.Type
    field :branch, :string, default: "0001"
    field :digit, :string
    field :number, :string

    belongs_to :user, Cumbucax.Users.User

    timestamps()
  end

  @creation_fields ~w(user_id balance)a

  @spec build(map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Schema.t()}
  def build(attrs) do
    %__MODULE__{}
    |> cast(attrs, @creation_fields)
    |> validate_required(@creation_fields)
    |> validate_change(:balance, fn :balance, balance ->
      if Money.negative?(balance) do
        [balance: "cannot be negative"]
      else
        []
      end
    end)
    |> put_change(:number, create_account_number())
    |> put_change(:digit, create_account_digit())
    |> apply_action(:insert)
  end

  defp create_account_number, do: Integer.to_string(Enum.random(100_000..999_999))

  defp create_account_digit, do: Integer.to_string(Enum.random(1..9))

  def update_changeset(account, {:transfer, amount}) do
    account
    |> transfer_result_is_negative?(amount)
    |> apply_balance_update_change(amount)
  end

  def update_changeset(%__MODULE__{balance: balance} = account, {:deposit, amount}) do
    account
    |> cast(%{balance: update_balance(:add, balance, amount)}, [:balance])
  end

  defp apply_balance_update_change({true, account}, _amount) do
    account
    |> cast(%{}, [])
    |> add_error(:balance, "insufficient balance")
    |> apply_action(:update)
  end

  defp apply_balance_update_change({false, %__MODULE__{balance: balance} = account}, amount) do
    account
    |> cast(%{balance: update_balance(:subtract, balance, amount)}, [:balance])
  end

  defp transfer_result_is_negative?(account, amount) do
    {Money.negative?(Money.subtract(account.balance, amount)), account}
  end

  defp update_balance(:subtract, balance, amount), do: Money.subtract(balance, amount)

  defp update_balance(:add, balance, amount), do: Money.add(balance, amount)
end
