defmodule Cumbucax.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Cumbucax.Repo

  alias Cumbucax.Transactions.Transaction

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  List a list of transactions by filters.

  Filters allowed:

  - `id`: transaction's number.
  - `from`: transaction's branch.
  - `to`: transaction's digit.
  - `requester_account_id`: transaction's requester account ID.
  - `beneficiary_account_id`:  transaction's beneficiary account ID.

  Returns nil if the list is empty.

  ## Examples

      iex> list_transactions_by(id: "123456")
       [%Transaction{}]

      iex> list_transactions_by(id: "invalid_id")
      nil

  """

  def list_transactions_by(filters) do
    filters
    |> Enum.reduce(Transaction, fn
      {:id, id}, query ->
        query |> where([q], q.id == ^id)

      {:from, from}, query ->
        query |> where([q], q.inserted_at >= ^from)

      {:to, to}, query ->
        query |> where([q], q.inserted_at <= ^to)

      {:requester_account_id, requester_account_id}, query ->
        query |> where([q], q.requester_account_id == ^requester_account_id)

      {:beneficiary_account_id, beneficiary_account_id}, query ->
        query |> where([q], q.beneficiary_account_id == ^beneficiary_account_id)
    end)
    |> order_by([t], asc: t.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single transaction by filters and lock the row for update, if needed.

  Returns nil if the transaction does not exist.

  ## Parameters

    `filters`: A list of filters.
    Filters allowed:

    - `ID`: Transactions's ID
    - `beneficiary_account_id`: Beneficiary's account ID associated with the transaction
    - `requester_account_id`: Requester's account ID associated with the transaction

    `lock`: If true, lock the row. Otherwise, not.

  ## Examples

      iex> get_by_and_lock_account(number: "123456")
      %Transaction{}

      iex> get_by_and_lock_account(number: "invalid_number")
      nil

  """
  @spec get_transaction_by(map() | keyword(), boolean()) :: Ecto.Schema.t() | nil
  def get_transaction_by(filters, lock \\ false) do
    query =
      Enum.reduce(filters, Transaction, fn
        {:id, id}, query ->
          query |> where([q], q.id == ^id)

        {:beneficiary_account_id, beneficiary_account_id}, query ->
          query |> where([q], q.beneficiary_account_id == ^beneficiary_account_id)

        {:requester_account_id, requester_account_id}, query ->
          query |> where([q], q.requester_account_id == ^requester_account_id)
      end)

    case lock do
      true ->
        query
        |> lock("FOR UPDATE")
        |> Repo.one()

      false ->
        query
        |> Repo.one()
    end
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs) do
    Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end
end
