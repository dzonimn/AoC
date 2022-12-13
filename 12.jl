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
    move::Int64 = 0
end

# RLBase.action_space(::MazeEnv) = (:UP, :DOWN, :LEFT, :RIGHT)
RLBase.action_space(::MazeEnv) = (1, 2, 3, 4)
RLBase.reward(env::MazeEnv) = env.reward
# function RLBase.reward(env::MazeEnv)
#     if is_terminated(env)
#         if env.position == env.goal
#             10
#         else
#             0
#         end
#     else
#         -1
#     end
# end
# RLBase.state(env::MazeEnv) = (env.map, env.position, env.goal)
# RLBase.state(env::MazeEnv) = vcat(reshape(env.map, :), env.position..., env.goal...)
function getsurrounding(mat, position)
    matrow, matcol = size(mat)
    row, col = position.I
    lrow, hrow = row-1, row+1
    lcol, hcol = col-1, col+1
    arr = zeros(Float32, 3, 3)
    for (i, row) in enumerate(lrow:hrow), (j, col) in enumerate(lcol:hcol)
        if row > matrow || row < 1 || col < 1 || col > matcol
            arr[i, j] = -1
        else
            arr[i, j] = mat[row, col]
        end
    end
    return Float32.(tanh.(arr))
end
RLBase.state(env::MazeEnv) = reshape(getsurrounding(env.map, CartesianIndex(env.position)),:)
function getsurrounding2(mat, position)
    matrow, matcol = size(mat)
    row, col = position.I
    lrow, hrow = row-1, row+1
    lcol, hcol = col-1, col+1
    arr = zeros(Int, 4)
    row-1 < 1 ? (arr[1] = -1) : (arr[1] = mat[row-1, col])
    row+1 > matrow ? (arr[2] = -1) : (arr[2] = mat[row+1, col])
    col-1 < 1 ? (arr[3] = -1) : (arr[3] = mat[row, col-1])
    col+1 > matrow ? (arr[4] = -1) : (arr[4] = mat[row, col+1])
    return arr
end
# RLBase.state(env::MazeEnv) = getsurrounding2(env.map, CartesianIndex(env.position))
# function RLBase.state_space(env::MazeEnv)
#     rows, cols = size(env.map)
#     goalrow, goalcol = env.goal
#     states = []
#     for row in 1:rows, col in 1:cols
#         push!(states, vcat(reshape(env.map, :), row, col, goalrow, goalcol))
#     end
#     return states
# end
function RLBase.state_space(env::MazeEnv)
    states = []
    for one in -1:30,two in -1:30,three in -1:30,four in -1:30,five in -1:30,six in -1:30,seven in -1:30, eight in -1:30, nine in -1:30
        push!(states, [one, two, three, four, five, six, seven, eight, nine])
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
    posrow, poscol = env.position
    if posrow == 1
        legal_actions[1] = 0
    elseif posrow == rows
        legal_actions[2] = 0
    end
    if poscol == 1
        legal_actions[3] = 0
    elseif poscol == cols
        legal_actions[4] = 0
    end

    current_height = env.map[posrow, poscol]
    up_height = env.map[max(1, posrow - 1), poscol]
    down_height = env.map[min(rows, posrow + 1), poscol]
    left_height = env.map[posrow, max(1, poscol-1)]
    right_height = env.map[posrow, min(cols, poscol+1)]
    # cases where the adjacent is shorter
    # up_height - current_height < 0 && (legal_actions[1] = 0)
    # down_height - current_height < 0 && (legal_actions[2] = 0)
    # left_height - current_height < 0 && (legal_actions[3] = 0)
    # right_height - current_height < 0 && (legal_actions[4] = 0)
    # cases where the adjacent is taller by more than 1
    up_height - current_height > 1 && (legal_actions[1] = 0)
    down_height - current_height > 1 && (legal_actions[2] = 0)
    left_height - current_height > 1 && (legal_actions[3] = 0)
    right_height - current_height > 1 && (legal_actions[4] = 0)

    return Bool.(legal_actions)
end
function RLBase.is_terminated(env::MazeEnv)
    (env.position == env.goal) || (length(legal_action_space(env)) == 0) || (env.move > 100)
end
function RLBase.reset!(env::MazeEnv)
    env.reward = 0
    env.map = env.reset_state.map
    env.position = env.reset_state.position
    env.goal = env.reset_state.goal
    env.move = 0
end
function (env::MazeEnv)(action)
    prev_height = env.map[env.position...]
    posrow, poscol = env.position
    if action == 1 #:UP
        env.position = (posrow - 1, poscol)
    elseif action == 2 #:DOWN
        env.position = (posrow + 1, poscol)
    elseif action == 3 #:LEFT
        env.position = (posrow, poscol - 1)
    elseif action == 4 #:RIGHT
        env.position = (posrow, poscol + 1)
    end
    
    # do not punish if height increased
    if env.position == env.goal
        env.reward += 1000
    elseif prev_height < env.map[env.position...]
        env.reward += 0
    else
        env.reward -= 1
    end
    
    env.move+=1
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
    n_atoms = 51
    agent = Agent(
        policy = QBasedPolicy(
            learner = RainbowLearner(
                approximator = NeuralNetworkApproximator(
                    model = Chain(
                        # x->x/max(x...),
                        Dense(ns, 128, relu; init = glorot_uniform(rng)),
                        Dense(128, 128, relu; init = glorot_uniform(rng)),
                        Dense(128, na * n_atoms; init = glorot_uniform(rng)),
                    ) |> cpu,
                    optimizer = ADAM(0.0005),
                ),
                target_approximator = NeuralNetworkApproximator(
                    model = Chain(
                        # x->x/max(x...),
                        Dense(ns, 128, relu; init = glorot_uniform(rng)),
                        Dense(128, 128, relu; init = glorot_uniform(rng)),
                        Dense(128, na * n_atoms; init = glorot_uniform(rng)),
                    ) |> cpu,
                    optimizer = ADAM(0.0005),
                ),
                n_actions = na,
                n_atoms = n_atoms,
                Vₘₐₓ = 1000.0f0,
                Vₘᵢₙ = -1.0f0,
                update_freq = 1,
                γ = 0.99f0,
                update_horizon = 1,
                batch_size = 32,
                stack_size = nothing,
                min_replay_history = 100,
                loss_func = (ŷ, y) -> logitcrossentropy(ŷ, y; agg = identity),
                target_update_freq = 100,
                # rng = rng,
            ),
            explorer = EpsilonGreedyExplorer(
                kind = :exp,
                # ϵ_stable = 0.01,
                ϵ_stable=1,
                decay_steps = 50,
                # rng = rng,
            ),
        ),
        trajectory=CircularArraySARTTrajectory(;
            capacity=10000,
            state=Vector{Float32} => (ns,),
            action=Int32 => (),
            reward=Int32 => (),
            terminal=Bool=>()
        ),
    )
    stop_condition = StopAfterNoImprovement(() -> hook.reward, 5)
    stop_condition = StopAfterStep(100_000, is_show_progress=!haskey(ENV, "CI"))
    hook = TotalRewardPerEpisode()
    Experiment(agent, env, stop_condition, hook, "# Rainbow")
end
ex = test()

##

function part1()

end