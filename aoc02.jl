data = [split(d," ") for d in split(read("data/in02.dat", String),"\r\n")]

rounds = [(d[1][1] - 'A' + 1, d[2][1] - 'X' + 1) for d in data]

rps = [3 6 0; 0 3 6; 6 0 3]

sum([r[2] + rps[r...] for r in rounds])

rounds2 = [(r[1], findfirst(rps[r[1],:] .== r[2]*3-3)) for r in rounds]
sum([r[2] + rps[r...] for r in rounds2])