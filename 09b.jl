using Test

module Types
abstract type Node end
struct Tail <: Node
    id::Int
    pos::Vector{Int}
end
struct Head <: Node
    pos::Vector{Int}
end
struct Map
    layout::Matrix{Int}
    head::Head
    tails::Vector{Tail}
    tail_visited::Matrix{Int}
end

# Base.show(io::IO, s::Symbol) = print(io, s)
function Base.show(io::IO, map::Map)
    showmap = Matrix{Union{Int, Symbol}}(map.layout)
    showmap = replace(showmap, 0 => :⬛)
    # showmap[CartesianIndex(map.head.pos...)] = 1
    # for (idx, i) in enumerate(2:10)
    #     showmap[CartesianIndex(map.tails[idx].pos...)] = i
    # end
    showmap[CartesianIndex(map.head.pos...)] = :🐱
    for (idx, i) in enumerate(2:10)
        showmap[CartesianIndex(map.tails[idx].pos...)] = :🔗
    end
    function overlay(s1, s2)
        if s2 == 1
            return :🔲
        else
            return s1
        end
    end
    showmap = overlay.(showmap, map.tail_visited)
    for row in eachrow(showmap)
        print(io, row...)
        print(io, "\n")
    end
    # display(showmap)
end

function move!(n1::Node, n2::Node)
    if n1.pos == n2.pos
        return nothing
    end
    
    n1_adjacent_spaces = [
        (n1.pos[1]+1, n1.pos[2]),
        (n1.pos[1]-1, n1.pos[2]),
        (n1.pos[1], n1.pos[2]+1),
        (n1.pos[1], n1.pos[2]-1),
    ]
    n1_diagonal_spaces = [(n1.pos[1]+i, n1.pos[2]+j) for (i,j) in (-1:2:1, -1:2:1)]
    
    if n2.pos in n1_adjacent_spaces || n2.pos in n1_diagonal_spaces
        return nothing
    end
    
    # this happens when one is separated 2 spaces adjacently
    if n2.pos == [n1.pos[1]+2, n1.pos[2]]
        n1.pos[1] += 1
    elseif n2.pos == [n1.pos[1]-2, n1.pos[2]]
        n1.pos[1] -= 1
    elseif n2.pos == [n1.pos[1], n1.pos[2]+2]
        n1.pos[2] += 1
    elseif n2.pos == [n1.pos[1], n1.pos[2]-2]
        n1.pos[2] -= 1
    end
        
    # this happens when one is separated 2 spaces diagonally
    if n2.pos == [n1.pos[1]+2, n1.pos[2]+2]
        n1.pos[1] += 1; n1.pos[2] += 1
    elseif n2.pos == [n1.pos[1]-2, n1.pos[2]-2]
        n1.pos[1] -= 1; n1.pos[2] -= 1
    elseif n2.pos == [n1.pos[1]-2, n1.pos[2]+2]
        n1.pos[1] -= 1; n1.pos[2] += 1
    elseif n2.pos == [n1.pos[1]+2, n1.pos[2]-2]
        n1.pos[1] += 1; n1.pos[2] -= 1
    end
    
    # this happens when one is seperated in a knight's move
    if n2.pos == [n1.pos[1]+1, n1.pos[2]+2] || n2.pos == [n1.pos[1]+2, n1.pos[2]+1]
        n1.pos[1] += 1; n1.pos[2] += 1
    elseif n2.pos == [n1.pos[1]-1, n1.pos[2]+2] || n2.pos == [n1.pos[1]-2, n1.pos[2]+1]
        n1.pos[1] -= 1; n1.pos[2] += 1
    elseif n2.pos == [n1.pos[1]-1, n1.pos[2]-2] || n2.pos == [n1.pos[1]-2, n1.pos[2]-1]
        n1.pos[1] -= 1; n1.pos[2] -= 1
    elseif n2.pos == [n1.pos[1]+1, n1.pos[2]-2] || n2.pos == [n1.pos[1]+2, n1.pos[2]-1]
        n1.pos[1] += 1; n1.pos[2] -= 1
    end
    
    return nothing
end

end
Map = Types.Map
Head = Types.Head
Tail = Types.Tail
move! = Types.move!

function processinstr(map::Map, direction, magnitude)
    # pos = findfirst(==(1), map)
    head = map.head
    tails = map.tails
    tvisited = map.tail_visited

    for _ in 1:parse(Int, magnitude)
        if direction == "U"
            head.pos[1] -= 1
            # head = Head((head.pos[1]-1, head.pos[2]))
            # hpos = head[1] - 1, head[2]
        elseif direction == "D"
            head.pos[1] += 1
            # head = Head((head.pos[1]+1, head.pos[2]))
            # hpos = hpos[1] + 1, hpos[2]
        elseif direction == "L"
            head.pos[2] -= 1
            # head = Head((head.pos[1], head.pos[2]-1))
            # hpos = hpos[1], hpos[2] - 1
        elseif direction == "R"
            head.pos[2] += 1
            # head = Head((head.pos[1], head.pos[2]+1))
            # hpos = hpos[1], hpos[2] + 1
        end
        
        move!(tails[1], head)
        for i in 2:9
            move!(tails[i], tails[i-1])
        end

        tvisited[CartesianIndex(tails[end].pos...)] = 1
        run(`clear`)
        show(Map(map.layout, head, tails, tvisited))
        sleep(0.00111)
    end
    return Map(map.layout, head, tails, tvisited)
end

function solve(input, dims=40)
    input = split(input, "\n")
    start = Head([dims÷2, dims÷2])
    tails = Tail[]
    for i in 1:9
        push!(tails, Tail(i, [dims÷2, dims÷2]))
    end
    map = Map(
        zeros(Int, dims, dims),
        start,
        tails,
        zeros(Int, dims, dims)
    )

    # @show movehead(input)
    for i in input
        map = processinstr(map, split(i)...)
    end
    @show sum(map.tail_visited)
    return map
end

# solve(raw"""R 5
# U 8
# L 8
# D 3
# R 17
# D 10
# L 25
# U 20""", 35)

##

solve(read("./data/9.txt", String), 100)

##
