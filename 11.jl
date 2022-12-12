using Test
using Logging


mutable struct Monkey
    # items::Vector{BigFloat}
    items::Vector{Item}
    operation::Vector{String}
    divisiblecondition::Int64
    truemonkey::Int64
    falsemonkey::Int64
    inspectcount::Int64
end

##

Base.global_logger(ConsoleLogger(Warn))

function operate(monkey, item)
    if monkey.operation[2] == "old"
        return eval(Meta.parse("$item $(monkey.operation[1]) $item"))
    else
        return eval(Meta.parse("$item $(monkey.operation[1]) $(monkey.operation[2])"))
    end
end

function runround(monkeys)
    for (i, monkey) in enumerate(monkeys)
        @info "Monkey $(i-1):"

        while !isempty(monkey.items)
            item = popfirst!(monkey.items)
            monkey.inspectcount += 1
            @info "  Monkey inspects item with worry level of $item"
            worrylevel = operate(monkey, item)
            @info "    Worry level increases by $item to $worrylevel"
            # worrylevel = worrylevel ÷ 3
            # @info "    Monkey gets bored: worry level divided by 3 to $worrylevel"

            # worrylevel %= monkey.divisiblecondition
            # if isinteger(worrylevel/monkey.divisiblecondition)
            if worrylevel%monkey.divisiblecondition == 0
                throwto = monkey.truemonkey
            else
                throwto = monkey.falsemonkey
            end
            push!(monkeys[throwto+1].items, worrylevel)
            @info "    Item with worry level $worrylevel is thrown to monkey $throwto"
        end
    end
end

function f(in)
    startingitems = eachmatch(r"Starting items: (.+?)\n", in)
    operations = eachmatch(r"Operation: (.+?)\n", in)
    tests = eachmatch(r"Test: (.+?)\n", in)
    ttests = eachmatch(r"If true: (.+?)\n", in)
    ftests = eachmatch(r"If false: (.+)", in)

    startingitems = getproperty.(collect(startingitems), :captures)
    startingitems = map(startingitems) do arr
        parse.(Int, split(arr[1], ", "))
    end
    operations = getproperty.(collect(operations), :captures)
    operations = map(operations) do arr
        op, val = arr[1][11], arr[1][13:end]
        [string(op), string(val)]
        # eval(Meta.parse("x -> x $op $val"))
    end
    tests = getproperty.(collect(tests), :captures)
    ttests = getproperty.(collect(ttests), :captures)
    ftests = getproperty.(collect(ftests), :captures)
    throws = map(tests, ttests, ftests) do tes, t, f
        divisibleby = parse(Int, match(r"by (\d{1,})", tes[1])[1])
        truethrow = parse(Int, match(r"monkey (\d{1,})", t[1])[1])
        falsethrow = parse(Int, match(r"monkey (\d{1,})", f[1])[1])
        (divisibleby, truethrow, falsethrow)
    end
    
    monkeys = Monkey[]
    for (i, op, throw) in zip(startingitems, operations, throws)
        push!(monkeys, Monkey(i, op, throw[1], throw[2], throw[3], 0))
    end
    monkeys
end

function test()
    input = raw"""
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1"""
    # input = split(input, "\n")

    monkeys = f(input)
    for _ in 1:20
        runround(monkeys)
    end
    @show getproperty.(monkeys, :inspectcount)
    *(sort(getproperty.(monkeys, :inspectcount))[end-1:end]...)
    # for i in input
    #     @show f(i)
    # end
end

test()

##

function part1()
    input = read("data/11.txt", String)
    # input = split(input, "\n")
    monkeys = f(input)
    for _ in 1:20
        runround(monkeys)
    end
    @show getproperty.(monkeys, :inspectcount)
    *(sort(getproperty.(monkeys, :inspectcount))[end-1:end]...)
end

part1()

##
using Logging
Base.global_logger(ConsoleLogger(Warn))

mutable struct Item
    multipliers::Vector{BigInt}
    addifier::Int64
