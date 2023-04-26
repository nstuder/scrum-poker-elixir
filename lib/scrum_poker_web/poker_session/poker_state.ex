defmodule ScrumPokerWeb.PokerSessions.PokerSessions do
  use GenServer
  alias :global, as: Global

  def start_link(name) do
    case GenServer.start_link(__MODULE__, %{users: [%{name: "Niklas", selected: ""}], show: false, subscribers: []}, name: {:global, name}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def subscribe(id, subscriber) do
    pid = Global.whereis_name(id)
    GenServer.cast(pid, {:subscribe, subscriber})
  end

  def unsubscribe(id, subscriber) do
    pid = Global.whereis_name(id)
    GenServer.cast(pid, {:unsubscribe, subscriber})
  end

  def init(state), do: {:ok, state}

  def add_user(id, user) do
    pid = Global.whereis_name(id)
    GenServer.cast(pid, {:add_user, user})
  end

  def select_point(id, user, value) do
    pid = Global.whereis_name(id)
    GenServer.call(pid, {:select_point, user, value})
  end

  def view(id) do
    pid = Global.whereis_name(id)
    GenServer.call(pid, :view)
  end

  def reset(id) do
    pid = Global.whereis_name(id)
    GenServer.call(pid, :reset)
  end

  def get_state(id) do
    pid = Global.whereis_name(id)
    GenServer.call(pid, :get_state)
  end


  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:view, _from, %{subscribers: subscribers} = state) do
    newState = state |> Map.put(:show, true)

    subscribers |> Enum.each(fn sub ->
      send(sub, {:state_changed, newState})
    end)
    {:reply, newState, newState}
  end

  def handle_call(:reset, _from, %{subscribers: subscribers, users: users} = state) do
    newState = state
    |> Map.put(:show, false)
    |> Map.put(:users, users |> Enum.map(fn %{name: name} -> %{name: name, selected: ""} end))

    subscribers |> Enum.each(fn sub ->
      send(sub, {:state_changed, newState})
    end)
    {:reply, newState, newState}
  end

  def handle_call({:select_point, user, value}, _from, %{subscribers: subscribers, users: users} = state) do
    newUsers = users
      |> Enum.map(fn x -> if x[:name] == user, do: Map.put(x, :selected, value), else: x end)

    newState = state |> Map.put(:users, newUsers)

    subscribers |> Enum.each(fn sub ->
      send(sub, {:state_changed, newState})
    end)
    {:reply, newState, newState}
  end

  def handle_cast({:add_user, user}, %{users: users, subscribers: subscribers} = state) do
    newState = Map.put(state, :users, [user | users])
    subscribers |> Enum.each(fn sub ->
      send(sub, {:state_changed, newState})
    end)

    {:noreply, Map.put(state, :users, [user | users])}
  end

  def handle_cast({:subscribe, subscriber}, %{subscribers: subs} = state) do
    {:noreply, Map.put(state, :subscribers , [subscriber | subs])}
  end

  def handle_cast({:unsubscribe, subscriber}, %{subscribers: subs} = state) do
    {:noreply, Map.put(state, :subscribers , List.delete(subs, subscriber))}
  end

end
