from chess import Board
import time

def move_gen_test(board, depth):
    if depth == 0:
        return 1

    moves = board.generate_moves()
    num_pos = 0
    for move in moves:
        board.make_valid_move(move)
        num_pos += move_gen_test(board, depth - 1)
        board.undo()

    return num_pos

b = Board("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - ")
for i in range(5):
    start = time.time()
    num_pos = move_gen_test(b, i)
    end = time.time()
    print(f"Depth {i}: {num_pos} positions     Time: {end - start}")
