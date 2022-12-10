# step 1, load data
abstract type Dir end
struct Up <: Dir end; struct Down <: Dir end; struct Left <: Dir end; struct Right <: Dir end

const Coor = Tuple{Int64, Int64}
const Rope = Vector{Coor}

dirDict = Dict('R' => Right, 'U' => Up, 'D' => Down, 'L' => Left)
move(::Type{Up},    p::Coor)::Coor = p .+ (0, 1)
move(::Type{Down},  p::Coor)::Coor = p .- (0, 1)
move(::Type{Right}, p::Coor)::Coor = p .+ (1, 0)
move(::Type{Left},  p::Coor)::Coor = p .- (1, 0)
follow(dp::Coor) = (max( abs.(dp)...) ≤ 1) ? (0,0) : sign.(dp)

function move!(T::Type{<:Dir}, r::Rope)::Rope
    r[1] = move(T, r[1])
    for k = 2:lastindex(r) r[k] = r[k] .+ follow(r[k-1] .- r[k]) end
    return r
end

function evolve(moves, l::Int64)::Vector{Rope}
    swing = [[(0,0) for _ in 1:l]]
    for m in moves push!(swing, copy(move!(m, swing[end]))) end
    return swing    
end

# I frikking love loading data with oneliners!
moves = vcat([[dirDict[d[1]] for _ in 1:parse(Int64,d[3:end])] for d in split(read("data/in09.dat", String), "\r\n")]...)
length(unique([r[end] for r in evolve(moves, 2)]))  |> println
length(unique([r[end] for r in evolve(moves, 10)])) |> println