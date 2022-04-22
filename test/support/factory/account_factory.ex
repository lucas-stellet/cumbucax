defmodule Cumbucax.Factory.AccountFactory do
  @moduledoc """
  Module responsible for defining Account factory used in tests.
  """

  alias Cumbucax.Accounts.Account

  defmacro __using__(_opts) do
    quote do
      def account_factory do
        %Account{
          balance: Money.new(100_000),
          branch: "0001",
          digit: Faker.Util.format("%d"),
          number: Faker.Util.format("%d%d%d%d%d%d")
        }
      end
    end
  end
end
