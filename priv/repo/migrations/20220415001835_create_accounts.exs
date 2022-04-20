defmodule Cumbucax.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :number, :string
      add :branch, :string
      add :digit, :string
      add :balance, :integer
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid)

      timestamps()
    end
  end
end
