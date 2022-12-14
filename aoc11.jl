function parse_operation(s::AbstractString)::Vector{Int64}
    q = match(r"([^\+\*\s]*)\s*(\+|\*)\s*([^\+\*\s]*)", s)
    if q[2] == "*"
        return q[3] == "old" ? [1, 0, 0] : [0, parse(Int64, q[3]), 0]
    elseif q[2] == "+"
        return [0, 1, parse(Int64, q[3])]
    end
    error("could not parse operation")
end
polyval(v::Vector{Int64}, x::Real) = sum((x .^ (length(v)-1:-1:0)) .* v)

struct Monkey
    items::Vector{Int64}
    op::Vector{Int64}
    test::Int64
    targetT::Int64
    targetF::Int64
end
Monkey(s::AbstractString...)::Monkey = Monkey(parse.(Int64, split(s[1], ",")), parse_operation(s[2]), (parse.(Int64, s[3:end]))...)

function do_next!(mm::Vector{Monkey}, id::Int64, w::Int64, q::Int64)
    item = (polyval( mm[id+1].op, popfirst!( mm[id+1].items)) ÷ w) % q
    target = item %  mm[id+1].test == 0 ?  mm[id+1].targetT :  mm[id+1].targetF
    push!(mm[target + 1].items, item)
end

function round!(mm::Vector{Monkey}, w::Int64, q::Int64)
    activity = zeros(Int64, size(mm))
    for k = 0:length(mm)-1
        while !isempty(mm[k+1].items) 
            do_next!(mm, k, w, q) 
            activity[k+1] += 1
        end
    end
    return activity
end

banana = r"\D*(?<id>\d*):\R\s*\D*\s(?<it>.+?)\R\s*.*?=\s(?<op>.+?)\R\s\D*(?<tst>\d*)\R\s*.*true\D*(?<T>\d*)\R\s*.*false\D*(?<F>\d*)\R?"
data = [Monkey(m["it"], m["op"], m["tst"], m["T"], m["F"]) for m in eachmatch(banana, read("data/in11.dat", String))]
q = lcm([m.test for m in data]...)

deepcopy(data) |> x-> prod(sort(sum([round!(x, 3, q) for k in 1:20]   ))[end-1:end]) |> println
deepcopy(data) |> x-> prod(sort(sum([round!(x, 1, q) for k in 1:10000]))[end-1:end]) |> println
