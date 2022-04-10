from libc.stdio cimport printf
from libc.string cimport memset
from helper cimport U64, print_bitboard, get_bit, set_bit, pop_bit, get_ls1b_index
from attack cimport pawn_attacks, knight_attacks, king_attacks, get_bishop_attacks, get_rook_attacks, get_queen_attacks
from const cimport square_to_coord, ascii_pieces, char_to_piece, empty_board, start_position, tricky_position, killer_position, cmk_position 
from move cimport encode_move, get_move_source, get_move_target, get_move_piece, get_move_promoted, get_move_capture, get_move_castling, get_move_double, get_move_enpassant, print_move, Moves

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

    cdef int is_square_attacked(self, int square, int side):
        if side == white and pawn_attacks[black][square] & self.bitboards[P]:
            return 1

        if side == black and pawn_attacks[white][square] & self.bitboards[p]:
            return 1

        if knight_attacks[square] & (self.bitboards[N] if (side == white) else self.bitboards[n]):
            return 1

        if get_bishop_attacks(square, self.occupancies[both]) & (self.bitboards[B] if (side == white) else self.bitboards[b]):
            return 1

        if get_rook_attacks(square, self.occupancies[both]) & (self.bitboards[R] if (side == white) else self.bitboards[r]):
            return 1

        if get_queen_attacks(square, self.occupancies[both]) & (self.bitboards[Q] if (side == white) else self.bitboards[q]):
            return 1

        if king_attacks[square] & (self.bitboards[K] if (side == white) else self.bitboards[k]):
            return 1

        return 0

    def print_attacked_squares(self, int side):
        printf("\n")
        cdef int rank, file, square
        for rank in range(8):
            for file in range(8):
                square = 8 * rank + file

                if not(file):
                    printf(" %d  ", 8 - rank)

                printf("%d ", 1 if self.is_square_attacked(square, side) else 0)
            printf("\n")
        printf("\n    a b c d e f g h\n\n") # File label

    cpdef generate_moves(self):
        cdef int source_square, target_square, piece
        cdef U64 bitboard, attacks 

        for piece, bb in enumerate(self.bitboards):
            bitboard = bb # generate copy of bitboard

            # Generate white pawns & white king castle
            if self.side == white:
                if piece == P:
                    while bitboard:
                        source_square = get_ls1b_index(bitboard)
                        target_square = source_square - 8

                        if target_square >= a8 and not(get_bit(self.occupancies[both], target_square)):
                            # Promotion
                            if source_square >= a7 and source_square <= h7:
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])

                            # Single pawn move
                            else:
                                printf("%s%s\tpawn\tpush\n", square_to_coord[source_square], square_to_coord[target_square])
                                
                                # Double pawn move
                                if (source_square >= a2 and source_square <= h2) and not(get_bit(self.occupancies[both], target_square - 8)):
                                    printf("%s%s\tpawn\tpush double\n", square_to_coord[source_square], square_to_coord[target_square - 8])
                        
                        attacks = pawn_attacks[self.side][source_square] & self.occupancies[black]
                        while attacks:
                            target_square = get_ls1b_index(attacks)

                            # Capture promotion
                            if source_square >= a7 and source_square <= h7:
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])

                            # Normal pawn capture
                            else:
                                printf("%s%s\tpawn\tcapture\n", square_to_coord[source_square], square_to_coord[target_square])

                            attacks = pop_bit(attacks, target_square)

                        # Enpassant
                        if self.enpassant != no_sq:
                            attacks = pawn_attacks[self.side][source_square] & (1ULL << self.enpassant)
                            if attacks:
                                target_square = self.enpassant
                                printf("%s%s\tpawn\tcapture enpassant\n", square_to_coord[source_square], square_to_coord[target_square])

                        bitboard = pop_bit(bitboard, source_square)

                # Castling moves
                if piece == K:
                    # Kingside
                    if self.castling & wk:
                        if not(get_bit(self.occupancies[both], f1)) and not(get_bit(self.occupancies[both], g1)):
                            if not(self.is_square_attacked(e1, black)) and not(self.is_square_attacked(f1, black)):
                                printf("e1g1\tcastling\n")

                    # Queenside
                    if self.castling & wq:
                        if not(get_bit(self.occupancies[both], d1)) and not(get_bit(self.occupancies[both], c1)) and not(get_bit(self.occupancies[both], b1)):
                            if not(self.is_square_attacked(e1, black)) and not(self.is_square_attacked(d1, black)):
                                printf("e1c1\tcastling\n")

            # Generate black pawns & black king castle
            else:
                if piece == p:
                    while bitboard:
                        source_square = get_ls1b_index(bitboard)
                        target_square = source_square + 8

                        if target_square <= h1 and not(get_bit(self.occupancies[both], target_square)):
                            # Promotion
                            if source_square >= a2 and source_square <= h2:
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])

                            # Single pawn move
                            else:
                                printf("%s%s\tpawn\tpush\n", square_to_coord[source_square], square_to_coord[target_square])
                                
                                # Double pawn move
                                if (source_square >= a7 and source_square <= h7) and not(get_bit(self.occupancies[both], target_square + 8)):
                                    printf("%s%s\tpawn\tpush double\n", square_to_coord[source_square], square_to_coord[target_square - 8])
                        
                        attacks = pawn_attacks[self.side][source_square] & self.occupancies[white]
                        while attacks:
                            target_square = get_ls1b_index(attacks)

                            # Capture promotion
                            if source_square >= a2 and source_square <= h2:
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])
                                printf("%s%sq\tpawn\tpromotion\n", square_to_coord[source_square], square_to_coord[target_square])

                            # Normal pawn capture
                            else:
                                printf("%s%s\tpawn\tcapture\n", square_to_coord[source_square], square_to_coord[target_square])

                            attacks = pop_bit(attacks, target_square)

                        # Enpassant
                        if self.enpassant != no_sq:
                            attacks = pawn_attacks[self.side][source_square] & (1ULL << self.enpassant)
                            if attacks:
                                target_square = self.enpassant
                                printf("%s%s\tpawn\tcapture enpassant\n", square_to_coord[source_square], square_to_coord[target_square])

                        bitboard = pop_bit(bitboard, source_square)

                # Castling moves
                if piece == k:
                    # Kingside
                    if self.castling & bk:
                        if not(get_bit(self.occupancies[both], f8)) and not(get_bit(self.occupancies[both], g8)):
                            if not(self.is_square_attacked(e8, white)) and not(self.is_square_attacked(f8, white)):
                                printf("e8g8\tcastling\n")

                    # Queenside
                    if self.castling & bq:
                        if not(get_bit(self.occupancies[both], d8)) and not(get_bit(self.occupancies[both], c8)) and not(get_bit(self.occupancies[both], b8)):
                            if not(self.is_square_attacked(e8, white)) and not(self.is_square_attacked(d8, white)):
                                printf("e8c8\tcastling\n")

            # Generate knight moves
            if (self.side == white and piece == N) or (self.side == black and piece == n):
                while bitboard:
                    source_square = get_ls1b_index(bitboard)

                    attacks = knight_attacks[source_square] & (~self.occupancies[white] if self.side == white else ~self.occupancies[black])
                    while attacks:
                        target_square = get_ls1b_index(attacks)

                        # Quiet move
                        if not get_bit(self.occupancies[black] if self.side == white else self.occupancies[white], target_square):
                            printf("%s%s\tknight\tquiet\n", square_to_coord[source_square], square_to_coord[target_square])

                        # Capture
                        else:
                            printf("%s%s\tknight\tcapture\n", square_to_coord[source_square], square_to_coord[target_square])

                        attacks = pop_bit(attacks, target_square)
                    bitboard = pop_bit(bitboard, source_square)

            # Generate bishop moves
            if (self.side == white and piece == B) or (self.side == black and piece == b):
                while bitboard:
                    source_square = get_ls1b_index(bitboard)

                    attacks = get_bishop_attacks(source_square, self.occupancies[both]) & (~self.occupancies[white] if self.side == white else ~self.occupancies[black])
                    while attacks:
                        target_square = get_ls1b_index(attacks)

                        # Quiet move
                        if not get_bit(self.occupancies[black] if self.side == white else self.occupancies[white], target_square):
                            printf("%s%s\tbishop\tquiet\n", square_to_coord[source_square], square_to_coord[target_square])

                        # Capture
                        else:
                            printf("%s%s\tbishop\tcapture\n", square_to_coord[source_square], square_to_coord[target_square])

                        attacks = pop_bit(attacks, target_square)
                    bitboard = pop_bit(bitboard, source_square)

            # Generate rook moves
            if (self.side == white and piece == R) or (self.side == black and piece == r):
                while bitboard:
                    source_square = get_ls1b_index(bitboard)

                    attacks = get_rook_attacks(source_square, self.occupancies[both]) & (~self.occupancies[white] if self.side == white else ~self.occupancies[black])
                    while attacks:
                        target_square = get_ls1b_index(attacks)

                        # Quiet move
                        if not get_bit(self.occupancies[black] if self.side == white else self.occupancies[white], target_square):
                            printf("%s%s\trook\tquiet\n", square_to_coord[source_square], square_to_coord[target_square])

                        # Capture
                        else:
                            printf("%s%s\trook\tcapture\n", square_to_coord[source_square], square_to_coord[target_square])

                        attacks = pop_bit(attacks, target_square)
                    bitboard = pop_bit(bitboard, source_square)

            # Generate queen moves
            if (self.side == white and piece == Q) or (self.side == black and piece == q):
                while bitboard:
                    source_square = get_ls1b_index(bitboard)

                    attacks = get_queen_attacks(source_square, self.occupancies[both]) & (~self.occupancies[white] if self.side == white else ~self.occupancies[black])
                    while attacks:
                        target_square = get_ls1b_index(attacks)

                        # Quiet move
                        if not get_bit(self.occupancies[black] if self.side == white else self.occupancies[white], target_square):
                            printf("%s%s\tqueen\tquiet\n", square_to_coord[source_square], square_to_coord[target_square])

                        # Capture
                        else:
                            printf("%s%s\tqueen\tcapture\n", square_to_coord[source_square], square_to_coord[target_square])

                        attacks = pop_bit(attacks, target_square)
                    bitboard = pop_bit(bitboard, source_square)

            # Generate king moves
            if (self.side == white and piece == K) or (self.side == black and piece == k):
                while bitboard:
                    source_square = get_ls1b_index(bitboard)

                    attacks = king_attacks[source_square] & (~self.occupancies[white] if self.side == white else ~self.occupancies[black])
                    while attacks:
                        target_square = get_ls1b_index(attacks)

                        # Quiet move
                        if not get_bit(self.occupancies[black] if self.side == white else self.occupancies[white], target_square):
                            printf("%s%s\tking\tquiet\n", square_to_coord[source_square], square_to_coord[target_square])

                        # Capture
                        else:
                            printf("%s%s\tking\tcapture\n", square_to_coord[source_square], square_to_coord[target_square])

                        attacks = pop_bit(attacks, target_square)
                    bitboard = pop_bit(bitboard, source_square)

# cdef Board chess = Board()
# chess.parse_fen(b"r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1 ")
# chess.print_board()
# chess.generate_moves()

cdef int move = encode_move(d7, e8, P, Q, 1, 0, 0, 0)

# printf("source square: %s\n", square_to_coord[get_move_source(move)])
# printf("target square: %s\n", square_to_coord[get_move_target(move)])
# printf("piece: %c\n", ascii_pieces[get_move_piece(move)])
# printf("promoted piece: %c\n", ascii_pieces[get_move_promoted(move)])
# printf("capture flag: %i\n", 1 if get_move_capture(move) else 0)
# printf("double flag: %i\n", 1 if get_move_double(move) else 0)
# printf("enpassant flag: %i\n", 1 if get_move_enpassant(move) else 0)
# printf("castling flag: %i\n", 1 if get_move_castling(move) else 0)
# print_move(move)

cdef Moves move_list = Moves()
move_list.add_move(encode_move(d7, e8, B, b, 1, 0, 0, 0))
move_list.print_move_list()
