data = filter(!isempty, split(read("data/in22.dat", String), r"\R"))
const W = max(length.(data)...) + 2

const Void = ' '
const Wall = '#'

const Atlas = permutedims(hcat(repeat([' '], W),[[' '; collect(rpad(d, W - 1))] for d in data[1:end-1]]..., repeat([' '], W)))
const H = size(Atlas, 1)
# [println(join(a)) for a in eachrow(Atlas)];

abstract type Move end 
struct Walk <: Move n::Int64 end
struct Left <: Move end
struct Right <: Move end

function nexthing(s::AbstractString)::Tuple{Move, AbstractString}
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
    i, s = nexthing(s)
    push!(r, i)
end

const Route = r

function moveone!(p, d)::Bool
    q = p + d

    if Atlas[q...] == Void 
        if d == [0, 1]
            q[2] = findfirst(!=(Void), Atlas[p[1], :])
        elseif d == [0, -1] 
            q[2] = findlast(!=(Void), Atlas[p[1], :])
        elseif d == [1, 0] 
            q[1] = findfirst(!=(Void), Atlas[:, p[2]])
        elseif d == [-1, 0] 
            q[1] = findlast(!=(Void), Atlas[:, p[2]])  
        else 
            error()
        end
    end

    if Atlas[q...] == Wall 
        return false 
    end
    
    p[:] = q 
    return true 
end

function move!(::Left, ::Vector{Int64}, d::Vector{Int64})::Bool 
    d[:] = [0 -1; 1 0] * d
    return true
end

function move!(::Right, ::Vector{Int64}, d::Vector{Int64})::Bool 
    d[:] = [0 1; -1 0] * d
    return true
end

function move!(m::Walk, p::Vector{Int64}, d::Vector{Int64})::Bool 
    for _ = 1:m.n 
        if !moveone!(p, d)
            return false 
        end
    end
    return true
end

function gps(p, d)
    if d == [0, 1]
        c = '>'
    elseif d == [0, -1] 
        c = '<'
    elseif d == [1, 0] 
        c = 'v' 
    elseif d == [-1, 0] 
        c = '^' 
    end 
    a = copy(Atlas)
    a[p...] = c 
    [println(join(b)) for b in eachrow(a)]
    return nothing
end


function faceval(d)
    if d == [0, 1]
        return 0
    elseif d == [0, -1] 
        return 2
    elseif d == [1, 0] 
        return 1
    elseif d == [-1, 0] 
        return 3
    end 
end


p, d = [2, findfirst(!=(' '), Atlas[2,:])], [0, 1] 

# gps(p, d)
for m in Route
    move!(m, p, d)
    # gps(p, d)
end

(p[1] .- 1) * 1000 + (p[2] .- 1) *4 + faceval(d)