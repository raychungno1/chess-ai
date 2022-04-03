from .move import Move
from .dict import mailbox, mailbox_64, offsets


class Piece:
    EMPTY = 0
    KING = 1
    PAWN = 2
    KNIGHT = 3
    BISHOP = 4
    ROOK = 5
    QUEEN = 6

    WHITE = 8
    BLACK = 16

    char_to_piece = {
        "": EMPTY,
        "k": KING,
        "p": PAWN,
        "n": KNIGHT,
        "b": BISHOP,
        "r": ROOK,
        "q": QUEEN,
    }

    piece_to_char = {
        EMPTY: " ",
        KING: "k",
        PAWN: "p",
        KNIGHT: "n",
        BISHOP: "b",
        ROOK: "r",
        QUEEN: "q",
    }

    def __init__(self, char=""):
        self.color = Piece.BLACK if char.islower() else Piece.WHITE
        if char == "":
            self.color = 0
        self.type = Piece.char_to_piece[char.lower()]
        self.num_moves = 0

    def is_sliding(self):
        return self.type >= 4

    def tostring(self):
        str = Piece.piece_to_char[self.type]
        if self.color == Piece.WHITE:
            str = str.upper()
        return str

    def correct_turn(self, white_to_move):
        return white_to_move and self.color == Piece.WHITE or not(white_to_move) and self.color == Piece.BLACK

    def gen_attack(self, board, i):
        from .board import Board
        if self.type == Piece.PAWN:
            target = -1
            if self.color == Piece.WHITE:
                if Board.get_col(i) != 0:
                    target = i + 7
                    board.attack_map[target] = 1
                if Board.get_col(i) != 7:
                    target = i + 9
                    board.attack_map[target] = 1
            else:
                if Board.get_col(i) != 0:
                    target = i - 9
                    board.attack_map[target] = 1
                if Board.get_col(i) != 7:
                    target = i - 7
                    board.attack_map[target] = 1

            if target != -1 and board.get_piece(target).type == Piece.KING and board.get_piece(target).correct_turn(board.white_to_move):
                board.checks.append([-128])

        else:
            for offset in offsets[self.type]:
                if offset == 0:
                    break

                n = i
                checking_pins = False
                possible_check = [i]
                possible_pin = [i]
                while 1:
                    n = mailbox[mailbox_64[n] + offset]
                    if n == -1:
                        break

                    if checking_pins == False:
                        board.attack_map[n] = 1

                    if board.get_piece(n).type != Piece.EMPTY:
                        if checking_pins == False:
                            checking_pins = True
                            if board.get_piece(n).type == Piece.KING and board.get_piece(n).correct_turn(board.white_to_move):
                                board.checks.append(possible_check)
                                break
                        else:
                            if board.get_piece(n).type == Piece.KING and board.get_piece(n).correct_turn(board.white_to_move):
                                board.pins.append(possible_pin)
                            break

                    possible_check.append(n)
                    possible_pin.append(n)

                    if not self.is_sliding():
                        break

    def gen_moves(self, board, i):
        moves = []

        from .board import Board
        if self.type == Piece.PAWN:
            if self.color == Piece.WHITE:
                if Board.get_col(i) != 0 and (board.get_piece(i + 7).color == Piece.BLACK or board.en_passant == i + 7) and (len(board.checks) == 0 or all([(i + 7) in check for check in board.checks])) and Piece.valid_pin_move(i, i + 7, board):
                    moves.append(Move(board, i, i + 7))
                if Board.get_col(i) != 7 and (board.get_piece(i + 9).color == Piece.BLACK or board.en_passant == i + 9) and (len(board.checks) == 0 or all([(i + 9) in check for check in board.checks])) and Piece.valid_pin_move(i, i + 9, board):
                    moves.append(Move(board, i, i + 9))
                if board.get_piece(i + 8).type == Piece.EMPTY and Piece.valid_pin_move(i, i + 8, board):
                    if len(board.checks) == 0 or all([(i + 8) in check for check in board.checks]):
                        moves.append(Move(board, i, i + 8))
                    if Board.get_row(i) == 1 and board.get_piece(i + 16).type == Piece.EMPTY and (len(board.checks) == 0 or all([(i + 16) in check for check in board.checks])):
                        moves.append(Move(board, i, i + 16))
            else:
                if Board.get_col(i) != 0 and (board.get_piece(i - 9).color == Piece.WHITE or board.en_passant == i - 9) and (len(board.checks) == 0 or all([(i - 9) in check for check in board.checks])) and Piece.valid_pin_move(i, i - 9, board):
                    moves.append(Move(board, i, i - 9))
                if Board.get_col(i) != 7 and (board.get_piece(i - 7).color == Piece.WHITE or board.en_passant == i - 7) and (len(board.checks) == 0 or all([(i - 7) in check for check in board.checks])) and Piece.valid_pin_move(i, i - 7, board):
                    moves.append(Move(board, i, i - 7))
                if board.get_piece(i - 8).type == Piece.EMPTY and Piece.valid_pin_move(i, i - 8, board):
                    if len(board.checks) == 0 or all([(i - 8) in check for check in board.checks]):
                        moves.append(Move(board, i, i - 8))
                    if Board.get_row(i) == 6 and board.get_piece(i - 16).type == Piece.EMPTY and (len(board.checks) == 0 or all([(i - 16) in check for check in board.checks])):
                        moves.append(Move(board, i, i - 16))

        else:
            for offset in offsets[self.type]:
                if offset == 0:
                    break

                n = i
                while 1:
                    n = mailbox[mailbox_64[n] + offset]
                    if n == -1:
                        break

                    if self.type == Piece.KING and ((board.attack_map[n] == 1 or n - i in [i - check[-1] for check in board.checks]) or (not board.get_piece(n).correct_turn(board.white_to_move))):
                        if (board.attack_map[n] == 1 or n - i in [i - check[-1] for check in board.checks]):
                            break
                        if (not board.get_piece(n).correct_turn(board.white_to_move)):
                            moves.append(Move(board, i, n))
                            break

                    if Piece.valid_pin_move(i, n, board) and (len(board.checks) == 0 or all([(n) in check for check in board.checks])):
                        if board.get_piece(n).type != Piece.EMPTY:
                            if not board.get_piece(n).correct_turn(board.white_to_move):
                                moves.append(Move(board, i, n))
                            break
                        moves.append(Move(board, i, n))
                    elif board.get_piece(n).correct_turn(board.white_to_move):
                        break

                    if not self.is_sliding():
                        break

            if self.type == Piece.KING and len(board.checks) == 0:
                if (self.color == Piece.WHITE):
                    if board.white_long_castle and board.get_piece(1).type == Piece.EMPTY and board.get_piece(2).type == Piece.EMPTY and board.get_piece(3).type == Piece.EMPTY and board.attack_map[1] == 0 and board.attack_map[2] == 0 and board.attack_map[3] == 0:
                        moves.append(Move(board, i, i - 2))
                    if board.white_short_castle and board.get_piece(5).type == Piece.EMPTY and board.get_piece(6).type == Piece.EMPTY and board.attack_map[5] == 0 and board.attack_map[6] == 0:
                        moves.append(Move(board, i, i + 2))

                else:
                    if board.black_long_castle and board.get_piece(57).type == Piece.EMPTY and board.get_piece(58).type == Piece.EMPTY and board.get_piece(59).type == Piece.EMPTY and board.attack_map[57] == 0 and board.attack_map[58] == 0 and board.attack_map[59] == 0:
                        moves.append(Move(board, i, i - 2))
                    if board.black_short_castle and board.get_piece(61).type == Piece.EMPTY and board.get_piece(62).type == Piece.EMPTY and board.attack_map[61] == 0 and board.attack_map[62] == 0:
                        moves.append(Move(board, i, i + 2))

        return moves

    def valid_pin_move(start, target, board):
        valid_pin = None
        for pin in board.pins:
            if start in pin:
                valid_pin = pin
                break

        if valid_pin == None:
            return True
        else:
            return target in valid_pin
