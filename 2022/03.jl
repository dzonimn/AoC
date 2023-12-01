using Test

f(str) = (str[1:Int(length(str)/2)], str[Int(length(str)/2)+1:end])
g(arr) = intersect(arr...)[1]
function priority(char)
    if char ∈ 'a':'z'
        return Int(char) -96
    elseif char ∈ 'A':'Z'
        return Int(char) - 38
    end
end
function h(strs)
    intersect(
    intersect.(strs[1:2]...),
    intersect.(strs[2:3]...)
    )[1]
end

function test()
    input = """
vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw"""
    @test f("vJrwpWtwJgWrhcsFMMfFFhFp") == ("vJrwpWtwJgWr", "hcsFMMfFFhFp")
    @test g(["vJrwpWtwJgWr", "hcsFMMfFFhFp"]) == 'p'
    @test priority('a') == 1
    @test priority('A') == 27
    input = split(input, "\n")
    @show h(collect(input[3i-2:3i] for i in 1:Int(length(input)/3))[2])

end

test()


##

function main()
    data = read("data/3.txt", String)
    data = split(data, "\n")
    priority.(g.(f.(data))) |> sum
end

main()

##

function main()
    data = read("data/3.txt", String)
    data = split(data, "\n")
    priority.(h.(data[3i-2:3i] for i in 1:Int(length(data)/3))) |> sum
end

main()