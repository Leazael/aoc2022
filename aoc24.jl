data = permutedims(hcat(collect.(split(read("data/in24.dat", String), r"\R"))...))
const H, W = size(data)

disp(m) = join.(eachrow(m)) .|> println

mutable struct Blizzard 
    p :: CartesianIndex{2}
    d :: CartesianIndex{2}
end
pos(b::Blizzard) = b.p
dir(b::Blizzard) = b.d 
dchar(b::Blizzard) = b.d.I[1] == 1 ? 'v' : ( b.d.I[1] == -1 ? '^' : ( b.d.I[2] == -1 ? '<' : '>' ) )

const Walls = findall(==('#'), data)

function evolve_step!(b::Blizzard)::Bool
    b.p = b.p + b.d
    if b.p in Walls || b.p.I[1] == 0 || b.p.I[1] == H+1 || b.p.I[2] == 0|| b.p.I[2] == W+1
        if dchar(b) == '^'
            b.p = CartesianIndex(H , b.p.I[2])
        elseif dchar(b) == 'v'
            b.p = CartesianIndex(1 , b.p.I[2])
        elseif dchar(b) == '<'
            b.p = CartesianIndex(b.p.I[1], W)
        elseif dchar(b) == '>'
            b.p = CartesianIndex(b.p.I[1], 1)
        else
            error()
        end
        return true
    else
        return false 
    end
end

function  evolve!(b::Blizzard)
    k = 0
    while evolve_step!(b) 
        k += 1
        if k > 1000
            error("oops")
        end
    end    
end

function enwall!(wrld)
    for w in Walls
        wrld[w] = '#'
    end
end

function enblizzen!(ww::Matrix{Char}, bb::Vector{Blizzard})
    pp = pos.(bb)
    cnt = [count([x == p for x in pp]) for p in pp]

    for i in eachindex(cnt,pp,bb)
        if cnt[i] == 1
            ww[bb[i].p] = dchar(bb[i])
        elseif 2 ≤ cnt[i] ≤ 9
            ww[bb[i].p] = '0' + cnt[i]
        else
            ww[bb[i].p] = 'X' 
        end
    end
    
end


function evolve!(wwOld, bb)
    evolve!.(bb)
    cc = findall(==('E'), wwOld)

    ww = fill('.', H, W)
    for c in cc
        nbh = map(p -> c + p, [CartesianIndex(0,0), CartesianIndex(1,0), CartesianIndex(0,1), CartesianIndex(-1,0), CartesianIndex(0,-1)])
        filter!(c -> 1 ≤ c.I[1] ≤ H, nbh)
        filter!(c -> 1 ≤ c.I[2] ≤ W, nbh)
        for n in nbh 
            ww[n] = 'E'
        end
    end

    enwall!(ww)
    enblizzen!(ww, bb)
    wwOld[:] = ww[:]
end


blzz = vcat([Blizzard(p, CartesianIndex( 0, 1)) for p in findall(==('>'), data)],
            [Blizzard(p, CartesianIndex( 0,-1)) for p in findall(==('<'), data)],
            [Blizzard(p, CartesianIndex(-1, 0)) for p in findall(==('^'), data)],
            [Blizzard(p, CartesianIndex( 1, 0)) for p in findall(==('v'), data)])

goal = CartesianIndex(H, W-1)
start = CartesianIndex(1, 2)

wrld = fill('.', H, W)
enwall!(wrld)
wrld[start] = 'E'

k = 0
while wrld[goal] != 'E'
    k += 1
    evolve!(wrld, blzz)
    println(k)
end
wrld |> disp;

wrld = fill('.', H, W)
enwall!(wrld)
wrld[goal] = 'E'

while wrld[start] != 'E'
    k += 1
    evolve!(wrld, blzz)
    println(k)
end
wrld |> disp;

wrld = fill('.', H, W)
enwall!(wrld)
wrld[start] = 'E'

while wrld[goal] != 'E'
    k += 1
    evolve!(wrld, blzz)
    println(k)
end
wrld |> disp;