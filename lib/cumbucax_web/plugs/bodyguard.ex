defmodule CumbucaxWeb.BodyGuard do
  @moduledoc """
  Plug que verifica se o usuário tem como role admim ou não.
  """
  import Plug.Conn

  import Guardian.Plug, only: [current_resource: 1]

  def init(options), do: options

  def call(conn, _opts) do
    user = current_resource(conn)
    user_with_account = Cumbucax.Repo.preload(user, :account)

    assign(conn, :requester_account_id, user_with_account.account.id)
  end
end
