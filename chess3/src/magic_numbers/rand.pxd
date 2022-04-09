from helper cimport U64


cdef unsigned int rand_state

cdef unsigned int get_random_U32_number(unsigned int *state)

cdef U64 get_random_U64_numbers(unsigned int *state)

cdef U64 generate_magic_number(unsigned int *state)
