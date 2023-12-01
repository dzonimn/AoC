using Test

abstract type Instruction end
mutable struct ADDX <: Instruction
    timer::Int64
    effect::Int64
end
mutable struct NOOP <: Instruction
    timer::Int64
    effect::Int64
end

mutable struct CPU
    cycle::Int64
    X::Int64
    instructions::Vector{Instruction}
end

function addinstruction(cpu, input)
    noop = NOOP(0, 0)
    addx(n) = ADDX(1, n)

    if input == "noop"
        push!(cpu.instructions, noop)
    else
        _, n = split(input)
        n = parse(Int, n)
        push!(cpu.instructions, addx(n))
    end
    
    return cpu
end

function step(cpu)
    expiredinstructionsidxs = findall(i->i.timer == 0, cpu.instructions)
    for idx in reverse(expiredinstructionsidxs)
        cpu.X += cpu.instructions[idx].effect
        deleteat!(cpu.instructions, idx)
    end

    for ins in cpu.instructions
        ins.timer = ins.timer - 1
    end
    cpu.cycle += 1
    
    return cpu
end

function test()
    input = raw"""
addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop"""
    input = split(input, "\n")

    cpu = CPU(1, 1, [])

    for i in input
        cpu = addinstruction(cpu, i)
        while !isempty(cpu.instructions)
            cpu = step(cpu)
        end
    end
    @show cpu
end

test()

##

function part1()
    input = read("data/10.txt", String)
    input = split(input, "\n")

    input = readlines("data/10.txt")
    cpu = CPU(1,1,[])
    
    strengths = Int64[]
    for i in input
        # @info "Add instruction before cycle"
        cpu = addinstruction(cpu, i)
        # @show cpu
        while !isempty(cpu.instructions)
            # @info "Step through 1 cycle"
            cpu = step(cpu)
            # @show cpu
            if cpu.cycle ∈ [20, 60, 100, 140, 180, 220]
                push!(strengths, cpu.cycle*cpu.X)
            end
        end
        # @info "Finished all instructions, going to next instruction"
    end
    
    sum(strengths)
end

part1()

##

function part2()
    input = read("data/10.txt", String)
    input = split(input, "\n")
end

part2()