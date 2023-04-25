defmodule ScrumPokerWeb.SessionLive do
  use Phoenix.LiveView
  import ScrumPokerWeb.PokerSessions.PokerSessions
  alias ScrumPokerWeb.PokerSessions.PokerSessions
  require Logger

  @story_points [0, 1, 2, 3, 5, 8, 13, 20, 40, 100]

  def mount(%{"id" => id}, session, socket) do
    pid = PokerSessions.start_link(id)
    PokerSessions.subscribe(id, self())
    state = PokerSessions.get_state(id)
    {:ok, assign(socket, state: state, story_points: @story_points, sessionId: id)}
  end

  def render(assigns) do
    Logger.info(assigns)
    ~H"""
    <div>Hello from live</div>
    <section class="flex align-items-evenly">
    <%= for point <- @story_points do %>
      <div class="mx-2">
        <button phx-click="select-points" value={point}>
          <%= point %>
        </button>
      </div>
    <% end %>
    </section>
    <button phx-click="view">View</button>
    <button phx-click="reset">Reset</button>
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
    """
  end

  def handle_event("select-points", %{"value" => value}, socket) do
    newState = PokerSessions.select_point(socket.assigns.sessionId, "Niklas", value)
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
