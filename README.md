# Cumbucax

## Acessando a API online

A API está disponível no endereço abaixo:

[cumbucax.gigalixirapp.com/api](https://cumbucax.gigalixirapp.com/api)

Para facilitar o acesso, alguns usuários e suas respectivas contas foram criados.

```json
{
  "first_name": "Lana",
  "last_name": "Doe",
  "password": "123senha",
  "cpf": "005.006.007-08"
  "account": {
      "number": "654321",
      "branch": "0001",
      "digit": "7"
  }
}

{
  "first_name": "John",
  "last_name": "Doe",
  "password": "123senha",
  "cpf": "001.002.003-04"
  "account": {
      "number": "123456",
      "branch": "0001",
      "digit": "7"
  }
}
```

## Rodando localmente

Com a inenção de facilitar a iniclização e o uso da aplicação localmente, criei um setup para o uso do banco de dados.

## Postman collection

Caso você utilize o Postman como interface para enviar requisições para API's, basta acessar o link abaixo que você terá acesso a uma coleção de requisições tanto no ambiente de produção quanto do de desenvolvimento.

### [Cumbucax Public Workspace Postman](https://www.postman.com/restless-capsule-16017/workspace/cumbucax/overview)

## Utilização da API
### Registro de Conta Bancaria

**[POST]** _/api/register_

Criação de novas contas bancárias. Não é permitido criar mais de uma conta bancária com o uso do mesmo CPF.

```json
Exemplo de requisição

{
    "account": {
        "cpf": "xxx.xxx.xxx-xx", // formato padrao para envio xxx.xxx.xxx-xx
        "first_name": "FIRST_NAME",
        "last_name": "LAST_NAME",
        "password": "SENHA", // minimo de 06 e maximo de 10
        "balance": "R$ 1.000,00" // formato padrao para envio R$ 9.999,99
    }
}
```

```json
Exemplo da resposta

{
    "data": {
        "account": {
            "balance": "R$1.000,00",
            "branch": "0001",
            "digit": "7",
            "number": "215900",
            "owner": "FIRST_NAME LAST_NAME"
        },
        "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9..."
    }
}
```

**[POST]** _/api/login_

Login de usuário. Só será possível acessar as demais rotas abaixo com um token válido.

```json
Exemplo de requisição

{

    "cpf": "xxx.xxx.xxx-xx",
    "password": "10203040"

}
```

```json
Exemplo da resposta

{
    "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9 ..."
}
```

**[POST]** _/api/transactions

Realiza transferências a partir da conta do usuário logado para a conta do beneficiário escolhido.

```json
Exemplo de requisição

{
    "transfer": {
        "branch": "0001",
        "number": "123456",
        "digit": "7",
        "amount": "R$ 4,00" // formato padrao para envio R$ x,xx
    }
}
```

```json
Exemplo da resposta

{
    "data": {
        "transfer": {
            "balance": "R$996,00",
            "result": "transfer done",
            "transaction_id": "8d656ed0-641d-4929-b891-e3caad553651"
        }
    }
}
```


**[PATCH]** _/api/transactions/refund_

Reliza um estorno da transação cujo ID é passado via requisição.

```json
Exemplo de requisição

{
    "transaction_id": "1991cf1d-2ec3-4838-ad86-683d9f35cf4b"
}
```

```json
Exemplo da resposta

{
    "data": {
        "transfer_refund": {
            "message": "refund done",
            "transaction": "1991cf1d-2ec3-4838-ad86-683d9f35cf4b"
        }
    }
}
```

**[GET]** _/api/transactions_

Retorna todas as transações de acordo com os filtros abaixo que devem ser enviados
via _query params_:

- id = ID da transação
- from = data de inicio para a busca no padrão ISO-8601: 2022-04-21 16:13:50
- to = data final para a busca no padrão ISO-8601: 2022-04-22 19:13:50
- beneficiary_account_id = ID da conta beneficiada pela transação

Para escolher o tipo de relatório basta enviar a requisição
como nos exemplos abaixo:


```json
Exemplo da resposta

{
    "data": [
        {
            "amount": "R$4,00",
            "beneficiary_account_id": "5bbe32ba-4044-4be0-9718-c57938d121ce",
            "id": "8d656ed0-641d-4929-b891-e3caad553651",
            "status": "refunded",
            "transaction_at": "2022-04-22T20:38:30"
        }
    ]
}
```
