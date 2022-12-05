function move9000!(crates::Vector{Vector{Char}}, amount::Int64, from::Int64, to::Int64)
    for k = 1:amount
        pushfirst!(crates[to], popfirst!(crates[from]))
    end
end

function move9001!(crates::Vector{Vector{Char}}, amount::Int64, from::Int64, to::Int64)
    prepend!(crates[to], crates[from][1:amount])
    for k = 1:amount
        popfirst!(crates[from])
    end    
end

function read_crates(io::IOStream; cHeight::Int64 = 8, cOffset = 2, cWidth = 4)::Vector{Vector{Char}}
    crateData = [readline(io) for k in 1:cHeight]
    crates = [collect(strip(join(r))) for r in eachrow(hcat(collect.(crateData)...)[cOffset:cWidth:end,:])]    
    
    [readline(io) for k in 1:2] # skip two lines
    return crates
end

function execute(dataLoc::String, stackFun::Function)::String
    open(dataLoc) do io
        crates = read_crates(io)
        
        while !eof(io)
            move = match(r"move (\d*) from (\d*) to (\d*)" , readline(io)) |> collect |> x -> parse.(Int64, x)
            stackFun(crates, move...) 
        end

        return [c[1] for c in crates] |> join
    end
end

part_1(dataLoc::String)::String = execute(dataLoc, move9000!)
part_2(dataLoc::String)::String = execute(dataLoc, move9001!)

# run the code

execute("data/in05.dat", move9000!) |> println
execute("data/in05.dat", move9001!) |> println
