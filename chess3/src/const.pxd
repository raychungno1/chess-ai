from helper cimport U64


cdef char *square_to_coord[64]

cdef U64 rook_magic_numbers[64]
cdef U64 bishop_magic_numbers[64]

cdef char ascii_pieces[12]

cdef int char_to_piece(char c)

cdef char *empty_board
cdef char *start_position
cdef char *tricky_position
cdef char *killer_position
cdef char *cmk_position
cdef char *last