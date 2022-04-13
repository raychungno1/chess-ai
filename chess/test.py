import time
from board import Board
from move import Moves, print_move

chess = Board()
chess.parse_fen(b"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 ")
chess.print_board()
print(chess.get_piece(26))

# m = chess.generate_moves_square(62)
# m.print_move_list()
# print(chess.parse_move(b"e2e4"))
# start = time.perf_counter()
# chess.perft_test(5)
# end = time.perf_counter()
# print(f"Time: {end - start}")

# for depth in range(6):
#     start = time.perf_counter()
#     nodes = chess.perft(depth)
#     end = time.perf_counter()
#     print(f"Depth: {depth} Nodes: {nodes} | Time: {end - start}")
