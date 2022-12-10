abstract type Instruction end
struct Noop <: Instruction end
struct Addx <: Instruction
    v::Int64
end

run!(::Noop, regList::Vector{Int64}) = push!(regList, regList[end])
run!(T::Addx, regList::Vector{Int64}) = append!(regList, [regList[end], regList[end] + T.v])
function run!(il::Vector{Instruction}, refList::Vector{Int64}) 
    for d in il run!(d, refList) end 
    return refList
end

make_sprite(k::Int64)::String = ((k > 0 ? repeat('.', k-1) : "") * "###" * repeat('.', 40-k))[1:40]
function draw(spritePos::Vector{Int64})
    screen = join([make_sprite(spritePos[c])[(c-1) % 40 + 1] for c in 1:240])
    return [screen[(k*40 + 1) : (k+1)*40] for k in 0:5]
end

# these input parsers are getting worse.
data = [(s[1] == 'n' ? Noop() : Addx(parse(Int64, s[6:end]))) for s in split(read("data/in10.dat", String), "\r\n")]
spritePos = run!(data, [1])

sum(spritePos[20:40:220] .* (20:40:220)) |> println
draw(spritePos) .|> println;