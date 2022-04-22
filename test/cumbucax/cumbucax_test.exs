defmodule CumbucaxTest do
  @moduledoc false
  use Cumbucax.DataCase, async: true

  alias Cumbucax.Transactions.Transaction
  alias Cumbucax.Users.User

  describe "get_user_by/1" do
    setup do
      user = insert(:user)

      %{user: user}
    end

    test "returns the user with given id and cpf", %{user: user} do
      filters = [id: user.id, cpf: user.cpf]

      assert {:ok, %User{} = inserted_user} = Cumbucax.get_user_by(filters)
      assert inserted_user.id == user.id
      assert inserted_user.cpf == user.cpf
    end

    test "returns an error with wrong id and cpf" do
      filters = [id: Ecto.UUID.generate(), cpf: Faker.Util.format("%3d.%3d.%3d-%2d")]

      assert {:error, "User not found"} = Cumbucax.get_user_by(filters)
    end
  end

  describe "register_user_and_account/1" do
    setup do
      valid_attrs = %{
        cpf: "001.002.003-04",
        first_name: "John",
        last_name: "Doe",
        password: "swordfish",
        balance: 11_111
      }

      invalid_attrs = %{
        cpf: "00100200304",
        first_name: "John",
        password: "senhainvalida123",
        balance: -1
      }

      %{valid_attrs: valid_attrs, invalid_attrs: invalid_attrs}
    end

    test "returns a bank account information when given valid attributes", %{valid_attrs: attrs} do
      assert {:ok, bank_account} = Cumbucax.register_user_and_account(attrs)

      assert bank_account.owner == attrs.first_name <> " " <> attrs.last_name
      assert bank_account.balance == Money.new(attrs.balance) |> convert_money_to_string()
    end

    test "returns an tuple error when given invalid attributes missing last name", %{
      invalid_attrs: attrs
    } do
      assert {:error, %{last_name: ["can't be blank"]}} =
               Cumbucax.register_user_and_account(attrs)
    end
  end

  describe "transfer/1" do
    setup do
      requester_account = insert(:account, user: insert(:user), balance: Money.new(100_000))
      beneficiary_account = insert(:account, user: insert(:user), balance: Money.new(100_000))

      %{requester_account: requester_account, beneficiary_account: beneficiary_account}
    end

    test "with valid attributes return the updated account balance and the amount transferred", %{
      requester_account: requester_account,
      beneficiary_account: beneficiary_account
    } do
      transfer_attrs = %{
        requester_account_id: requester_account.id,
        branch: beneficiary_account.branch,
        digit: beneficiary_account.digit,
        number: beneficiary_account.number,
        amount: "R$100,00"
      }

      assert {:ok, %{balance: balance, result: "transfer done", transaction_id: _transaction_id}} =
               Cumbucax.transfer(transfer_attrs)

      assert Money.parse!(balance) == Money.new(90_000)
    end

    test "with invalid account data return an error message", %{
      requester_account: requester_account
    } do
      transfer_attrs = %{
        requester_account_id: requester_account.id,
        branch: "0001",
        digit: "8",
        number: "123455",
        amount: "R$100,00"
      }

      assert {:error, "account not found"} = Cumbucax.transfer(transfer_attrs)
    end

    test "when requester has no sufficient balance to do the transfer", %{
      requester_account: requester_account,
      beneficiary_account: beneficiary_account
    } do
      transfer_attrs = %{
        requester_account_id: requester_account.id,
        branch: beneficiary_account.branch,
        digit: beneficiary_account.digit,
        number: beneficiary_account.number,
        amount: "R$9000,00"
      }

      assert {:error, "insufficient balance"} = Cumbucax.transfer(transfer_attrs)
    end
  end

  describe "transfer_refund/1" do
    setup do
      requester_account = insert(:account, user: insert(:user), balance: Money.new(100_000))
      beneficiary_account = insert(:account, user: insert(:user), balance: Money.new(100_000))

      transfer_attrs = %{
        requester_account_id: requester_account.id,
        branch: beneficiary_account.branch,
        digit: beneficiary_account.digit,
        number: beneficiary_account.number,
        amount: "R$100,00"
      }

      %{
        requester_account: requester_account,
        beneficiary_account: beneficiary_account,
        transfer_attrs: transfer_attrs
      }
    end

    test "with valid attributes refunds the amount to requester and removes from beneficiary", %{
      requester_account: requester_account,
      transfer_attrs: transfer_attrs
    } do
      {:ok,
       %{
         balance: _balance,
         result: "transfer done",
         transaction_id: transaction_id
       }} = Cumbucax.transfer(transfer_attrs)

      refund_attrs = %{transaction_id: transaction_id, requester_account_id: requester_account.id}

      assert {:ok, %{message: "refund done", transaction: ^transaction_id}} =
               Cumbucax.transfer_refund(refund_attrs)

      assert {:ok, requester_balance_after_refund} =
               Cumbucax.get_account_balance(requester_account.id)

      assert Money.equals?(
               requester_account.balance,
               requester_balance_after_refund
             ) ==
               true
    end

    test "with requester id different from who requested the transaction returns error", %{
      transfer_attrs: transfer_attrs
    } do
      {:ok,
       %{
         balance: _balance,
         result: "transfer done",
         transaction_id: transaction_id
       }} = Cumbucax.transfer(transfer_attrs)

      refund_attrs = %{transaction_id: transaction_id, requester_account_id: Ecto.UUID.generate()}

      assert {:error, "transaction not found"} = Cumbucax.transfer_refund(refund_attrs)
    end

    test "with wrong transaction id returns error", %{
      requester_account: requester_account,
      transfer_attrs: transfer_attrs
    } do
      {:ok,
       %{
         balance: _balance,
         result: "transfer done",
         transaction_id: _transaction_id
       }} = Cumbucax.transfer(transfer_attrs)

      refund_attrs = %{
        transaction_id: Ecto.UUID.generate(),
        requester_account_id: requester_account.id
      }

      assert {:error, "transaction not found"} = Cumbucax.transfer_refund(refund_attrs)
    end
  end

  describe "list_transactions_by_date/2" do
    setup do
      requester_account = insert(:account, user: insert(:user))
      beneficiary_account = insert(:account, user: insert(:user))

      %{
        requester_account: requester_account,
        beneficiary_account: beneficiary_account
      }
    end

    test "with correct filters returns a list of transactions", %{
      requester_account: requester_account,
      beneficiary_account: beneficiary_account
    } do
      %Transaction{id: transaction_1_id} =
        insert(:transaction,
          beneficiary_account_id: beneficiary_account.id,
          inserted_at: "2022-01-01 01:01:00",
          requester_account_id: requester_account.id,
          status: :completed
        )

      insert(:transaction,
        beneficiary_account_id: beneficiary_account.id,
        inserted_at: "2022-01-01 05:05:00",
        requester_account_id: requester_account.id,
        status: :completed
      )

      transactions_filters = [
        from: "2022-01-01 00:00:00",
        to: "2022-01-01 01:02:00",
        requester_account_id: requester_account.id
      ]

      assert {:ok, [%Transaction{id: ^transaction_1_id}]} =
               Cumbucax.list_transactions_by(transactions_filters)
    end

    test "with incorrect filters returns a empty list", %{
      requester_account: requester_account,
      beneficiary_account: beneficiary_account
    } do
      insert(:transaction,
        beneficiary_account_id: beneficiary_account.id,
        inserted_at: "2022-01-01 01:01:00",
        requester_account_id: requester_account.id,
        status: :completed
      )

      insert(:transaction,
        beneficiary_account_id: beneficiary_account.id,
        inserted_at: "2022-01-01 05:05:00",
        requester_account_id: requester_account.id,
        status: :completed
      )

      transactions_filters = [
        from: "2022-01-01 06:00:00",
        from: "2022-01-01 09:00:00",
        requester_account_id: requester_account.id
      ]

      assert {:ok, []} = Cumbucax.list_transactions_by(transactions_filters)
    end
  end

  describe "get_account_balance/1" do
    setup do
      account = insert(:account, user: insert(:user), balance: Money.new(100_000))

      %{account: account}
    end

    test "with valid account id returns account balance", %{account: account} do
      {:ok, account_balance} = Cumbucax.get_account_balance(account.id)

      assert Money.equals?(account.balance, account_balance) == true
    end

    test "with invalid account id returns error" do
      assert {:error, "account not found"} = Cumbucax.get_account_balance(Ecto.UUID.generate())
    end
  end
end
