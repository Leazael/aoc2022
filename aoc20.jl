function moveto!(v::AbstractVector, k::Int64, i::Int64)
    # move from k to i 
    if k == i 
        return
    end 

    if k < i 
        w = v[k:i]
        v[k:i-1] = w[2:(i-k+1)]
        v[i] = w[1]
        return 
    else 
        w = v[i:k]
        v[i+1:k] = w[1:(k-i)]
        v[i] = w[end]
        return
    end
end

function moveby!(v::AbstractVector, k::Int64, i::Int64) 
    if i < 0 
        m = abs(i) ÷ (length(v) - 1)
        return moveby!(v, k, i + (length(v) - 1)*(m+1))
    end

    j =  ( rem(k + i - 1, length(v) - 1) ) + 1
    return moveto!(v, k, j)
end


truth = [2 1 -3 3 -2 0 4; 1 -3 2 3 -2 0 4; 1 2 3 -2 -3 0 4; 1 2 -2 -3 0 3 4; 1 2 -3 0 3 4 -2; 1 2 -3 0 3 4 -2; 1 2 -3 4 0 3 -2]

data = parse.(Int64, split(read("data/in20.dat", String), r"\R")) .* 811589153

function mix(v::Vector{Int64}, m::Int64)
    n = length(v)
    ind = collect(1:n)

    for _ in 1:m 
        for i in 1:n
            k = findfirst(j -> j == i, ind)
            moveby!(ind, k, v[i])
        end
    end

    return v[ind]
end

out = mix(data, 10)
start = findfirst(iszero, out)
out[((start .+ collect(1000:1000:3000) .- 1) .% length(out)) .+ 1] |> sum