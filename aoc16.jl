struct Junk
    id::Int64
    flow::Int64
    tunnels::Vector{Int64}
end
Base.hash(j::Junk) = hash((j.id, j.valve, j.flow, j.tunnels))
flow(j::Junk) = j.flow

findpos(a::String, b::Vector{String}) = findfirst(a .== b)
findpos(a::Vector{String}, b::Vector{String}) = [findfirst(q .== b) for q in a]

clean(m::RegexMatch) = (string(m[1]), parse(Int64, m[2]), string.(strip.(split(m[3], ","))))
data = sort(clean.(eachmatch(r"Valve (\w\w) has flow rate=(\d+); tunnels? leads? to valves? (.*)\R?", read("data/in16.dat", String)) |> collect); by = x -> x[1])
valves = first.(data)
Junctures = [Junk(findpos(d[1], valves), d[2], findpos(d[3], valves)) for d in data]
TotalFlow = sum(flow.(Junctures))

# find all possible paths of total length 31, starting at one 
struct State
    id::Int64 
    open::Bool 
end
id(s::State) = s.id
isopen(s::State) = s.open
flow(s::State) = Junctures[s.id].flow

function score(p::Vector{State}, n::Int64)
    openTimes = Int64.(filter(!isnothing, [findfirst(==(State(j.id, true)), p) for j in Junctures]))
    if isempty(openTimes)
        return 0 
    else
        return sum((n .- openTimes) .* flow.(p[openTimes]))
    end
end
overview(p::Vector{State}, n::Int64) = (p[end].id, sort(unique(id.(filter(isopen, p))))) => score(p, n)
overview(pp::Vector{Vector{State}}, n::Int64) = [overview(p, n) for p in pp]

function reduce_paths(pths::Vector{Vector{State}})
    hists = overview(pths, 31)
    uu = unique(first.(hists))
    out = Vector{State}[]
    for u in uu
        tInd = findall(h -> h[1] == u, hists)
        m = max(last.(hists[tInd])...)
        push!(out, pths[tInd[findfirst(i -> hists[i][2] == m, tInd)]])
    end
    return out
end

function reduce_paths(pths::Vector{Vector{State}}, n::Int64)
    nPaths = reverse(sort(pths; by = x-> score(x,n)))
    m = min(length(nPaths), 20)
    return nPaths[1:m]
end


function find_max_path(s::State, n::Int64)
    pths = [[s]]
    oo = overview(pths, n)
    oldPths = pths
    for k = 1:n-1
        newPths = Vector{State}[]
        for p in pths

            # waiting  at an open valve is always an option
            if p[end].open
                push!(newPths, [p; p[end]])            
            end

            if !p[end].open && Junctures[p[end].id].flow > 0
                push!(newPths, [p; State(p[end].id, true)])
            end 

            j = Junctures[p[end].id]
            for d in j.tunnels
                if d in id.(p)
                    i = findlast(s -> id(s) == d, p)
                    np = [p; State(d, p[i].open)]
                else 
                    np = [p; State(d, false)]
                end
                push!(newPths, np)
            end
        end

        pths = reduce_paths(newPths)
        pths = reduce_paths(pths, n)
        # println(k, ": ", length(pths))
    end # 78613
    max(last.(overview(pths, 31))...) 
end


#2113 too highpt

@time find_max_path(State(1,false), 31)

################## part 2 


function score(p::Vector{State}, n::Int64)
    openTimes = Int64.(filter(!isnothing, [findfirst(==(State(j.id, true)), p) for j in Junctures]))
    if isempty(openTimes)
        return 0 
    else
        return sum((n .- openTimes) .* flow.(p[openTimes]))
    end
end

overview(p::Vector{State}, n::Int64) = (p[end].id, sort(unique(id.(filter(isopen, p))))) => score(p, n)
overview(pp::Vector{Vector{State}}, n::Int64) = [overview(p, n) for p in pp]

function reduce_paths(pths::Vector{Vector{State}}, n::Int64)
    hists = overview(pths, n)
    uu = unique(first.(hists))
    out = Vector{State}[]
    for u in uu
        tInd = findall(h -> h[1] == u, hists)
        m = max(last.(hists[tInd])...)
        push!(out, pths[tInd[findfirst(i -> hists[i][2] == m, tInd)]])
    end

    return out
end



pths = [[State(1,false)]]
oo = overview(pths, 27)
oldPths = pths
for k = 1:24
    newPths = Vector{State}[]
    for p in pths

        # waiting  at an open valve is always an option
        if p[end].open
            push!(newPths, [p; p[end]])            
        end

        if !p[end].open && Junctures[p[end].id].flow > 0
            push!(newPths, [p; State(p[end].id, true)])
        end 

        j = Junctures[p[end].id]
        for d in j.tunnels
            if d in id.(p)
                i = findlast(s -> id(s) == d, p)
                np = [p; State(d, p[i].open)]
            else 
                np = [p; State(d, false)]
            end
            push!(newPths, np)
        end
    end

    pths = reduce_paths(newPths, 27)
    println(k, ": ", length(pths))

end # 78613


function domin(a,b)
    if isnothing(a)
        return b 
    end

    if isnothing(b)
        return a
    end

    return min(a,b)
end

function score(p1, p2, n)
    ot1 = [findfirst((id.(p1) .== v) .&& (isopen.(p1))) for v in ValveIds]
    ot2 = [findfirst((id.(p2) .== v) .&& (isopen.(p2))) for v in ValveIds]
    ot = [domin(t...) for t in zip(ot1, ot2)]
    tInd = .!isnothing.(ot)
    if any(tInd)
        return sum(FlowList[tInd] .* (n .- ot[tInd]))
    else 
        return 0 
    end
end

Base.hash(pths[1])
ott = unique([[findfirst((id.(p) .== v) .&& (isopen.(p))) for v in ValveIds] for p in pths])
nott = [isnothing.(ot) for ot in ott]


function find_joint_max(ott)
    m = 0
    for k in eachindex(ott)
        ot1 = ott[k]
        candidates = ott[[all(nott[j] .|| nott[k]) for j in eachindex(ott)]]
        filter!(ot -> hash(ot1)<hash(ot), candidates)
        for ot2 in candidates
            ot = [domin(t...) for t in zip(ot1, ot2)]
            tInd = .!isnothing.(ot)
            if any(tInd)
                sc = sum(FlowList[tInd] .* (27 .- ot[tInd]))
                if sc > m 
                    m = sc
                    println(m, " ($k)/", length(ott))
                end
            end
        end
    end
    return m
end

@time find_joint_max(ott)