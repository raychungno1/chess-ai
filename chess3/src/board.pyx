from helper cimport U64, get_bit, set_bit, pop_bit, print_bitboard
from attack cimport pawn_attacks, knight_attacks, king_attacks, mask_rook_attacks


# print_bitboard(mask_rook_attacks(d5))
cdef int square
for square in range(64):
    print_bitboard(mask_rook_attacks(square))
    # print_bitboard(king_attacks[square])
