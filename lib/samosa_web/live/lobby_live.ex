defmodule SamosaWeb.LobbyLive do
    use SamosaWeb, :live_view
    use Phoenix.HTML

    @connection_poll_interval 2000
  #  alias SamosaWeb.Player

    def mount(%{"intent" => "host", "name" => name}, %{"user_id" => user_id_token}, socket) do
      user_id = decode_user_id_token(user_id_token)

      case connected?(socket) do
        true ->
            {
              :ok,
              assign(socket, room: load_room_as_host(user_id), loaded: true, user_id: user_id, name: name, server_shutdown: false, disconnected: false)
            }
        false ->
            {:ok, assign(socket, user_id: user_id, name: name, loaded: false, server_shutdown: false, disconnected: false)}
      end
    end

    def mount(%{"intent" => "join", "name" => name, "code" => room_code}, %{"user_id" => user_id_token}, socket) do
      user_id = decode_user_id_token(user_id_token)

      case connected?(socket) do
        true ->
            {
              :ok,
              assign(socket, room: load_room_as_guest(user_id, room_code), loaded: true, user_id: user_id, name: name, server_shutdown: false, disconnected: false)
            }
        false ->
            {:ok, assign(socket, user_id: user_id, name: name, loaded: false, server_shutdown: false, disconnected: false)}
      end
    end

    def mount(_, _, socket), do: {:ok, push_redirect(socket, to: Routes.live_path(socket, SamosaWeb.MainScreenLive))}

    def load_room_as_host(host_user_id) do
      room = Samosa.LobbyManager.create_lobby(host_user_id)

      Samosa.LobbyManager.subscribe(room.room_code)
      # Process.send_after(self(), :update, @connection_poll_interval)

      room
    end

    def load_room_as_guest(user_id, room_code) do
      room = Samosa.LobbyManager.join_lobby(user_id, room_code)

      Samosa.LobbyManager.subscribe(room_code)
      # Process.send_after(self(), :update, @connection_poll_interval)

      room
    end

    # def handle_info(:check_for_disconnect, socket) do
    #     case get_connect_info(socket) do
    #       nil -> {:noreply, assign(socket, disconnected: true)}
    #       _ -> {:noreply, socket}
    #     end
    # end

    def handle_info(:server_shutdown, socket) do
      {:noreply, assign(socket, server_shutdown: true)}
    end

    def handle_info({:updated_room, room}, socket) do
      {:noreply, assign(socket, room: room)}
    end
  
    # def handle_info({:player_joined, room}, socket) do
    #   {:noreply, assign(socket, room: room)}
    # end

    # def handle_info({:player_left, room}, socket) do
    #   {:noreply, assign(socket, room: room)}
    # end

    # def handle_info({:new_host, room}, socket) do
    #   {:noreply, assign(socket, room: room)}
    # end

    def decode_user_id_token(user_id_token) do
      case Phoenix.Token.verify(SamosaWeb.Endpoint, SamosaWeb.PlayerSession.session_salt(), user_id_token) do
          {:ok, user_id} -> user_id
          _ -> raise("Invalid user_id_token")
      end
    end
end