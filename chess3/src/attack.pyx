from board cimport white, black
from helper cimport set_bit


# Bit masks for certain files
cdef U64 not_a_file = 18374403900871474942ULL
cdef U64 not_ab_file = 18229723555195321596ULL
cdef U64 not_h_file = 9187201950435737471ULL
cdef U64 not_hg_file = 4557430888798830399ULL

cdef U64 mask_pawn_attacks(int side, int square):
    cdef U64 attacks = 0ULL
    cdef U64 bitboard = set_bit(0ULL, square)

    # Pawn attack offsets 7, 9
    if side: # Black pawn
        if (bitboard << 7) & not_h_file:
            attacks |= (bitboard << 7)

        if (bitboard << 9) & not_a_file:
            attacks |= (bitboard << 9)

    else: # White pawn
        if (bitboard >> 7) & not_a_file:
            attacks |= (bitboard >> 7)

        if (bitboard >> 9) & not_h_file:
            attacks |= (bitboard >> 9)

    return attacks

cdef U64 mask_knight_attacks(int square):
    cdef U64 attacks = 0ULL
    cdef U64 bitboard = set_bit(0ULL, square)

    # Knight attack offsets 17, 15, 10, 6
    if (bitboard >> 17) & not_h_file:
        attacks |= (bitboard >> 17)
    if (bitboard >> 15) & not_a_file:
        attacks |= (bitboard >> 15)
    if (bitboard >> 10) & not_hg_file:
        attacks |= (bitboard >> 10)
    if (bitboard >> 6) & not_ab_file:
        attacks |= (bitboard >> 6)

    if (bitboard << 17) & not_a_file:
        attacks |= (bitboard << 17)
    if (bitboard << 15) & not_h_file:
        attacks |= (bitboard << 15)
    if (bitboard << 10) & not_ab_file:
        attacks |= (bitboard << 10)
    if (bitboard << 6) & not_hg_file:
        attacks |= (bitboard << 6)

    return attacks

cdef U64 mask_king_attacks(int square):
    cdef U64 attacks = 0ULL
    cdef U64 bitboard = set_bit(0ULL, square)

    # King attack offsets 1, 7, 8, 9
    if bitboard >> 8:
        attacks |= (bitboard >> 8)
    if (bitboard >> 9) & not_h_file:
        attacks |= (bitboard >> 9)
    if (bitboard >> 7) & not_a_file:
        attacks |= (bitboard >> 7)
    if (bitboard >> 1) & not_h_file:
        attacks |= (bitboard >> 1)

    if bitboard << 8:
        attacks |= (bitboard << 8)
    if (bitboard << 9) & not_a_file:
        attacks |= (bitboard << 9)
    if (bitboard << 7) & not_h_file:
        attacks |= (bitboard << 7)
    if (bitboard << 1) & not_a_file:
        attacks |= (bitboard << 1)

    return attacks

cdef init_leapers_attacks():
    cdef int square
    for square in range(64):
        pawn_attacks[white][square] = mask_pawn_attacks(white, square)
        pawn_attacks[black][square] = mask_pawn_attacks(black, square)

        knight_attacks[square] = mask_knight_attacks(square)

        king_attacks[square] = mask_king_attacks(square)
        
init_leapers_attacks()