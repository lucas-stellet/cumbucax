defmodule Seeds do
  alias Cumbucax.Repo

  alias Cumbucax.Accounts.Account
  alias Cumbucax.Users.User

  def run(_repo) do
    user_1 =
      Repo.insert!(%User{
        cpf: "001.002.003-04",
        first_name: "John",
        last_name: "Doe",
        password_hash:
          "$argon2id$v=19$m=65536,t=8,p=2$5lVFTBqK5NhI2z5xr1j/bA$LPKvma+WVvjCf2tdOzbNXuUTivvHJauYCET26W0cfn0"
      })

    Repo.insert!(%Account{
      id: Ecto.UUID.generate(),
      branch: "0001",
      number: "135790",
      digit: "2",
      balance: Money.new(100),
      user_id: user_1.id
    })
  end
end

Cumbucax.Release.load_app()

Ecto.Migrator.with_repo(Cumbucax.Repo, &Seeds.run/1)
