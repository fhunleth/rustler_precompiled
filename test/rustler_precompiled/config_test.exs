defmodule RustlerPrecompiled.ConfigTest do
  use ExUnit.Case, async: true

  alias RustlerPrecompiled.Config

  test "new/1 sets `force_build?` to true when pre-release version is used" do
    config =
      Config.new(
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0-dev"
      )

    assert config.force_build?
  end

  test "new/1 sets `force_build?` when configured" do
    config =
      Config.new(
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        force_build: true,
        version: "0.2.0"
      )

    assert config.force_build?
  end

  test "new/1 requireds `force_build` option when is not a pre-release" do
    assert_raise KeyError, ~r/key :force_build not found/, fn ->
      Config.new(
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0"
      )
    end
  end

  test "new/1 accepts a single string for targets" do
    opts = [
      otp_app: :rustler_precompiled,
      module: RustlerPrecompilationExample.Native,
      base_url:
        "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
      version: "0.2.0-dev"
    ]

    config = Config.new(opts ++ [targets: "aarch64-unknown-linux-gnu"])
    assert config.targets == ["aarch64-unknown-linux-gnu"]
  end

  test "new/1 validates the given targets" do
    opts = [
      otp_app: :rustler_precompiled,
      module: RustlerPrecompilationExample.Native,
      base_url:
        "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
      version: "0.2.0-dev"
    ]

    assert_raise RuntimeError,
                 "`:targets` should include at least one target",
                 fn ->
                   Config.new(opts ++ [targets: []])
                 end

    assert_raise RuntimeError,
                 "`:targets` should include at least one target",
                 fn ->
                   Config.new(opts ++ [targets: nil])
                 end

    assert_raise RuntimeError,
                 """
                 `:targets` contains targets that are not supported by Rust:

                 ["aarch64-unknown-linux-foo"]
                 """,
                 fn ->
                   Config.new(
                     opts ++
                       [
                         targets: [
                           "aarch64-unknown-linux-gnu",
                           "aarch64-unknown-linux-gnu_ilp32",
                           "aarch64-unknown-linux-musl",
                           "aarch64-unknown-linux-foo"
                         ]
                       ]
                   )
                 end
  end

  test "new/1 configures a set of default targets" do
    config =
      Config.new(
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0-dev"
      )

    assert config.targets == [
             "aarch64-apple-darwin",
             "aarch64-unknown-linux-musl",
             "x86_64-apple-darwin",
             "x86_64-unknown-linux-gnu",
             "x86_64-unknown-linux-musl",
             "arm-unknown-linux-gnueabihf",
             "aarch64-unknown-linux-gnu",
             "x86_64-pc-windows-msvc",
             "x86_64-pc-windows-gnu"
           ]
  end

  test "new/1 does not duplicate targets when is appended with the same value as defaults" do
    opts = [
      otp_app: :rustler_precompiled,
      module: RustlerPrecompilationExample.Native,
      base_url:
        "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
      version: "0.2.0-dev",
      targets: Config.default_targets() ++ ["aarch64-unknown-linux-musl"]
    ]

    config = Config.new(opts)

    assert config.targets == [
             "aarch64-apple-darwin",
             "aarch64-unknown-linux-musl",
             "x86_64-apple-darwin",
             "x86_64-unknown-linux-gnu",
             "x86_64-unknown-linux-musl",
             "arm-unknown-linux-gnueabihf",
             "aarch64-unknown-linux-gnu",
             "x86_64-pc-windows-msvc",
             "x86_64-pc-windows-gnu"
           ]
  end
end
