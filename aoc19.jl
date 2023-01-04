data = [parse.(UInt16, collect(m)) for m in eachmatch(r"Blue\D+\d+\D+(\d+)\D+(\d+)\D+(\d+)\D+(\d+)\D+(\d+)\D+(\d+)\D+\.\R?", read("data/in19.dat", String))]
# Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.

const Ore, Cla, Obs, Geo = (0x0001,0x0000,0x0000,0x0000), (0x0000,0x0001,0x0000,0x0000), (0x0000,0x0000,0x0001,0x0000), (0x0000,0x0000,0x0000,0x0001)
const ConstructionCosts = [[d[1] .* Ore, d[2] .* Ore, d[3] .* Ore .+ d[4] .*Cla, d[5] .* Ore .+ d[6] .* Obs] for d in data]
bp = ConstructionCosts[1]

function next_states(bp::Vector{NTuple{4, UInt16}}, state::NTuple{8, UInt16})::Vector{NTuple{8, UInt16}}
    newStates = NTuple{8, UInt16}[]
    newResources = state[1:4] .+ state[5:8]
    
    if (state[1] ≥ bp[4][1]) && (state[3] ≥ bp[4][3])
        push!(newStates, ((newResources .- bp[4])..., (state[5:8] .+ Geo)...) ) # if a geode robot can be made...
    else
        if state[3] == 0 && state[7] == 0 && (state[1] ≥ bp[3][1]) & (state[2] ≥ bp[3][2])
            push!(newStates, ((newResources .- bp[3])..., (state[5:8] .+ Obs)...) )
        else
            push!(newStates, (newResources..., state[5:8]...))

            if state[1] ≥ bp[1][1]
                push!(newStates, ((newResources .- bp[1])..., (state[5:8] .+ Ore)...) )
            end

            if state[1] ≥ bp[2][1]                
                push!(newStates, ((newResources .- bp[2])..., (state[5:8] .+ Cla)...) )
            end

            if (state[1] ≥ bp[3][1]) & (state[2] ≥ bp[3][2])
                push!(newStates, ((newResources .- bp[3])..., (state[5:8] .+ Obs)...) )
            end
        end
    end

    return newStates
end

next_states(bp::Vector{NTuple{4, UInt16}}, states::Vector{NTuple{8, UInt16}}) = vcat([next_states(bp, s) for s in states]...)
bp = ConstructionCosts[1]

# dumb but fast :P
compare(s1::NTuple{8, UInt16}, s2::NTuple{8, UInt16}) = (s1 != s2) && ( (s1[1]≤s2[1]) && ( (s1[2]≤s2[2]) && ( (s1[3]≤s2[3]) && ( (s1[4]≤s2[4]) && ( (s1[5]≤s2[5]) && ( (s1[6]≤s2[6]) && ( (s1[7]≤s2[7]) && (s1[8]≤s2[8]) ) ) )  ) ) ) )

function reduce!(ss::Vector{NTuple{8, UInt16}}, k::Int64)::Bool
    s = ss[k]
    if s == (0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff)
        return false 
    end
    tInd = findall(t -> compare(t, s), ss)
    for i in tInd 
        ss[i] = (0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff)
    end
    return true
end

function reduce!(ss::Vector{NTuple{8, UInt16}})::Bool
    for j = 1:length(ss)
        reduce!(ss, j)
    end
    filter!(t -> t != (0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff), ss)
    return true
end

function best_geode(bp::Vector{NTuple{4, UInt16}}, n::Int64)
    ss = [(0x0000,0x0000,0x0000,0x0000,0x0001,0x0000,0x0000,0x0000)]
    for k in 1:n
        ss = unique(next_states(bp, ss))
        reduce!(ss)
        println("$k => $(length(ss))")
    end
    return max([s[4] for s in ss]...)
end


@time best_geode(ConstructionCosts[1], 24) |> (println ∘ Int64)

a = best_geode(ConstructionCosts[1], 32) |> (println ∘ Int64) # 16
b = best_geode(ConstructionCosts[2], 32) |> (println ∘ Int64) # 40
c = best_geode(ConstructionCosts[3], 32) |> (println ∘ Int64) # 21