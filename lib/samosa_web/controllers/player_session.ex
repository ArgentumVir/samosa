defmodule SamosaWeb.PlayerSession do
    import Plug.Conn

    def init(opts), do: opts

    def session_salt, do: "VEM6YQirj"
    def generate_user_id do
        Ecto.UUID.generate
    end

    def generate_user_id_token do
        Phoenix.Token.sign(
            SamosaWeb.Endpoint,
            session_salt(),
            generate_user_id()
        )
    end

    def verify_token(user_id_token) do
        Phoenix.Token.verify(
            SamosaWeb.Endpoint,
            SamosaWeb.PlayerSession.session_salt(),
            user_id_token
        )
    end

    def put_new_user_id_token(conn) do
        user_id = generate_user_id_token()

        conn
            |> put_session("user_id", user_id)
    end

    def call(conn, _opts) do
        case get_session(conn, "user_id") do
            nil -> put_new_user_id_token(conn)
            token -> 
                case verify_token(token) do
                    {:ok, _} -> conn
                    {:error, :expired} -> put_new_user_id_token(conn)
                    _ -> raise 'Unknown error'
                end
        end
    end
end