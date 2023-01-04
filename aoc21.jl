using Symbolics 

@variables x

abstract type Monkey end

struct Oper <: Monkey
    id::String
    op::Function 
    inid1::String
    inid2::String
end

struct Numb <: Monkey
    id::String
    n::Int64
end

struct Humn <: Monkey
    id::String
end

id(m::Monkey) = m.id

const FunDict = Dict("+" => (x,y) -> x + y, "-" => (x,y) -> x - y, "*" => (x,y) -> x * y, "/" => (x,y) -> x//y)

function Base.parse(::Type{Monkey}, s::AbstractString)::Monkey
    id, rest = split(s, ": ")
    if ' ' in rest
        id1, op, id2 = split(rest, ' ')
        return Oper(id, FunDict[op], id1, id2)
    else
        n = parse(Int64, rest)
        return Numb(id, n)
    end
end

function evaluate(s::String, mList::Vector{Monkey})
    mInd = findfirst(==(s), id.(mList))
    m = mList[mInd]
    if isa(m, Numb)
        return m.n 
    elseif isa(m, Oper)
        return m.op(evaluate(m.inid1, mList), evaluate(m.inid2, mList))
    elseif isa(m, Humn)
        return x
    end    
end

data = parse.(Monkey, split(read("data/in21.dat", String), r"\R"))
evaluate("root", data) |> println

data[findfirst(==("humn"), id.(data))] = Humn("humn")

data[findfirst(==("root"), id.(data))].inid1

# root: bhft + pzqf
lhs = evaluate(data[findfirst(==("root"), id.(data))].inid1, data)
rhs = evaluate(data[findfirst(==("root"), id.(data))].inid2, data)

numerator((Symbolics.solve_for(lhs ~ rhs, x) ).val) |> println ÷