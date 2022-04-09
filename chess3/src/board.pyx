from libc.stdio cimport printf
from helper cimport U64, print_bitboard, set_bit
from attack cimport pawn_attacks, knight_attacks, king_attacks, get_bishop_attacks, get_rook_attacks

cdef U64 occupancy = 0ULL
occupancy = set_bit(occupancy, c5)
occupancy = set_bit(occupancy, f2)
occupancy = set_bit(occupancy, g7)
occupancy = set_bit(occupancy, b2)
occupancy = set_bit(occupancy, b5)
occupancy = set_bit(occupancy, e2)
occupancy = set_bit(occupancy, e7)

print_bitboard(occupancy)
print_bitboard(get_bishop_attacks(d4, occupancy))
print_bitboard(get_rook_attacks(e5, occupancy))
