defmodule Samosa.LobbyManagerTest do
  use ExUnit.Case, async: true
  alias Samosa.LobbyManager

  setup do
    # lobby_manager = start_supervised!(Samosa.LobbyManager)
    # %{lobby_manager: lobby_manager}
    :ok
  end

    test "CRUD room", _state do
      host_id = Ecto.UUID.generate()
      room = LobbyManager.create_lobby(host_id)
      room_code = room.room_code

      assert %{
        host_user_id: ^host_id,
        member_ids: [^host_id],
        room_code: ^room_code,
      } = room

      assert %{
        host_user_id: ^host_id,
        member_ids: [^host_id],
        room_code: ^room_code,
      } = LobbyManager.create_lobby(host_id)

      assert %{
        host_user_id: ^host_id,
        member_ids: [^host_id],
        room_code: ^room_code,
      } = LobbyManager.get_lobby(room.room_code)

      assert %{
        host_user_id: ^host_id,
        member_ids: [^host_id],
        room_code: ^room_code,
      } = LobbyManager.join_lobby(host_id, room.room_code)

      user_id = Ecto.UUID.generate()

      assert %{
        host_user_id: ^host_id,
        member_ids: [^host_id, ^user_id],
        room_code: ^room_code,
      } = LobbyManager.join_lobby(user_id, room.room_code)

      assert :ok = LobbyManager.delete_lobby(host_id, room.room_code)

      assert 404 = LobbyManager.join_lobby(user_id, room.room_code)
    end

    
  end