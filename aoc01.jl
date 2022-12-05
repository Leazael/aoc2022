data = split(read("data/in01.dat", String),"\r\n")
tInd = findall(isempty.(data))

packs =  [parse.(Int64, data[k[1]:k[2]-1]) for k in zip([1; tInd .+ 1], [tInd;length(data)])]
cals = [sum(p) for p in packs]

max(cals...)

sum(sort(cals; rev = true)[1:3])