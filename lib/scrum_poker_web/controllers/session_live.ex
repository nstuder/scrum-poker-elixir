defmodule ScrumPokerWeb.SessionLive do
  use Phoenix.LiveView
  alias ScrumPokerWeb.PokerSessions.PokerSessions
  require Logger

  @story_points [0, 1, 2, 3, 5, 8, 13, 20, 40, 100]

  def mount(%{"id" => id, "name" => name}, _session, socket) do
    #_pid = PokerSessions.start_link(id)
    PokerSessions.subscribe(id, self())
    state = PokerSessions.get_state(id)
    IO.puts("Mount State:")
    IO.inspect(state)
    {:ok, assign(socket, state: state, story_points: @story_points, sessionId: id, name: name)}
  end

  def render(assigns) do
    Logger.info(assigns)
    ~H"""
    <section class="flex justify-center flex-wrap">
    <%= for point <- @story_points do %>
      <div class="m-2">
        <button phx-click="select-points"
        value={point}
        class="w-40 h-56 cursor-pointer block border border-gray-200 shadow hover:bg-gray-100 rounded-lg pointer flex items-center justify-center">
          <div class="text-3xl"><%= point %></div>
        </button>
      </div>
    <% end %>
    </section>
    <section class="container mx-auto my-5">
      <div class="flex justify-between my-5">
        <button phx-click="reset" class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded">Reset</button>
        <button phx-click="view" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">View</button>
      </div>
      <table class="w-full border">
        <thead>
          <th>Name</th>
          <th>Story Points</th>
        </thead>
        <tbody>
        <%= for user <- @state.users do %>
          <tr class="mt-2">
            <td class="p-2">
              <%= user.name %>
            </td>
            <td class="p-2">
            <%= if @state.show do %>
              <%= user.selected %>
            <% end %>
            </td>
          </tr>
        <% end %>
        </tbody>
      </table>
    </section>
    """
  end

  def handle_event("select-points", %{"value" => value}, socket) do
    newState = PokerSessions.select_point(socket.assigns.sessionId, socket.assigns.name, value)
    {:noreply, assign(socket, state: newState)}
  end

  def handle_event("view", _params, socket) do
    {:noreply, assign(socket, state: PokerSessions.view(socket.assigns.sessionId))}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, state: PokerSessions.reset(socket.assigns.sessionId))}
  end

  def handle_info({:state_changed, state}, socket) do
    Logger.info("state changed")
    IO.inspect(state)
    {:noreply, assign(socket, state: state)}
  end
end
