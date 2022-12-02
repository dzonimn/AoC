abstract type Move end
Base.@kwdef struct Rock <: Move
    points = 1
end
Base.@kwdef struct Paper <: Move
    points = 2
end
Base.@kwdef struct Scissors <: Move
    points = 3
end

abstract type Result end
Base.@kwdef struct Win <: Result
    points = 6
end
Base.@kwdef struct Loss <: Result
    points = 0
end
Base.@kwdef struct Draw <: Result
    points = 3
end

duel(::T, ::T) where T<:Move = Draw() 
duel(::Rock, ::Scissors) = Win()
duel(::Paper, ::Rock) = Win()
duel(::Scissors, ::Paper) = Win()
duel(::Scissors, ::Rock) = Loss()
duel(::Rock, ::Paper) = Loss()
duel(::Paper, ::Scissors) = Loss()

points(left, right) = left.points + duel(left, right).points

data = read("data/2.txt", String)
data = split(data, "\n")
lefts = getindex.(data, 1)
rights = getindex.(data, 3)

function change_to_rps(char)
    if char ∈ ['A', 'X']
        return Rock()
    elseif char ∈ ['B', 'Y']
        return Paper()
    elseif char ∈ ['C', 'Z']
        return Scissors()
    end
end

leftrps = change_to_rps.(lefts)
rightrps = change_to_rps.(rights)

points.(rightrps,leftrps) |> sum

## part 2
function change_to_result(char)
    if char ∈ [ 'X']
        return Loss()
    elseif char ∈ [ 'Y']
        return Draw()
    elseif char ∈ [ 'Z']
        return Win()
    end
end
    
rightresult = change_to_result.(rights)

correct_move(::Rock, ::Win) = Paper()
correct_move(::Paper, ::Win) = Scissors()
correct_move(::Scissors, ::Win) = Rock()
correct_move(::Rock, ::Loss) = Scissors()
correct_move(::Paper, ::Loss) = Rock()
correct_move(::Scissors, ::Loss) = Paper()
correct_move(::T, ::Draw) where T<:Move = T()

rightrps = correct_move.(leftrps, rightresult)

points.(rightrps,leftrps) |> sum