from chess import Board
import time

def move_gen_test(board, depth):
    if depth == 0:
        return 1

    moves = board.generate_moves()
    num_pos = 0

    for move in moves:
        prev_en_passant = board.en_passant
        board.make_valid_move(move)
        num_pos += move_gen_test(board, depth - 1)
        board.undo()
        board.en_passant = prev_en_passant

    return num_pos

b = Board()
for i in range(5):
    start = time.time()
    num_pos = move_gen_test(b, i)
    end = time.time()
    print(f"Depth {i}: {num_pos} positions     Time: {end - start}")