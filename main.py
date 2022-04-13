import sys
sys.path.append('./chess')
from board import Board
from move import Moves, encode_move, get_move_source, get_move_target, get_move_piece, get_move_promoted, get_move_capture, get_move_castling, get_move_double, get_move_enpassant

import time

chess = Board()
chess.parse_fen(b"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 ")

# start = time.perf_counter()
# chess.perft_test(5)
# end = time.perf_counter()
# print(f"Time: {end - start}")

for i in range(7):
    start = time.perf_counter()
    num_pos = chess.perft(i)
    end = time.perf_counter()
    print(f"Depth {i}: {num_pos} positions     Time: {end - start}")
