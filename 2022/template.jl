using Test

function f(in)
    in
end

function test()
    input = raw"""
"""
    input = split(input, "\n")


    @show f(input)
    # for i in input
    #     @show f(i)
    # end
end

test()

##

function solve()
    input = read("data/", String)
    input = split(input, "\n")
end

solve()
