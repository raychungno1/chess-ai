cdef int ply[1]
cpdef int search_position(object board, int depth)
cdef int mvv_lva[12][12]

cdef int killer_moves[2][64]
cdef int history_moves[12][64]
cdef int pv_length[64]
cdef int pv_table[64][64]

cdef int score_move(int move, object board, int ply)
cdef object sort_moves(object chess, int ply)
cdef print_move_scores (object move_list, object chess)
