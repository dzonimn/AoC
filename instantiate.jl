using Dates

todaydate = day(today())

print("Enter the file number [$todaydate]: ")
filename = readline()

@assert all(isdigit, filename) "Must be integer"

if length(filename) == 1
    filenamewithzero = "0" * string(filename)
    filecontents = read("./template.jl", String)
    filecontents = replace(filecontents, "data/" => "data/$filenamewithzero.txt")
else
    filecontents = read("./template.jl", String)
    filecontents = replace(filecontents, "data/" => "data/$filename.txt")
end

write("$filename.jl", filecontents)
touch("data/$filename.txt")