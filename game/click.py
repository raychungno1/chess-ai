from .const import Const


def get_board_square(mx, my):
    row = (my - 50) // Const.SQUARE_SIZE
    col = (mx - 50) // Const.SQUARE_SIZE
    if row >= 8 or row < 0 or col >= 8 or col < 0:
        return None
    return row * 8 + col