splithalf(str) = Iterators.partition(str, length(str) ÷ 2)
findcommon(arr) = intersect(arr...)[1]
function priority(char)
    if char ∈ 'a':'z'
        return Int(char) - 96
    elseif char ∈ 'A':'Z'
        return Int(char) - 38
    end
end
function findcommoninchunk(strs)
    intersect(
        intersect.(strs[1:2]...),
        intersect.(strs[2:3]...)
    )[1]
end

## part 1
input = readlines("data/3.txt")
priority.(findcommon.(splithalf.(data))) |> sum

## part 2
priority.(findcommoninchunk.(Iterators.partition(data, 3))) |> sum