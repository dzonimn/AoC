using Dates

todaydate = day(today())

print("Enter the file number [$todaydate]: ")
filename = readline()

filename == "" && (filename = string(todaydate))
@assert all(isdigit, filename) "Must be integer"

if length(filename) == 1
    jlfilename = "0" * string(filename)
else
    jlfilename = filename
end

filecontents = read("./template.jl", String)
filecontents = replace(filecontents, "data/" => "data/$filename.txt")

write("$filename.jl", filecontents)
touch("data/$jlfilename.txt")