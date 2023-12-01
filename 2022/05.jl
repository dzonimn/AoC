using Test

struct Box
    char::Char
end
struct Stack
    boxes::Vector{Box}
end
Base.length(x::Stack) = length(x.boxes)
Base.last(x::Stack) = x.boxes[end]
struct Warehouse
    stacks::Vector{Stack}
end

function f(i)
    stacknumber = parse.(Int, split(i[end])) |> x -> max(x...)

    warehouse = Warehouse([])
    for _ in 1:stacknumber
        push!(warehouse.stacks, Stack([]))
    end
    for j in i[end-1:-1:1]
        for (col, char) in enumerate(split(getindex(j, 2:4:(4*stacknumber-2)), ""))
            if char == " "
                continue
            end
            push!(warehouse.stacks[col].boxes, Box(char[1]))
        end
    end
    return warehouse
end

function g(i)
    _, qty, from, to = tryparse.(Int, split(i, r"move | from | to "))
    return (qty=qty, from=from, to=to)
end

function h!(warehouse, instruction)
    for _ in 1:instruction.qty
        moveboxes = pop!(warehouse.stacks[instruction.from].boxes)
        push!(warehouse.stacks[instruction.to].boxes, moveboxes)
    end
end

function j!(warehouse, instruction)
    moveboxes = last(warehouse.stacks[instruction.from].boxes, instruction.qty)
    for _ in 1:instruction.qty
        pop!(warehouse.stacks[instruction.from].boxes)
    end
    push!(warehouse.stacks[instruction.to].boxes, moveboxes...)
end

function highestbox(warehouse)
    _, stackidx = findmax(length.(warehouse.stacks))
    return warehouse.stacks[stackidx].boxes[end]
end

function highestboxeachstack(warehouse)
    last.(warehouse.stacks)
end

function test()
    input = """
    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2"""
    input = split(input, "\n")

    @show warehouse = f(input[1:4])
    for i in input[6:end]
        @show instruction = g(i)
        # h!(warehouse, instruction)
        j!(warehouse, instruction)
        @show warehouse
    end

    @show highestboxeachstack(warehouse)
end

test()

##

function part1()
    data = read("data/5.txt", String)
    data = split(data, "\r\n")

    warehouse = f(data[1:9])
    for i in data[11:end]
        instruction = g(i)
        h!(warehouse, instruction)
    end

    @show warehouse

    highestboxeachstack(warehouse)
end

part1()

##

function part2()
    data = read("data/5.txt", String)
    data = split(data, "\n")

    warehouse = f(data[1:9])
    for i in data[11:end]
        instruction = g(i)
        j!(warehouse, instruction)
    end

    @show warehouse

    highestboxeachstack(warehouse)
end

part2()