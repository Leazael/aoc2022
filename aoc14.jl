const Wall, Free, Sand = '#', '.', '∘'
const FallDirections = [[0,1], [-1, 1], [1, 1]]

drawcave(cave::Matrix{Char}) = join(join.(eachrow(permutedims(cave))),'\n') |> println

function find_walls(lines::Vector{Vector{Vector{Int64}}})
    walls = Vector{Int64}[]
    for d in lines 
        for k in 1:length(d)-1
            p1, p2 = ([CartesianIndex(c...) for c in eachcol(sortslices(hcat(d[k], d[k+1]), dims = 2))])
            unique!(append!(walls, [[Tuple(x)...] for x in (p1:p2)[:]]))
        end
    end
    return walls
end

function build_cave(walls::Vector{Vector{Int64}})
    h = max(last.(walls)...) + 3
    w = 2*h + 1
    offset = [500 - (w ÷ 2) - 1, -1]
    cave = repeat(['.'], w, h)
    for w in walls  
        cave[(w .- offset)...] = Wall
    end
    cave[:,end] .= Wall
    return (offset, cave )
end

function step!(cave::Matrix{Char}, s)::Bool
    filter!(y -> (y[2] in 1:size(cave,2)) && (y[1] in 1:size(cave,1)) && (cave[y...] == Free), [s + x for x in FallDirections])

    if isempty(opts) return false end

    s[1], s[2] = opts[1][1], opts[1][2]
    return true
end

function drop!(cave::Matrix{Char}, s::Vector{Int64}, void::Int64)::Bool
    if cave[s...] == Sand return false end

    while step!(cave,s) end

    if s[2] + void < size(cave,2)
        cave[s...] = Sand
        return true 
    else 
        return false
    end
end

function fill!(cave::Matrix{Char}, s::Vector{Int64}, void::Int64)
    k = 0
    while drop!(cave, copy(s), void) k+= 1 end
    return k
end

o, cave = [[parse.(Int64,m) for m in eachmatch(r"(\d+),(\d+)", d)] for d in split(read("data/in14.dat", String), r"\R")] |> find_walls |> build_cave

cave1 = copy(cave)
fill!(cave1, [500, 0] - o, 1) |> println
# cave1 |> drawcave

cave2 = copy(cave)
@time fill!(cave2, [500, 0] - o, 0) |> println
# cave2 |> drawcave