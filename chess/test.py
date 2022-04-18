import time
from board import Board
from move import Moves, print_move
from search import search_position

chess = Board()
chess.parse_fen(b"r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1 ")
chess.print_board()
search_position(chess, 5)
# print_move(search_position(chess, 5))

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
