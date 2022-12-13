defmodule Genservers do
  use GenServer

  defmodule User do
    defstruct [:id, :username, :email, :password]
  end

  def start() do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  def push(element) do
    GenServer.cast(__MODULE__, {:push, element})
  end

  def pop() do
    GenServer.cast(__MODULE__, :pop)
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  @impl true
  def init(_state) do
    {:ok, []}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end

  @impl true
  def handle_cast(:pop, state) do
    [_head | tail] = state
    {:noreply, tail}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, {:current_state, state}, state}
  end
end
