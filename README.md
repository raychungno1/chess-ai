# Chess AI

This chess engine plays at a speculated rating of 1700 at a depth of 7. View a demo of the program [here](https://youtu.be/oOvJXMsbHoo).

## Features/Optimizations
* Pygame UI
* Bitboard board representation
* Precalculated attack tables for all pieces
* Positional & Material based evaluation function
* Search Optimizations
  * Negamax Alpha Beta Pruning
    * Principle Variation Search
    * Late Move Reduction
    * Null Move Reduction
  * Quiescence Search to avoid the Horizon Effect
  * Iterative Deepening
    * Adjusting aspiration windows
* Move Ordering Optimizations
  * Principle Variation (used in iterative deepening)
  * Most Valuable Victim - Least Valuable Attacker table (capture moves)
  * Killer Moves table (quiet moves)
  * History Moves table (quiet moves)

## Run the program:
A GCC compiler is required to compile and run the program using Cython. 
1. Go to root directory
2. Initialize virtualenv with `python -m virtualenv env`
3. Activate virtualenv with `./env/Scripts/activate` on Windows or `source env/Scripts/activate` on Mac
4. Install dependencies with `pip install -r requirements.txt`
5. Move into the chess folder with `cd chess`
6. Compile the cython files with `python setup.py build_ext --inplace`
7. Go to root directory
8. Run the game with `python game.py`