defmodule Cumbucax.UsersTest do
  use Cumbucax.DataCase

  alias Cumbucax.Users

  describe "users" do
    alias Cumbucax.Users.User

    @invalid_attrs %{cpf: nil, first_name: nil, last_name: nil}

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)

      assert %User{id: inserted_user_id} = Users.get_user!(user.id)

      assert inserted_user_id == user.id
    end

    test "get_user_by/1 returns the user with given id and cpf" do
      user = insert(:user)
      filters = [id: user.id, cpf: user.cpf]

      assert inserted_user = Users.get_user_by(filters)
      assert inserted_user.id == user.id
      assert inserted_user.cpf == user.cpf
    end

    test "get_user_by/1 returns nil with wrong id and cpf" do
      filters = [id: Ecto.UUID.generate(), cpf: Faker.Util.format("%3d.%3d.%3d-%2d")]

      assert is_nil(Users.get_user_by(filters))
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        cpf: Faker.Util.format("%3d.%3d.%3d-%2d"),
        first_name: Faker.Person.first_name(),
        last_name: Faker.Person.last_name(),
        password: "password`"
      }

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)

      assert user.cpf == valid_attrs.cpf
      assert user.last_name == valid_attrs.last_name
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end
  end
end
