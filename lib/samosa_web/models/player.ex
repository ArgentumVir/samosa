defmodule SamosaWeb.Player do
    use Ecto.Schema
    import Ecto.Changeset
  
    embedded_schema do
      field :name
      field :room_code
    end
  
    def changeset(attrs, player \\ %SamosaWeb.Player{}) do
        player
            |> cast(attrs, [:name, :room_code])
            |> validate_required([:name, :room_code])
            |> validate_length(:name, min: 1, max: 32)
            |> validate_length(:room_code, is: 3)
            |> validate_format(:room_code, ~r/\d/, message: "only numbers allowed")
    end
  end