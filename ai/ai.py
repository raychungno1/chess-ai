import random
from chess import Piece

class AI:
    def choose_move(board):
        moves = board.generate_moves()
        if len(moves) > 0:
            return random.choice(moves)


    def eval(board):
        white_pos = AI.count_material(board, Piece.WHITE)
        print(white_pos)
        black_pos = AI.count_material(board, Piece.BLACK)
        print(black_pos)
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
