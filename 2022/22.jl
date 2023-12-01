using Test

module Types
abstract type Cell end
struct Wall <: Cell end
struct Open <: Cell end
struct Empty <: Cell end
Base.show(io::IO, ::Wall) = print(io, "#")
Base.show(io::IO, ::Open) = print(io, ".")
Base.show(io::IO, ::Empty) = print(io, " ")
mutable struct Facing
    angle::Int64
end
function Base.setproperty!(facing::Facing, name::Symbol, val::Int64)
    if name == :angle
        @assert val % 90 == 0
        setfield!(facing, name, facing.angle + val)
    end
end
mutable struct World
    map::Matrix{<:Cell}
    position::Tuple{Int64,Int64}
    facing::Facing
end
end
Cell = Types.Cell
Wall = Types.Wall
Open = Types.Open
Empty = Types.Empty
World = Types.World

function convertmap(in)
    map = split(in, '\n')
    rows, cols = length(map), max(length.(map)...)
    for i in eachindex(map)
        if length(map[i]) < cols
            map[i] *= repeat(' ', cols - length(map[i]))
        end
    end
    mapmatrix = Matrix{Cell}(undef, rows, cols)
    rownum = 1
    for row in map
        ex = replace(row, ' ' => "Empty() ", '.' => "Open() ", '#' => "Wall() ")
        ex = '[' * ex * ']'
        mapmatrix[rownum, :] = eval(Meta.parse(ex))
        rownum += 1
    end
    return mapmatrix
end
function convertinstr(instructions)
    ms = eachmatch(r"(\d+)([RL])", instructions) |> collect
    parse.(Int64, getindex.(ms, 1)), getindex.(ms, 2)
end

function test()
    input = raw"""
        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5"""
    input = split(input, "\n\n")
    map = input[1]
    instructions = input[2]

    map = convertmap(map)
    rowpos, colpos = 1, findfirst(==(Open()), map[1, :])
    world = World(map, (rowpos, colpos),)
    magnitude, direction = convertinstr(instructions)
    for (m, d) in zip(magnitude, direction)
        if d == "L"
            world
        elseif d == "R"
        end
    end
end

test()

##

function part1()
    input = read("data/22.txt", String)
    input = replace(input, '\r' => "")
    input = split(input, "\n\n")
    map = input[1]
    # instructions = input[2]

    map = convertmap(map)
    # rowpos, colpos = 1, findfirst(==(Open()), map[1, :])
    # world = World(map, (rowpos, colpos),)
end

part1()

##

function part2()
    input = read("data/22.txt", String)
    input = split(input, "\n")
end

part2()