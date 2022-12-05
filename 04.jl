using Test

function engulfs(left, right)
    left = split(left, "-")
    right = split(right, "-")
    left1 = parse(Int, left[1])
    right1 = parse(Int, right[1])
    left2 = parse(Int, left[2])
    right2 = parse(Int, right[2])
    
    if left1 <= right1 && left2 >= right2
        return true
    elseif right1 <= left1 && right2 >= left2
            return true
    else
        return false
    end
end

function overlaps(left, right)
    left = split(left, "-")
    right = split(right, "-")
    left1 = parse(Int, left[1])
    right1 = parse(Int, right[1])
    left2 = parse(Int, left[2])
    right2 = parse(Int, right[2])
    
    for l in left1:left2
        if l ∈ right1:right2
            return true
        end
    end
    return false
end

function test()
    input = """
2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8"""
    input = split(input, "\n")
    input = split.(input, ",")
    
    for inp in input
        @show overlaps(inp[1], inp[2])
    end
    # @show engulfs(input[1][1], input[1][2])
    # @show engulfs(input[5][2], input[5][1])
    # @show engulfs(input[4][1], input[4][2])
end

test()

##

function part1()
    data = read("data/4.txt", String)
    data = split(data, "\n")
    data = split.(data, ",")
    @show engulfs.(getindex.(data, 1), getindex.(data,2)) |> sum
    @show engulfs.(getindex.(data, 2), getindex.(data,1)) |> sum

end

part1()

##

function part2()
    data = read("data/4.txt", String)
    data = split(data, "\n")
    data = split.(data, ",")
    @show overlaps.(getindex.(data, 1), getindex.(data,2)) |> sum
    @show overlaps.(getindex.(data, 2), getindex.(data,1)) |> sum
end

part2()