end

mutable struct Monkey
    # items::Vector{BigFloat}
    items::Vector{Item}
    operation::Vector{String}
    divisiblecondition::Int64
    truemonkey::Int64
    falsemonkey::Int64
    inspectcount::Int64
end

function g(in)
    startingitems = eachmatch(r"Starting items: (.+?)\n", in)
    operations = eachmatch(r"Operation: (.+?)\n", in)
    tests = eachmatch(r"Test: (.+?)\n", in)
    ttests = eachmatch(r"If true: (.+?)\n", in)
    ftests = eachmatch(r"If false: (.+)", in)

    startingitems = getproperty.(collect(startingitems), :captures)
    startingitems = map(startingitems) do arr
        parse.(Int, split(arr[1], ", "))
    end
    operations = getproperty.(collect(operations), :captures)
    operations = map(operations) do arr
        op, val = arr[1][11], arr[1][13:end]
        [string(op), string(val)]
        # eval(Meta.parse("x -> x $op $val"))
    end
    tests = getproperty.(collect(tests), :captures)
    ttests = getproperty.(collect(ttests), :captures)
    ftests = getproperty.(collect(ftests), :captures)
    throws = map(tests, ttests, ftests) do tes, t, f
        divisibleby = parse(Int, match(r"by (\d{1,})", tes[1])[1])
        truethrow = parse(Int, match(r"monkey (\d{1,})", t[1])[1])
        falsethrow = parse(Int, match(r"monkey (\d{1,})", f[1])[1])
        (divisibleby, truethrow, falsethrow)
    end
    
    monkeys = Monkey[]
    for (i, op, throw) in zip(startingitems, operations, throws)
        items = Item[]
        for item in i
            push!(items, Item([item, 1], item%1))
        end
        push!(monkeys, Monkey(items, op, throw[1], throw[2], throw[3], 0))
    end
    monkeys
end

function operate2(monkey::Monkey, item::Item)
    if monkey.operation[2] != "old"
        val = parse(Int, monkey.operation[2])
        if monkey.operation[1] == "+"
            item.addifier += val
        elseif monkey.operation[1] == "*"
            idxmin = findmin(item.multipliers)[2]
            item.multipliers[idxmin] *= val
        end
    else
        ms = copy(item.multipliers)
        val = push!(item.multipliers, ms...)
    end
end

function isdivisible(item, condition::Int64)
    return all(x->x%condition == 0, item.multipliers) && (item.addifier % condition == 0) 
end

function runround2(monkeys)
    for (i, monkey) in enumerate(monkeys)
        @info "Monkey $(i-1):"

        while !isempty(monkey.items)
            item = popfirst!(monkey.items)
            monkey.inspectcount += 1
            @info "  Monkey inspects item with worry level of $item"
            operate2(monkey, item)
            @info "    Worry level increases by $item to $item"
            # worrylevel = worrylevel ÷ 3
            # @info "    Monkey gets bored: worry level divided by 3 to $worrylevel"

            # worrylevel %= monkey.divisiblecondition
            # if isinteger(worrylevel/monkey.divisiblecondition)
            if isdivisible(item, monkey.divisiblecondition)
                throwto = monkey.truemonkey
            else
                throwto = monkey.falsemonkey
            end
            push!(monkeys[throwto+1].items, item)
            # @info "    Item with worry level $worrylevel is thrown to monkey $throwto"
        end
    end
end

function test()
    input = raw"""
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1"""
    # input = split(input, "\n")

    monkeys = g(input)
    for _ in 1:20
        runround2(monkeys)
    end
    monkeys
    # @show getproperty.(monkeys, :inspectcount)
    # *(sort(getproperty.(monkeys, :inspectcount))[end-1:end]...)
    # for i in input
    #     @show f(i)
    # end
end

test()
##

function part2()
    input = read("data/11.txt", String)
    # input = split(input, "\n")
    monkeys = f(input)

end

part2()