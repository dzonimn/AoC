include("load.jl")

function main()
    inp = load(@__FILE__())

    # map(inp) do i
    #     i = split(i, ':')[2]
    #     win_nos, my_nos = split(i, '|')
    #     win_nos, my_nos = parse.(Int, split(win_nos)), parse.(Int, split(my_nos))
    #     matching = intersect(win_nos, my_nos)
    #     if isempty(matching)
    #         return 0
    #     elseif length(matching) == 1
    #         return 1
    #     else
    #         return 2^(length(matching) - 1)
    #     end
    # end |> sum


    function no_matching(i)
        win_nos, my_nos = split(i, '|')
        win_nos, my_nos = parse.(Int, split(win_nos)), parse.(Int, split(my_nos))
        return intersect(win_nos, my_nos) |> length
    end

    stack = []
    total_cards = Dict()
    for card in inp
        m = match(r"Card(?: +)(\d+): (.+?)$", card)
        no_matches = no_matching(m[2])

        for _ in 1:length(stack)
            card2 = popfirst!(stack)
            m2 = match(r"Card(?: +)(\d+): (.+?)$", inp[card2])
            no_matches2 = no_matching(m2[2])
            for i in 1:no_matches2
                push!(stack, parse(Int, m2[1]) + i)
            end
            total_cards[m2[1]] = get(total_cards, m2[1], 0) + 1
        end

        for i in 1:no_matches
            push!(stack, parse(Int, m[1]) + i)
        end
        total_cards[m[1]] = get(total_cards, m[1], 0) + 1
    end
    return stack, values(total_cards) |> sum
end

main()
