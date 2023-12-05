using Chain
using DataStructures

function load(filenum)
    file = split(filenum, "/")[end]
    datafile = split(file, ".")[1] * ".txt"
    # read("data/$datafile", String)
    readlines("data/$datafile")
end