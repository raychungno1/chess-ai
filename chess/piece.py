from enum import Enum


class Type(Enum):
    KING = 1
    PAWN = 2
    KNIGHT = 3
    BISHOP = 4
    ROOK = 5
    QUEEN = 6


class Color(Enum):
    WHITE = 0
    BLACK = 1


char_to_type = {
    "k": Type.KING,
    "p": Type.PAWN,
    "n": Type.KNIGHT,
    "b": Type.BISHOP,
    "r": Type.ROOK,
    "q": Type.QUEEN
}

char_to_col = {
    "a": 0,
    "b": 1,
    "c": 2,
    "d": 3,
    "e": 4,
    "f": 5,
    "g": 6,
    "h": 7
}

class Piece:

    def __init__(self, type, color):
        self.type = type
        self.color = color

    def tostring(self):
        if self.type == Type.KING:
            result = "k"

        elif self.type == Type.PAWN:
            result = "p"

        elif self.type == Type.KNIGHT:
            result = "n"

        elif self.type == Type.BISHOP:
            result = "b"

        elif self.type == Type.ROOK:
            result = "r"

        elif self.type == Type.QUEEN:
            result = "q"

        if self.color == Color.WHITE:
            result = result.capitalize()

        return result
