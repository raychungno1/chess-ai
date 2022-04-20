import pygame
from .const import Const
import sys
sys.path.append('./chess')
from board import Board
from move import Moves, print_move, encode_move, get_move_source, get_move_target, get_move_piece, get_move_promoted, get_move_capture, get_move_castling, get_move_double, get_move_enpassant

pygame.font.init()
FONT = pygame.font.SysFont('ariel', 40)


def draw_board(WIN, PIECE_IMG, board, square_clicked, mx, my, moves, prev_move, depth, nodes, eval, search_time):
    WIN.fill(Const.BG)

    for row in range(8):
        for col in range(8):

            if (row + col) % 2 == 0:
                color = Const.DARK_SQUARE
            else:
                color = Const.LIGHT_SQUARE

            draw_square(WIN, row, col, color)

    for i in range(moves.count):
        move = moves.moves[i]
        source = get_move_source(move)
        target = get_move_target(move)
        draw_square(WIN, source // 8, source % 8, Const.HIGHLIGHT_ORIGIN)
        draw_square(WIN, target // 8, target % 8, Const.HIGHLIGHT_MOVE)

    if prev_move:
        source = get_move_source(prev_move)
        target = get_move_target(prev_move)
        draw_square(WIN, source // 8, source % 8, Const.HIGHLIGHT_ORIGIN)
        draw_square(WIN, target // 8, target % 8, Const.HIGHLIGHT_MOVE)

    for row in range(8):
        for col in range(8):

            x = Const.SQUARE_SIZE // 2 + Const.SQUARE_SIZE * col
            y = Const.SQUARE_SIZE // 2 + Const.SQUARE_SIZE * row

            if row * 8 + col != square_clicked:
                WIN.blit(
                    PIECE_IMG,
                    (x, y),
                    get_piece_img(board.get_piece(row * 8 + col))
                )

    if square_clicked != None:
        WIN.blit(
            PIECE_IMG,
            (mx - Const.SQUARE_SIZE // 2, my - Const.SQUARE_SIZE // 2),
            get_piece_img(board.get_piece(square_clicked))
        )



    text = FONT.render("Depth:", 1, Const.BLACK)
    WIN.blit(text, (720, Const.SQUARE_SIZE))
    text = FONT.render(str(depth), 1, Const.BLACK)
    WIN.blit(text, (720, Const.SQUARE_SIZE * 1.4))

    text = FONT.render("Nodes Searched:", 1, Const.BLACK)
    WIN.blit(text, (720, Const.SQUARE_SIZE * 2))
    text = FONT.render(str(nodes), 1, Const.BLACK)
    WIN.blit(text, (720, Const.SQUARE_SIZE * 2.4))

    text = FONT.render("Evaluation:", 1, Const.BLACK)
    WIN.blit(text, (720, Const.SQUARE_SIZE * 3))
    text = FONT.render(str(eval), 1, Const.BLACK)
    WIN.blit(text, (720, Const.SQUARE_SIZE * 3.4))

    text = FONT.render("Time:", 1, Const.BLACK)
    WIN.blit(text, (720, Const.SQUARE_SIZE * 4))
    text = FONT.render("{:.2f}".format(search_time), 1, Const.BLACK)
    WIN.blit(text, (720, Const.SQUARE_SIZE * 4.4))


def draw_square(WIN, row, col, color):
    square = pygame.Rect(
        Const.SQUARE_SIZE // 2 + Const.SQUARE_SIZE * col,
        Const.SQUARE_SIZE // 2 + Const.SQUARE_SIZE * row,
        Const.SQUARE_SIZE,
        Const.SQUARE_SIZE
    )
    pygame.draw.rect(WIN, color, square)


def get_piece_img(piece):
    if piece == 0:
        return Const.W_PAWN
    if piece == 1:
        return Const.W_KNIGHT
    if piece == 2:
        return Const.W_BISHOP
    if piece == 3:
        return Const.W_ROOK
    if piece == 4:
        return Const.W_QUEEN
    if piece == 5:
        return Const.W_KING
    if piece == 6:
        return Const.B_PAWN
    if piece == 7:
        return Const.B_KNIGHT
    if piece == 8:
        return Const.B_BISHOP
    if piece == 9:
        return Const.B_ROOK
    if piece == 10:
        return Const.B_QUEEN
    if piece == 11:
        return Const.B_KING

    return Const.EMPTY

