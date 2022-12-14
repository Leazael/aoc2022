get_neigbours(c::CartesianIndex, w::Int64, h::Int64) = filter(x ->(x[1] in 1:w) && (x[2] in 1:h), [c + CartesianIndex(v...) for v in [(0,1), (1,0), (-1,0), (0,-1)]])

function dijkstra(M::Matrix{Int64}, init::Union{Vector{CartesianIndex{2}},BitMatrix})::Matrix{Int64}
    w, h, inf = size(M)..., length(M)
    unvisited = collect(CartesianIndices(M))[:]

    d = ones(Int64, size(M)) .* inf 
    d[init] .= 0

    while !isempty(unvisited)
        c = unvisited[findmin(d[unvisited])[2]]
        for v in filter(in(unvisited), get_neigbours(c, w, h))
            td = d[c] + (M[v] - M[c] ≤ 1  ? 1 : inf)
            d[v] = min(d[v], td)
        end
        filter!(!=(c), unvisited)
    end

    return d
end

str, fin, data = hcat(collect.(split(read("data/in12.dat", String), r"\R"))...) |> Q -> (findfirst.([Q .== 'S', Q .== 'E'])..., Q .- 'a')
data[[str, fin]] .= 0, 26

dijkstra(data, [str])[fin] |> Int64 |> println
dijkstra(data, data .== 0)[fin] |> Int64 |> println