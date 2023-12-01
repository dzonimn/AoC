using Test

module Types
struct Map
    layout::Matrix{Int}
    head_pos::Tuple{Int,Int}
    tail_pos::Tuple{Int,Int}
    tail_visited::Matrix{Int}
end
struct Head end
struct Tail end
end
Map = Types.Map
Head = Types.Head
Tail = Types.Tail
function Base.show(io::IO, map::Map)
    showmap = copy(map.layout)
    showmap[CartesianIndex(map.head_pos)] = 1
    showmap[CartesianIndex(map.tail_pos)] = 2
    display(showmap)
end

function beside(tpos, hpos)
    if tpos == hpos
        return true
    end
    if sum(abs.(hpos .- tpos)) > 2
        return false
    elseif (tpos[1]+2, tpos[2]) == hpos || (tpos[1]-2, tpos[2]) == hpos || (tpos[1], tpos[2]+2) == hpos || (tpos[1], tpos[2]-2) == hpos
        return false
    else
        return true
    end
end
function processinstr(map::Map, direction, magnitude)
    # pos = findfirst(==(1), map)
    hpos = map.head_pos
    tpos = map.tail_pos
    tvisited = map.tail_visited

    for _ in 1:parse(Int, magnitude)
        hpos_prev = hpos
        if direction == "U"
            hpos = hpos[1] - 1, hpos[2]
        elseif direction == "D"
            hpos = hpos[1] + 1, hpos[2]
        elseif direction == "L"
            hpos = hpos[1], hpos[2] - 1
        elseif direction == "R"
            hpos = hpos[1], hpos[2] + 1
        end

        if !beside(tpos, hpos)
            tpos = hpos_prev
        end
        tvisited[CartesianIndex(tpos)] = 1
        # show(Map(map.layout, hpos, tpos, tvisited))
        # readline()
    end
    return Map(map.layout, hpos, tpos, tvisited)
end

function solve(input)
    input = split(input, "\n")
    map = Map(
        zeros(Int, 1000, 1000),
        (500, 500),
        (500, 500),
        zeros(Int, 1000, 1000)
    )

    # @show movehead(input)
    for i in input
        map = processinstr(map, split(i)...)
    end
    @show sum(map.tail_visited)
end

solve(raw"""
    R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2""")

##

solve(read("./data/9.txt", String))

##
