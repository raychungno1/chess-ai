from libc.stdio cimport printf
from board cimport Board, Square, File
from helper cimport uint64_t, popCount

cdef uint64_t fileMask[8]
fileMask[:] = [
    0x0101010101010101,
    0x0202020202020202,
    0x0404040404040404,
    0x0808080808080808,
    0x1010101010101010,
    0x2020202020202020,
    0x4040404040404040,
    0x8080808080808080
]

cdef uint64_t rankMask[8]
rankMask[:] = [
    0x00000000000000FF,
    0x000000000000FF00,
    0x0000000000FF0000,
    0x00000000FF000000,
    0x000000FF00000000,
    0x0000FF0000000000,
    0x00FF000000000000,
    0xFF00000000000000
]

# cpdef newBitBoard(char* fen):


cpdef printBitBoard(uint64_t bitBoard):
    cdef int i, j
    for i in range(7, -1, -1):
        for j in range(8):
            # printf("%i ", (i * 8 + j))
            printf("%i ", (bitBoard >> (i * 8 + j)) & 1)
        printf("\n")

# printf("\n")
