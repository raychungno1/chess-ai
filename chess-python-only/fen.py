from .piece import Piece
from .dict import char_to_col

class FEN:
    def load_pieces(string):
        board = []
        for i in range(64):
            board.append(Piece())

        row, col = 7, 0

        for i, char in enumerate(string):
            if char == "/":
                col = 0
                row -= 1

            elif char.isdigit():
                col += int(char)

            elif char.isalpha():
                board[row * 8 + col] = Piece(char)
                col += 1

            else:
                break

        return board, string[i + 1:]

    def load_turn(string):
        return string[0] == "w", string[2:]

    def load_castle(string):
        white_long_castle = False
        white_short_castle = False
        black_long_castle = False
        black_short_castle = False

        for i, char in enumerate(string):
            if char == "K":
                white_short_castle = True

            elif char == "Q":
                white_long_castle = True

            elif char == "k":
                black_short_castle = True

            elif char == "q":
                black_long_castle = True

            elif char == " ":
                break

        return (
            white_long_castle,
            white_short_castle,
            black_long_castle,
            black_short_castle,
            string[i + 1:]
        )

    def load_en_passant(string):
        if (string[0].isalpha()):
            col = char_to_col[string[0]]
            row = int(string[1]) - 1
            return row * 8 + col, string[3:]

        return None, string[2:]

    def load_half_moves(string):
        i = 0
        for i, char in enumerate(string):
            if not char.isdigit():
                break

        if string[:i] == "":
            return 0, string
        return int(string[:i]), string[i + 1:]

    def load_move_num(string):
        for i, char in enumerate(string):
            if not char.isdigit():
                break

        return int(string[:i]), string[i + 1:]
