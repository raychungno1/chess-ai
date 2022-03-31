from .fen import FEN


class Board:
    def __init__(self, string="rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"):
        (self.board,
         self.white_to_move,
         self.white_long_castle,
         self.white_short_castle,
         self.black_long_castle,
         self.black_short_castle,
         self.en_passant,
         self.half_moves,
         self.move_num) = FEN.load(string)

    def print(self):
        row = 7
        col = 0

        print("-" * 33)
        for row in range(7, -1, -1):
            print("|", end="")
            for col in range(8):
                if (self.board[row * 8 + col] == None):
                    print("   |", end="")
                else:
                    print(f" {self.board[row * 8 + col].tostring()} |", end="")

            print("\n" + "-" * 33)
