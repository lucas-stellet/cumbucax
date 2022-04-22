defmodule CumbucaxWeb.CumbucaxView do
  use CumbucaxWeb, :view

  alias CumbucaxWeb.TransactionView

  def render("account.json", %{account: account, token: token}) do
    %{data: %{account: account, token: token}}
  end

  def render("register.json", %{token: token}) do
    %{data: %{token: token}}
  end

  def render("transfer.json", %{transfer: transfer}) do
    %{data: %{transfer: transfer}}
  end

  def render("transactions.json", %{transaction: transaction}) do
    %{data: render_many(transaction, TransactionView, "show.json")}
  end

  def render("refund.json", %{transfer_refund: transfer_refund}) do
    %{data: %{transfer_refund: transfer_refund}}
  end
end
