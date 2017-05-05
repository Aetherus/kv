defmodule KV.RegistryTest do
  use ExUnit.Case, async: true
  alias KV.{Bucket, Registry}

  setup context do
    {:ok, _registry} = Registry.start_link(context.test)
    {:ok, registry: context.test}
  end

  test "spawns buckets", %{registry: registry} do
    assert Registry.lookup(registry, "shopping") == :error

    Registry.create(registry, "shopping")
    assert {:ok, bucket} = Registry.lookup(registry, "shopping")

    Bucket.put(bucket, "milk", 1)
    assert Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    Registry.create(registry, "shopping")
    {:ok, bucket} = Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    _ = Registry.create(registry, "bogus")
    assert Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    Registry.create(registry, "shopping")
    {:ok, bucket} = Registry.lookup(registry, "shopping")

    ref = Process.monitor(bucket)
    Process.exit(bucket, :shutdown)

    assert_receive {:DOWN, ^ref, _, _, _}

    _ = Registry.create(registry, "bogus")
    assert Registry.lookup(registry, "shopping") == :error
  end
end
