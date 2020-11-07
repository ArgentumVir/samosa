defmodule Samosa.LobbyManager do
    use GenServer

    def subscribe(room_code) do
        Phoenix.PubSub.subscribe(Samosa.PubSub, "#{__MODULE__}:#{room_code}")
        Phoenix.PubSub.subscribe(Samosa.PubSub, "#{__MODULE__}")
    end

    def broadcast_to_room(room_code, message) do
        Phoenix.PubSub.broadcast(Samosa.PubSub, "#{__MODULE__}:#{room_code}", message)
    end

    def broadcast_to_all(message) do
        Phoenix.PubSub.broadcast(Samosa.PubSub, "#{__MODULE__}", message)
    end

    def init(lobby_data) do
        Process.flag(:trap_exit, true)
        {:ok, lobby_data}
    end

    def start_link(_opts) do
        GenServer.start_link(__MODULE__,  %{}, name: __MODULE__)
    end
    
    def create_lobby(host_user_id) do
       GenServer.call(__MODULE__, {:create, host_user_id})
    end

    def get_lobby(room_code) do
        GenServer.call(__MODULE__, {:get, room_code})
    end

    def delete_lobby(host_user_id, room_code) do
        GenServer.cast(__MODULE__, {:delete, host_user_id, room_code})
    end

    # Room limits not implemented
    def join_lobby(member_id, room_code) do
        GenServer.call(__MODULE__, {:join, member_id, room_code})
    end

    # Server

    def handle_cast({:delete, host_user_id, room_code}, lobby_data) do
        {
            :noreply,
            Map.delete(lobby_data, host_user_id)
                |> Map.delete(room_code)
        }
    end

    def handle_call({:create, host_user_id}, _from, lobby_data) do
        with 404 <- get_room_from_host_id(host_user_id, lobby_data),
            room_code <- questionably_generate_room_code(lobby_data),
            initial_room_state <- %{ host_user_id: host_user_id, member_ids: [host_user_id], room_code: room_code }
        do
            {
                :reply,
                initial_room_state,
                Map.put(lobby_data, host_user_id, initial_room_state)
                    |> Map.put(to_string(room_code), host_user_id)
            }
        else
            room -> { :reply, room, lobby_data }
        end
    end

    def handle_call({:get, room_code}, _from, lobby_data) do
        {
            :reply,
            get_room_from_code(room_code, lobby_data),
            lobby_data
        }
    end

    def handle_call({:join, member_id, room_code}, _from, lobby_data) do
        with  room = %{ host_user_id: host_user_id, member_ids: member_ids } <- get_room_from_code(room_code, lobby_data) do
            if Enum.member?(member_ids, member_id) do
                {
                    :reply,
                    room,
                    lobby_data
                }
            else
                new_lobby_data = update_in(lobby_data[host_user_id][:member_ids], &(&1 ++ [member_id]))
                updated_room = new_lobby_data[host_user_id]

                broadcast_to_room(room_code, updated_room: updated_room)

                {
                    :reply,
                    updated_room,
                    new_lobby_data
                }
            end
        else
            404 ->
                IO.inspect "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                IO.inspect room_code
                IO.inspect lobby_data
                {
                    :reply,
                    404,
                    lobby_data
                }
        end
    end

    # def handle_call({:remove_member, member_id, room_code}, _from, lobby_data) do
    #     broadcast_to_room(room_code, message)
    # end

    # In unlikely event you get lots of rooms, this will end up being bad
    # Case for :full not handled, will hang until room empties
    def questionably_generate_room_code(lobby_data) do
        room_code = Enum.random(100..999)

        case Map.get(lobby_data, room_code, :open) do
            :open -> room_code
            _ -> questionably_generate_room_code(lobby_data)
        end
    end

    def get_room_from_code(room_code, lobby_data) do
        case Map.get(lobby_data, room_code, 404) do
            404 -> 404
            host_user_id -> Map.get(lobby_data, host_user_id)
         end
    end

    def get_room_from_host_id(host_user_id, lobby_data) do
        case Map.get(lobby_data, host_user_id, 404) do
            404 -> 404
            room -> room
        end
    end

    def terminate(reason, lobby_data) do
        broadcast_to_all(:server_shutdown)
        IO.inspect "LobbyManager TERMINATE called."

        :normal
    end
end