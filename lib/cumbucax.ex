defmodule Cumbucax do
  @moduledoc """
  Cumbcax module is the boundary between domain/business logic and the web application.
  """

  alias Cumbucax.Accounts
  alias Cumbucax.BankAccount
  alias Cumbucax.Repo
  alias Cumbucax.Transactions
  alias Cumbucax.Transfer
  alias Cumbucax.TransferRefund
  alias Cumbucax.Users
  alias Ecto.Multi

  import Cumbucax.Helpers

  @doc false
  def get_user_by(filters) do
    case Users.get_user_by(filters) do
      nil ->
        {:error, "User not found"}

      user ->
        {:ok, user}
    end
  end

  @doc false
  def get_account_balance(account_id) do
    account_id
    |> Accounts.get_account()
    |> case do
      nil ->
        {:error, "account not found"}

      %Accounts.Account{} = account ->
        {:ok, account.balance}
    end
  end

  @doc false
  def register_user_and_account(params) do
    Multi.new()
    |> Multi.run(:validate_params, fn _, _ ->
      BankAccount.validate_params(params)
    end)
    |> Multi.run(:check_user_registration, fn _, %{validate_params: params} ->
      case Users.get_user_by(cpf: params.cpf) do
        nil ->
          {:ok, :not_registered}

        _user ->
          {:error, "one account already exists with the CPF #{params.cpf}"}
      end
    end)
    |> Multi.run(:insert_user, fn _, %{validate_params: params} ->
      Users.create_user(params)
    end)
    |> Multi.run(:insert_account, fn _, %{validate_params: params, insert_user: user} ->
      params
      |> Map.put(:user_id, user.id)
      |> Accounts.create_account()
    end)
    |> Repo.transaction()
    |> handle_multi_result(fn multi_result ->
      case multi_result do
        {:error, _, error, _} ->
          {:error, error}

        {:ok, %{insert_user: user, insert_account: account}} ->
          {:ok, user,
           %{
             owner: user.first_name <> " " <> user.last_name,
             branch: account.branch,
             number: account.number,
             digit: account.digit,
             balance: convert_money_to_string(account.balance)
           }}
      end
    end)
  end

  @doc false
  def transfer(params) do
    Multi.new()
    |> Multi.run(:validate_params, fn _, _ ->
      Transfer.validate_params(params)
    end)
    |> Multi.run(:get_requester_account, fn _, %{validate_params: transfer_params} ->
      transfer_params
      |> Map.get(:requester_account_id, transfer_params)
      |> Accounts.get_and_lock_account()
      |> case do
        nil ->
          {:error, "account not found"}

        account ->
          {:ok, account}
      end
    end)
    |> Multi.run(:check_requester_equal_beneficiary, fn _,
                                                        %{
                                                          validate_params: transfer_params,
                                                          get_requester_account:
                                                            %Accounts.Account{
                                                              branch: requester_account_branch,
                                                              digit: requester_account_digit,
                                                              number: requester_account_number
                                                            }
                                                        } ->
      []
      |> Kernel.++([requester_account_branch == transfer_params.branch])
      |> Kernel.++([requester_account_digit == transfer_params.digit])
      |> Kernel.++([requester_account_number == transfer_params.number])
      |> Enum.all?()
      |> case do
        true ->
          {:error, "beneficiary account is the same as requester account"}

        false ->
          {:ok, :not_equal}
      end
    end)
    |> Multi.run(:get_beneficiary_account, fn _, %{validate_params: transfer_params} ->
      [
        branch: transfer_params.branch,
        digit: transfer_params.digit,
        number: transfer_params.number
      ]
      |> Accounts.get_by_and_lock_account()
      |> case do
        nil ->
          {:error, "account not found"}

        account ->
          {:ok, account}
      end
    end)
    |> Multi.run(:create_transaction, fn _,
                                         %{
                                           validate_params: %{amount: amount},
                                           get_requester_account: %Accounts.Account{
                                             id: requester_account_id
                                           },
                                           get_beneficiary_account: %Accounts.Account{
                                             id: beneficiary_account_id
                                           }
                                         } ->
      %{
        requester_account_id: requester_account_id,
        beneficiary_account_id: beneficiary_account_id,
        amount: amount,
        status: :pending
      }
      |> Transactions.create_transaction()
    end)
    |> Multi.run(:transfer_amount, fn _,
                                      %{
                                        validate_params: transfer_params,
                                        get_requester_account: account
                                      } ->
      amount = transfer_params.amount
      Accounts.update_account(account, {:transfer, amount})
    end)
    |> Multi.run(:deposit_amount, fn _,
                                     %{
                                       validate_params: transfer_params,
                                       get_beneficiary_account: account
                                     } ->
      amount = transfer_params.amount
      Accounts.update_account(account, {:deposit, amount})
    end)
    |> Multi.run(:update_transaction, fn _,
                                         %{
                                           create_transaction: transaction
                                         } ->
      Transactions.update_transaction(transaction, %{status: :completed})
    end)
    |> Repo.transaction()
    |> handle_multi_result(fn multi_result ->
      case multi_result do
        {:error, _, %Ecto.Changeset{} = changeset, _} ->
          [[error]] =
            transform_changeset_errors(changeset)
            |> Map.values()

          {:error, error}

        {:error, _, error, _} ->
          {:error, error}

        {:ok,
         %{
           validate_params: transfer_params,
           create_transaction: %Transactions.Transaction{id: transaction_id}
         }} ->
          account =
            transfer_params
            |> Map.get(:requester_account_id, transfer_params)
            |> Accounts.get_account!()

          {:ok,
           %{
             result: "transfer done",
             balance: convert_money_to_string(account.balance),
             transaction_id: transaction_id
           }}
      end
    end)
  end

  @doc false
  def transfer_refund(params) do
    Multi.new()
    |> Multi.run(:validate_params, fn _, _ ->
      TransferRefund.validate_params(params)
    end)
    |> Multi.run(:get_transaction_information, fn _, %{validate_params: params} ->
      [
        id: params.transaction_id,
        requester_account_id: params.requester_account_id
      ]
      |> Transactions.get_transaction_by(true)
      |> case do
        nil ->
          {:error, "transaction not found"}

        transaction ->
          {:ok, transaction}
      end
    end)
    |> Multi.run(:refund_amount_to_requester, fn _, %{get_transaction_information: transaction} ->
      transaction.requester_account_id
      |> Accounts.get_account!()
      |> Accounts.update_account({:deposit, transaction.amount})
    end)
    |> Multi.run(:refund_amount_to_beneficiary, fn _,
                                                   %{get_transaction_information: transaction} ->
      transaction.beneficiary_account_id
      |> Accounts.get_account!()
      |> Accounts.update_account({:transfer, transaction.amount})
    end)
    |> Multi.run(:update_transaction, fn _,
                                         %{
                                           get_transaction_information: transaction
                                         } ->
      Transactions.update_transaction(transaction, %{status: :refunded})
    end)
    |> Repo.transaction()
    |> handle_multi_result(fn multi_result ->
      case multi_result do
        {:error, _, %Ecto.Changeset{} = changeset, _} ->
          [[error]] =
            transform_changeset_errors(changeset)
            |> Map.values()

          {:error, error}

        {:error, _, error, _} ->
          {:error, error}

        {:ok,
         %{
           get_transaction_information: transaction
         }} ->
          {:ok,
           %{
             transaction: transaction.id,
             message: "refund done"
           }}
      end
    end)
  end

  @doc false
  def list_transactions_by(params) do
    case Transactions.ListTransactionsFitersParams.validate_params(params) do
      {:ok, valid_filters} ->
        valid_filters
        |> Transactions.list_transactions_by()
        |> case do
          nil ->
            {:ok, []}

          transactions ->
            {:ok, transactions}
        end

      error ->
        error
    end
  end
end
