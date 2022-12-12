using Test

function f()

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

function part1()
    input = read("data/", String)
    input = split(input, "\n")
end

part1()

##

function part2()
    input = read("data/", String)
    input = split(input, "\n")
end

part2()