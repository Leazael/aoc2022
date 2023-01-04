const MoveQueue = [true, false][(collect(read("data/in17.dat", String)) .- '<' .+ 2) .÷ 2]
const NMoves = length(MoveQueue)
const HRocks = reverse.([[0x00,0x00,0x00,0x3c], [0x00,0x10,0x38,0x10], [0x00,0x08,0x08,0x38], [0x20,0x20,0x20,0x20], [0x00,0x00,0x30,0x30]])
const RockQueue = [1,2,3,4,5]

function move!(bLeft::Bool, rock::Vector{UInt8})
    if bLeft 
        if all(q -> q & 0x80 === 0x00, rock)
            rock .<<= 1
            return true
        end
        return false  
    else
        if  all(q -> q & 0x03 === 0x00, rock)
            rock .>>= 1
            return true
        end
        return false
    end
    error()
end


function spawn!(chamber::Vector{UInt8}, rockId::Int64)
    append!(chamber, zeros(UInt8, 7))
    return copy(HRocks[rockId])
end 
    
function step!(chamber::Vector{UInt8}, rock::Vector{UInt8}, rockY::Int64, bLeft::Bool)::Bool
    bMoved = move!(bLeft, rock)
    # bLeft ? println("left") : println("right") 

    if any(!=(0x00), chamber[rockY:rockY+3] .& rock) && bMoved 
        move!(!bLeft, rock) # undo move
        # println("udno")
    end

    if rockY == 1 return false end 

    if any(!=(0x00), chamber[rockY-1:rockY+2] .& rock) return false end 

    return true
end

function drop!(chamber::Vector{UInt8}, rockId::Int64, startMove::Int64)
    rock = spawn!(chamber, rockId)
    rockY = length(chamber) - 3 

    while step!(chamber, rock, rockY, MoveQueue[startMove])
        startMove = (startMove % NMoves) + 1
        rockY -= 1
    end

    chamber[rockY:rockY+3] = chamber[rockY:rockY+3] .| rock
    while chamber[end] === 0x00
        pop!(chamber)
    end

    hurdle = [|(chamber[k:k+2]...) .== 0xfe for k in 1:length(chamber)-2]
    nDrop = 0 
    if any(hurdle)
        nDrop = findlast(hurdle)
        deleteat!(chamber, 1:nDrop)
    end

    return ( (startMove % NMoves) + 1, nDrop)
end 

function runn!(n::Int64, chamber::Vector{UInt8})
    rockId = 0
    startMove = 1
    nPruned = 0
    for _ in 1:n
        rockId = (rockId % 5) + 1
        startMove, k = drop!(chamber, rockId, startMove)
        nPruned += k
    end
    return nPruned + length(chamber)
end

chamber = UInt8[]
@time runn!(2022, chamber)# 3068

chamber = UInt8[]
runn!(10^5, chamber) #157581

# after 295, it repeats with periods of 1745, accruing 2750 rows.

nBlocks = 10^12
chamber = UInt8[]

rockId = 0
startMove = 1
nPruned = 0

for _ in 1:295
    rockId = (rockId % 5) + 1
    startMove, k = drop!(chamber, rockId, startMove)
    nPruned += k
end # 436
h0 = hash((chamber, rockId, startMove))
nBlocks -= 295

nLoops = nBlocks ÷ 1745
nPruned += 2750 * nLoops
nBlocks = nBlocks % 1745

for _ in 1:nBlocks
    rockId = (rockId % 5) + 1
    startMove, k = drop!(chamber, rockId, startMove)
    nPruned += k
end # 436

nPruned + length(chamber)