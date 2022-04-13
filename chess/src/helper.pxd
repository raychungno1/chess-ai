ctypedef unsigned long long U64

cdef U64 get_bit(U64 bitboard, int square)

cdef U64 set_bit(U64 bitboard, int square)

cdef U64 pop_bit(U64 bitboard, int square)

cdef int count_bits(U64 bitboard)

cdef int get_ls1b_index(U64 bitboard)

cdef print_bitboard(U64 bitboard)
