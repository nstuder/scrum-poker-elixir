defmodule ScrumPokerWeb.PageController do
  use ScrumPokerWeb, :controller
  require Logger
  alias ScrumPokerWeb.PokerSessions.PokerSessions


  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def login(conn, %{"sessionId" => session_id}) do
    Logger.info("login to Session")
    redirect(conn, to: "/session/#{session_id}")
  end

  def create(conn, _params) do
    Logger.info("create new Session")
    id = "abcdefg"
    PokerSessions.start_link(id)
    redirect(conn, to: "/session/#{id}?name=Niklas")
  end

  def join(conn, %{"id" => session_id}) do
    Logger.info("join Session")
    PokerSessions.add_user(session_id, %{name: "Lisa", selected: ""})
    redirect(conn, to: "/session/#{session_id}?name=Lisa")
  end
end
