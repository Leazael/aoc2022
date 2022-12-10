data = hcat(collect.(split(read("data/in08.dat", String), "\r\n"))...) .- '0'

function vis(M::Matrix{Int64})
    out, T = trues(size(M)), trues(size(M))
    for i in 2:size(M,1)-1, j in 2:size(M,2)-1
        T[i,:], T[:,j] = M[i,:] .< M[i,j], M[:,j] .< M[i,j]
        out[i,j] = all(T[i, 1:j-1]) || all(T[i, j+1:end]) || all(T[1:i-1, j]) || all(T[i+1:end, j])
    end
    return out
end

+(vis(data)...) |> println

dist(v::BitVector)::Int64 = any(v) ? findfirst(v) : length(v)
dist(x::Int64, v::Vector{Int64})::Int64 = dist(v .>= x)
dist(x::Int64, v::Vector{Int64}, w...)::Int64 = dist(x, v) * dist(x, w...)

function housevals(M::Matrix{Int64})
    out = similar(M)
    for i in 1:size(M,1), j in 1:size(M,2)
        out[i,j] = dist(M[i,j], M[i+1:end,j], M[i,j+1:end], M[i-1:-1:1,j], M[i,j-1:-1:1])
    end
    return out
end

max(housevals(data)...) |> println