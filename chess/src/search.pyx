from libc.stdio cimport printf
from eval cimport evaluate
from helper cimport get_ls1b_index
from board cimport Board, BoardCopy, K, k, white, black
from move cimport Moves, print_move


cpdef int search_position(object board, int depth):
    cdef int nodes = 0, ply = 0, best_move = 0, score = 0
    score = negamax(board, -50000, 50000, depth, &nodes, &ply, &best_move)

    if best_move:
        printf("into score cp %d depth %d nodes %ld\n", score, depth, nodes)
        printf("Best Move: ")
        print_move(best_move)
    return best_move

cdef int quiescence(object board, int alpha, int beta, int *nodes, int *ply):
    cdef int evaluation = evaluate(board)

    # Fail hard beta cutoff
    if evaluation >= beta:
        return beta # node fails high

    # Found better move
    if evaluation > alpha:
        alpha = evaluation

    cdef move_list = board.generate_moves()

    cdef int i, score
    cdef BoardCopy copy
    for i in range(move_list.count):
        copy = board.copy_board()
        ply[0] += 1

        if board.make_move(move_list.moves[i], 1) == 0:
            ply[0] -= 1
            continue

        score = -quiescence(board, -beta, -alpha, nodes, ply)
        ply[0] -= 1
        board.take_back(copy)

        # Fail hard beta cutoff
        if score >= beta:
            return beta # node fails high

        # Found better move
        if score > alpha:
            alpha = score

    # Node fails low
    return alpha

cdef int negamax(object board, int alpha, int beta, int depth, int *nodes, int *ply, int *best_move):
    if depth == 0:
        # return evaluate(board)
        return quiescence(board, alpha, beta, nodes, ply)
    
    nodes[0] += 1
    cdef int best_so_far, old_alpha
    old_alpha = alpha

    cdef int in_check = board.is_square_attacked(get_ls1b_index(board.bitboards[K]) if board.side == white else get_ls1b_index(board.bitboards[k]), board.side ^ 1)
    cdef int legal_moves = 0

    cdef move_list = board.generate_moves()

    cdef int i, score
    cdef BoardCopy copy
    for i in range(move_list.count):
        copy = board.copy_board()
        ply[0] += 1

        if board.make_move(move_list.moves[i], 0) == 0:
            ply[0] -= 1
            continue

        legal_moves += 1
        score = -negamax(board, -beta, -alpha, depth - 1, nodes, ply, best_move)
        ply[0] -= 1
        board.take_back(copy)

        # Fail hard beta cutoff
        if score >= beta:
            return beta # node fails high

        # Found better move
        if score > alpha:
            alpha = score

            if ply[0] == 0:
                best_so_far = move_list.moves[i]

    if legal_moves == 0:
        if in_check:
            return -49000 + ply[0] # this is VERY important!

        return 0

    if old_alpha != alpha:
        best_move[0] = best_so_far

    # Node fails low
    return alpha
    