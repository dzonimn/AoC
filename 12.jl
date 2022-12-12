using ReinforcementLearning
using Random
using Flux
using Flux.Losses
import Flux: params

Base.@kwdef mutable struct MazeEnv <: AbstractEnv
    reward::Int64 = 0
    map::Matrix{Int64} = [
        0 0 0 0 0
        0 0 0 0 0
    ]
    position::Tuple{Int64,Int64} = (1, 1)
    goal::Tuple{Int64,Int64} = (2, 5)
    reset_state = (map=map, position=position, goal=goal)
end

# RLBase.action_space(::MazeEnv) = (:UP, :DOWN, :LEFT, :RIGHT)
RLBase.action_space(::MazeEnv) = (1, 2, 3, 4)
function RLBase.reward(env::MazeEnv)
    if is_terminated(env)
        if env.position == env.goal
            return 10
        else
            return 0
        end
    else
        return -1
    end
end
# RLBase.state(env::MazeEnv) = (env.map, env.position, env.goal)
RLBase.state(env::MazeEnv) = vcat(reshape(env.map, :), env.position..., env.goal...)
function RLBase.state_space(env::MazeEnv)
    x, y = size(env.map)
    state_positions = (Base.OneTo(x), Base.OneTo(y))
    goalx, goaly = env.goal
    states = []
    for x in 1:x, y in 1:y
        push!(states, vcat(reshape(env.map, :), x, y, goalx, goaly))
    end
    return states
end
function RLBase.legal_action_space(env::MazeEnv)
    findall(legal_action_space_mask(env))
end
function RLBase.legal_action_space_mask(env::MazeEnv)
    # legal_actions = (:UP, :DOWN, :LEFT, :RIGHT)
    legal_actions = ones(Int, 4)
    rows, cols = size(env.map)
    xpos, ypos = env.position
    if ypos == 1
        legal_actions[1] = 0
    elseif ypos == cols
        legal_actions[2] = 0
    end
    if xpos == 1
        legal_actions[3] = 0
    elseif xpos == rows
        legal_actions[4] = 0
    end

    current_height = env.map[xpos, ypos]
    up_height = env.map[xpos, max(1, ypos)]
    down_height = env.map[xpos, min(cols, ypos)]
    left_height = env.map[max(1, xpos - 1), ypos]
    right_height = env.map[min(rows, xpos + 1), ypos]
    up_height - current_height < 0 && (legal_actions[1] = 0)
    down_height - current_height < 0 && (legal_actions[2] = 0)
    left_height - current_height < 0 && (legal_actions[3] = 0)
    right_height - current_height < 0 && (legal_actions[4] = 0)
    up_height - current_height > 1 && (legal_actions[1] = 0)
    down_height - current_height > 1 && (legal_actions[2] = 0)
    left_height - current_height > 1 && (legal_actions[3] = 0)
    right_height - current_height > 1 && (legal_actions[4] = 0)

    return Bool.(legal_actions)
end
function RLBase.is_terminated(env::MazeEnv)
    (env.position == env.goal) || (length(legal_action_space(env)) == 0)
end
function RLBase.reset!(env::MazeEnv)
    env.reward = 0
    env.map = env.reset_state.map
    env.position = env.reset_state.position
    env.goal = env.reset_state.goal
end
function (env::MazeEnv)(action)
    xcur, ycur = env.position
    if action == 1 #:UP
        env.position = (xcur, ycur - 1)
    elseif action == 2 #:DOWN
        env.position = (xcur, ycur + 1)
    elseif action == 3 #:LEFT
        env.position = (xcur - 1, ycur)
    elseif action == 4 #:RIGHT
        env.position = (xcur + 1, ycur)
    end
end

RLBase.NumAgentStyle(::MazeEnv) = SINGLE_AGENT
RLBase.DynamicStyle(::MazeEnv) = SEQUENTIAL
RLBase.ActionStyle(::MazeEnv) = FULL_ACTION_SET
RLBase.InformationStyle(::MazeEnv) = PERFECT_INFORMATION
RLBase.StateStyle(::MazeEnv) = Observation{Int}()
RLBase.RewardStyle(::MazeEnv) = TERMINAL_REWARD
RLBase.UtilityStyle(::MazeEnv) = GENERAL_SUM
RLBase.ChanceStyle(::MazeEnv) = DETERMINISTIC

