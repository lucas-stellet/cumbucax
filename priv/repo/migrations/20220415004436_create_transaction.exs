defmodule Cumbucax.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def change do
    create table(:transaction, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :amount, :integer
      add :overturned, :boolean, default: false, null: false
      add :overturned_at, :naive_datetime
      add :status, :string
      add :beneficiary_id, references(:accounts, on_delete: :nothing, type: :binary_id)
      add :requester_id, references(:accounts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:transaction, [:beneficiary_id])
    create index(:transaction, [:requester_id])
  end
end
