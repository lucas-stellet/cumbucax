defmodule CumbucaxWeb.Auth.Guardian do
  @moduledoc """
  Implementation module for Guardian and functions for authentication.
  """
  use Guardian, otp_app: :cumbucax

  alias Cumbucax

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def resource_from_claims(%{"sub" => id}), do: Cumbucax.get_user_by([{:id, id}])

  def resource_from_claims(_claims) do
    {:error, :unauthorized}
  end

  def authenticate(cpf: cpf, password: password) do
    case Cumbucax.get_user_by([{:cpf, cpf}]) do
      {:error, _} ->
        {:error, "Account not found"}

      {:ok, user} ->
        validate_password(user, password)
    end
  end

  def validate_password(%Cumbucax.Users.User{password_hash: hash} = user, password) do
    case Argon2.verify_pass(password, hash) do
      true -> create_token(user)
      false -> {:error, :unauthorized}
    end
  end

  defp create_token(user) do
    {:ok, token, _claims} = encode_and_sign(user)
    {:ok, token}
  end
end
