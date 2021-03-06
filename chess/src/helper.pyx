from libc.stdio cimport printf

cdef U64 get_bit(U64 bitboard, int square):
    return 1 if bitboard & (1ULL << square) else 0

cdef U64 set_bit(U64 bitboard, int square):
    return bitboard | (1ULL << square)

cdef U64 pop_bit(U64 bitboard, int square):
    return bitboard ^ (1ULL << square) if get_bit(bitboard, square) else bitboard

cdef int count_bits(U64 bitboard):
    cdef int count = 0

    while bitboard:
        count += 1

        # sets least significant "1" bit to "0"
        bitboard &= bitboard - 1

    return count

cdef int get_ls1b_index(U64 bitboard):
    if bitboard:
        # bithack
        return count_bits((bitboard & -bitboard) - 1)
    else:
        return -1

cdef print_bitboard(U64 bitboard):
    cdef int rank, file, square

    printf("\n")
    for rank in range(8): # Ranks
        for file in range(8): # Files
            square = rank * 8 + file # Square index

            if not(file):
                printf(" %d ", 8 - rank) # Rank label

            # Square state
            printf(" %d", get_bit(bitboard, square))

        printf("\n")

    printf("\n    a b c d e f g h\n\n") # File label

    printf("    Bitboard: %llud\n\n", bitboard) # Decimal representation