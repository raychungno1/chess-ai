import time
from board import Board
from move import Moves, print_move
from search import search_position

chess = Board()
# chess.parse_fen(b"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 ")
chess.parse_fen(b"r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1 ")
# chess.parse_fen(b"rnbqkb1r/pp1p1pPp/8/2p1pP2/1P1P4/3P3P/P1P1P3/RNBQKBNR w KQkq e6 0 1")
# chess.parse_fen(b"r2q1rk1/ppp2ppp/2n1bn2/2b1p3/3pP3/3P1NPP/PPP1NPB1/R1BQ1RK1 b - - 0 9 ")
chess.print_board()
search_position(chess, 7)
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
