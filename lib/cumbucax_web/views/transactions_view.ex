defmodule CumbucaxWeb.TransactionView do
  use CumbucaxWeb, :view
  alias CumbucaxWeb.TransactionView

  def render("index.json", %{transaction: transaction}) do
    render_many(transaction, TransactionView, "transaction.json")
  end

  def render("show.json", %{transaction: transaction}) do
    render_one(transaction, TransactionView, "transaction.json")
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{
      id: transaction.id,
      amount: Cumbucax.Helpers.convert_money_to_string(transaction.amount),
      status: transaction.status,
      beneficiary_account_id: transaction.beneficiary_account_id,
      transaction_at: transaction.inserted_at
    }
  end
end
