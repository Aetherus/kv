defmodule KV.RegistryTest do
  use ExUnit.Case, async: true
  alias KV.{Bucket, Registry}

  setup do
    {:ok, registry} = Registry.start_link()
    {:ok, registry: registry}
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
    assert Registry.lookup(registry, "shopping") == :error
  end
end
