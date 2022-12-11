using Test

function f(map, direction, magnitude)
    pos = findfirst(==(1), map)

    for _ in 1:parse(Int, magnitude)
        if direction == "U"
            map[pos[1]-1, pos[2]] = 1
        elseif direction == "D"
            map[pos[1]+1, pos[2]] = 1
        elseif direction == "L"
            map[pos[1], pos[2]-1] = 1
        elseif direction == "R"
            map[pos[1], pos[2]+1] = 1
        end
        map[pos] = 0
        pos = findfirst(==(1), map)
        display(map)
    end
end

function test()
    hmap = zeros(Int, 10, 10)
    hmap[5, 5] = 1

    input = raw"""
    R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2"""
    input = split(input, "\n")

    # @show movehead(input)
    for i in input
        @show f(hmap, split(i)...)
    end
end

test()

##

function part1()
    input = readlines("data/9.txt")
end

part1()

##

function part2()
    input = readlines("data/9.txt")
end

part2()