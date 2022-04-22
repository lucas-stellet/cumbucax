defmodule Cumbucax.Factory.TransactionFactory do
  @moduledoc """
  Module responsible for defining Transaction factory used in tests.
  """

  alias Cumbucax.Transactions.Transaction

  defmacro __using__(_opts) do
    quote do
      def transaction_factory do
        %Transaction{
          amount: Money.new(10000),
          status: :pending,
          beneficiary_account_id: Ecto.UUID.generate(),
          requester_account_id: Ecto.UUID.generate()
        }
      end
    end
  end
end
