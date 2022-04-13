from libc.stdio cimport printf
from libc.string cimport memset
from attack cimport mask_bishop_attacks, mask_rook_attacks, bishop_attacks_on_the_fly, rook_attacks_on_the_fly, set_occupancy
from rand cimport rand_state, generate_magic_number
from helper cimport count_bits

cdef U64 find_magic_number(int square, int relevant_bits, int bishop):
    cdef U64 occupancies[4096]
    cdef U64 attacks[4096]
    cdef U64 used_attacks[4096]

    cdef U64 attack_mask = mask_bishop_attacks(square) if bishop else mask_rook_attacks(square)

    cdef int occupancy_indecies = 1 << relevant_bits

    cdef int index
    for index in range(occupancy_indecies):
        occupancies[index] = set_occupancy(index, relevant_bits, attack_mask)

        attacks[index] = bishop_attacks_on_the_fly(square, occupancies[index]) if bishop else rook_attacks_on_the_fly(square, occupancies[index])

    # Test magic number loop
    cdef int random_count, fail, magic_index
    cdef U64 magic_number
    for random_count in range(100000000):
        # Generate candidate
        magic_number = generate_magic_number(&rand_state)

        # Skip invalid magic num
        if count_bits((attack_mask * magic_number) & 0xFF00000000000000) < 6:
            continue

        # init used attacks
        memset(used_attacks, 0ULL, sizeof(used_attacks))

        # test magic index
        index = 0
        fail = 0
        while not(fail) and index < occupancy_indecies:
            magic_index = <int>((occupancies[index] * magic_number) >> (64 - relevant_bits))

            # if magic index works
            if used_attacks[magic_index] == 0ULL:
                # init used attacks
                used_attacks[magic_index] = attacks[index]

            elif used_attacks[magic_index] != attacks[index]:
                # magic index doesn't work
                fail = 1

            index += 1

        if not(fail):
            return magic_number
    
    printf("  Magic nuber fails!")
    return 0ULL
