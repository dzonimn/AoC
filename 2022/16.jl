using Test

module Types
struct Node
    name::Symbol
    flow_rate::Int64
    connections::Vector{Symbol}
end
end
Node=Types.Node

function f(inp)
    graph = []
    for i in inp
        ms = collect(eachmatch(r"Valve (\w{2}) has flow rate=(\d{1,}); tunnels? leads? to valves? (.+?)$", i))
        connections = Symbol.(split(ms[1][3], ", "))
        n = Node(Symbol(ms[1][1]), parse(Int, ms[1][2]), connections)
        push!(graph, n)
    end
    
    findnodeidx(graph, symbol) = findfirst(x->x.name == symbol, graph)
    function shortestdist(graph, a, b)
        dist = Dict{Symbol, Int64}()
        prev = Dict{Symbol, Symbol}()
        queue = Symbol[]
        for node in getproperty.(graph, :name)
            dist[node] = 99999
            prev[node] = :none
            push!(queue, node)
        end
        sourcenode = graph[findnodeidx(graph, a)]
        dist[sourcenode.name] = 0
        # mindistnode = sourcenode

        while !isempty(queue)
            distvalue, mindistnode = findmin(dist)
            deleteat!(queue, findfirst(==(mindistnode), queue))
            deleteat!(dist, findfirst(==(distvalue), queue))
            
            for node in graph[findnodeidx(graph, mindistnode)].connections
                alt = dist[mindistnode] + 1
                if alt < dist[node]
                    dist[node] = alt
                    prev[node] = mindistnode
                end
            end
        end
        
        return dist, prev
    end

    @show shortestdist(graph, :AA, :HH)
    
    # return graph
end

function test()
    input = raw"""
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
"""
    input = split(input, "\n")[1:end-1]

    @show f(input)
end

test()

##

function solve()
    input = read("data/", String)
    input = split(input, "\n")
end

solve()
