using Test

function f()

end

function test()
    input = """

"""
    input = split(input, "\n")

    # @show f(input)
    # for i in input
    #     @show f(i)
    # end
end

test()

##

function part1()
    data = read("data/", String)
    data = split(data, "\n")
end

part1()

##

function part2()
    data = read("data/", String)
    data = split(data, "\n")
end

part2()