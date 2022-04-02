from chess.piece import Empty
from .fen import FEN
from .dict import char_to_col, col_to_char
from .piece import King, Rook


class Board:
    def __init__(self, string="rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"):
        self.board, string = FEN.load_pieces(string)

        self.white_to_move, string = FEN.load_turn(string)

        (self.white_long_castle,
         self.white_short_castle,
         self.black_long_castle,
         self.black_short_castle, string) = FEN.load_castle(string)

        self.en_passant, string = FEN.load_en_passant(string)

        self.half_moves, string = FEN.load_half_moves(string)

        self.move_num = int(string)

        self.move_list = []

    def print(self):
        row, col = 7, 0

        print("-" * 33)
        for row in range(7, -1, -1):
            print("|", end="")
            for col in range(8):
                print(f" {self.board[row * 8 + col].tostring()} |", end="")

            print("\n" + "-" * 33)

    def get_piece(self, index):
        return self.board[index]

    def generate_moves(self, index=None):
        moves = []

        if index == None:
            for i, piece in enumerate(self.board):
                if piece.correct_turn(self.white_to_move):
                    moves += piece.gen_moves(self, i)
        elif self.board[index].correct_turn(self.white_to_move):
            moves += self.board[index].gen_moves(self, index)

        return moves

    def move(self, possible_move):
        for move in self.generate_moves():
            if move.equals(possible_move):

                print(move.tostring())  # PRINT MOVE

                self.move_list.append(move)
                self.board[move.target_square] = self.board[move.start_square]
                self.board[move.start_square] = Empty()
                move.ep_square = self.en_passant

                # Resolving en passant
                self.move_en_passant(move)

                # Resolving castle moves and updates castling rights
                self.move_castle(move)

                # Resolving rouble pawn pushes (updating en passant rule)
                self.move_pawn_push(move)

                self.white_to_move = not self.white_to_move

    def move_en_passant(self, move):
        if self.en_passant != None and move.is_en_passant():
            if self.white_to_move:
                move.ep_piece = self.board[move.target_square - 8]
                self.board[move.target_square - 8] = Empty()
            else:
                move.ep_piece = self.board[move.target_square + 8]
                self.board[move.target_square + 8] = Empty()

    def move_castle(self, move):
        if self.white_to_move:
            if type(move.piece) == King:
                move.piece.num_moves += 1
                self.white_long_castle = False
                self.white_short_castle = False
            if type(move.piece) == Rook:
                move.piece.num_moves += 1
                if move.start_square == 0:
                    self.white_long_castle = False
                if move.start_square == 7:
                    self.white_short_castle = False
        else:
            if type(move.piece) == King:
                move.piece.num_moves += 1
                self.black_long_castle = False
                self.black_short_castle = False
            if type(move.piece) == Rook:
                move.piece.num_moves += 1
                if move.start_square == 56:
                    self.black_long_castle = False
                if move.start_square == 63:
                    self.black_short_castle = False

        if move.is_king_side_castle():
            self.board[move.target_square -
                       1] = self.board[move.target_square + 1]
            self.board[move.target_square + 1] = Empty()

        if move.is_queen_side_castle():
            self.board[move.target_square +
                       1] = self.board[move.target_square - 2]
            self.board[move.target_square - 2] = Empty()

    def move_pawn_push(self, move):
        if move.is_double_pawn_push():
            if self.white_to_move:
                self.en_passant = move.start_square + 8
            else:
                self.en_passant = move.start_square - 8
        else:
            self.en_passant = None

    def undo(self):
        if len(self.move_list) > 0:
            move = self.move_list.pop()
            self.board[move.start_square] = self.board[move.target_square]
            self.board[move.target_square] = move.captured_piece
            self.white_to_move = not self.white_to_move
            self.en_passant = move.ep_square

            # Resolving en passant
            self.undo_en_passant(move)

            # Resolving castle moves and updates castling rights
            self.undo_castle(move)

            # Resolving rouble pawn pushes (updating en passant rule)
            self.undo_pawn_push(move)

    def undo_en_passant(self, move):
        from .piece import Pawn
        if move.ep_piece != None:
            self.en_passant = move.target_square
            if self.white_to_move:
                self.board[move.target_square - 8] = move.ep_piece
            else:
                self.board[move.target_square + 8] = move.ep_piece

    def undo_castle(self, move):
        if move.is_king_side_castle():
            self.board[move.target_square +
                       1] = self.board[move.target_square - 1]
            self.board[move.target_square - 1] = Empty()

        if move.is_queen_side_castle():
            self.board[move.target_square -
                       2] = self.board[move.target_square + 1]
            self.board[move.target_square + 1] = Empty()

        if self.white_to_move:
            if type(move.piece) == King:
                move.piece.num_moves -= 1
                print(move.start_square)
                if move.piece.num_moves == 0 and move.start_square == 4:
                    if type(self.board[0]) == Rook and self.board[0].num_moves == 0:
                        self.white_long_castle = True
                    if type(self.board[7]) == Rook and self.board[7].num_moves == 0:
                        self.white_short_castle = True
            if type(move.piece) == Rook:
                move.piece.num_moves -= 1
                if move.piece.num_moves == 0 and type(self.board[4]) == King and self.board[4].num_moves == 0:
                    if move.start_square == 0:
                        self.white_long_castle = True
                    if move.start_square == 7:
                        self.white_short_castle = True

        else:
            if type(move.piece) == King:
                move.piece.num_moves -= 1
                if move.piece.num_moves == 0 and move.start_square == 60:
                    if type(self.board[56]) == Rook and self.board[56].num_moves == 0:
                        self.black_long_castle = True
                    if type(self.board[63]) == Rook and self.board[63].num_moves == 0:
                        self.black_short_castle = True
            if type(move.piece) == Rook:
                move.piece.num_moves -= 1
                if move.piece.num_moves == 0 and type(self.board[60]) == King and self.board[60].num_moves == 0:
                    if move.start_square == 56:
                        self.black_long_castle = True
                    if move.start_square == 63:
                        self.black_short_castle = True

    def undo_pawn_push(self, move):
        if move.is_double_pawn_push():
            self.en_passant = None

    def get_index(row_or_str, col=0):
        if type(row_or_str) == str:
            col = char_to_col[row_or_str[0]]
            row = int(row_or_str[1]) - 1
            return row * 8 + col
        else:
            return row_or_str * 8 + col

    def get_row_col(index):
        return index // 8, index % 8

    def get_notation(index):
        return col_to_char[index % 8] + str(index // 8 + 1)
