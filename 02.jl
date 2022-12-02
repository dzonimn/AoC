abstract type Move end
struct Rock <: Move end
struct Paper<: Move  end
struct Scissors<: Move  end

function main()
    data = read("data/2.txt", String)
    data = split(data, "\n")
    
    # part 1
    leftrps = getindex.(data, 1)
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
    
    leftrps = change_to_rps.(leftrps)
    rightrps = change_to_rps.(rights)
   
    #win conditions
    duel(::Rock, ::Scissors) = 1 + 6
    duel(::Paper, ::Rock) = 2 + 6
    duel(::Scissors, ::Paper) = 3 + 6

    #losee conditions
    duel(::Rock, ::Paper) = 1 + 0
    duel(::Paper, ::Scissors) = 2 + 0
    duel(::Scissors, ::Rock) = 3 + 0 

    #draw conditiosn
    duel(::Rock, ::Rock) = 1 +3
    duel(::Paper, ::Paper) = 2 + 3
    duel(::Scissors, ::Scissors) = 3 + 3
    
    results = duel.(rightrps, leftrps)
    
    @show sum(results)
    
    # part 2
    function change_to_result(char)
        if char ∈ [ 'X']
            return "Lose"
        elseif char ∈ [ 'Y']
            return "Draw"
        elseif char ∈ [ 'Z']
            return "Win"
        end
    end
    
    rightresult = change_to_result.(rights)
    
    function correct_move(move::Rock, desiredresult)
        if desiredresult == "Win"
            return Paper()
        elseif desiredresult == "Lose"
            return Scissors()
        elseif desiredresult == "Draw"
            return Rock()
        end
    end
    function correct_move(move::Paper, desiredresult)
        if desiredresult == "Win"
            return Scissors()
        elseif desiredresult == "Lose"
            return Rock()
        elseif desiredresult == "Draw"
            return Paper()
        end
    end
    function correct_move(move::Scissors, desiredresult)
        if desiredresult == "Win"
            return Rock()
        elseif desiredresult == "Lose"
            return Paper()
        elseif desiredresult == "Draw"
            return Scissors()
        end
    end
    
    correct_moves = correct_move.(leftrps, rightresult)
    
    results = duel.(correct_moves, leftrps)
    
    sum(results)    
end

main()