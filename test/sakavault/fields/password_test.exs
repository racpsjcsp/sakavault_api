defmodule SakaVault.Fields.PasswordTest do
  use SakaVault.DataCase

  alias SakaVault.Fields.Password, as: Field

  test ".type is :binary" do
    assert Field.type() == :binary
  end

  test ".cast converts a value to a string" do
    assert {:ok, "42"} == Field.cast(42)
    assert {:ok, "atom"} == Field.cast(:atom)
  end

  test ".dump returns an Argon2id Hash given a password string" do
    {:ok, result} = Field.dump("password")

    assert is_binary(result)
    assert String.starts_with?(result, "$argon2id$v=19$m=65536,t=6,p=1$")
  end

  test ".load does not modify the hash, since the hash cannot be reversed" do
    hash = Field.hash_password("password")

    assert {:ok, ^hash} = Field.load(hash)
  end

  test ".equal? correctly determines hash equality and inequality" do
    hash1 = Field.hash_password("password")
    hash2 = Field.hash_password("password")

    assert Field.equal?(hash1, hash1)
    refute Field.equal?(hash1, hash2)
  end

  test "hash_password/1 uses Argon2id to Hash a value" do
    password = "EverythingisAwesome"
    hash = Field.hash_password(password)

    assert Argon2.verify_pass(password, hash)
  end

  test "verify_password checks the password against the Argon2id Hash" do
    password = "EverythingisAwesome"
    hash = Field.hash_password(password)

    assert Field.verify_password(password, hash)
  end

  test ".verify_password fails if password does NOT match hash" do
    password = "EverythingisAwesome"
    hash = Field.hash_password(password)

    refute Field.verify_password("LordBusiness", hash)
  end
end
