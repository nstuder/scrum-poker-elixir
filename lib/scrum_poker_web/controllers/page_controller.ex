defmodule ScrumPokerWeb.PageController do
  use ScrumPokerWeb, :controller
  require Logger


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
    redirect(conn, to: "/session")
  end
end
