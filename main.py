from chess import Board, Piece, Queen, Color, Rook, Bishop, King, Pawn, Knight
b = Board()
b.print()
moves = b.generate_moves()

for move in moves:
  print(move.tostring())

print(len(moves))