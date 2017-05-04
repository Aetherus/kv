defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  alias KV.Bucket

  setup do
    {:ok, bucket} = KV.Bucket.start_link()
    {:ok, bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert Bucket.get(bucket, "milk") == nil

    Bucket.put(bucket, "milk", 3)
    assert Bucket.get(bucket, "milk") == 3
  end

  test "deletes key and returns the current value", %{bucket: bucket} do
    Bucket.put(bucket, "milk", 3)
    assert Bucket.delete(bucket, "milk") == 3
    assert Bucket.get(bucket, "milk") == nil
    assert Bucket.delete(bucket, "cheese") == nil
  end
end
