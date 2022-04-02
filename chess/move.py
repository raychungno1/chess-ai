
class Move:
    def __init__(self, piece, start, target):
        self.piece = piece
        self.start_square = start
        self.target_square = target

    def tostring(self):
        str = self.piece.tostring()
        from .board import Board
        if str.lower() == "p":
            return Board.get_notation(self.target_square)
        return self.piece.tostring() + Board.get_notation(self.target_square)

    def equals(self, move):
        return self.start_square == move.start_square and self.target_square == move.target_square

    def is_double_pawn_push(self):
        from .board import Board
        row1, _ = Board.get_row_col(self.start_square)
        row2, _ = Board.get_row_col(self.target_square)

        from .piece import Pawn
        return type(self.piece) == Pawn and abs(row1 - row2) == 2

    def is_en_passant(self, ep_index):
        from .piece import Pawn
        return type(self.piece) == Pawn and self.target_square == ep_index

    def is_king_side_castle(self):
        from .board import Board
        _, col1 = Board.get_row_col(self.start_square)
        _, col2 = Board.get_row_col(self.target_square)

        from .piece import King
        return type(self.piece) == King and col2 - col1 == 2
        
    def is_queen_side_castle(self):
        from .board import Board
        _, col1 = Board.get_row_col(self.start_square)
        _, col2 = Board.get_row_col(self.target_square)

        from .piece import King
        return type(self.piece) == King and col1 - col2 == 2

