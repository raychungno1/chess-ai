import pygame
from .const import Const
from chess import Board, Piece

pygame.font.init()
FONT = pygame.font.SysFont('ariel', 40)


def draw_board(WIN, PIECE_IMG, board, square_clicked, mx, my):
    WIN.fill(Const.BG)

    for row in range(8):
        for col in range(8):

            if (row + col) % 2 == 0:
                color = Const.DARK_SQUARE
            else:
                color = Const.LIGHT_SQUARE

            draw_square(WIN, row, col, color)

    if square_clicked != None and board.get_piece(square_clicked).type != Piece.EMPTY:
        row, col = Board.get_row_col(square_clicked)
        draw_square(WIN, row, col, Const.HIGHLIGHT_ORIGIN)

        moves = board.get_moves(square_clicked)
        for move in moves:
            row, col = Board.get_row_col(move.target_square)
            draw_square(WIN, row, col, Const.HIGHLIGHT_MOVE)

    for row in range(8):
        for col in range(8):

            x = Const.SQUARE_SIZE // 2 + Const.SQUARE_SIZE * col
            y = Const.SQUARE_SIZE // 2 + Const.SQUARE_SIZE * (7 - row)

            if Board.get_index(row, col) != square_clicked:
                WIN.blit(
                    PIECE_IMG,
                    (x, y),
                    get_piece_img(board.get_piece(Board.get_index(row, col)))
                )

    text = FONT.render("Undo", 1, Const.BLACK)
    WIN.blit(text, (Const.WIDTH - text.get_width() - 10, Const.HEIGHT - text.get_height() - 10))


    if square_clicked != None:
        WIN.blit(
            PIECE_IMG,
            (mx - Const.SQUARE_SIZE // 2, my - Const.SQUARE_SIZE // 2),
            get_piece_img(board.get_piece(square_clicked))
        )


def draw_square(WIN, row, col, color):
    square = pygame.Rect(
        Const.SQUARE_SIZE // 2 + Const.SQUARE_SIZE * col,
        Const.SQUARE_SIZE // 2 + Const.SQUARE_SIZE * (7 - row),
        Const.SQUARE_SIZE,
        Const.SQUARE_SIZE
    )
    pygame.draw.rect(WIN, color, square)


def get_piece_img(piece):
    if piece.type == Piece.EMPTY:
        return Const.EMPTY

    if piece.type == Piece.KING:
        if piece.color == Piece.WHITE:
            return Const.W_KING
        return Const.B_KING

    elif piece.type == Piece.PAWN:
        if piece.color == Piece.WHITE:
            return Const.W_PAWN
        return Const.B_PAWN

    elif piece.type == Piece.KNIGHT:
        if piece.color == Piece.WHITE:
            return Const.W_KNIGHT
        return Const.B_KNIGHT

    elif piece.type == Piece.BISHOP:
        if piece.color == Piece.WHITE:
            return Const.W_BISHOP
        return Const.B_BISHOP

    elif piece.type == Piece.ROOK:
        if piece.color == Piece.WHITE:
            return Const.W_ROOK
        return Const.B_ROOK

    elif piece.type == Piece.QUEEN:
        if piece.color == Piece.WHITE:
            return Const.W_QUEEN
        return Const.B_QUEEN
