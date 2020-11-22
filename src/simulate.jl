using Random
using StatsBase

"""
	simluate_rollout(b::Board, policy, side [rng=MersenneTwister(420))

Simulate one rollout of a simulation based on the given `Chess.board` state.

Policy is a function, given the board and `MoveList`, returns an `AbstractArray` of probability
weights for each `Move` in `Move`List` based on index.
"""
function simulate_rollout(b::Board, policy, side; rng = MersenneTwister(420))::Tuple{Board, Int64}
	#pprint(b) # Debugging
	movelist = MoveList(200)
	num_sim_moves = 0
	while !isterminal(b) # TODO Use `matein1` possibly to trim leaf nodes in sims?
		moves(b, movelist)
		policy_weights = ProbabilityWeights(policy(b, movelist))
		#pprint(b)
		#println(movelist, policy_weights)
		domove!(b, sample(movelist, policy_weights))
		recycle!(movelist)
		num_sim_moves += 1
	end
	return b, num_sim_moves
end

"""
	CESPF(b::Board, movelist::MoveList)
Utilizes `Chess.jl`'s `see()` function to simulate (C)apture / (E)scape (S)tronger (P)iece
(F)irst heuristic in simulation/rollout policy. We use Chess weights set in `see` function to get weight for which
move we prefer to take.
"""
function CESPF(b::Board, movelist::MoveList)
	unnorm_policy_weights = map(x -> see(b, x), movelist)
	# Center raw centipawn values to 1 to then normalize
	centered_policy_weights = (1 + abs(min(unnorm_policy_weights...))) .+
					unnorm_policy_weights
	return centered_policy_weights / sum(centered_policy_weights)
end

"""
	CESPF_greedy(b::Board, movelist::MoveList)
Utilizes `Chess.jl`'s `see()` function to simulate (C)apture / (E)scape (S)tronger (P)iece
(F)irst heuristic in simulation/rollout policy. We use Chess weights set in `see` function to get weight for which
move we prefer to take. This is greedy, and will set only the maximal valued policies to a non-zero 
probability
"""
function CESPF_greedy(b::Board, movelist::MoveList)
	unnorm_policy_weights = map(x -> see(b, x), movelist)
	policy_weights = zeros(length(unnorm_policy_weights))
	max_idxs = findall(unnorm_policy_weights .== maximum(unnorm_policy_weights))
	for max_idx in max_idxs
		policy_weights[max_idx] = 1.0 / length(max_idxs)
	end
	return policy_weights
end


