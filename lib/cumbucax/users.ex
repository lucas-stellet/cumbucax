defmodule Cumbucax.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Cumbucax.Repo

  alias Cumbucax.Users.User

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by a filter.

  Filters allowed
  - `cpf`: User's CPF.
  - `id`: User's ID.

  Returns an error tuple if the user doest not exist.

  ## Examples

      iex> get_user_by([{:cpf, "valid cpf"}])
      {:ok, %User{}}

      iex> get_user_by([{:cpf, "invalid_cpf}])
      {:error, "User not found"}

  """
  def get_user_by(filters) do
    filters
    |> Enum.reduce(User, fn
      {:cpf, cpf}, query ->
        query |> where([q], q.cpf == ^cpf)

      {:id, id}, query ->
        query |> where([q], q.id == ^id)
    end)
    |> Repo.one()
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    case User.build(attrs) do
      {:ok, changeset} ->
        Repo.insert(changeset)

      {:error, %Ecto.Changeset{}} = error ->
        error
    end
  end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking user changes.

  # ## Examples

  #     iex> change_user(user)
  #     %Ecto.Changeset{data: %User{}}

  # """
  # def change_user(%User{} = user, attrs \\ %{}) do
  #   User.changeset(user, attrs)
  # end
end
