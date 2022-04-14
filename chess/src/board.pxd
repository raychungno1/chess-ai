from helper cimport U64
from move cimport Moves

cdef enum:
    a8, b8, c8, d8, e8, f8, g8, h8,
    a7, b7, c7, d7, e7, f7, g7, h7,
    a6, b6, c6, d6, e6, f6, g6, h6,
    a5, b5, c5, d5, e5, f5, g5, h5,
    a4, b4, c4, d4, e4, f4, g4, h4,
    a3, b3, c3, d3, e3, f3, g3, h3,
    a2, b2, c2, d2, e2, f2, g2, h2,
    a1, b1, c1, d1, e1, f1, g1, h1, no_sq

cdef enum:
    white, black, both

cdef enum:
    P, N, B, R, Q, K, p, n, b, r, q, k

cdef enum:
    wk = 1, wq = 2, bk = 4, bq = 8

ctypedef struct BoardCopy:
    U64 bitboards[12]
    U64 occupancies[3]
    int side, enpassant, castling
    
cdef class Board:
    cdef public U64 bitboards[12]
    cdef public U64 occupancies[3]
    cdef public int side, enpassant, castling

    cdef int is_square_attacked(self, int square, int side)
    cpdef generate_moves(self)
    cpdef generate_moves_square(self, int square)
    cpdef BoardCopy copy_board(self)
    cpdef take_back(self, BoardCopy copy)
    cpdef int make_move(self, int move, int move_flag)
    cpdef long perft(self, int depth)
    cpdef long perft_test(self, int depth)
    cpdef int parse_move(self, char *move_str)
    cpdef int get_piece(self, int square)
    