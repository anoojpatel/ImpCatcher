# ImpCatcher
This is a Chess Engine for [Dark Chess](https://en.wikipedia.org/wiki/Dark_chess) or also known
as [Fog of War Chess](https://www.chess.com/terms/fog-of-war-chess). This means that there is imperfect
information between players. The variant of Chess is immensely interesting w.r.t. Chess and Reinforcement learning! It combines the tactical and strategic complexity of Chess with the mind reading games of Texas Hold'em Poker. 

For example, knowing how the [Opening](https://en.wikipedia.org/wiki/Chess_opening#Classification%20of%20chess%20openings) plays out, or what variation is being played makes a huge difference in response for Black when there is perfect information. Not knowing if there is a gambit offer, or a sneaky [Scholar's mate](https://en.wikipedia.org/wiki/Scholar%27s_mate) attempt being made. Understanding the Belief states of the game state, but also the Belief probabilities of the player is something to take into account.

## Purpose
The idea here is to investigate the possible algorithms and tricks we can employ to build a generally smart Chess Engine. Utilizing first Monte Carlo Tree Search in Julia with good heuristics and a good nondeterministic MCTS model to account for Public Belief states. 
Combine this with self-play to train policy and value networks similar to AlphaZero/MuZero (DeepMind), and combine with the limited depth-subgame solving CFR from ReBeL (Facebook Research).

## Known Challenges
While there are great resources on solving subgames by decomposing the nash-equilibrium search problem, the public state (what information both players know about each other's pieces) is very small, especially during the opening, which intuitively feels like the most important part of the game when [developing](https://en.wikibooks.org/wiki/Chess_Strategy/Development#Development) your pieces. For example, if players start with a simple 1.e4, e5 opening, we will have no public state. Unlike the Poker variants, which have state shared at progression of the game, we don't. 

Another big problem is assymetric information. For example, if an opponent brings out their queen or sets up their bishops/rooks for "vision" we may not be aware of it and possible move our king into danger.

This leads into the second problem, which is the size of possible actions, and reciprocally, the possible distribution of moves the opponent can make. Assume do not "scout" or gain information about enemy positions from 3 moves that we make, there are possible ~(20*24*35) variations that may be played. That value is cubed when trying to account for which move we make minimizes our regret. Exhaustively searching here will not be useful (However further research on investigating how "balanced" the game is based on which opening has a dominant strategy). 

## Goal
Build a decent Chess engine such that I have someone to play against! (and hopefully others who want
this variant to grow!)

## Strategies (Current and New)
- \[x] Capture/Escape Best piece Heuristic simulation/rollout at leaf nodes
- \[ ] Belief States using state counts for all possible configurations and tracking MCTS for all belief
states as a subtree.
- \[ ] Efficient memory use along with Zobrist keys to build and prune our probability states
- \[ ] CFR decomposition over current policy in subgame solving
- \[ ] Depth limited Search (Apparently keeps tree growth consistent but has theoretical garantees for
nash equilibrium
- \[ ] Visualization tool
- \[ ] Hand crafted features vs Pure self-play Policy network similar to ReBeL/MuZero
- \[ ] Efficient Data store for generated games and labels for training value/policy network

### Name Origin
Based on the Runescape beginner quest for collecting beads from imps. It was divergent yet a tedious process. Something I find building this engine will be. Dealing with exploitability will be a very interesting challenge!

### References
 1. [Tobias Graf, Marco Platzner,
Adaptive playouts for online learning of policies during Monte Carlo Tree Search](http://www.sciencedirect.com/science/article/pii/S0304397516302742)
Theoretical Computer Science,
Volume 644,
2016,
Pages 53-62

2. Chang, R.-S., Jain, L. C., & Peng, S.-L. (Eds.). (2013). Advances in Intelligent Systems and Applications - Volume 1. Smart Innovation, Systems and Technologies. doi:10.1007/978-3-642-35452-6

3. [Monte Carlo Tree Search](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search)

4. [Safe and Nested Subgame Solving for Imperfect-Information Games](https://arxiv.org/abs/1705.02955)

5. [Reinforcement Learning to Play an Optimal
Nash Equilibrium in Team Markov Games](https://papers.nips.cc/paper/2002/file/f8e59f4b2fe7c5705bf878bbd494ccdf-Paper.pdf)

6. [Combining Deep Reinforcement Learning and Search for Imperfect-Information Games](https://arxiv.org/pdf/2007.13544.pdf)

