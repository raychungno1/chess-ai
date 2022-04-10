from helper cimport set_bit, pop_bit, count_bits, get_ls1b_index
from const cimport rook_magic_numbers, bishop_magic_numbers


# Bit masks for certain files
cdef U64 not_a_file = 18374403900871474942ULL
cdef U64 not_ab_file = 18229723555195321596ULL
cdef U64 not_h_file = 9187201950435737471ULL
cdef U64 not_hg_file = 4557430888798830399ULL

# Occupancy bit count for every square on board
bishop_relevant_bits[:] = [
    6, 5, 5, 5, 5, 5, 5, 6, 
    5, 5, 5, 5, 5, 5, 5, 5,
    5, 5, 7, 7, 7, 7, 5, 5,
    5, 5, 7, 9, 9, 7, 5, 5,
    5, 5, 7, 9, 9, 7, 5, 5,
    5, 5, 7, 7, 7, 7, 5, 5,
    5, 5, 5, 5, 5, 5, 5, 5,
    6, 5, 5, 5, 5, 5, 5, 6
]

rook_relevant_bits[:] = [
    12, 11, 11, 11, 11, 11, 11, 12, 
    11, 10, 10, 10, 10, 10, 10, 11,
    11, 10, 10, 10, 10, 10, 10, 11,
    11, 10, 10, 10, 10, 10, 10, 11,
    11, 10, 10, 10, 10, 10, 10, 11,
    11, 10, 10, 10, 10, 10, 10, 11,
    11, 10, 10, 10, 10, 10, 10, 11,
    12, 11, 11, 11, 11, 11, 11, 12
]

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

cdef U64 mask_bishop_attacks(int square):
    cdef U64 attacks = 0ULL

    cdef int tr = square // 8 # target rank
    cdef int tf = square % 8 # target file
    cdef int r = tr + 1
    cdef int f = tf + 1
    
    while r <= 6 and f <= 6:
        attacks |= (1ULL << (r * 8 + f))
        r += 1
        f += 1

    r = tr - 1
    f = tf + 1
    while r >= 1 and f <= 6:
        attacks |= (1ULL << (r * 8 + f))
        r -= 1
        f += 1

    r = tr + 1
    f = tf - 1
    while r <= 6 and f >= 1:
        attacks |= (1ULL << (r * 8 + f))
        r += 1
        f -= 1

    r = tr - 1
    f = tf - 1
    while r >= 1 and f >= 1:
        attacks |= (1ULL << (r * 8 + f))
        r -= 1
        f -= 1

    return attacks

cdef U64 bishop_attacks_on_the_fly(int square, U64 block):
    cdef U64 attacks = 0ULL

    cdef int tr = square // 8 # target rank
    cdef int tf = square % 8 # target file
    cdef int r = tr + 1
    cdef int f = tf + 1
    
    while r <= 7 and f <= 7:
        attacks |= (1ULL << (r * 8 + f))
        if (1ULL << (r * 8 + f)) & block:
            break
        r += 1
        f += 1

    r = tr - 1
    f = tf + 1
    while r >= 0 and f <= 7:
        attacks |= (1ULL << (r * 8 + f))
        if (1ULL << (r * 8 + f)) & block:
            break
        r -= 1
        f += 1

    r = tr + 1
    f = tf - 1
    while r <= 7 and f >= 0:
        attacks |= (1ULL << (r * 8 + f))
        if (1ULL << (r * 8 + f)) & block:
            break
        r += 1
        f -= 1

    r = tr - 1
    f = tf - 1
    while r >= 0 and f >= 0:
        attacks |= (1ULL << (r * 8 + f))
        if (1ULL << (r * 8 + f)) & block:
            break
        r -= 1
        f -= 1

    return attacks
    
cdef U64 mask_rook_attacks(int square):
    cdef U64 attacks = 0ULL

    cdef int tr = square // 8 # target rank
    cdef int tf = square % 8 # target file
    cdef int r, f
    
    for r in range(tr + 1, 7):
        attacks |= (1ULL << (r * 8 + tf))

    for f in range(tf + 1, 7):
        attacks |= (1ULL << (tr * 8 + f))

    for r in range(tr - 1, 0, -1):
        attacks |= (1ULL << (r * 8 + tf))

    for f in range(tf - 1, 0, -1):
        attacks |= (1ULL << (tr * 8 + f))

    return attacks

