import pygame

class Const:
  FPS = 30
  WIDTH, HEIGHT = 1000, 720

  BG = (210, 205, 202)
  DARK_SQUARE = (223, 197, 170)
  LIGHT_SQUARE = (237, 226, 222)
  BLACK = (0, 0, 0)
  HIGHLIGHT_MOVE = (188, 183, 179)
  HIGHLIGHT_ORIGIN = (148, 140, 137)

  SQUARE_SIZE = 80
  EMPTY = pygame.Rect(0, 0, 0, 0)
  W_KING = pygame.Rect(0, 0, SQUARE_SIZE, SQUARE_SIZE)
  B_KING = pygame.Rect(0, SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE)
  W_QUEEN = pygame.Rect(SQUARE_SIZE, 0, SQUARE_SIZE, SQUARE_SIZE)
  B_QUEEN = pygame.Rect(SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE)
  W_BISHOP = pygame.Rect(2 * SQUARE_SIZE, 0, SQUARE_SIZE, SQUARE_SIZE)
  B_BISHOP = pygame.Rect(2 * SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE)
  W_KNIGHT = pygame.Rect(3 * SQUARE_SIZE, 0, SQUARE_SIZE, SQUARE_SIZE)
  B_KNIGHT = pygame.Rect(3 * SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE)
  W_ROOK = pygame.Rect(4 * SQUARE_SIZE, 0, SQUARE_SIZE, SQUARE_SIZE)
  B_ROOK = pygame.Rect(4 * SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE)
  W_PAWN = pygame.Rect(5 * SQUARE_SIZE, 0, SQUARE_SIZE, SQUARE_SIZE)
  B_PAWN = pygame.Rect(5 * SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE)

square_to_coord = [
  "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8",
  "a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7",
  "a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6",
  "a5", "b5", "c5", "d5", "e5", "f5", "g5", "h5",
  "a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4",
  "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3",
  "a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2",
  "a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1"
]
