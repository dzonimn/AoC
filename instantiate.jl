using Dates

todaydate = day(today())
if todaydate < 10
    todaydatefile = "0" * string(todaydate)
else
    todaydatefile = string(todaydate)
end

filecontents = read("./template.jl", String)
filecontents = replace(filecontents, "data/" => "data/$todaydate.txt")

write("$todaydatefile.jl", filecontents)
