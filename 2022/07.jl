using Test

@enum State Default Readdir

function f(in)
    working_dir = []
    d = Dict{Vector{String},Int}()
    for line in in
        # @show line
        if startswith(line, raw"$ cd")
            dir = line[6:end]
            if dir == "/"
                continue
            elseif dir == ".."
                pop!(working_dir)
            else
                push!(working_dir, dir)
            end
        elseif startswith(line, "dir ")
            continue
        elseif isnumeric(line[1])
            size = parse(Int, split(line)[1])
            !haskey(d, working_dir) && (d[working_dir] = 0)
            if length(working_dir) >= 1
                let working_dir = working_dir
                    while true
                        # @show working_dir
                        !haskey(d, working_dir) && (d[working_dir] = 0)
                        if length(working_dir) == 0
                            d[[]] += size
                            break
                        else
                            d[working_dir] += size
                            working_dir = working_dir[1:end-1]
                        end
                    end
                end
            else
                d[working_dir] += size
            end
        end
    end
    return d
end

struct File
    name::String
    size::Int64
end
struct Directory
    name::String
    contents::Vector{Union{Directory,File}}
end

function test()
    input = raw"""
$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k"""
    input = split(input, "\n")

    @show sizes = f(input)
    map(x -> x.second, sizes |> collect) |> x -> filter(<(100000), x) |> sum
    # for i in input
    #     @show f(i)
    # end
end

test()

##

function part1()
    data = read("data/7.txt", String)
    data = split(data, "\r\n")
    @show sizes = f(data)
    map(x -> x.second, sizes |> collect) |> x -> filter(<(100000), x) |> sum
end

part1()

##

function part2()
    input = readlines("data/7.txt")
    sizes = f(input)
    remaining = 70000000 - sizes[[]]
    required = 30000000 - remaining
    values(sizes) |> collect |> sort |> x -> filter(>(required), x)
end

part2()