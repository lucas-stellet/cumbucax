defmodule Cumbucax.Factory.UserFactory do
  @moduledoc """
  Module responsible for defining User factory used in tests.
  """

  alias Cumbucax.Users.User

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %User{
          first_name: Faker.Person.first_name(),
          last_name: Faker.Person.last_name(),
          password: Faker.Util.format("%2a%2A%4d"),
          cpf: Faker.Util.format("%3d.%3d.%3d-%2d")
        }
      end
    end
  end
end
