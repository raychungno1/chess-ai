import os
from numpy import square
import pygame
from game import Const, draw_board, get_board_square
from chess import Board, Move


WIN = pygame.display.set_mode((Const.WIDTH, Const.HEIGHT))
pygame.display.set_caption("Chess")
PIECE_IMG = pygame.transform.scale(pygame.image.load(os.path.join(
    "img", "chess_pieces.png")), (Const.SQUARE_SIZE * 6, Const.SQUARE_SIZE * 2))


def main():
    board = Board()
    clock = pygame.time.Clock()

    clicking = False
    mx, my = 0, 0
    square_clicked = None

    while True:
        clock.tick(Const.FPS)
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()

            if event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1:
                    clicking = True
                    mx, my = pygame.mouse.get_pos()
                    square_clicked = get_board_square(mx, my)
                    print(square_clicked)
                    # print(f"{mx}, {my}")
                    # print(square_clicked)

            if event.type == pygame.MOUSEBUTTONUP:
                if event.button == 1:
                    clicking = False
                    mx, my = pygame.mouse.get_pos()
                    target_square = get_board_square(mx, my)
                    board.move(Move(board.get_piece(square_clicked),
                               square_clicked, target_square))
                    square_clicked = None

        if clicking:
            mx, my = pygame.mouse.get_pos()

        draw_window(board, square_clicked, mx, my)


def draw_window(board, square_clicked, mx, my):
    draw_board(WIN, PIECE_IMG, board, square_clicked, mx, my)
    pygame.display.update()


if __name__ == "__main__":
    main()
