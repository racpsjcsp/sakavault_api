defmodule SakaVault.Fields.HashTest do
  use SakaVault.DataCase

  alias SakaVault.Fields.Hash, as: Field

  test ".type is :binary" do
    assert Field.type() == :binary
  end

  test ".cast converts a value to a string" do
    assert {:ok, "42"} == Field.cast(42)
    assert {:ok, "atom"} == Field.cast(:atom)
  end

  test ".dump converts a value to a sha256 hash" do
    {:ok, hash} = Field.dump("hello")

    assert hash ==
             <<125, 10, 106, 68, 212, 30, 105, 212, 9, 99, 88, 83, 108, 103, 237, 11, 48, 82, 247,
               202, 127, 38, 121, 167, 237, 214, 94, 10, 149, 140, 108, 146>>
  end

  test ".hash converts a value to a sha256 hash with secret_key_base as salt" do
    hash = Field.hash("alex@example.com")

    assert hash ==
             <<95, 23, 61, 35, 115, 243, 90, 194, 40, 21, 89, 151, 170, 183, 155, 97, 63, 136,
               180, 195, 48, 55, 50, 204, 238, 198, 221, 75, 168, 29, 172, 27>>
  end

  test ".load does not modify the hash, since the hash cannot be reversed" do
    hash =
      <<16, 231, 67, 229, 9, 181, 13, 87, 69, 76, 227, 205, 43, 124, 16, 75, 46, 161, 206, 219,
        141, 203, 199, 88, 112, 1, 204, 189, 109, 248, 22, 254>>

    assert {:ok, ^hash} = Field.load(hash)
  end

  test ".equal? correctly determines hash equality and inequality" do
    hash1 =
      <<16, 231, 67, 229, 9, 181, 13, 87, 69, 76, 227, 205, 43, 124, 16, 75, 46, 161, 206, 219,
        141, 203, 199, 88, 112, 1, 204, 189, 109, 248, 22, 254>>

    hash2 =
      <<10, 231, 67, 229, 9, 181, 13, 87, 69, 76, 227, 205, 43, 124, 16, 75, 46, 161, 206, 219,
        141, 203, 199, 88, 112, 1, 204, 189, 109, 248, 22, 254>>

    assert Field.equal?(hash1, hash1)
    refute Field.equal?(hash1, hash2)
  end
end
