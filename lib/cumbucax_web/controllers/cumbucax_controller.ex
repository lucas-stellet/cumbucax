defmodule CumbucaxWeb.CumbucaxController do
  use CumbucaxWeb, :controller

  alias CumbucaxWeb.Auth.Guardian

  action_fallback CumbucaxWeb.FallbackController

  def hello(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{"message" => "Welcome to Cumbucax API!"})
  end

  def register(conn, %{"account" => account_params}) do
    with {:ok, user, account} <- Cumbucax.register_user_and_account(account_params),
         {:ok, token, _} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("account.json", account: account, token: token)
    end
  end

  def login(conn, %{"cpf" => cpf, "password" => password}) do
    with {:ok, token} <- Guardian.authenticate(cpf: cpf, password: password) do
      conn
      |> put_status(:ok)
      |> render("login.json", token: token)
    end
  end

  def transfer(conn, %{"transfer" => transfer_params}) do
    updated_transfer_params = merge_data_with_requester_account_id(conn, transfer_params)

    with {:ok, transfer} <- Cumbucax.transfer(updated_transfer_params) do
      conn
      |> put_status(:ok)
      |> render("transfer.json", transfer: transfer)
    end
  end

  def refund(conn, %{"transaction_id" => transaction_id}) do
    refund_params =
      merge_data_with_requester_account_id(conn, %{"transaction_id" => transaction_id})

    with {:ok, transfer_refund} <- Cumbucax.transfer_refund(refund_params) do
      conn
      |> put_status(:ok)
      |> render("refund.json", transfer_refund: transfer_refund)
    end
  end

  def list(conn, filters) do
    updated_filters = merge_data_with_requester_account_id(conn, filters)

    with {:ok, transaction} <- Cumbucax.list_transactions_by(updated_filters) do
      conn
      |> put_status(:ok)
      |> render("transactions.json", transaction: transaction)
    end
  end

  defp merge_data_with_requester_account_id(conn, data) when is_list(data) do
    requester_account_id = Map.get(conn.assigns, :requester_account_id)

    data
    |> Keyword.put(:requester_account_id, requester_account_id)
  end

  defp merge_data_with_requester_account_id(conn, data) do
    requester_account_id = Map.get(conn.assigns, :requester_account_id)

    data
    |> Map.put("requester_account_id", requester_account_id)
  end
end
