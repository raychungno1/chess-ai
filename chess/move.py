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

        from .piece import Piece
        if self.piece.type != Piece.PAWN:
            str = self.piece.tostring().upper()

        from .board import Board
        if self.captured_piece.type != Piece.EMPTY or self.is_en_passant():
            if self.piece.type == Piece.PAWN:
                str = Board.get_notation(self.start_square)[0]
            str += "x"

        return str + Board.get_notation(self.target_square)

    def equals(self, move):
        return self.start_square == move.start_square and self.target_square == move.target_square

    def is_double_pawn_push(self):
        from .board import Board
        row1, _ = Board.get_row_col(self.start_square)
        row2, _ = Board.get_row_col(self.target_square)

        from .piece import Piece
        return self.piece.type == Piece.PAWN and abs(row1 - row2) == 2

    def is_en_passant(self):
        from .piece import Piece
        return self.piece.type == Piece.PAWN and self.target_square == self.board.en_passant

    def is_castle(self):
        from .board import Board
        _, col1 = Board.get_row_col(self.start_square)
        _, col2 = Board.get_row_col(self.target_square)

        from .piece import Piece
        return self.piece.type == Piece.KING and abs(col1 - col2) == 2

    def is_king_side_castle(self):
        from .board import Board
        _, col1 = Board.get_row_col(self.start_square)
        _, col2 = Board.get_row_col(self.target_square)

        from .piece import Piece
        return self.piece.type == Piece.KING and col2 - col1 == 2

    def is_queen_side_castle(self):
        from .board import Board
        _, col1 = Board.get_row_col(self.start_square)
        _, col2 = Board.get_row_col(self.target_square)

        from .piece import Piece
        return self.piece.type == Piece.KING and col1 - col2 == 2

    def is_promotion(self):
        from .piece import Piece
        if self.piece.color == Piece.WHITE:
            return self.piece.type == Piece.PAWN and self.target_square >= 56
        return self.piece.type == Piece.PAWN and self.target_square < 8
