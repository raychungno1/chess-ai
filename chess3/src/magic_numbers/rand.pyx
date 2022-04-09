cdef unsigned int rand_state = 1804289383

cdef unsigned int get_random_U32_number(unsigned int *state):
    cdef unsigned int number = state[0]

    # XOR shift algorithm
    number ^= number << 13
    number ^= number >> 17
    number ^= number << 5

    state[0] = number
    return number

cdef U64 get_random_U64_numbers(unsigned int *state):
    cdef U64 n1, n2, n3, n4
    n1 = <U64>(get_random_U32_number(state)) & 0xFFFF
    n2 = <U64>(get_random_U32_number(state)) & 0xFFFF
    n3 = <U64>(get_random_U32_number(state)) & 0xFFFF
    n4 = <U64>(get_random_U32_number(state)) & 0xFFFF

    return n1 | (n2 << 16) | (n3 << 32) | (n4 << 48)

cdef U64 generate_magic_number(unsigned int *state):
    return get_random_U64_numbers(state) & get_random_U64_numbers(state) & get_random_U64_numbers(state)
