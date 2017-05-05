defmodule KV.Registry do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def lookup(server, name) when is_atom(server) do
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  #def lookup(server, name) do
  #  GenServer.call(server, {:lookup, name})
  #end

  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  def stop(server) do
    GenServer.stop(server)
  end

  def init(table) do
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end
  
  #def handle_call({:lookup, name}, _from, {names, _} = state) do
  #  {:reply, Map.fetch(names, name), state}
  #end

  def handle_call({:create, name}, _from, {names, refs} = state) do
    case lookup(names, name) do
      {:ok, bucket} ->
        {:reply, bucket, state}
      :error ->
        {:ok, bucket} = KV.BucketSupervisor.start_bucket()
        ref = Process.monitor(bucket)
        refs = Map.put(refs, ref, name)
        # names = Map.put(names, name, bucket)
        :ets.insert(names, {name, bucket})
        {:reply, bucket, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    #names = Map.delete(names, name)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_, state), do: {:noreply, state}
end
