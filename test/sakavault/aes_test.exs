defmodule SakaVault.AESTest do
  use SakaVault.DataCase

  alias SakaVault.AES

  describe ".encrypt/1" do
    test "encrypt includes the random initial vector in the value" do
      <<initial_vector::binary-16, cipher_text::binary>> = AES.encrypt("hello")

      assert is_binary(cipher_text)

      assert String.length(cipher_text) != 0
      assert String.length(initial_vector) != 0
    end

    test "encrypt does not produce the same ciphertext twice" do
      assert AES.encrypt("hello") != AES.encrypt("hello")
    end
  end

  describe "decrypt/1" do
    test "decrypt cipher text that was encrypted with default key" do
      plain_text = "hello" |> AES.encrypt() |> AES.decrypt()

      assert plain_text == "hello"
    end

    test "can still decrypt the value after adding a new encryption key" do
      encrypted_value = "hello" |> AES.encrypt()

      original_keys = Application.get_env(:sakavault, SakaVault.EncryptionKeys)[:keys]

      Application.put_env(:sakavault, SakaVault.EncryptionKeys,
        keys: "#{original_keys},#{:base64.encode(:crypto.strong_rand_bytes(32))}"
      )

      assert "hello" == encrypted_value |> AES.decrypt()

      Application.put_env(:sakavault, SakaVault.EncryptionKeys, keys: original_keys)
    end
  end
end
