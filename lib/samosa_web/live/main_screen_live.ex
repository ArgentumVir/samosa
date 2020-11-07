defmodule SamosaWeb.MainScreenLive do
  use SamosaWeb, :live_view
  use Phoenix.HTML
  alias SamosaWeb.Player

  @impl true
  def mount(params, %{"user_id" => user_id_token}, socket) do
    {:ok, assign(
        socket,
        user_id: decode_user_id_token(user_id_token),
        changeset: Player.changeset(%{name: nil, room_code: nil}),
        is_join_disabled: true,
        is_host_disabled: true
      )
    }
  end

  def decode_user_id_token(user_id_token) do
    case Phoenix.Token.verify(SamosaWeb.Endpoint, SamosaWeb.PlayerSession.session_salt(), user_id_token) do
        {:ok, user_id} -> user_id
        _ -> raise("Invalid user_id_token")
    end
  end

  @impl true
  def handle_event("join", %{"player" => %{"name" => name, "room_code" => room_code}}, socket) do
    case socket.assigns.changeset.errors do
      [] ->
          {:noreply, push_redirect(socket, to: Routes.live_path(socket, SamosaWeb.LobbyLive, intent: :join, code: room_code, name: name))}
      _ ->
        {:noreply, socket}
      end
  end

  def handle_event("host", payload, socket) do
    case Keyword.has_key?(socket.assigns.changeset.errors, :name) do
      true ->
        {:noreply, socket}
      false ->
        {:noreply, push_redirect(socket, to: Routes.live_path(socket, SamosaWeb.LobbyLive, intent: :host, name: socket.assigns.changeset.changes.name))}
    end
  end

  def handle_event("validate", %{"player" => params}, socket) do
    player = Player.changeset(params)
      |> Map.put(:action, :insert)

    {
      :noreply,
      assign(
        socket,
        changeset: player,
        is_join_disabled: is_join_disabled?(params, player.errors),
        is_host_disabled: is_host_disabled?(params, player.errors)
      )
    }
  end

  def is_join_disabled?(%{"name" => name, "room_code" => room_code}, errors) do
    name == "" || room_code == "" || errors != []
  end

  def is_host_disabled?(%{"name" => name}, errors) do
    name == "" || Keyword.has_key?(errors, :name)
  end
end
