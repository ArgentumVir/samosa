defprotocol ToKlist do
    def to_klist(map)
end

defimpl ToKlist, for: Map do
    def to_klist(dict), do: Enum.map(dict, fn({k, v}) -> {k, v} end)
end
