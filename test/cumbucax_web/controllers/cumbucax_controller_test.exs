defmodule CumbucaxWeb.CumbucaxControllerTest do
  @moduledoc false

  use CumbucaxWeb.ConnCase, async: true

  alias CumbucaxWeb.Auth.Guardian

  import Cumbucax.Factory

  setup %{conn: conn} do
    valid_attrs = %{
      cpf: "001.002.003-04",
      first_name: "John",
      last_name: "Doe",
      password: "123senha",
      balance: "R$1.000,00"
    }

    {:ok, requester_user, _} = Cumbucax.register_user_and_account(valid_attrs)

    %Cumbucax.Users.User{account: requester_account} =
      Cumbucax.Repo.preload(requester_user, :account)

    beneficiary_account = insert(:account, user: insert(:user))

    {:ok,
     %{
       transaction_id: transaction_id
     }} =
      Cumbucax.transfer(%{
        "branch" => beneficiary_account.branch,
        "number" => beneficiary_account.number,
        "digit" => beneficiary_account.digit,
        "amount" => "R$ 10,00",
        "requester_account_id" => requester_account.id
      })

    {:ok, token, _} = Guardian.encode_and_sign(requester_user)

    authenticated_conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "bearer: " <> token)

    %{
      conn: conn,
      authenticated_conn: authenticated_conn,
      requester_user: requester_user,
      requester_account: requester_account,
      beneficiary_account: beneficiary_account,
      tranasction_id: transaction_id
    }
  end

  describe "hello" do
    test "returns a welcome message", %{conn: conn} do
      assert %{"message" => "Welcome to Cumbucax API!"} ==
               conn
               |> get(Routes.cumbucax_path(conn, :hello))
               |> json_response(:ok)
    end
  end

  describe "register" do
    test "with valid params returns a created bank account", %{conn: conn} do
      params = %{
        "account" => %{
          "cpf" => "110.220.330-44",
          "first_name" => "Nick",
          "last_name" => "Fury",
          "password" => "vingadores",
          "balance" => "R$5.000,00"
        }
      }

      assert %{
               "data" => %{
                 "account" => %{
                   "balance" => retrieved_account_balance,
                   "owner" => retrieved_account_owner
                 },
                 "token" => _token
               }
             } =
               conn
               |> post(Routes.cumbucax_path(conn, :register, params))
               |> json_response(:created)

      assert retrieved_account_balance == params["account"]["balance"]

      assert retrieved_account_owner ==
               params["account"]["first_name"] <> " " <> params["account"]["last_name"]
    end

    test "with invalid params returns an error return", %{conn: conn} do
      invalid_params = %{
        "account" => %{
          "cpf" => "110.220.330.44",
          "first_name" => "Nick",
          "last_name" => "Fury",
          "password" => "vingadores"
        }
      }

      assert %{"error" => %{"details" => %{"balance" => ["can't be blank"]}}} =
               conn
               |> post(Routes.cumbucax_path(conn, :register, invalid_params))
               |> json_response(422)
    end
  end

  describe "login" do
    test "with valid params returns valid token", %{
      conn: conn,
      requester_user: user
    } do
      params = %{
        "cpf" => user.cpf,
        "password" => user.password
      }

      assert %{"data" => %{"token" => _token}} =
               conn
               |> post(Routes.cumbucax_path(conn, :login, params))
               |> json_response(:ok)
    end

    test "with invalid params returns valid token", %{
      conn: conn,
      requester_user: user
    } do
      params = %{
        "cpf" => user.cpf,
        "password" => "wrongpass"
      }

      assert %{"error" => %{"details" => "Incorrect cpf or password"}} =
               conn
               |> post(Routes.cumbucax_path(conn, :login, params))
               |> json_response(:unauthorized)
    end
  end

  describe "transfer" do
    test "with valid params returns the transaction id and the account balance", %{
      authenticated_conn: conn,
      beneficiary_account: beneficiary_account
    } do
      params = %{
        "transfer" => %{
          "branch" => beneficiary_account.branch,
          "number" => beneficiary_account.number,
          "digit" => beneficiary_account.digit,
          "amount" => "R$ 990,00"
        }
      }

      assert %{
               "data" => %{
                 "transfer" => %{
                   "balance" => actual_balance,
                   "result" => "transfer done",
                   "transaction_id" => _transaction_id
                 }
               }
             } =
               conn
               |> post(Routes.cumbucax_path(conn, :transfer, params))
               |> json_response(:ok)

      assert actual_balance == "R$0,00"
    end

    test "with a transfer below the balance returns an insuficient balance message", %{
      authenticated_conn: conn,
      beneficiary_account: beneficiary_account
    } do
      params = %{
        "transfer" => %{
          "branch" => beneficiary_account.branch,
          "number" => beneficiary_account.number,
          "digit" => beneficiary_account.digit,
          "amount" => "R$ 9.000,00"
        }
      }

      assert %{"error" => %{"details" => "insufficient balance"}} =
               conn
               |> post(Routes.cumbucax_path(conn, :transfer, params))
               |> json_response(:bad_request)
    end

    test "when the beneficiary account data is equal the requester account returns an error message",
         %{
           authenticated_conn: conn,
           requester_account: requester_account
         } do
      params = %{
        "transfer" => %{
          "branch" => requester_account.branch,
          "number" => requester_account.number,
          "digit" => requester_account.digit,
          "amount" => "R$ 100,00"
        }
      }

      assert %{
               "error" => %{"details" => "beneficiary account is the same as requester account"}
             } =
               conn
               |> post(Routes.cumbucax_path(conn, :transfer, params))
               |> json_response(:bad_request)
    end
  end

  describe "refund" do
    test "with a valid transaction id returns a successful message", %{
      authenticated_conn: conn,
      tranasction_id: transaction_id
    } do
      params = %{
        "transaction_id" => transaction_id
      }

      assert %{
               "data" => %{
                 "transfer_refund" => %{
                   "message" => "refund done",
                   "transaction" => ^transaction_id
                 }
               }
             } =
               conn
               |> patch(Routes.cumbucax_path(conn, :refund, params))
               |> json_response(:ok)
    end

    test "with invalid transaction id returns a error message", %{
      authenticated_conn: conn
    } do
      params = %{
        "transaction_id" => Ecto.UUID.generate()
      }

      assert %{"error" => %{"details" => "transaction not found"}} =
               conn
               |> patch(Routes.cumbucax_path(conn, :refund, params))
               |> json_response(:bad_request)
    end
  end
end
