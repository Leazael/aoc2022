using LinearAlgebra

const data = map(s -> parse.(Int64, split(s, ',')), split(read("data/in18.dat", String), r"\R"))
const Diameter = vcat(data...) |> d -> ceil(Int64, (3 + max(d...) - min(d...)) * sqrt(3))

const Sides = [([0,0,0], [1,1,0]),([0,0,0], [0,1,1]),([0,0,0], [1,0,1]),([1,1,1], [1,0,0]),([1,1,1], [0,1,0]),([1,1,1], [0,0,1])]

allSurf = vcat([[(s[1]+d, s[2]+d) for s in Sides] for d in data]...)
allCOMs = [c[1] + c[2] for c in allSurf]
const Surfaces = filter(x -> count(map(==(x[1]+x[2]), allCOMs)) == 1, allSurf)

function is_feasible(c::Vector{Int64}, pp::Vector{Vector{Int64}}, dir::Int64 )
    tt = filter(d -> (c[1:3 .!= dir] == d[1:3 .!= dir]) , pp)
    if isempty(tt) return false end
    v = [t[dir] for t in tt]
    return min(v...) < c[dir] < max(v...)
end
is_feasible(c::Vector{Int64}, pp::Vector{Vector{Int64}}) = is_feasible(c,pp,1) &&  is_feasible(c,pp,2) && is_feasible(c,pp,3)


# first generate a list of "suspect" locations
# that is, data points, with data in all six sides 
const MinSize = [min([d[k]-1 for d in data]...) for k in 1:3]
const MaxSize = [max([d[k]+1 for d in data]...) for k in 1:3]

const Neighbours = [[1,0,0], [-1,0,0], [0,1,0], [0,-1,0], [0,0,1], [0,0,-1]]
get_neighbours(p::Vector{Int64}) = filter(r -> all( MinSize .≤ r ) && all( r .≤ MaxSize ) ,  [p + q for q in Neighbours])


# write a fill algorythm
exterior = Vector{Int64}[]

unadded = [MinSize]
while !isempty(unadded)
    p = popfirst!(unadded)
    nb = get_neighbours(p)
    filter!(!in(data), nb)
    filter!(!in(unadded), nb)
    filter!(!in(exterior), nb)

    append!(unadded, nb)
    push!(exterior, p)
end


allSurfExt = vcat([[(s[1]+d, s[2]+d) for s in Sides] for d in exterior]...)
allCOMsExt = [c[1] + c[2] for c in allSurfExt]
filter!(x -> count(map(==(x[1]+x[2]), allCOMsExt)) == 1, allSurfExt)

length(allSurfExt) - (6* (22^2)) 