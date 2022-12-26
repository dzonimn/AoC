using Test

function snafunumber(str)
    digits = parse.(Int,replace.(split(str, ""), "="=>"-2", "-"=>"-1"))
    factors = [5^i for i in length(digits)-1:-1:0]
    sum(digits .* factors)
end

function test()
    input = raw"""
1=-0-2
12111
2=0=
21
2=01
111
20012
112
1=-1=
1-12
12
1=
122"""
    input = split(input, "\n")

    # @show f(input)
    sum = 0
    for i in input
        @show sum += snafunumber(i)
    end
    return sum
end

test()

##

function solve()
    input = read("data/25.txt", String)
    input = split(input, "\n")
end

solve()
