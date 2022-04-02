import os
from numpy import square
import pygame
from game import Const, draw_board, get_board_square, undo_clicked
from chess import Board, Move


WIN = pygame.display.set_mode((Const.WIDTH, Const.HEIGHT))
pygame.display.set_caption("Chess")
PIECE_IMG = pygame.transform.scale(pygame.image.load(os.path.join(
    "img", "chess_pieces.png")), (Const.SQUARE_SIZE * 6, Const.SQUARE_SIZE * 2))


def main():
    board = Board()
    clock = pygame.time.Clock()

    mx, my = 0, 0
    square_clicked = None

    while True:
        clock.tick(Const.FPS)
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()

            if event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1:
                    mx, my = pygame.mouse.get_pos()
                    square_clicked = get_board_square(mx, my)
                    if undo_clicked(mx, my):
                        board.undo()

            if event.type == pygame.MOUSEBUTTONUP:
                if event.button == 1:
                    mx, my = pygame.mouse.get_pos()
                    target_square = get_board_square(mx, my)
                    if target_square != None:
                        board.move(Move(board, square_clicked, target_square))
                    square_clicked = None

        mx, my = pygame.mouse.get_pos()

        draw_window(board, square_clicked, mx, my)


def draw_window(board, square_clicked, mx, my):
    draw_board(WIN, PIECE_IMG, board, square_clicked, mx, my)
    pygame.display.update()


if __name__ == "__main__":
    main()