##

function RL.Experiment(
    ::Val{:JuliaRL},
    ::Val{:BasicDQN},
    env,
    ::Nothing;
    seed=123
)
    # rng = StableRNG(seed)
    rng = MersenneTwister(seed)
    env = env
    ns, na = length(state(env)), length(action_space(env))

    policy = Agent(
        policy=QBasedPolicy(
            learner=BasicDQNLearner(
                approximator=NeuralNetworkApproximator(
                    model=Chain(
                        Dense(ns, 128, relu; init=glorot_uniform(rng)),
                        Dense(128, 128, relu; init=glorot_uniform(rng)),
                        Dense(128, na; init=glorot_uniform(rng)),
                    ) |> cpu,
                    optimizer=ADAM(),
                ),
                batch_size=32,
                min_replay_history=100,
                loss_func=huber_loss,
                rng=rng,
            ),
            explorer=EpsilonGreedyExplorer(
                kind=:exp,
                ϵ_stable=0.01,
                decay_steps=500,
                rng=rng,
            ),
        ),
        trajectory=CircularArraySARTTrajectory(
            capacity=1000,
            state=Vector{Int32} => (ns,),
            action=Int32 => (),
        ),
    )
    stop_condition = StopAfterStep(10_000, is_show_progress=!haskey(ENV, "CI"))
    hook = TotalRewardPerEpisode()
    Experiment(policy, env, stop_condition, hook, "# BasicDQN <-> MazeEnv")
end

ex = E`JuliaRL_BasicDQN_MazeEnv`
run(ex)

##

function converttonum(c)
    if c == 'S'
        return -1
    elseif c == 'E'
        return -2
    end
    return Int(c) - 97
end
function parseline(line)
end
function parsemap(in)
    in = split(in)
    y, x = length(in[1]), length(in)
    map = Matrix{Int64}(undef, x, y)
    for (row, line) in enumerate(in)
        for (col, c) in enumerate(line)
            map[row, col] = converttonum(c)
        end
    end
    goalidx = findfirst(==(-2), map)
    map[goalidx] = max(map...) + 1
    return map
end

function test()
    input = """Sabqponm
    abcryxxl
    accszExk
    acctuvwj
    abdefghi"""
    # input = split(input)
    map = parsemap(input)
    start_pos = findfirst(==(-1), map).I
    goal_pos = findfirst(==(max(map...)), map).I
    env = MazeEnv(; map=map, position=start_pos, goal=goal_pos)

    rng = MersenneTwister(123)
    ns, na = length(state(env)), length(action_space(env))

    agent = Agent(
        policy=QBasedPolicy(
            learner=BasicDQNLearner(
                approximator=NeuralNetworkApproximator(
                    model=Chain(
                        Dense(ns, 128, relu; init=glorot_uniform(rng)),
                        Dense(128, 128, relu; init=glorot_uniform(rng)),
                        Dense(128, na; init=glorot_uniform(rng)),
                    ) |> cpu,
                    optimizer=ADAM(),
                ),
                batch_size=32,
                min_replay_history=100,
                loss_func=huber_loss,
                rng=rng,
            ),
            explorer=EpsilonGreedyExplorer(
                kind=:exp,
                ϵ_stable=0.01,
                decay_steps=500,
                rng=rng,
            ),
        ),
        trajectory=CircularArraySARTTrajectory(
            capacity=1000,
            state=Vector{Int32} => (ns,),
            action=Int32 => (),
            reward=Int32 => (),
        ),
    )
    # stop_condition = StopAfterNoImprovement(() -> reward(env), 100)
    stop_condition = StopAfterStep(10_000, is_show_progress=!haskey(ENV, "CI"))
    hook = TotalRewardPerEpisode()
    Experiment(agent, env, stop_condition, hook, "# BasicDQN <-> MazeEnv")
end
ex = test()

##

function part1()

end