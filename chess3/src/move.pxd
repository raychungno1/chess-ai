cdef int encode_move(int source, int target, int piece, int promoted, int capture, int double_pawn, int enpassant, int castling)

cdef int get_move_source(int move)
cdef int get_move_target(int move)
cdef int get_move_piece(int move)
cdef int get_move_promoted(int move)
cdef int get_move_capture(int move)
cdef int get_move_double(int move)
cdef int get_move_enpassant(int move)
cdef int get_move_castling(int move)

cpdef print_move(int move)

cdef enum:
    all_moves, only_captures

cdef class Moves:
    cdef public int moves[256]
    cdef public int count

    cpdef add_move(self, int move)
    cpdef print_move_list(self)
