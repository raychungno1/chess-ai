from helper cimport U64


# Pre-calculated attack tables
cdef U64 pawn_attacks[2][64]
cdef U64 knight_attacks[64]
cdef U64 king_attacks[64]

cdef U64 mask_rook_attacks(int square)
