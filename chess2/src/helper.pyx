cimport helper

cdef uint64_t popCount (uint64_t x):
    cdef int count = 0
    while x:
        count += 1
        x &= x - 1 # reset LS1B
    return count
