from libc.stdio cimport printf
from helper cimport U64, get_bit, set_bit, pop_bit, count_bits, get_ls1b_index, print_bitboard
from attack cimport pawn_attacks, knight_attacks, king_attacks, set_occupancy, mask_bishop_attacks, mask_rook_attacks

square_to_coord[:] = [
    "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8",
    "a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7",
    "a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6",
    "a5", "b5", "c5", "d5", "e5", "f5", "g5", "h5",
    "a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4",
    "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3",
    "a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2",
    "a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1"
]

cdef int rank, file, square
for rank in range(8):
    for file in range(8):
        square = rank * 8 + file

        printf("%d, ", count_bits(mask_rook_attacks(square)))
    printf("\n")
