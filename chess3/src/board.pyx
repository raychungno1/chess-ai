from libc.stdio cimport printf
from libc.string cimport memset
from helper cimport U64, print_bitboard, get_bit, set_bit
from attack cimport pawn_attacks, knight_attacks, king_attacks, get_bishop_attacks, get_rook_attacks
from const cimport square_to_coord, ascii_pieces, char_to_piece, empty_board, start_position, tricky_position, killer_position, cmk_position 


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

                piece = -1 # check if a piece is on the current square
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

    def parse_fen(self, char *fen):
        memset(self.bitboards, 0ULL, sizeof(self.bitboards))
        memset(self.occupancies, 0ULL, sizeof(self.occupancies))
        self.side = 0
        self.enpassant = no_sq
        self.castling = 0

        # Parse board
        cdef int rank = 0, file, square, piece, index = 0
        while rank < 8:
            file = 0

            while file < 8:
                square = 8 * rank + file

                if (fen[index] >= 'a' and fen[index] <= 'z') or (fen[index] >= 'A' and fen[index] <= 'Z'):
                    piece = char_to_piece(fen[index])
                    self.bitboards[piece] = set_bit(self.bitboards[piece], square)

                    index += 1

                if fen[index] >= '0' and fen[index] <= '9':
                    offset = fen[index] - <int>'0' # convert char to int

                    piece = -1 # check if a piece is on the current square
                    for i, bitboard in enumerate(self.bitboards):
                        if get_bit(bitboard, square):
                            piece = i

                    if piece == -1:
                        file -= 1

                    file += offset
                    index += 1
                    
                if fen[index] == '/':
                    index += 1

                file += 1
            rank += 1
        index += 1
        
        # Parse side to move
        self.side = white if fen[index] == 'w' else black
        index += 2
        
        # Parse castling rights
        while fen[index] != ' ':
            if fen[index] == 'K':
                self.castling |= wk
            elif fen[index] == 'Q':
                self.castling |= wq
            elif fen[index] == 'k':
                self.castling |= bk
            elif fen[index] == 'q':
                self.castling |= bq
            index += 1
        index += 1

        # Parse enpassant square
        if fen[index] != '-':
            file = fen[index] - <int>'a'
            rank = 8 - (fen[index + 1] - <int>'0')

            self.enpassant = 8 * rank + file
            index += 3
        else:
            self.enpassant = no_sq
            index += 2

        # White occupancies
        for piece in range(P, K + 1):
            self.occupancies[0] |= self.bitboards[piece]

        # Black occupancies
        for piece in range(p, k + 1):
            self.occupancies[1] |= self.bitboards[piece]

        # General occupancies
        self.occupancies[2] = self.occupancies[0] | self.occupancies[1]

cdef Board chess = Board()
# printf("FEN: %s\n", cmk_position)
chess.parse_fen(start_position)
chess.print_board()

chess.parse_fen(b"r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R b Kk e6 0 1 ")
chess.print_board()

chess.parse_fen(b"r2q1rk1/ppp2ppp/2n1bn2/2b1p3/3pP3/3P1NPP/PPP1NPB1/R1BQ1RK1 w q a3 0 9 ")
chess.print_board()
