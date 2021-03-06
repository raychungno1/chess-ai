import os
import pygame
from game import Const, draw_board, get_board_square, square_to_coord
import sys
sys.path.append('./chess')
from board import Board
from move import Moves, print_move
from search import search_position

# from ai import AI
import time

WIN = pygame.display.set_mode((Const.WIDTH, Const.HEIGHT))
pygame.display.set_caption("Chess")
PIECE_IMG = pygame.transform.scale(pygame.image.load(os.path.join(
    "img", "chess_pieces.png")), (Const.SQUARE_SIZE * 6, Const.SQUARE_SIZE * 2))


def main():
    board = Board()
    board.parse_fen(b"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 ")
    board.print_board()
    clock = pygame.time.Clock()

    mx, my = 0, 0
    square_clicked = None
    target_square = None
    moves = Moves()
    moves.count = 0
    prev_move = 0
    depth = 7
    nodes = 0
    eval = 0
    search_time = 0

    while True:
        clock.tick(Const.FPS)
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                return

            if event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1:
                    mx, my = pygame.mouse.get_pos()
                    square_clicked = get_board_square(mx, my)
                    if square_clicked is not None:
                        moves = board.generate_moves_square(square_clicked)

            if event.type == pygame.MOUSEBUTTONUP:
                if event.button == 1:
                    mx, my = pygame.mouse.get_pos()
                    target_square = get_board_square(mx, my)
                    if square_clicked != None and target_square != None:
                        move = square_to_coord[square_clicked] + square_to_coord[target_square] + "q"
                        move = board.parse_move(move.encode("ascii"))
                        if move:

                            print_move(move)
                            if board.make_move(move, 0):
                                prev_move = move
                                board.print_board()
                                start = time.perf_counter()
                                move, nodes, eval = search_position(board, depth)
                                end = time.perf_counter()
                                search_time = end - start
                                if move:
                                    print_move(move)
                                    board.make_move(move, 0)
                                    prev_move = move

                    moves = Moves()
                    moves.count = 0
                    target_square = None
                    square_clicked = None

        mx, my = pygame.mouse.get_pos()

        draw_window(board, square_clicked, mx, my, moves, prev_move, depth, nodes, eval, search_time)


def draw_window(board, square_clicked, mx, my, moves, prev_move, depth, nodes, eval, search_time):
    draw_board(WIN, PIECE_IMG, board, square_clicked, mx, my, moves, prev_move, depth, nodes, eval, search_time)
    pygame.display.update()


if __name__ == "__main__":
    main()
