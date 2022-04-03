import random


class AI:
    def choose_move(board):
        moves = board.generate_moves()
        if len(moves) > 0:
            return random.choice(moves)