cdef U64 rook_attacks_on_the_fly(int square, U64 block):
    cdef U64 attacks = 0ULL

    cdef int tr = square // 8 # target rank
    cdef int tf = square % 8 # target file
    cdef int r, f
    
    for r in range(tr + 1, 8):
        attacks |= (1ULL << (r * 8 + tf))
        if (1ULL << (r * 8 + tf)) & block:
            break

    for f in range(tf + 1, 8):
        attacks |= (1ULL << (tr * 8 + f))
        if (1ULL << (tr * 8 + f)) & block:
            break

    for r in range(tr - 1, -1, -1):
        attacks |= (1ULL << (r * 8 + tf))
        if (1ULL << (r * 8 + tf)) & block:
            break

    for f in range(tf - 1, -1, -1):
        attacks |= (1ULL << (tr * 8 + f))
        if (1ULL << (tr * 8 + f)) & block:
            break

    return attacks

cdef init_leapers_attacks():
    cdef int square
    for square in range(64):
        pawn_attacks[white][square] = mask_pawn_attacks(white, square)
        pawn_attacks[black][square] = mask_pawn_attacks(black, square)

        knight_attacks[square] = mask_knight_attacks(square)

        king_attacks[square] = mask_king_attacks(square)

cdef U64 set_occupancy(int index, int bits_in_mask, U64 attack_mask):
    cdef U64 occupancy = 0ULL
    cdef int count, square

    for count in range(bits_in_mask):
        square = get_ls1b_index(attack_mask)

        attack_mask = pop_bit(attack_mask, square)

        if index & (1 << count):
            occupancy |= (1ULL << square)
    return occupancy

cdef init_sliders_attacks(int bishop):
    cdef int square, relevant_bits_count, occupancy_indicies, index, magic_index
    cdef U64 attack_mask, occupancy
    for square in range(64):
        bishop_masks[square] = mask_bishop_attacks(square)
        rook_masks[square] = mask_rook_attacks(square)

        attack_mask = bishop_masks[square] if bishop else rook_masks[square]

        relevant_bits_count = count_bits(attack_mask)
        occupancy_indicies = (1 << relevant_bits_count)

        for index in range(occupancy_indicies):
            occupancy = set_occupancy(index, relevant_bits_count, attack_mask)
            if bishop:
                magic_index = (occupancy * bishop_magic_numbers[square]) >> (64 - bishop_relevant_bits[square])
                bishop_attacks[square][magic_index] = bishop_attacks_on_the_fly(square, occupancy)
            else:
                magic_index = (occupancy * rook_magic_numbers[square]) >> (64 - rook_relevant_bits[square])
                rook_attacks[square][magic_index] = rook_attacks_on_the_fly(square, occupancy)
        
cdef U64 get_bishop_attacks(int square, U64 occupancy):
    occupancy &= bishop_masks[square]
    occupancy *= bishop_magic_numbers[square]
    occupancy >>= 64 - bishop_relevant_bits[square]

    return bishop_attacks[square][occupancy]

cdef U64 get_rook_attacks(int square, U64 occupancy):
    occupancy &= rook_masks[square]
    occupancy *= rook_magic_numbers[square]
    occupancy >>= 64 - rook_relevant_bits[square]

    return rook_attacks[square][occupancy]

cdef U64 get_queen_attacks(int square, U64 occupancy):
    cdef U64 queen_attacks = 0ULL
    
    cdef U64 bishop_occupancy = occupancy
    cdef U64 rook_occupancy = occupancy

    bishop_occupancy &= bishop_masks[square]
    bishop_occupancy *= bishop_magic_numbers[square]
    bishop_occupancy >>= 64 - bishop_relevant_bits[square]

    queen_attacks = bishop_attacks[square][bishop_occupancy]

    rook_occupancy &= rook_masks[square]
    rook_occupancy *= rook_magic_numbers[square]
    rook_occupancy >>= 64 - rook_relevant_bits[square]

    queen_attacks |= rook_attacks[square][rook_occupancy]

    return queen_attacks

init_leapers_attacks()
init_sliders_attacks(bishop)
init_sliders_attacks(rook)
