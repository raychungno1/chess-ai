import random

from numpy import Infinity
from chess import Piece

class AI:
    def choose_move(board):
        moves = board.get_moves()
        if len(moves) == 0:
            return

        depth = 3
        value = -Infinity
        best_move = moves[0]
        for move in board.get_moves():
            board.make_valid_move(move)
            evaluation = AI.minimax(board, depth - 1, False)
            if evaluation > value:
                best_move = move
                value = evaluation
            board.undo()
        return best_move
        # moves = board.get_moves()
        # if len(moves) > 0:
        #     return random.choice(moves)

    def minimax(board, depth, is_maximizer):
        if board.check_winner():
            if is_maximizer == True:
                return -100
            else:
                return 100

        if depth == 0:
            return AI.eval(board)
        
        if is_maximizer == True:
            value = -Infinity
            for move in board.get_moves():
                board.make_valid_move(move)
                value = max(value, AI.minimax(board, depth - 1, False))
                board.undo()
            return value
        else:
            value = Infinity
            for move in board.get_moves():
                board.make_valid_move(move)
                value = min(value, AI.minimax(board, depth - 1, True))
                board.undo()
            return value

    def eval(board):
        white_pos = AI.count_material(board, Piece.WHITE)
        black_pos = AI.count_material(board, Piece.BLACK)
        eval = white_pos - black_pos

        if board.white_to_move:
            eval *= -1

        return eval

    piece_values = {
        Piece.EMPTY: 0,
        Piece.KING: 0,
        Piece.QUEEN: 9,
        Piece.ROOK: 5,
        Piece.BISHOP: 3,
        Piece.KNIGHT: 3,
        Piece.PAWN: 1
    }

    def count_material(board, color):
        eval = 0
        for piece in board.board:
            if piece.color == color:
                eval += AI.piece_values[piece.type]
        return eval
