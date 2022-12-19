using Test

module Types
@enum Resource Ore Clay Obsidian Geode

abstract type Robot end
struct OreRobot <: Robot
    cost::Matrix{Int64}
end
struct ClayRobot <: Robot
    cost::Matrix{Int64}
end
struct ObsidianRobot <: Robot
    cost::Matrix{Int64}
end
struct GeodeRobot <: Robot
    cost::Matrix{Int64}
end

mutable struct Bank{T<:Int64}
    # ore::T
    # clay::T
    # obsidian::T
    # geode::T
    amount::Matrix{T}
end
end
Resource = Types.Resource
OreRobot = Types.OreRobot
ClayRobot = Types.ClayRobot
ObsidianRobot = Types.ObsidianRobot
GeodeRobot = Types.GeodeRobot
Robot = Types.Robot
Bank = Types.Bank

function f(blueprint)
    # lines = split(blueprint, "\n")[2:5]
    m1 = match(r"Each ore robot costs (\d+) ore", blueprint)
    m2 = match(r"Each clay robot costs (\d+) ore", blueprint)
    m3 = match(r"Each obsidian robot costs (\d+) ore and (\d+) clay", blueprint)
    m4 = match(r"Each geode robot costs (\d+) ore and (\d+) obsidian", blueprint)
    orerobot = OreRobot([parse(Int64, m1[1]) 0 0 0])
    clayrobot = ClayRobot([parse(Int64, m2[1]) 0 0 0])
    obsidianrobot = ObsidianRobot([parse.(Int64, m3)... 0 0])
    geoderobot = GeodeRobot([parse(Int64, m4[1]) 0 parse(Int64, m4[2]) 0])
    return (ore=orerobot, clay=clayrobot, obsidian=obsidianrobot, geode=geoderobot)
end

mine!(bank, ::OreRobot) = (bank.amount += [1 0 0 0])
mine!(bank, ::ClayRobot) = (bank.amount += [0 1 0 0])
mine!(bank, ::ObsidianRobot) = (bank.amount += [0 0 1 0])
mine!(bank, ::GeodeRobot) = (bank.amount += [0 0 0 1])
canbuy(bank, robot::Robot) = all(robot.cost .<= bank.amount)
function step!(bank, robots, robotcosts)
    # spend resource
    robotstobuy = []
    while any((
        canbuy(bank, robotcosts.ore),
        canbuy(bank, robotcosts.clay),
        canbuy(bank, robotcosts.obsidian),
        canbuy(bank, robotcosts.geode),
    ))
        if canbuy(bank, robotcosts.geode)
            @info "Buy a geode robot"
            bank.amount -= robotcosts.geode.cost
            push!(robotstobuy, robotcosts.geode)
        elseif canbuy(bank, robotcosts.obsidian)
            @info "Buy a obsidian robot"
            bank.amount -= robotcosts.obsidian.cost
            push!(robotstobuy, robotcosts.obsidian)
        elseif canbuy(bank, robotcosts.clay)
            @info "Buy a clay robot"
            bank.amount -= robotcosts.clay.cost
            push!(robotstobuy, robotcosts.clay)
        elseif canbuy(bank, robotcosts.ore)
            @info "Buy a ore robot"
            bank.amount -= robotcosts.ore.cost
            push!(robotstobuy, robotcosts.ore)
        end
        @info "$bank"
    end

    # collect resources
    for robot in robots
        mine!(bank, robot)
    end
    @info "You now have $(bank.amount)"

    # add robots to inventory
    push!(robots, robotstobuy...)
end

function test()
    input = raw"""
Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian."""
    input = split(input, "\n")

    # @show f(input)
    for i in input
        robotcosts = f(i)
        robots = Robot[robotcosts.ore]
        bank = Bank([0 0 0 0])
        for min in 1:24
            @info "Minute $min"
            step!(bank, robots, robotcosts)
        end
    end
end

test()

##

function part1()
    input = read("data/", String)
    input = split(input, "\n")
end

part1()

##

function part2()
    input = read("data/", String)
    input = split(input, "\n")
end

part2()