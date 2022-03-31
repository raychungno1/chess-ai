from .piece import Type, Color, Piece, char_to_type, char_to_col


class FEN:
    def load(string):
        board, string = FEN.__load_pieces(string)

        white_to_move, string = FEN.__load_turn(string)

        (white_long_castle,
         white_short_castle,
         black_long_castle,
         black_short_castle, string) = FEN.__load_castle(string)

        en_passant, string = FEN.__load_en_passant(string)

        half_moves, string = FEN.__load_half_moves(string)

        move_num = int(string)

        return (
            board,
            white_to_move,
            white_long_castle,
            white_short_castle,
            black_long_castle,
            black_short_castle,
            en_passant,
            half_moves,
            move_num
        )

    def __load_pieces(string):
        board = [None] * 64
        row = 7
        col = 0

        for i, char in enumerate(string):
            if char == "/":
                col = 0
                row -= 1

            elif char.isdigit():
                col += int(char)

            elif char.lower() in char_to_type:
                board[row * 8 + col] = Piece(
                    char_to_type[char.lower()],
                    Color.WHITE if char.isupper() else Color.BLACK
                )
                col += 1

            else:
                break

        return board, string[i + 1:]

    def __load_turn(string):
        return string[0] == "w", string[2:]

    def __load_castle(string):
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

    def __load_en_passant(string):
        if (string[0].isalpha()):
            col = char_to_col[string[0]]
            row = int(string[1]) - 1
            return row * 8 + col, string[3:]

        return None, string[2:]

    def __load_half_moves(string):
        for i, char in enumerate(string):
            if not char.isdigit():
                break

        return int(string[:i]), string[i + 1:]

    def __load_move_num(string):
        for i, char in enumerate(string):
            if not char.isdigit():
                break

        return int(string[:i]), string[i + 1:]
