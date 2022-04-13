cpdef int encode_move(int source, int target, int piece, int promoted, int capture, int double_pawn, int enpassant, int castling)

cpdef int get_move_source(int move)
cpdef int get_move_target(int move)
cpdef int get_move_piece(int move)
cpdef int get_move_promoted(int move)
cpdef int get_move_capture(int move)
cpdef int get_move_double(int move)
cpdef int get_move_enpassant(int move)
cpdef int get_move_castling(int move)

cdef char promoted_pieces[12]

cpdef print_move(int move)

cdef enum:
    all_moves, only_captures

cdef class Moves:
    cdef public int moves[256]
    cdef public int count

    cpdef add_move(self, int move)
    cpdef print_move_list(self)
