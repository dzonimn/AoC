using Test

function f(in)
    cols = length(in[1])
    reshape(parse.(Int, split(join(in), "")), cols, cols)'
end
function isvisiblefromleft(row, rownum)
    edgetree = row[1]
    visible_trees = []

    lasthighest = edgetree
    lasttree = edgetree
    for (col, tree) in enumerate(row[1:end])
        # col == 1 && continue
        # col == length(row) && continue
        if lasttree == 9
            return visible_trees
        elseif tree <= lasttree
            continue
        elseif tree > lasttree && tree > lasthighest
            push!(visible_trees, [rownum, col])
            lasthighest = tree
        end
        lasttree = tree
    end

    return visible_trees
end
function isvisiblefromtop(col, colnum)
    edgetree = col[1]
    visible_trees = []

    lasthighest = edgetree
    lasttree = edgetree
    for (row, tree) in enumerate(col[1:end])
        # row == 1 && continue
        # row == length(col) && continue
        if lasttree == 9
            return visible_trees
        elseif tree <= lasttree
            continue
        elseif tree > lasttree && tree > lasthighest
            push!(visible_trees, [row, colnum])
            lasthighest = tree
        end
        lasttree = tree
    end

    return visible_trees
end
function isvisiblefromright(row, rownum)
    edgetree = row[end]
    visible_trees = []

    lasthighest = edgetree
    lasttree = edgetree
    for (col, tree) in reverse(enumerate(row[1:end]) |> collect)
        # col == 1 && continue
        # col == length(row) && continue
        if lasttree == 9
            return visible_trees
        elseif tree <= lasttree
            continue
        elseif tree > lasttree && tree > lasthighest
            push!(visible_trees, [rownum, col])
            lasthighest = tree
        end
        lasttree = tree
    end

    return visible_trees
end
function isvisiblefrombottom(col, colnum)
    edgetree = col[end]
    visible_trees = []

    lasthighest = edgetree
    lasttree = edgetree
    for (row, tree) in reverse(enumerate(col[1:end]) |> collect)
        # row == 1 && continue
        # row == length(col) && continue
        if lasttree == 9
            return visible_trees
        elseif tree <= lasttree
            continue
        elseif tree > lasttree && tree > lasthighest
            push!(visible_trees, [row, colnum])
            lasthighest = tree
        end
        lasttree = tree
    end

    return visible_trees
end
function g(in)
    visible_trees = Set()
    for (i, r) in enumerate(eachrow(in))
        for t in isvisiblefromleft(r, i)
            push!(visible_trees, t)
        end
        for t in isvisiblefromright(r, i)
            push!(visible_trees, t)
        end
    end
    for (i, c) in enumerate(eachcol(in))
        for t in isvisiblefrombottom(c, i)
            push!(visible_trees, t)
        end
        for t in isvisiblefromtop(c, i)
            push!(visible_trees, t)
        end
    end
    filter!(x -> x[1] != 1, visible_trees)
    filter!(x -> x[2] != 1, visible_trees)
    filter!(x -> x[1] != length(in[1, :]), visible_trees)
    filter!(x -> x[2] != length(in[1, :]), visible_trees)
    return +(length(visible_trees), (length(in[1, :]) - 1) * 4)
end

function test()
    input = raw"""
30373
25512
65332
33549
35390"""
    input = split(input, "\n")

    grid = f(input)
    @show g(grid)
    # for i in input
    #     @show f(i)
    # end
end

test()

##

function part1()
    data = read("data/8.txt", String)
    data = split(data, "\r\n")
    grid = f(data)
    g(grid)
end

part1()

##

function score(in, curr_tree, direction, r, c, nrows, ncols)
    score = 0
    if direction == :up
        # r == 1 && return 0
        while true
            score += 1
            r - score == 0 && return score - 1
            if curr_tree <= in[r-score, c]
                return score
            end
        end
    elseif direction == :down
        # r == nrows && return 0
        while true
            score += 1
            r + score == nrows + 1 && return score - 1
            if curr_tree <= in[r+score, c]
                return score
            end
        end
    elseif direction == :left
        # c == 1 && return 0
        while true
            score += 1
            c - score == 0 && return score - 1
            if curr_tree <= in[r, c-score]
                return score
            end
        end
    elseif direction == :right
        # c == ncols && return 0
        while true
            score += 1
            c + score == ncols + 1 && return score - 1
            if curr_tree <= in[r, c+score]
                return score
            end
        end
    end
end
function g(in)
    nrows = length(in[1, :])
    ncols = length(in[:, 1])
    scores = similar(in)
    for r in 1:nrows, c in 1:ncols
        curr_tree = in[r, c]
        # @show r, c, score(in, curr_tree, :left, r, c, nrows, ncols)
        scores[r, c] = score(in, curr_tree, :up, r, c, nrows, ncols) * score(in, curr_tree, :down, r, c, nrows, ncols) * score(in, curr_tree, :left, r, c, nrows, ncols) * score(in, curr_tree, :right, r, c, nrows, ncols)
    end
    return scores
end

function test()
    input = raw"""
30373
25512
65332
33549
35390"""
    input = split(input, "\n")

    grid = f(input)
    @show g(grid)
    # for i in input
    #     @show f(i)
    # end
end

test()

##

function part2()
    data = read("data/8.txt", String)
    data = split(data, "\r\n")
    grid = f(data)
    g(grid) |> x -> max(x...)
end

part2()