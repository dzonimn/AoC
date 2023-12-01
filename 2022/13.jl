using Test

function checklengths(left, right)
    if length(right) > length(left)
        return true
    else
        return false
    end
end
function inorder(left::Int64, right::Int64)
    for (l, r) in zip(left, right)
        if l == r
            continue
        elseif l > r
            return false
        elseif l < r
            return true
        end
    end
end
# function inorder(left::Vector{Int64}, right::Vector{Int64})
#     for (l, r) in zip(left, right)
#         if l == r
#             continue
#         elseif l > r
#             return false
#         elseif l < r
#             return true
#         end
#     end
#     return checklengths(left, right)
# end
# function inorder(left::Vector{Vector{Int64}}, right::Vector{Any})
#     for (l, r) in zip(left, right)
#         if l == r
#             continue
#         else
#             return inorder(l, r)
#         end
#     end
#     return inorder(l, r)
# end
inorder(left::Vector{T}, right::Integer) where {T<:Union{Int64,Any}} = inorder(left, Int64[right])
inorder(left::Int64, right::Vector{T}) where {T<:Union{Int64,Any}} = inorder(Int64[left], right)
# function inorder(left::Vector{Int64}, right::Vector{Vector{Int64}})
#     for (l, r) in zip(left, right)
#         l == r && continue
#         return inorder(l, r)
#     end
# end
function inorder(left::Vector{T}, right::Vector{U}) where {T<:Union{Int64,Any},U<:Union{Int64,Any}}
    @show left right
    for (l, r) in zip(left, right)
        if l == r
            continue
        else
            return inorder(l, r)
        end
    end
    return checklengths(left, right)
end
function inorder(left, right)
    for (l, r) in zip(left, right)
        return inorder(l, r)
    end
    return checklengths(left, right)
end

function f(in)
    l, r = split(in, "\n")
    left = eval(Meta.parse(l))
    right = eval(Meta.parse(r))
    inorder(left, right)
end

function test()
    input = raw"""[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]"""
    input = split(input, "\n\n")

    # @show f.(input)
    indices = []
    for (idx, i) in enumerate(input)
        f(i) && push!(indices, idx)
    end
    @show indices
    sum(indices)
end

test()

##

function part1()
    input = read("data/13.txt", String)
    input = replace(input, "\r\n" => "\n")
    input = split(input, "\n\n")
    indices = []
    for (idx, i) in enumerate(input)
        f(i) && push!(indices, idx)
    end
    sum(indices)
end

part1()

##

function part2()
    input = read("data/13.txt", String)
    input = split(input, "\n")
end

part2()