using Test

module Types
struct Cube
    x::Int64
    y::Int64
    z::Int64
end
end
Cube = Types.Cube

function add!(grid, in)
    push!(grid, Cube(parse.(Int, eachsplit(in, ','))...))
end

function countconnections(grid)
    connections = 0
    for cube in grid
        cubex1 = Cube(cube.x + 1, cube.y, cube.z)
        cubex2 = Cube(cube.x - 1, cube.y, cube.z)
        cubey1 = Cube(cube.x, cube.y + 1, cube.z)
        cubey2 = Cube(cube.x, cube.y - 1, cube.z)
        cubez1 = Cube(cube.x, cube.y, cube.z + 1)
        cubez2 = Cube(cube.x, cube.y, cube.z - 1)
        !isnothing(findfirst(==(cubex1), grid)) && (connections += 1)
        !isnothing(findfirst(==(cubex2), grid)) && (connections += 1)
        !isnothing(findfirst(==(cubey1), grid)) && (connections += 1)
        !isnothing(findfirst(==(cubey2), grid)) && (connections += 1)
        !isnothing(findfirst(==(cubez1), grid)) && (connections += 1)
        !isnothing(findfirst(==(cubez2), grid)) && (connections += 1)
    end
    return connections
end

function test()
    input = raw"""
2,2,2
1,2,2
3,2,2
2,1,2
2,3,2
2,2,1
2,2,3
2,2,4
2,2,6
1,2,5
3,2,5
2,1,5
2,3,5"""
    input = split(input, "\n")

    # @show f(input)
    grid = []
    for i in input
        add!(grid, i)
    end
    cons = countconnections(grid)
    6 * length(grid) - cons
end

test()

##

function part1()
    input = read("data/18.txt", String)
    input = split(input, "\n")
    grid = []
    for i in input
        add!(grid, i)
    end
    cons = countconnections(grid)
    6 * length(grid) - cons
end

part1()

##

function part2()
    input = read("data/", String)
    input = split(input, "\n")
end

part2()