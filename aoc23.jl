abstract type Square end 
struct Void <: Square end
mutable struct Elf <: Square 
    dirs::Vector{DataType}
    pos::CartesianIndex{2}
    dest::CartesianIndex{2}
    b::Bool
end
Square(c::Char)::Square = c == '.' ? Void() : Elf([North, South, West, East], CartesianIndex(0,0), CartesianIndex(0,0), false)
disp(w::Matrix{Square}) = [join(r) for r in eachrow( (x -> isa(x, Elf) ? '#' : '.').(w) )]

abstract type Dir end
struct North <: Dir end 
struct South <: Dir end 
struct West <: Dir end 
struct East <: Dir end 

mv(::Type{North}) = CartesianIndex(-1, 0)
mv(::Type{South}) = CartesianIndex( 1, 0)
mv(::Type{West})  = CartesianIndex( 0,-1)
mv(::Type{East})  = CartesianIndex( 0, 1)

nbh(p::CartesianIndex, ::Type{North}) = [p + CartesianIndex(-1, 0), p + CartesianIndex(-1, 1), p + CartesianIndex(-1,-1)]
nbh(p::CartesianIndex, ::Type{South}) = [p + CartesianIndex( 1, 0), p + CartesianIndex( 1, 1), p + CartesianIndex( 1,-1)]
nbh(p::CartesianIndex, ::Type{West})  = [p + CartesianIndex( 0,-1), p + CartesianIndex(-1,-1), p + CartesianIndex( 1,-1)]
nbh(p::CartesianIndex, ::Type{East})  = [p + CartesianIndex( 0, 1), p + CartesianIndex(-1, 1), p + CartesianIndex( 1, 1)]
nbh(p::CartesianIndex) = unique(vcat([nbh(p, w) for w in [North, South, East, West]]...))

data = Square.(permutedims(hcat(collect.(split(read("data/in23.dat", String), r"\R"))...)))

wrld = Matrix{Square}(deepcopy(data))
disp(wrld)

k = 0 
while true
    k = k + 1
    println(k)
    h, w = size(wrld)
    wrld = hcat(repeat([Void()], h+2, 1), vcat( repeat([Void()], 1, w), wrld, repeat([Void()], 1, w)), repeat([Void()], h+2, 1))

    for i in CartesianIndices(wrld)
        if wrld[i] isa Elf 
            e = wrld[i]
            e.dest, e.pos = i, i
            e.b = false
            if all(isa.(wrld[nbh(i)], Void))
                # do nothing
            else
                for k in 1:4  
                    d = e.dirs[k]
                    if all(isa.(wrld[nbh(i, d)], Void))
                        e.dest = i + mv(d)
                        e.b = true
                        break
                    end
                end
            end
            push!(e.dirs, popfirst!(e.dirs))
        end
    end



    ind = collect(CartesianIndices(wrld))[:]
    filter!(x -> isa(wrld[x], Elf), ind)
    filter!(x -> wrld[x].b, ind)

    if isempty(ind)
        break 
    end

    dests = map(x -> wrld[x].dest, ind)
    filter!(x -> count([wrld[x].dest == d for d in dests]) == 1, ind)
    for i in ind 
        wrld[wrld[i].dest] = deepcopy(wrld[i])
        wrld[i] = Void()
    end

    if all(isa.(wrld[1,:], Void))
        wrld = wrld[2:end, :]
    end

    if all(isa.(wrld[end,:], Void))
        wrld = wrld[1:end-1, :]
    end

    if all(isa.(wrld[:,1], Void))
        wrld = wrld[:, 2:end]
    end

    if all(isa.(wrld[:,end], Void))
        wrld = wrld[:, 1:end-1]
    end
end

# count(isa.(wrld, Void))