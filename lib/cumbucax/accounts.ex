defmodule Cumbucax.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Cumbucax.Accounts.Account
  alias Cumbucax.Repo

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)
  """

  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Gets a single account.

  Returns nil if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      nil
  """
  def get_account(id), do: Repo.get(Account, id)

  @doc """
  Gets a single account and lock the row for update.

  Returns nil if the Account does not exist.

  ## Examples

      iex> get_and_lock_account(123)
      %Account{}

      iex> get_and_lock_account(456)
      nil
  """
  def get_and_lock_account(id) do
    from(a in Account,
      where: a.id == ^id,
      lock: "FOR UPDATE"
    )
    |> Repo.one()
  end

  @doc """
  Gets a single account by filters and lock the row for update.

  Filters allowed:

  - `number`: account's number.
  - `branch`: account's branch.
  - `digit`: account's digit.

  Returns nil if the account does not exist.

  ## Examples

      iex> get_by_and_lock_account(number: "123456")
       %Account{}

      iex> get_by_and_lock_account(number: "invalid_number")
      nil

  """
  def get_by_and_lock_account(filters) do
    filters
    |> Enum.reduce(Account, fn
      {:branch, branch}, query ->
        query |> where([q], q.branch == ^branch)

      {:number, number}, query ->
        query |> where([q], q.number == ^number)

      {:digit, digit}, query ->
        query |> where([q], q.digit == ^digit)
    end)
    |> lock("FOR UPDATE")
    |> Repo.one()
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs) do
    case Account.build(attrs) do
      {:ok, changeset} ->
        Repo.insert(changeset)

      {:error, %Ecto.Changeset{}} = error ->
        error
    end
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.update_changeset(attrs)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset ->
        Repo.update(changeset)

      error ->
        error
    end
  end
end
