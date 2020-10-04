defmodule SakaVault.Fields.EncryptedTest do
  use SakaVault.DataCase

  alias SakaVault.Fields.Encrypted, as: Field

  test ".type is :binary" do
    assert Field.type() == :binary
  end

  test ".cast converts a value to a string" do
    assert {:ok, "123"} == Field.cast(123)
  end

  test ".dump encrypts a value" do
    {:ok, cipher_text} = Field.dump("hello")

    assert cipher_text != "hello"
    assert String.length(cipher_text) != 0
  end
end
