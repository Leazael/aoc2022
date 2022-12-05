data = split(read("data/in03.dat",String))

# data = split("vJrwpWtwJgWrhcsFMMfFFhFp
# jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
# PmmdzqPrVvPwwTWBwg
# wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
# ttgJtRGJQctTZtZT
# CrZsJsPPZsGzwwsLwLmpwMDw")

prio(c::Char) = isuppercase(c)*26 + (lowercase(c) - 'a' + 1)
prios = [prio.(collect(d)) for d in data]

prios1 = [p[1:length(p)÷2] for p in prios]
prios2 = [p[length(p)÷2 + 1:end] for p in prios]

inters = [intersect(q[1], q[2])[1] for q in zip(prios1, prios2)]
sum(inters)

sum([intersect(prios[k],prios[k+1],prios[k+2]) for k in 1:3:length(prios)])