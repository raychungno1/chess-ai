from .const import Const
from chess import Board

def get_board_square(mx, my):
    row = 7 - ((my - 50) // Const.SQUARE_SIZE)
    col = (mx - 50) // Const.SQUARE_SIZE
    if row >= 8 or row < 0 or col >= 8 or col < 0:
        return None
    return Board.get_index(row, col)
