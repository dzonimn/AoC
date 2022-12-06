using Test

function f(i; start=1)
    for idx in 14+start-1:length(i)
        # @show idx
        if length(unique(i[idx-13:idx])) == 14
            return idx
        end
    end
end

function g(i)
    charsseen = Set()
    for (idx, c) in enumerate(i)
        push!(charsseen, c)
        if length(charsseen) == 14
            return idx
        end
    end
end

function test()
    input = """
mjqjpqmgbljsphdztnvjfqwrcgsmlb
bvwbjplbgvbhsrlpgdmjqwftvncz
nppdvjthqldpwncqszvftbrmjlhg
nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg
zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"""
    input = split(input, "\n")

    # @show f(input)
    for i in input
        @show f(i)
        @show g(f(i))
        @show f(g(i), start=g(i))
    end
end

test()

##

function part1()
    data = read("data/6.txt", String)
    # data = split(data, "\n")
    f(data)
    # g(data)
end

part1()

##

function part2()
    data = read("data/6.txt", String)
    data = split(data, "\n")
end

part2()