
function part1(pp::Vector{Pair{Vector{Int64}, Vector{Int64}}}, y::Int64)
    xx = UnitRange{Int64}[]
    for p in pp 
        pS, pB = p
        r = sum(abs.(pS - pB))
        if abs(pS[2] - y) ≤ r 
            push!(xx, range(sort([r - abs(pS[2] - y) + pS[1], pS[1] - (r - abs(pS[2] - y))])...))
        end
    end
    return filter(!in(first.(unique(filter(p -> p[2] == y, last.(pp))))), unique(vcat(collect.(xx)...)))
end

circle(r::Int64) = [[[k, r - k] for k in 0:r-1]; [[r-k, -k] for k in 0:r-1]; [[-k, -r+k] for k in 0:r-1]; [[-r+k, k] for k in 0:r-1]]
circle(p::Vector{Int64}, r::Int64) = [p + q for q in circle(r)]

function investigate_edge(pp::Vector{Pair{Vector{Int64}, Vector{Int64}}}, k::Int64, m::Int64)
    pS, pB = pp[k]
    r = sum(abs.(pS - pB))
    circ = circle(pS, r + 1)
    filter!(c -> (c[1] in 0:m) && (c[2] in 0:m), circ)
    rr = [sum(abs.(p[1] - p[2])) for p in pp]

    for j in filter(!=(k), 1:length(pp))
        filter!(c -> sum(abs.(c - pp[j][1])) > rr[j], circ)
        if isempty(circ)
            return nothing 
        end
    end
    
    return circ    
end

function find_beacon(pp::Vector{Pair{Vector{Int64}, Vector{Int64}}}, m::Int64)
    for k = 1:length(pp)
        c = investigate_edge(pp, k, m)
        if !isnothing(c)
            return c
        end
    end
    error("Beacon not found")
end


data = map(m -> parse.(Int64, m), eachmatch(r"\D+x=(-?\d+)\D+y=(-?\d+)\D+x=(-?\d+)\D+y=(-?\d+)\R?", read("data/in15.dat", String)))
pp = [(s[1:2] => s[3:4]) for s in data]
rr = [sum(abs.(p[1] - p[2])) for p in pp]

part1(pp, 2000000) |> length |> println

pB = find_beacon(pp, 4000000)[1]
sum(pB .* [4000000, 1])