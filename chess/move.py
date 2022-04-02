class Move:
    def __init__(self, board, start, target, promotion_piece = None):
        self.board = board
        self.piece = board.get_piece(start)
        self.start_square = start
        self.target_square = target
        self.captured_piece = board.get_piece(self.target_square)
        self.ep_square = None
        self.ep_piece = None
        self.promotion_piece = None

    def tostring(self):
        str = ""

        if self.is_king_side_castle():
            return "O-O"

        if self.is_queen_side_castle():
            return "O-O-O"

        from .piece import Pawn
        if type(self.piece) != Pawn:
            str = self.piece.tostring().upper()

        from .board import Board
        if not self.captured_piece.empty() or self.is_en_passant():
            if type(self.piece) == Pawn:
                str = Board.get_notation(self.start_square)[0]
            str += "x"

        return str + Board.get_notation(self.target_square)

    def equals(self, move):
        return self.start_square == move.start_square and self.target_square == move.target_square

    def is_double_pawn_push(self):
        from .board import Board
        row1, _ = Board.get_row_col(self.start_square)
        row2, _ = Board.get_row_col(self.target_square)

        from .piece import Pawn
        return type(self.piece) == Pawn and abs(row1 - row2) == 2

    def is_en_passant(self):
        from .piece import Pawn
        return type(self.piece) == Pawn and self.target_square == self.board.en_passant

    def is_castle(self):
        from .board import Board
        _, col1 = Board.get_row_col(self.start_square)
        _, col2 = Board.get_row_col(self.target_square)

        from .piece import King
        return type(self.piece) == King and abs(col1 - col2) == 2

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

    def is_promotion(self):
        from .piece import Pawn
        return type(self.piece) == Pawn and self.target_square >= 56
