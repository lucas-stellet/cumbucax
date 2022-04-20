defmodule Cumbucax.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string
      add :last_name, :string
      add :password_hash, :string
      add :cpf, :string

      timestamps()
    end

    create unique_index(:users, [:cpf])
  end
end
