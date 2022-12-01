function main1()
    data = read("data/1.txt", String)
    calories = map(split.(split(data, "\n\n"), "\n")) do v
        parse.(Int, v)
    end
    sum.(calories) |> x->max(x...)
end

function main2()

end

function test()

end

test()
main1()
main2()