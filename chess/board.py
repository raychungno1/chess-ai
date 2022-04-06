from .fen import FEN
from .dict import char_to_col, col_to_char
from .piece import Piece


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

        if string == "":
            self.move_num = 0
        else:
            self.move_num = int(string)

        self.move_list = []

        self.attack_map = [0] * 64
        self.checks = []
        self.pins = []
        self.current_moves = self.generate_moves()

    def print(self):
        row, col = 7, 0

        print("-" * 33)
        for row in range(7, -1, -1):
            print("|", end="")
            for col in range(8):
                print(f" {self.board[row * 8 + col].tostring()} |", end="")

            print("\n" + "-" * 33)

    def print_attack_map(self):
        row, col = 7, 0

        for row in range(7, -1, -1):
            for col in range(8):
                print(f"{self.attack_map[row * 8 + col]} ", end="")
            print()


    def get_piece(self, index):
        return self.board[index]

    def generate_attack_map(self):
        self.attack_map = [0] * 64
        self.checks = []
        self.pins = []

        for i, piece in enumerate(self.board):
            if not piece.correct_turn(self.white_to_move) and piece.type != Piece.EMPTY:
                piece.gen_attack(self, i)

    def generate_moves(self, index=None):
        moves = []

        self.generate_attack_map()

        if index == None:
            for i, piece in enumerate(self.board):
                if piece.correct_turn(self.white_to_move):
                    moves += piece.gen_moves(self, i)

        elif self.board[index].correct_turn(self.white_to_move):
            moves += self.board[index].gen_moves(self, index)

        return moves

    def get_moves(self, index=None):
        if index is None:
            return self.current_moves

        moves = []
        for move in self.current_moves:
            if move.start_square == index:
                moves.append(move)
        return moves

    def attack_through_castle(self, move, opp_move):
        return (
            (move.is_king_side_castle() and self.white_to_move and opp_move.target_square == 5) or
            (move.is_king_side_castle() and not self.white_to_move and opp_move.target_square == 61) or
            (move.is_queen_side_castle() and self.white_to_move and opp_move.target_square == 3) or
            (move.is_queen_side_castle()
             and not self.white_to_move and opp_move.target_square == 59)
        )

    def move(self, possible_move):
        if possible_move == None or possible_move.start_square == possible_move.target_square:
            return

        for move in self.current_moves:
            if move.equals(possible_move):
                self.make_valid_move(move)
                return True
        return False

    def make_valid_move(self, move):
        self.move_list.append(move)
        self.board[move.target_square] = self.board[move.start_square]
        self.board[move.start_square] = Piece()
        move.ep_square = self.en_passant

        # Resolving en passant
        self.move_en_passant(move)

        # Resolving castle moves and updates castling rights
        self.move_castle(move)

        # Resolving rouble pawn pushes (updating en passant rule)
        self.move_pawn_push(move)

        # Resolving promotions
        self.move_promotion(move)

        self.white_to_move = not self.white_to_move

        self.current_moves = self.generate_moves()

    def move_en_passant(self, move):
        if move.is_en_passant():
            if self.white_to_move:
                move.ep_piece = self.board[move.target_square - 8]
                self.board[move.target_square - 8] = Piece()
            else:
                move.ep_piece = self.board[move.target_square + 8]
                self.board[move.target_square + 8] = Piece()

    def move_castle(self, move):
        if self.white_to_move:
            if move.piece.type == Piece.KING:
                move.piece.num_moves += 1
                self.white_long_castle = False
                self.white_short_castle = False
            if move.piece.type == Piece.ROOK:
                move.piece.num_moves += 1
                if move.start_square == 0:
                    self.white_long_castle = False
                if move.start_square == 7:
                    self.white_short_castle = False
        else:
            if move.piece.type == Piece.KING:
                move.piece.num_moves += 1
                self.black_long_castle = False
                self.black_short_castle = False
            if move.piece.type == Piece.ROOK:
                move.piece.num_moves += 1
                if move.start_square == 56:
                    self.black_long_castle = False
                if move.start_square == 63:
                    self.black_short_castle = False

        if move.is_king_side_castle():
            self.board[move.target_square -
                       1] = self.board[move.target_square + 1]
            self.board[move.target_square + 1] = Piece()

        if move.is_queen_side_castle():
            self.board[move.target_square +
                       1] = self.board[move.target_square - 2]
            self.board[move.target_square - 2] = Piece()

    def move_pawn_push(self, move):
        if move.is_double_pawn_push():
            if self.white_to_move:
                self.en_passant = move.start_square + 8
            else:
                self.en_passant = move.start_square - 8
        else:
            self.en_passant = None

    def move_promotion(self, move):
        if move.is_promotion() == True:
            from .piece import Piece
            if self.white_to_move == True:
                self.board[move.target_square] = Piece("Q")
            else:
                self.board[move.target_square] = Piece("q")

    def undo(self):
        if len(self.move_list) > 0:
            move = self.move_list.pop()
            self.board[move.start_square] = self.board[move.target_square]
            self.board[move.target_square] = move.captured_piece
            self.white_to_move = not self.white_to_move

            # Resolving en passant
            self.undo_en_passant(move)

            # Resolving castle moves and updates castling rights
            self.undo_castle(move)

            # Resolving rouble pawn pushes (updating en passant rule)
            self.undo_pawn_push(move)

            # Resolving promotions
            self.undo_promotion(move)

            self.en_passant = move.ep_square
            self.current_moves = self.generate_moves()

    def undo_en_passant(self, move):
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
            self.board[move.target_square - 1] = Piece()

        if move.is_queen_side_castle():
            self.board[move.target_square -
                       2] = self.board[move.target_square + 1]
            self.board[move.target_square + 1] = Piece()

        if self.white_to_move:
            if move.piece.type == Piece.KING:
                move.piece.num_moves -= 1
                if move.piece.num_moves == 0 and move.start_square == 4:
                    if self.board[0].type == Piece.ROOK and self.board[0].num_moves == 0:
                        self.white_long_castle = True
                    if self.board[7].type == Piece.ROOK and self.board[7].num_moves == 0:
                        self.white_short_castle = True
            if move.piece.type == Piece.ROOK:
                move.piece.num_moves -= 1
                if move.piece.num_moves == 0 and self.board[4].type == Piece.KING and self.board[4].num_moves == 0:
                    if move.start_square == 0:
                        self.white_long_castle = True
                    if move.start_square == 7:
                        self.white_short_castle = True

        else:
            if move.piece.type == Piece.KING:
                move.piece.num_moves -= 1
                if move.piece.num_moves == 0 and move.start_square == 60:
                    if self.board[56].type == Piece.ROOK and self.board[56].num_moves == 0:
                        self.black_long_castle = True
                    if self.board[63].type == Piece.ROOK and self.board[63].num_moves == 0:
                        self.black_short_castle = True
            if move.piece.type == Piece.ROOK:
                move.piece.num_moves -= 1
                if move.piece.num_moves == 0 and self.board[60].type == Piece.KING and self.board[60].num_moves == 0:
                    if move.start_square == 56:
                        self.black_long_castle = True
                    if move.start_square == 63:
                        self.black_short_castle = True

    def undo_pawn_push(self, move):
        if move.is_double_pawn_push():
            self.en_passant = None

    def undo_promotion(self, move):
        if move.is_promotion() == True:
            from .piece import Piece
            if self.white_to_move == True:
                self.board[move.start_square] = Piece("P")
            else:
                self.board[move.start_square] = Piece("p")

    def get_index(row_or_str, col=0):
        if type(row_or_str) == str:
            col = char_to_col[row_or_str[0]]
            row = int(row_or_str[1]) - 1
            return row * 8 + col
        else:
            return row_or_str * 8 + col

    def get_row(index):
        return index // 8

    def get_col(index):
        return index % 8

    def get_row_col(index):
        return index // 8, index % 8

    def get_notation(index):
        return col_to_char[index % 8] + str(index // 8 + 1)

    def check_winner(self):
        return len(self.current_moves) == 0
