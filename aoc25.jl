
dumparse(v::Char) = v == '0' ? 0 : (v == '1' ? 1 : (v == '2' ? 2 : (v == '-' ? -1 : -2)))
dumparse(i::Int64) = i ≥ 0 ? '0' + i : (i == -1 ? '-' : '=' )

dumparse(s::AbstractString) = dumparse.(collect(s))
unsnafu(v::Vector{Int64}) = sum( (5 .^ (length(v)-1 : -1 :0)) .* v )
unsnafu(s::AbstractString) = unsnafu(dumparse(s))

function ensnafu!(dd::Vector{Int64})
    pushfirst!(dd, 0)
    while true 
        i = findlast(>(2), dd)
        if isnothing(i) break end
        dd[i] -= 5 
        dd[i-1] += 1
    end
    while dd[1] == 0 
        popfirst!(dd)
    end
    return dd
end

ensnafu(i::Int64) = join(dumparse.(ensnafu!(reverse(digits(i; base=5)))))

data = split(read("data/in25.dat", String), r"\R")
ensnafu(sum(unsnafu.(data)))
