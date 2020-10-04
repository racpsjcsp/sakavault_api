defmodule SakaVaultWeb.AuthControllerTest do
  use SakaVaultWeb.ConnCase

  setup %{conn: conn} do
    {
      :ok,
      conn: put_req_header(conn, "accept", "application/json"), user: insert(:user)
    }
  end

  describe "POST /login" do
    test "renders user when data is valid", %{conn: conn, user: user} do
      params = %{email: user.email, password: user.name}

      assert response =
               conn
               |> post(Routes.auth_path(conn, :login), params)
               |> json_response(201)

      assert %{
               "token" => _,
               "user" => %{
                 "id" => user_id,
                 "name" => user_name,
                 "email" => user_email
               }
             } = response

      assert %{id: ^user_id, name: ^user_name, email: ^user_email} = user
    end

    test "when user not found", %{conn: conn} do
      params = %{email: "invalidemail", password: "invalidpass"}

      assert %{"errors" => errors} =
               conn
               |> post(Routes.auth_path(conn, :login), params)
               |> json_response(404)

      assert %{"detail" => "Not Found"} = errors
    end

    test "when invalid password not found", %{conn: conn, user: user} do
      params = %{email: user.email, password: "invalidpass"}

      assert %{"errors" => errors} =
               conn
               |> post(Routes.auth_path(conn, :login), params)
               |> json_response(401)

      assert %{"detail" => "Unauthorized"} = errors
    end
  end

  describe "POST /register" do
    test "renders user when data is valid", %{conn: conn} do
      params = %{name: "John Doe", password: "johndoe123", email: "john@doe.com"}

      assert response =
               conn
               |> post(Routes.auth_path(conn, :register), params)
               |> json_response(201)

      assert %{
               "token" => token,
               "user" => %{
                 "name" => "John Doe",
                 "email" => "john@doe.com"
               }
             } = response
    end

    test "renders errors when data is invalid", %{conn: conn} do
      assert %{"errors" => errors} =
               conn
               |> post(Routes.auth_path(conn, :register), %{name: "John Doe"})
               |> json_response(422)

      assert %{
               "email" => ["can't be blank"],
               "password" => ["can't be blank"]
             } = errors
    end
  end
end
