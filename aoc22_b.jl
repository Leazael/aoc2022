data = filter(!isempty, split(read("data/in22.dat", String), r"\R"))

const Void = ' '
const Wall = '#'

const L = 50
# const L = 4
const Faces = [0 1 2 0;0 3 0 0;4 5 0 0;6 0 0 0]
# const Faces = [0 0 1 0;2 3 4 0;0 0 5 6;0 0 0 0]

eCube = Dict{Int64, Matrix{Char}}()
push!(eCube, 1 => ['A' 'B'; 'C' 'D'])
push!(eCube, 2 => ['B' 'H'; 'D' 'F'])
push!(eCube, 3 => ['C' 'D'; 'E' 'F'])
push!(eCube, 4 => ['C' 'E'; 'A' 'G'])
push!(eCube, 5 => ['E' 'F'; 'G' 'H'])
push!(eCube, 6 => ['A' 'G'; 'B' 'H'])
# push!(eCube, 1 => ['A' 'B'; 'C' 'D'])
# push!(eCube, 2 => ['B' 'A'; 'H' 'G'])
# push!(eCube, 3 => ['A' 'C'; 'G' 'E'])
# push!(eCube, 4 => ['C' 'D'; 'E' 'F'])
# push!(eCube, 5 => ['E' 'F'; 'G' 'H'])
# push!(eCube, 6 => ['F' 'D'; 'H' 'B'])

net = permutedims(hcat([collect(rpad(d, 4*L)) for d in data[1:end-1]]...))
net = vcat(net, repeat([Void], 4*L - size(net,1), L*4))
tCube = Dict{Int64, Matrix{Char}}()
for i in CartesianIndex(0,0):CartesianIndex(3,3)
    F = net[CartesianIndex(1,1) + L*i : CartesianIndex(L,L) + L*i]
    if unique(F) != [Void]
        push!(tCube, Faces[i + CartesianIndex(1,1)] => F)
    end
end
const Cube = copy(tCube)

abstract type Move end 
abstract type Turn <: Move end
struct Walk <: Move n::Int64 end
struct Left <: Turn end
struct Right <: Turn end
struct Up <: Turn end
struct Down <: Turn end

mutable struct Pos 
    p::CartesianIndex{2}
    f::Int64
    n::Int64 # how many times to apply rotr90 to the face
end

mutable struct Dir 
    d::CartesianIndex
    Dir(x...) = new(CartesianIndex(x...))
end

function parse_next_move(s::AbstractString)::Tuple{Move, AbstractString}
    if s[1] in '0':'9'
        ds = match(r"(\d+)", s)[1]
        return (Walk(parse(Int64, ds)), s[length(ds)+1:end])
    elseif s[1] == 'L'
        return (Left(), s[2:end])
    elseif s[1] == 'R'
        return (Right(), s[2:end])
    else
        error()
    end
end

s = data[end]
r = Move[]
while !isempty(s)
    i, s = parse_next_move(s)
    push!(r, i)
end
const Route = copy(r)



const RMat, LMat = [0 1; -1 0], [0 -1; 1 0]

function move!(::Left, ::Pos, d::Dir)::Bool 
    d.d = CartesianIndex(Tuple((LMat * [d.d.I...])))
    return true
end

function move!(::Right, ::Pos, d::Dir)::Bool 
    d.d = CartesianIndex(Tuple((RMat * [d.d.I...])))
    return true
end

function rswivel!(p::Pos, d::Dir)
    p.n += 1 
    T = falses(L, L)
    T[p.p] = true
    p.p = findfirst(rotr90(T))
    d.d = CartesianIndex(Tuple((RMat * [d.d.I...])))
end


p = Pos(CartesianIndex(L,3), 3, 0)
d = Dir(1,0)

(p.p + d.d).I

function moveone!(p::Pos, d::Dir)::Bool
    q = (p.p + d.d)
    if q.I[1] == 0 || q.I[2] == 0 || q.I[1] == L+1 || q.I[2] == L + 1
        while d.d.I[1] != -1
            rswivel!(p, d)
       end # now we move up by defaut.

        edge = rotr90(eCube[p.f], p.n)[1,:]
        newFace = [k for k in 1:6 if k != p.f && edge[1] in eCube[k] && edge[2] in eCube[k]][1]
        nRots = filter(k -> rotr90(eCube[newFace], k)[end,:] == edge, 0:3)[1]

        q = CartesianIndex(L, p.p.I[2])

        if rotr90(Cube[newFace], nRots)[q] == Wall 
            return false 
        else 
            p.p = q 
            p.f = newFace 
            p.n = nRots
            return true
        end       
    else 
        if rotr90(Cube[p.f], p.n)[q] == Wall 
            return false 
        else 
            p.p = q
            return true 
        end
    end
end

function move!(m::Walk, p::Pos, d::Dir)::Bool 
    for _ = 1:m.n 
        if !moveone!(p, d)
            return false 
        end
    end
    return true
end

function faceval(d::Dir)
    if d.d.I[2] == 1
        return 0
    elseif d.d.I[2] == -1
        return 2
    elseif d.d.I[1] == 1
        return 1
    elseif d.d.I[1] == -1
        return 3
    end 
end


p = Pos(CartesianIndex(1,1), 1, 0)
d = Dir(0, 1)

for m in Route
    move!(m, p, d)
end

while p.n % 4 != 0
    rswivel!(p, d)
end

faceval(d)