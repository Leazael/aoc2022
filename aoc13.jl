# Make a new vector type. (I could overload the standard vectors, but ugly)
struct Packet{Any} <: AbstractVector{Any}
    v::Vector{Any}
end
Packet(v) = Packet{Any}(v)

# implement minimal behaviour needed voor vector type
Base.size(p::Packet) = size(p.v)
Base.getindex(p::Packet, i::Integer) = p.v[i]
Base.getindex(p::Packet, u::UnitRange)::Packet = Packet(p.v[u])

# function to repackage the first element in case of type mismatch
repack(p::Packet) = isa(p[1], Int64) ? Packet([p[1]]) : Packet(p[1])

# implement isless, which is called by '<', and all other comparators
function Base.isless(a::Packet,b::Packet)::Bool
    if isempty(a) || isempty(b) 
        return isempty(a) 
    end

    ca, cb = isa(a[1], Int64) && isa(b[1], Int64) ? (a[1], b[1]) : repack.((a, b))

    return ca == cb ? a[2:end] < b[2:end] : ca < cb
end

# load data
data = map(x -> Packet.(eval.(Meta.parse.(split(x, r"\R")))), split(read("data/in13.dat",String), r"\R\R"))

# part 1
sum(findall([<(x...) for x in data])) |> println # 6420

# part 2
dividers = [Packet([[2]]), Packet([[6]])]
*(findall([s in dividers for s in sort([vcat(data...); dividers])])...) |> println #22000