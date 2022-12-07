abstract type FakeData end

struct FakeFile <: FakeData
    name::String
    size::Int64 
end

struct FakeDir <: FakeData
    name::String
    content::Vector{FakeData}
    parentDir::Union{FakeDir, Nothing} # ugly, but makes for easy transversing
end

isdir(f::FakeData) = isa(f, FakeDir)
name(f::FakeData) = f.name

ls(d::FakeData) = d.content
lsdir(d::FakeDir) = filter(isdir, ls(d))
lsfile(d::FakeDir) = filter(!isdir, ls(d))
Base.size(f::FakeFile) = f.size
Base.size(d::FakeDir) = sum(size.(ls(d)))

function allsubdirs(fd::FakeDir)::Vector{FakeDir}
    out = [fd]
    for d in lsdir(fd), sd in allsubdirs(d)
        push!(out, sd)
    end
    return out
end

function sel_dir(fd::FakeDir, dirName::AbstractString)
    for s in lsdir(fd)
        if s.name == dirName
            return s
        end
    end
    error("Dir ", dirName, " not found")
end

function build_from_ls(fd::FakeDir, contents::Vector{<:AbstractString})
    for c in contents
        x = split(c, " ")
        if x[1] == "dir" && !(x[2] in name.(lsdir(fd)))
            push!(fd.content, FakeDir(x[2], [], fd))
        elseif x[1] != "dir" && !(x[2] in name.(lsfile(fd)))
            push!(fd.content, FakeFile(x[2], parse(Int64, x[1])))
        end
    end
end

function build_sys(comList::Vector{Vector{String}})::FakeDir
    sys = FakeDir("/", [], nothing)
    currentDir = sys
    for com in comList
        if com[1] == "ls"
            build_from_ls(currentDir, com[2:end])
        else
            target = split(com[1], ' ')[2]
            if target == "/"
                currentDir = sys
            elseif target == ".."
                currentDir = currentDir.parentDir
            else
                currentDir = sel_dir(currentDir, target)
            end              
        end
    end
    return sys
end

data = read("data/in07.dat", String)
commands = [string.(strip.(split(s, "\r\n", keepempty = false))) for s in split(data, '$', keepempty = false)]
sys = build_sys(commands[2:end])

sd = allsubdirs(sys)
sizes = [size(p) for p in sd]
sum(filter(<=(100000), sizes)) |> println

y = 30000000 - (70000000 - size(sys))
min(filter(>=(y), sizes)...) |> println