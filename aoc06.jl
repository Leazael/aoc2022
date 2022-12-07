function find_mark(dataLoc::String, m::Int64)
    open(dataLoc) do io  
        n, buffer = m, [read(io, Char) for _ in 1:m]

        while length(unique(buffer)) != m
            n = n + 1
            push!(buffer, read(io, Char))
            popfirst!(buffer)
        end

        return n
    end
end

find_mark("data/in06.dat", 4) |> println
find_mark("data/in06.dat", 14) |> println