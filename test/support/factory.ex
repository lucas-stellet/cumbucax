defmodule Cumbucax.Factory do
  @moduledoc """
  Factory Generator.
  """
  use ExMachina.Ecto, repo: Cumbucax.Repo

  use Cumbucax.Factory.AccountFactory
  use Cumbucax.Factory.UserFactory
  use Cumbucax.Factory.TransactionFactory
end
