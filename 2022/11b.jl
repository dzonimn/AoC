##
using Test
using Logging

module Types
mutable struct Monkey
    # items::Vector{BigFloat}
    items::Vector{Int64}
    operation::Vector{String}
    divisiblecondition::Int64
    truemonkey::Int64
    falsemonkey::Int64
    inspectcount::Int64
end
end
Monkey = Types.Monkey

Base.global_logger(ConsoleLogger(Warn))

function operate(monkey, item)
    if monkey.operation[2] == "old"
        return eval(Meta.parse("$item $(monkey.operation[1]) $item"))
    else
        return eval(Meta.parse("$item $(monkey.operation[1]) $(monkey.operation[2])"))
    end
end

function runround(monkeys, divisor)
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
            worrylevel %= divisor

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
    divisor = *(map(x->x.divisiblecondition, monkeys)...)
    for _ in 1:10000
        runround(monkeys, divisor)
    end
    @show getproperty.(monkeys, :inspectcount)
    @show *(sort(getproperty.(monkeys, :inspectcount))[end-1:end]...)
    # for i in input
    #     @show f(i)
    # end
end

#test()

##

function part1()
    input = read("data/11.txt", String)
    # input = split(input, "\n")
    monkeys = f(input)
    divisor = *(map(x->x.divisiblecondition, monkeys)...)
    for _ in 1:10000
        runround(monkeys, divisor)
    end
    @show getproperty.(monkeys, :inspectcount)
    @show *(sort(getproperty.(monkeys, :inspectcount))[end-1:end]...)
end

part1()
##
