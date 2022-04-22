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
          "$argon2id$v=19$m=65536,t=8,p=2$8U1BcFRm2aRzvQGIYZizcg$bQZA02f4OraWqqM+r3OTJLBDuflyvxNZMze1H/J5gqU"
      })

    Repo.insert!(%Account{
      id: Ecto.UUID.generate(),
      branch: "0001",
      number: "123456",
      digit: "7",
      balance: Money.new(100_000),
      user_id: user_1.id
    })

    user_2 =
      Repo.insert!(%User{
        cpf: "005.006.007-08",
        first_name: "Lana",
        last_name: "Doe",
        password_hash:
          "$argon2id$v=19$m=65536,t=8,p=2$8U1BcFRm2aRzvQGIYZizcg$bQZA02f4OraWqqM+r3OTJLBDuflyvxNZMze1H/J5gqU"
      })

    Repo.insert!(%Account{
      id: Ecto.UUID.generate(),
      branch: "0001",
      number: "654321",
      digit: "7",
      balance: Money.new(100_000),
      user_id: user_2.id
    })
  end
end

Cumbucax.Release.load_app()

Ecto.Migrator.with_repo(Cumbucax.Repo, &Seeds.run/1)
