from .move import Move


class Color:
    WHITE = 0
    BLACK = 1


class Piece:

    def __init__(self, color=Color.WHITE):
        self.color = color

    def correct_turn(self, white_to_move):
        return white_to_move and self.color == Color.WHITE or not(white_to_move) and self.color == Color.BLACK

    def tostring(self, str):
        if (self.color == Color.WHITE):
            str = str.capitalize()
        return str

    def empty(self):
        return False

    DIR_OFFSET = [1, -1, -8, 8, 7, 9, -7, -9]

    def gen_moves(self, board, i, offsets=DIR_OFFSET, range=8):
        moves = []
        origin = i

        for dir in offsets:
            distance = 0

            from .board import Board
            old_row, old_col = Board.get_row_col(origin)

            i = origin + dir
            row, col = Board.get_row_col(i)

            while (distance < range and i >= 0 and i < 64 and
                   abs(old_row - row) <= 1 and
                   abs(old_col - col) <= 1):

                if board.get_piece(i).correct_turn(board.white_to_move):
                    break

                moves.append(Move(board, origin, i))

                if not(board.get_piece(i).empty()) and not(board.get_piece(i).correct_turn(board.white_to_move)):
                    break

                i += dir
                distance += 1
                old_row, old_col = row, col
                row, col = Board.get_row_col(i)

        return moves


class King(Piece):
    def __init__(self, color=Color.WHITE):
        super().__init__(color)
        self.num_moves = 0
        
    def tostring(self):
        return super().tostring("k")

    def gen_moves(self, board, i):
        moves = super().gen_moves(board, i, Piece.DIR_OFFSET, 1)

        if (self.color == Color.WHITE):
            if board.white_long_castle and board.get_piece(1).empty() and board.get_piece(2).empty()  and board.get_piece(3).empty():
                moves.append(Move(board, i, i - 2))
            if board.white_short_castle and board.get_piece(5).empty() and board.get_piece(6).empty():
                moves.append(Move(board, i, i + 2))

        else:
            if board.black_long_castle and board.get_piece(57).empty() and board.get_piece(58).empty()  and board.get_piece(59).empty():
                moves.append(Move(board, i, i - 2))
            if board.black_short_castle and board.get_piece(61).empty() and board.get_piece(62).empty():
                moves.append(Move(board, i, i + 2))

        return moves


class Queen(Piece):
    def tostring(self):
        return super().tostring("q")

    def gen_moves(self, board, i):
        return super().gen_moves(board, i)


class Rook(Piece):
    def __init__(self, color=Color.WHITE):
        super().__init__(color)
        self.num_moves = 0

    def tostring(self):
        return super().tostring("r")

    def gen_moves(self, board, i):
        return super().gen_moves(board, i, Piece.DIR_OFFSET[:4])


class Bishop(Piece):
    def tostring(self):
        return super().tostring("b")

    def gen_moves(self, board, i):
        return super().gen_moves(board, i, Piece.DIR_OFFSET[4:])


class Knight(Piece):
    def tostring(self):
        return super().tostring("n")

    def gen_moves(self, board, i):
        moves = []

        from .board import Board
        row, col = Board.get_row_col(i)

        if row + 1 < 8:
            if col + 2 < 8 and not(board.get_piece(Board.get_index(row + 1, col + 2)).correct_turn(board.white_to_move)):
                moves.append(Move(board, i, Board.get_index(row + 1, col + 2)))
            if col - 2 >= 0 and not(board.get_piece(Board.get_index(row + 1, col - 2)).correct_turn(board.white_to_move)):
                moves.append(Move(board, i, Board.get_index(row + 1, col - 2)))

            if row + 2 < 8:
                if col + 1 < 8 and not(board.get_piece(Board.get_index(row + 2, col + 1)).correct_turn(board.white_to_move)):
                    moves.append(
                        Move(board, i, Board.get_index(row + 2, col + 1)))
                if col - 1 >= 0 and not(board.get_piece(Board.get_index(row + 2, col - 1)).correct_turn(board.white_to_move)):
                    moves.append(
                        Move(board, i, Board.get_index(row + 2, col - 1)))

        if row - 1 >= 0:
            if col + 2 < 8 and not(board.get_piece(Board.get_index(row - 1, col + 2)).correct_turn(board.white_to_move)):
                moves.append(Move(board, i, Board.get_index(row - 1, col + 2)))
            if col - 2 >= 0 and not(board.get_piece(Board.get_index(row - 1, col - 2)).correct_turn(board.white_to_move)):
                moves.append(Move(board, i, Board.get_index(row - 1, col - 2)))

            if row - 2 >= 0:
                if col + 1 < 8 and not(board.get_piece(Board.get_index(row - 2, col + 1)).correct_turn(board.white_to_move)):
                    moves.append(
                        Move(board, i, Board.get_index(row - 2, col + 1)))
                if col - 1 >= 0 and not(board.get_piece(Board.get_index(row - 2, col - 1)).correct_turn(board.white_to_move)):
                    moves.append(
                        Move(board, i, Board.get_index(row - 2, col - 1)))

        return moves


class Pawn(Piece):
    def tostring(self):
        return super().tostring("p")

    def gen_moves(self, board, i):
        moves = []

        from .board import Board
        row, col = Board.get_row_col(i)

        move_offset = 1 if self.color == Color.WHITE else -1
        double_row = 1 if self.color == Color.WHITE else 6

        if row + move_offset < 8:
            if board.get_piece(Board.get_index(row + move_offset, col)).empty():
                moves.append(
                    Move(board, i, Board.get_index(row + move_offset, col)))

                if row == double_row and board.get_piece(Board.get_index(row + 2 * move_offset, col)).empty():
                    moves.append(
                        Move(board, i, Board.get_index(row + 2 * move_offset, col)))

            if col + 1 < 8:
                if (not(board.get_piece(Board.get_index(row + move_offset, col + 1)).empty()) and not(board.get_piece(Board.get_index(row + move_offset, col + 1)).correct_turn(board.white_to_move))) or (board.en_passant == Board.get_index(row + move_offset, col + 1)):
                    moves.append(
                        Move(board, i, Board.get_index(row + move_offset, col + 1)))

            if col - 1 >= 0:
                if (not(board.get_piece(Board.get_index(row + move_offset, col - 1)).empty()) and not(board.get_piece(Board.get_index(row + move_offset, col - 1)).correct_turn(board.white_to_move))) or (board.en_passant == Board.get_index(row + move_offset, col - 1)):
                    moves.append(
                        Move(board, i, Board.get_index(row + move_offset, col - 1)))

        return moves


class Empty(Piece):
    def tostring(self):
        return super().tostring(" ")

    def correct_turn(self, _):
        return False

    def gen_moves(self, board, i):
        return []

    def empty(self):
        return True
