include("load.jl")

function main()
    inp = load(@__FILE__())
    # @chain inp begin
    #     split("\n")
    #     filter.(isnumeric, _)
    #     map(x -> x[1] * x[end], _)
    #     parse.(Int, _)
    #     sum
    # end

    numbers = 1:9
    numberstext = String.([:one :two :three :four :five :six :seven :eight :nine])
    replacetable = (t => n for (n, t) in zip(numbers, numberstext))
    revnumberstext = reverse.(numberstext)
    revreplacetable = (t => n for (n, t) in zip(numbers, revnumberstext))

    out = map(split(inp, "\n")) do i
        s = replace(i, replacetable..., count=1)
        s = filter.(isnumeric, s)
        s1 = s[1]

        s = replace(reverse(i), revreplacetable..., count=1) |> reverse
        s = filter.(isnumeric, s)
        s2 = s[end]
        # if length(s) == 1
        #     return parse(Int, s)
        # else
        #     @info i, s
        #     return parse(Int, s[1] * s[end])
        # end
        # return parse(Int, s[1] * s[end])
        return parse(Int, s1 * s2)
    end
    @info sum(out)
    # out = @chain inp begin
    #     split("\n")
    #     a, b = replace.(replacetable..., count=1), replace.(revreplacetable..., count=1)
    #     filter.(isnumeric, _)
    #     map(x -> begin
    #             if length(x) == 1
    #                 return x
    #             else
    #                 return x[1] * x[end]
    #             end
    #         end, _)
    #     # parse.(Int, _)
    #     # sum
    # end
    write("out.txt", join(out, "\n"))
end

main()