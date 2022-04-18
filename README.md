## Features/Optimizations
* Pygame UI
* Bitboard board representation
* Precalculated attack tables for all pieces
* Positional & Material based evaluation function
* Search Optimizations
  * Negamax Alpha Beta Pruning
    * Principle Variation Search enhancement
  * Quiescence Search to avoid the Horizon Effect
  * Iterative Deepening
* Move Ordering Optimizations
  * Principle Variation (used in iterative deepening)
  * Most Valuable Victim - Least Valuable Attacker table (capture moves)
  * Killer Moves table (quiet moves)
  * History Moves table (quiet moves)

## Run the program:
1. Go to root directory
2. Initialize virtualenv with `python -m virtualenv env`
3. Activate virtualenv with `./env/Scripts/activate` on Windows or `source env/Scripts/activate` on Mac
4. Install dependencies with `pip install -r requirements.txt`