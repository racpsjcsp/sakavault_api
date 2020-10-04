defmodule SakaVaultWeb.AccountController do
  use SakaVaultWeb, :controller

  action_fallback SakaVaultWeb.FallbackController

  def action(conn, _) do
    user = Guardian.Plug.current_resource(conn)

    apply(
      __MODULE__,
      action_name(conn),
      [conn, conn.params, user]
    )
  end

  def show(conn, _params, user) do
    render(conn, "account.json", user: user)
  end
end
