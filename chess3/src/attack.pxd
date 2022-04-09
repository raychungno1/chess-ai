from helper cimport U64
from const cimport rook_magic_numbers, bishop_magic_numbers


cdef enum:
    white, black

cdef enum:
    rook, bishop

# Pre-calculated attack tables
cdef U64 pawn_attacks[2][64]
cdef U64 knight_attacks[64]
cdef U64 king_attacks[64]

cdef U64 bishop_masks[64]
cdef U64 bishop_attacks[64][512]

cdef U64 rook_masks[64]
cdef U64 rook_attacks[64][4096]

cdef int bishop_relevant_bits[64]
cdef int rook_relevant_bits[64]

cdef U64 mask_bishop_attacks(int square)
cdef U64 mask_rook_attacks(int square)
cdef U64 bishop_attacks_on_the_fly(int square, U64 block)
cdef U64 rook_attacks_on_the_fly(int square, U64 block)
cdef U64 set_occupancy(int index, int bits_in_mask, U64 attack_mask)

cdef U64 get_bishop_attacks(int square, U64 occupancy)
cdef U64 get_rook_attacks(int square, U64 occupancy)
