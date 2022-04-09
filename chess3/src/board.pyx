from libc.stdio cimport printf
from helper cimport U64, print_bitboard, get_bit, set_bit
from attack cimport pawn_attacks, knight_attacks, king_attacks, get_bishop_attacks, get_rook_attacks
from const cimport square_to_coord, ascii_pieces, char_to_piece


cdef class Board:
    def __init__(self):
        self.side = 0
        self.enpassant = no_sq
        self.castling = 0

    def print_board(self):
        cdef int rank, file, square, piece, i
        cdef char dot = "."
        cdef char dash = "-"
        cdef char *na = "no"
        cdef char *castle = "KQkq"

        printf("\n")
        for rank in range(8):
            for file in range(8):
                square = 8 * rank + file

                if not(file):
                    printf(" %d ", 8 - rank)

                piece = -1
                for i, bitboard in enumerate(self.bitboards):
                    if get_bit(bitboard, square):
                        piece = i

                printf(" %c", dot if (piece == -1) else ascii_pieces[piece])

            printf("\n")

        printf("\n    a b c d e f g h\n\n") # File label
        printf("    Side:     %s\n", "black" if self.side else "white")
        printf("    Enpassant:   %s\n", square_to_coord[self.enpassant] if self.enpassant != no_sq else na)
        printf("    Castle:    %c%c%c%c\n\n", castle[0] if self.castling & wk else dash,
                                       castle[1] if self.castling & wq else dash,
                                       castle[2] if self.castling & bk else dash,
                                       castle[3] if self.castling & bq else dash)

cdef Board chess = Board()
chess.bitboards[P] = set_bit(chess.bitboards[P], a2)
chess.bitboards[P] = set_bit(chess.bitboards[P], b2)
chess.bitboards[P] = set_bit(chess.bitboards[P], c2)
chess.bitboards[P] = set_bit(chess.bitboards[P], d2)
chess.bitboards[P] = set_bit(chess.bitboards[P], e2)
chess.bitboards[P] = set_bit(chess.bitboards[P], f2)
chess.bitboards[P] = set_bit(chess.bitboards[P], g2)
chess.bitboards[P] = set_bit(chess.bitboards[P], h2)

chess.bitboards[N] = set_bit(chess.bitboards[N], b1)
chess.bitboards[N] = set_bit(chess.bitboards[N], g1)

chess.bitboards[B] = set_bit(chess.bitboards[B], c1)
chess.bitboards[B] = set_bit(chess.bitboards[B], f1)

chess.bitboards[R] = set_bit(chess.bitboards[R], a1)
chess.bitboards[R] = set_bit(chess.bitboards[R], h1)

chess.bitboards[Q] = set_bit(chess.bitboards[Q], d1)
chess.bitboards[K] = set_bit(chess.bitboards[K], e1)

chess.bitboards[p] = set_bit(chess.bitboards[p], a7)
chess.bitboards[p] = set_bit(chess.bitboards[p], b7)
chess.bitboards[p] = set_bit(chess.bitboards[p], c7)
chess.bitboards[p] = set_bit(chess.bitboards[p], d7)
chess.bitboards[p] = set_bit(chess.bitboards[p], e7)
chess.bitboards[p] = set_bit(chess.bitboards[p], f7)
chess.bitboards[p] = set_bit(chess.bitboards[p], g7)
chess.bitboards[p] = set_bit(chess.bitboards[p], h7)

chess.bitboards[n] = set_bit(chess.bitboards[n], b8)
chess.bitboards[n] = set_bit(chess.bitboards[n], g8)

chess.bitboards[b] = set_bit(chess.bitboards[b], c8)
chess.bitboards[b] = set_bit(chess.bitboards[b], f8)

chess.bitboards[r] = set_bit(chess.bitboards[r], a8)
chess.bitboards[r] = set_bit(chess.bitboards[r], h8)

chess.bitboards[q] = set_bit(chess.bitboards[q], d8)
chess.bitboards[k] = set_bit(chess.bitboards[k], e8)

chess.side = black
chess.enpassant = e3
chess.castling |= wk
chess.castling |= wq
chess.castling |= bk
chess.castling |= bq

print_bitboard(chess.bitboards[P])
chess.print_board()

for bitboard in chess.bitboards:
    print_bitboard(bitboard)
