defmodule Cumbucax.AccountsTest do
  @moduledoc false

  use Cumbucax.DataCase

  alias Cumbucax.Accounts

  describe "accounts" do
    alias Cumbucax.Accounts.Account

    @invalid_attrs %{balance: nil, branch: nil, digit: nil, number: nil}

    test "get_account!/1 returns the account with given id" do
      user = insert(:user)
      account = insert(:account, user_id: user.id)
      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      user = insert(:user)

      valid_attrs = %{
        balance: 42,
        user_id: user.id
      }

      assert {:ok, %Account{} = account} = Accounts.create_account(valid_attrs)
      assert account.balance == Money.new(42)
      assert not is_nil(account.branch)
      assert not is_nil(account.digit)
      assert not is_nil(account.number)
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "update_account/2 with transfer valid data updates the account" do
      account = insert(:account, user: insert(:user), balance: 100)

      update_attrs = {:transfer, Money.new(10)}

      assert {:ok, %Account{} = account} = Accounts.update_account(account, update_attrs)
      assert account.balance == Money.new(90)
    end

    test "update_account/2 with deposit valid data updates the account" do
      account = insert(:account, user: insert(:user), balance: 100)

      update_attrs = {:deposit, Money.new(10)}

      assert {:ok, %Account{} = account} = Accounts.update_account(account, update_attrs)
      assert account.balance == Money.new(110)
    end

    test "update_account/2 with insufficient balance when try to transfer amount returns error changeset" do
      account = insert(:account, user: insert(:user), balance: 10)

      invalid_update_attrs = {:transfer, 100}

      assert {:error, %Ecto.Changeset{} = changeset} =
               Accounts.update_account(account, invalid_update_attrs)

      assert errors_on(changeset) == %{balance: ["insufficient balance"]}
    end
  end
end
