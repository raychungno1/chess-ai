from libc.stdio cimport printf
from eval cimport evaluate
from helper cimport get_ls1b_index, get_bit
from board cimport Board, BoardCopy, P, N, B, R, Q, K, p, n, b, r, q, k, white, black
from move cimport Moves, print_move, get_move_capture, get_move_piece, get_move_source, get_move_target
from const cimport ascii_pieces


cpdef int search_position(object board, int depth):
    cdef int count
    cdef int nodes = 0, ply = 0, best_move = 0, score = 0
    score = negamax(board, -50000, 50000, depth, &nodes, &ply)

    printf("into score cp %d depth %d nodes %ld pv ", score, depth, nodes)

    # loop over moves within a PV line
    for count in range(pv_length[0]):
        print_move(pv_table[0][count])
        printf(" ")
    printf("\n")

    printf("Best Move: ")
    print_move(pv_table[0][0])

    return pv_table[0][0]

cdef int quiescence(object board, int alpha, int beta, int *nodes, int *ply):
    nodes[0] += 1
    cdef int evaluation = evaluate(board)

    # Fail hard beta cutoff
    if evaluation >= beta:
        return beta # node fails high

    # Found better move
    if evaluation > alpha:
        alpha = evaluation

    # cdef Moves move_list = board.generate_moves()
    cdef Moves move_list = sort_moves(board, ply[0])

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

cdef int negamax(object board, int alpha, int beta, int depth, int *nodes, int *ply):
    pv_length[ply[0]] = ply[0]

    if depth == 0:
        # return evaluate(board)
        return quiescence(board, alpha, beta, nodes, ply)
    
    nodes[0] += 1

    cdef int in_check = board.is_square_attacked(get_ls1b_index(board.bitboards[K]) if board.side == white else get_ls1b_index(board.bitboards[k]), board.side ^ 1)
    if in_check:
        depth += 1

    cdef int legal_moves = 0

    # cdef Moves move_list = board.generate_moves()
    cdef Moves move_list = sort_moves(board, ply[0])

    cdef int i, score, next_ply
    cdef BoardCopy copy
    for i in range(move_list.count):
        copy = board.copy_board()
        ply[0] += 1

        if board.make_move(move_list.moves[i], 0) == 0:
            ply[0] -= 1
            continue

        legal_moves += 1
        score = -negamax(board, -beta, -alpha, depth - 1, nodes, ply)
        ply[0] -= 1
        board.take_back(copy)

        # Fail hard beta cutoff
        if score >= beta:
            if get_move_capture(move_list.moves[i]) == 0:
                # Store killer move
                killer_moves[1][ply[0]] = killer_moves[0][ply[0]]
                killer_moves[0][ply[0]] = move_list.moves[i]
            return beta # node fails high

        # Found better move
        if score > alpha:
            if get_move_capture(move_list.moves[i]) == 0:
                # Store history moves
                history_moves[get_move_piece(move_list.moves[i])][get_move_target(move_list.moves[i])] += depth

            alpha = score

            # store PV move
            pv_table[ply[0]][ply[0]] = move_list.moves[i]
            # Loop over next ply
            for next_ply in range(ply[0] + 1, pv_length[ply[0] + 1]):
                # Copy move from deeper ply into curreny ply
                pv_table[ply[0]][next_ply] = pv_table[ply[0] + 1][next_ply]

            # Adjust pv_length
            pv_length[ply[0]] = pv_length[ply[0] + 1]

            if ply[0] == 0:
                best_so_far = move_list.moves[i]

    if legal_moves == 0:
        if in_check:
            return -49000 + ply[0] # this is VERY important!

        return 0

    # Node fails low
    return alpha
    
#     (Victims) Pawn Knight Bishop   Rook  Queen   King
#   (Attackers)
#         Pawn   105    205    305    405    505    605
#       Knight   104    204    304    404    504    604
#       Bishop   103    203    303    403    503    603
#         Rook   102    202    302    402    502    602
#        Queen   101    201    301    401    501    601
#         King   100    200    300    400    500    600

# MVV LVA [attacker][victim]
cdef int mvv_lva[12][12]
mvv_lva[:] = [
 	[105, 205, 305, 405, 505, 605,  105, 205, 305, 405, 505, 605],
	[104, 204, 304, 404, 504, 604,  104, 204, 304, 404, 504, 604],
	[103, 203, 303, 403, 503, 603,  103, 203, 303, 403, 503, 603],
	[102, 202, 302, 402, 502, 602,  102, 202, 302, 402, 502, 602],
	[101, 201, 301, 401, 501, 601,  101, 201, 301, 401, 501, 601],
	[100, 200, 300, 400, 500, 600,  100, 200, 300, 400, 500, 600],

	[105, 205, 305, 405, 505, 605,  105, 205, 305, 405, 505, 605],
	[104, 204, 304, 404, 504, 604,  104, 204, 304, 404, 504, 604],
	[103, 203, 303, 403, 503, 603,  103, 203, 303, 403, 503, 603],
	[102, 202, 302, 402, 502, 602,  102, 202, 302, 402, 502, 602],
	[101, 201, 301, 401, 501, 601,  101, 201, 301, 401, 501, 601],
	[100, 200, 300, 400, 500, 600,  100, 200, 300, 400, 500, 600]
]

cdef int i, j
# killer moves[id][ply]
for i in range(2):
    for j in range(64):
        killer_moves[i][j] = 0

# history moves[piece][ply]
for i in range(12):
    for j in range(64):
        history_moves[i][j] = 0

# PV length
for i in range(64):
    pv_length[i] = 0

# PV table
for i in range(64):
    for j in range(64):
        pv_table[i][j] = 0

cdef int score_move(int move, object board, int ply):
    cdef int target_piece = P
    cdef int start_piece, end_piece
    if get_move_capture(move):

        if board.side == white:
            start_piece = p
            end_piece = k
        else:
            start_piece = P
            end_piece = K

        for index in range(start_piece, end_piece + 1):
            if get_bit(board.bitboards[index], get_move_target(move)):
                target_piece = index
                break
        return mvv_lva[get_move_piece(move)][target_piece] + 10000
    else:
        # Score 1st killer move
        if killer_moves[0][ply] == move:
            return 9000

        # Score 2nd killer move
        elif killer_moves[1][ply] == move:
            return 8000

        # Score history move
        else:
            return history_moves[get_move_piece(move)][get_move_target(move)]
    return 0

cdef object sort_moves(object chess, int ply):
    cdef Moves move_list = chess.generate_moves()
    cdef int move_scores[64]
    cdef int i
    for i in range(move_list.count):
        move_scores[i] = score_move(move_list.moves[i], chess, ply)

    cdef int current_move, next_move, temp
    for current_move in range(move_list.count):
        for next_move in range(current_move + 1, move_list.count):
            if move_scores[current_move] < move_scores[next_move]:
                # Swap scores
                temp = move_scores[current_move]
                move_scores[current_move] = move_scores[next_move]
                move_scores[next_move] = temp

                move_list.swap_move(current_move, next_move)
        
    return move_list

cdef print_move_scores (object move_list, object chess):
    cdef int i, move
    printf("     Move Scores: \n\n")
    for i in range(move_list.count):
        move = move_list.moves[i]
        printf("     move: ")
        print_move(move)
        printf("score: %d\n", score_move(move, chess, 0))

