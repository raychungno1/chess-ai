import os
from numpy import square
import pygame
from game import Const, draw_board, get_board_square, undo_clicked
from chess import Board, Move
from ai import AI
import time

WIN = pygame.display.set_mode((Const.WIDTH, Const.HEIGHT))
pygame.display.set_caption("Chess")
PIECE_IMG = pygame.transform.scale(pygame.image.load(os.path.join(
    "img", "chess_pieces.png")), (Const.SQUARE_SIZE * 6, Const.SQUARE_SIZE * 2))


def main():
    board = Board()
    clock = pygame.time.Clock()

    mx, my = 0, 0
    square_clicked = None
    target_square = None
    undoing = False
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
                    if undo_clicked(mx, my):
                        board.undo()
                        board.undo()
                        undoing = True

            if event.type == pygame.MOUSEBUTTONUP:
                if event.button == 1:
                    if undoing == False:
                        mx, my = pygame.mouse.get_pos()
                        target_square = get_board_square(mx, my)
                        if square_clicked != None and target_square != None:
                            valid = board.move(Move(board, square_clicked, target_square))
                            if valid == True:
                                start = time.time()
                                move = AI.choose_move(board)
                                end = time.time()
                                print(f"Time: {end - start}")
                                board.move(move)
                                board.check_winner()
                        target_square = None
                        square_clicked = None
                    undoing = False

        mx, my = pygame.mouse.get_pos()

        draw_window(board, square_clicked, mx, my)


def draw_window(board, square_clicked, mx, my):
    draw_board(WIN, PIECE_IMG, board, square_clicked, mx, my)
    pygame.display.update()


if __name__ == "__main__":
    main()
