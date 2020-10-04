defmodule SakaVaultWeb.AccountControllerTest do
  use SakaVaultWeb.ConnCase

  setup %{conn: conn} do
    {
      :ok,
      conn: put_req_header(conn, "accept", "application/json"), user: insert(:user)
    }
  end

  describe "GET /show" do
    test "returns error if user not authenticated", %{conn: conn} do
      assert %{"errors" => errors} =
               conn
               |> get(Routes.account_path(conn, :show))
               |> json_response(401)

      assert %{"detail" => "unauthenticated"} = errors
    end

    test "returns error if invalid token is used", %{conn: conn} do
      assert %{"errors" => errors} =
               conn
               |> put_req_header("authorization", "Bearer invalid_token")
               |> get(Routes.account_path(conn, :show))
               |> json_response(401)

      assert %{"detail" => "invalid_token"} = errors
    end

    test "returns current user", %{conn: conn, user: user} do
      assert response =
               conn
               |> put_authorization(user)
               |> get(Routes.account_path(conn, :show))
               |> json_response(200)

      assert %{
               "id" => user.id,
               "name" => user.name,
               "email" => user.email
             } == response
    end
  end
end
