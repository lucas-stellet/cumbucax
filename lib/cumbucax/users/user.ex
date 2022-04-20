defmodule Cumbucax.Users.User do
  @moduledoc """
  Schema for user.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :cpf, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_one :account, Cumbucax.Accounts.Account

    timestamps()
  end

  @doc """
  Build a user with the given information and returns a validated `changeset`.

  ## Parameters
  ```attrs```- The attributes to create the user with.
  """
  @spec build(map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Schema.t()}
  def build(params) do
    params
    |> changeset()
    |> apply_action(:insert)
  end

  @required_fields ~w(cpf first_name last_name password)a

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_fields)
    |> unique_constraint(:cpf, message: "User with this CPF already exists.")
    |> validate_required(@required_fields)
    |> validate_format(:cpf, ~r/^\d{3}\.\d{3}\.\d{3}\-\d{2}$/, message: "invalid format")
    |> validate_length(:password,
      min: 6,
      max: 10,
      message: "password has to be between 6 and 10 characters. "
    )
    |> update_change(:first_name, &String.capitalize(&1))
    |> update_change(:last_name, &String.capitalize(&1))
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, Argon2.add_hash(password))
  end

  defp put_password_hash(changeset), do: changeset
end
