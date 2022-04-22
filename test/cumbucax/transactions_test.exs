defmodule Cumbucax.TransactionsTest do
  @moduledoc false
  use Cumbucax.DataCase, async: true

  alias Cumbucax.Transactions

  setup do
    requester_account = insert(:account)
    beneficiary_account = insert(:account)

    %{requester_account_id: requester_account.id, beneficiary_account_id: beneficiary_account.id}
  end

  describe "transaction" do
    alias Cumbucax.Transactions.Transaction

    @invalid_attrs %{amount: nil, status: nil}

    test "list_transactions_by returns all transactions made by an account if only the requester account id is giben",
         %{
           requester_account_id: requester_account_id,
           beneficiary_account_id: beneficiary_account_id
         } do
      transaction =
        insert(:transaction,
          requester_account_id: requester_account_id,
          beneficiary_account_id: beneficiary_account_id
        )

      assert Transactions.list_transactions_by(%{requester_account_id: requester_account_id}) == [
               transaction
             ]
    end

    test "list_transactions_by returns all transactions made by an account to a beneficiary account if the requester and beneficiary account ids are given",
         %{
           requester_account_id: requester_account_id,
           beneficiary_account_id: beneficiary_account_id
         } do
      transaction =
        insert(:transaction,
          requester_account_id: requester_account_id,
          beneficiary_account_id: beneficiary_account_id
        )

      assert Transactions.list_transactions_by(%{
               requester_account_id: requester_account_id,
               beneficiary_account_id: beneficiary_account_id
             }) == [
               transaction
             ]
    end

    test "list_transactions_by returns a transactions made by an account if the requester and transactions ids are given",
         %{
           requester_account_id: requester_account_id,
           beneficiary_account_id: beneficiary_account_id
         } do
      transaction =
        insert(:transaction,
          requester_account_id: requester_account_id,
          beneficiary_account_id: beneficiary_account_id
        )

      assert Transactions.list_transactions_by(%{
               requester_account_id: requester_account_id,
               id: transaction.id
             }) == [
               transaction
             ]
    end

    test "get_transaction!/1 returns the transaction with given id", %{
      requester_account_id: requester_account_id,
      beneficiary_account_id: beneficiary_account_id
    } do
      transaction =
        insert(:transaction,
          requester_account_id: requester_account_id,
          beneficiary_account_id: beneficiary_account_id
        )

      assert Transactions.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction", %{
      requester_account_id: requester_account_id,
      beneficiary_account_id: beneficiary_account_id
    } do
      valid_attrs = %{
        amount: 42,
        status: :pending,
        requester_account_id: requester_account_id,
        beneficiary_account_id: beneficiary_account_id
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert Money.equals?(transaction.amount, Money.new(valid_attrs.amount))
      assert transaction.status == :pending
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction", %{
      requester_account_id: requester_account_id,
      beneficiary_account_id: beneficiary_account_id
    } do
      transaction =
        insert(:transaction,
          requester_account_id: requester_account_id,
          beneficiary_account_id: beneficiary_account_id
        )

      update_attrs = %{
        status: :failed
      }

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, update_attrs)

      assert transaction.status == :failed
    end

    test "update_transaction/2 with invalid data returns error changeset", %{
      requester_account_id: requester_account_id,
      beneficiary_account_id: beneficiary_account_id
    } do
      transaction =
        insert(:transaction,
          requester_account_id: requester_account_id,
          beneficiary_account_id: beneficiary_account_id
        )

      assert {:error, %Ecto.Changeset{}} =
               Transactions.update_transaction(transaction, @invalid_attrs)

      assert transaction == Transactions.get_transaction!(transaction.id)
    end
  end
end
