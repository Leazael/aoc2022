data = split(read("data/in04.dat", String))
ranges = [parse.(Int64, collect(match(r"(\d*)\-(\d*),(\d*)\-(\d*)", d))) for d in data]

overlapping = filter(r -> (r[1] <= r[3] <= r[4] <= r[2]) || (r[3] <= r[1] <= r[2] <= r[4]), ranges)

filter(r -> !isempty(intersect(r[1]:r[2], r[3]:r[4])), ranges)