from libc.stdio cimport printf, getchar
from libc.string cimport memset, memcpy
from helper cimport U64, print_bitboard, get_bit, set_bit, pop_bit, get_ls1b_index
from attack cimport pawn_attacks, knight_attacks, king_attacks, get_bishop_attacks, get_rook_attacks, get_queen_attacks
from const cimport square_to_coord, ascii_pieces, char_to_piece, castling_rights, empty_board, start_position, tricky_position, killer_position, cmk_position 
from move cimport encode_move, get_move_source, get_move_target, get_move_piece, get_move_promoted, get_move_capture, get_move_castling, get_move_double, get_move_enpassant, print_move, Moves, all_moves, only_captures, promoted_pieces

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

    cpdef object generate_moves(self):
        cdef Moves move_list = Moves()
        move_list.count = 0

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
                                move_list.add_move(encode_move(source_square, target_square, piece, Q, 0, 0, 0, 0))
                                move_list.add_move(encode_move(source_square, target_square, piece, R, 0, 0, 0, 0))
                                move_list.add_move(encode_move(source_square, target_square, piece, B, 0, 0, 0, 0))
                                move_list.add_move(encode_move(source_square, target_square, piece, N, 0, 0, 0, 0))
                                
                            # Single pawn move
                            else:
                                move_list.add_move(encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))
                                
                                # Double pawn move
                                if (source_square >= a2 and source_square <= h2) and not(get_bit(self.occupancies[both], target_square - 8)):
                                    move_list.add_move(encode_move(source_square, target_square - 8, piece, 0, 0, 1, 0, 0))

                        attacks = pawn_attacks[self.side][source_square] & self.occupancies[black]
                        while attacks:
                            target_square = get_ls1b_index(attacks)

                            # Capture promotion
                            if source_square >= a7 and source_square <= h7:
                                move_list.add_move(encode_move(source_square, target_square, piece, Q, 1, 0, 0, 0))
                                move_list.add_move(encode_move(source_square, target_square, piece, R, 1, 0, 0, 0))
                                move_list.add_move(encode_move(source_square, target_square, piece, B, 1, 0, 0, 0))
                                move_list.add_move(encode_move(source_square, target_square, piece, N, 1, 0, 0, 0))

                            # Normal pawn capture
                            else:
                                move_list.add_move(encode_move(source_square, target_square, piece, 0, 1, 0, 0, 0))

                            attacks = pop_bit(attacks, target_square)

                        # Enpassant
                        if self.enpassant != no_sq:
                            attacks = pawn_attacks[self.side][source_square] & (1ULL << self.enpassant)
                            if attacks:
                                target_square = self.enpassant
                                move_list.add_move(encode_move(source_square, target_square, piece, 0, 1, 0, 1, 0))

                        bitboard = pop_bit(bitboard, source_square)

                # Castling moves
                if piece == K:
                    # Kingside
                    if self.castling & wk:
                        if not(get_bit(self.occupancies[both], f1)) and not(get_bit(self.occupancies[both], g1)):
                            if not(self.is_square_attacked(e1, black)) and not(self.is_square_attacked(f1, black)):
                                move_list.add_move(encode_move(e1, g1, piece, 0, 0, 0, 0, 1))

                    # Queenside
                    if self.castling & wq:
                        if not(get_bit(self.occupancies[both], d1)) and not(get_bit(self.occupancies[both], c1)) and not(get_bit(self.occupancies[both], b1)):
                            if not(self.is_square_attacked(e1, black)) and not(self.is_square_attacked(d1, black)):
                                move_list.add_move(encode_move(e1, c1, piece, 0, 0, 0, 0, 1))

            # Generate black pawns & black king castle
            else:
                if piece == p:
                    while bitboard:
                        source_square = get_ls1b_index(bitboard)
                        target_square = source_square + 8

                        if target_square <= h1 and not(get_bit(self.occupancies[both], target_square)):
                            # Promotion
                            if source_square >= a2 and source_square <= h2:
                                move_list.add_move(encode_move(source_square, target_square, piece, q, 0, 0, 0, 0))
                                move_list.add_move(encode_move(source_square, target_square, piece, r, 0, 0, 0, 0))
                                move_list.add_move(encode_move(source_square, target_square, piece, b, 0, 0, 0, 0))
                                move_list.add_move(encode_move(source_square, target_square, piece, n, 0, 0, 0, 0))

                            # Single pawn move
                            else:
                                move_list.add_move(encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))
                                
                                # Double pawn move
                                if (source_square >= a7 and source_square <= h7) and not(get_bit(self.occupancies[both], target_square + 8)):
                                    move_list.add_move(encode_move(source_square, target_square + 8, piece, 0, 0, 1, 0, 0))
                        
                        attacks = pawn_attacks[self.side][source_square] & self.occupancies[white]
                        while attacks:
                            target_square = get_ls1b_index(attacks)

                            # Capture promotion
                            if source_square >= a2 and source_square <= h2:
                                move_list.add_move(encode_move(source_square, target_square, piece, q, 1, 0, 0, 0))
                                move_list.add_move(encode_move(source_square, target_square, piece, r, 1, 0, 0, 0))
                                move_list.add_move(encode_move(source_square, target_square, piece, b, 1, 0, 0, 0))
                                move_list.add_move(encode_move(source_square, target_square, piece, n, 1, 0, 0, 0))

                            # Normal pawn capture
                            else:
                                move_list.add_move(encode_move(source_square, target_square, piece, 0, 1, 0, 0, 0))

                            attacks = pop_bit(attacks, target_square)

                        # Enpassant
                        if self.enpassant != no_sq:
                            attacks = pawn_attacks[self.side][source_square] & (1ULL << self.enpassant)
                            if attacks:
                                target_square = self.enpassant
                                move_list.add_move(encode_move(source_square, target_square, piece, 0, 1, 0, 1, 0))

                        bitboard = pop_bit(bitboard, source_square)

                # Castling moves
                if piece == k:
                    # Kingside
                    if self.castling & bk:
                        if not(get_bit(self.occupancies[both], f8)) and not(get_bit(self.occupancies[both], g8)):
                            if not(self.is_square_attacked(e8, white)) and not(self.is_square_attacked(f8, white)):
                                move_list.add_move(encode_move(e8, g8, piece, 0, 0, 0, 0, 1))

                    # Queenside
                    if self.castling & bq:
                        if not(get_bit(self.occupancies[both], d8)) and not(get_bit(self.occupancies[both], c8)) and not(get_bit(self.occupancies[both], b8)):
                            if not(self.is_square_attacked(e8, white)) and not(self.is_square_attacked(d8, white)):
                                move_list.add_move(encode_move(e8, c8, piece, 0, 0, 0, 0, 1))

            # Generate knight moves
            if (self.side == white and piece == N) or (self.side == black and piece == n):
                while bitboard:
                    source_square = get_ls1b_index(bitboard)

                    attacks = knight_attacks[source_square] & (~self.occupancies[white] if self.side == white else ~self.occupancies[black])
                    while attacks:
                        target_square = get_ls1b_index(attacks)

                        # Quiet move
                        if not get_bit(self.occupancies[black] if self.side == white else self.occupancies[white], target_square):
                            move_list.add_move(encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))

                        # Capture
                        else:
                            move_list.add_move(encode_move(source_square, target_square, piece, 0, 1, 0, 0, 0))

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
                            move_list.add_move(encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))

                        # Capture
                        else:
                            move_list.add_move(encode_move(source_square, target_square, piece, 0, 1, 0, 0, 0))

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
                            move_list.add_move(encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))

                        # Capture
                        else:
                            move_list.add_move(encode_move(source_square, target_square, piece, 0, 1, 0, 0, 0))

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
                            move_list.add_move(encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))

                        # Capture
                        else:
                            move_list.add_move(encode_move(source_square, target_square, piece, 0, 1, 0, 0, 0))

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
                            move_list.add_move(encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))

                        # Capture
                        else:
                            move_list.add_move(encode_move(source_square, target_square, piece, 0, 1, 0, 0, 0))

                        attacks = pop_bit(attacks, target_square)
                    bitboard = pop_bit(bitboard, source_square)

        return move_list

    cpdef BoardCopy copy_board(self):
        cdef BoardCopy copy
        memcpy(copy.bitboards, self.bitboards, 96)
        memcpy(copy.occupancies, self.occupancies, 24)
        copy.side = self.side
        copy.enpassant = self.enpassant
        copy.castling = self.castling
        return copy

    cpdef take_back(self, BoardCopy copy):
        memcpy(self.bitboards, copy.bitboards, 96)
        memcpy(self.occupancies, copy.occupancies, 24)
        self.side = copy.side
        self.enpassant = copy.enpassant
        self.castling = copy.castling

    cpdef int make_move(self, int move, int move_flag):
        cdef BoardCopy copy
        cdef int source_square, target_square, piece, capture, promoted, double_pawn, enpassant, castling, start_piece, end_piece, index

        if move_flag == all_moves:
            copy = self.copy_board()

            source_square = get_move_source(move)
            target_square = get_move_target(move)
            piece = get_move_piece(move)
            capture = get_move_capture(move)
            promoted = get_move_promoted(move)
            double_pawn = get_move_double(move)
            enpassant = get_move_enpassant(move)
            castling = get_move_castling(move)

            self.bitboards[piece] = pop_bit(self.bitboards[piece], source_square)
            self.bitboards[piece] = set_bit(self.bitboards[piece], target_square)

            # handle capture
            if capture:
                if self.side == white:
                    start_piece = p
                    end_piece = k
                else:
                    start_piece = P
                    end_piece = K

                for index in range(start_piece, end_piece + 1):
                    if get_bit(self.bitboards[index], target_square):
                        self.bitboards[index] = pop_bit(self.bitboards[index], target_square)
                        break

            # handle promotion
            if promoted:
                self.bitboards[piece] = pop_bit(self.bitboards[piece], target_square)
                self.bitboards[promoted] = set_bit(self.bitboards[promoted], target_square)

            # handle enpassant
            if enpassant:
                if self.side == white:
                    self.bitboards[p] = pop_bit(self.bitboards[p], target_square + 8)
                else:
                    self.bitboards[P] = pop_bit(self.bitboards[P], target_square - 8)

            self.enpassant = no_sq

            # handle double pawn push
            if double_pawn:
                self.enpassant = target_square + 8 if self.side == white else target_square - 8

            # handle castling
            if castling:
                if target_square == g1:
                    self.bitboards[R] = pop_bit(self.bitboards[R], h1)
                    self.bitboards[R] = set_bit(self.bitboards[R], f1)

                elif target_square == c1:
                    self.bitboards[R] = pop_bit(self.bitboards[R], a1)
                    self.bitboards[R] = set_bit(self.bitboards[R], d1)

                elif target_square == g8:
                    self.bitboards[r] = pop_bit(self.bitboards[r], h8)
                    self.bitboards[r] = set_bit(self.bitboards[r], f8)

                elif target_square == c8:
                    self.bitboards[r] = pop_bit(self.bitboards[r], a8)
                    self.bitboards[r] = set_bit(self.bitboards[r], d8)

            # update castling rights
            self.castling &= castling_rights[source_square]
            self.castling &= castling_rights[target_square]

            # update occupancy
            memset(self.occupancies, 0ULL, 24)
            for index in range(P, K + 1):
                self.occupancies[white] |= self.bitboards[index]

            for index in range(p, k + 1):
                self.occupancies[black] |= self.bitboards[index]

            self.occupancies[both] = self.occupancies[white] | self.occupancies[black]

            # change side
            self.side ^= 1

            # make sure king is not in check
            if self.is_square_attacked(get_ls1b_index(self.bitboards[k]) if self.side == white else get_ls1b_index(self.bitboards[K]), self.side):
                self.take_back(copy)
                return 0

            else:
                return 1

        else:
            if get_move_capture(move):
                self.make_move(move, all_moves)

            else:
                return 0

    cpdef long perft(self, int depth):
        if depth == 0:
            return 1

        cdef Moves move_list = self.generate_moves()

        cdef int i, result
        cdef BoardCopy copy
        cdef long nodes = 0

        for i in range(move_list.count):
            copy = self.copy_board()

            if not self.make_move(move_list.moves[i], all_moves):
                continue

            nodes += self.perft(depth - 1)

            self.take_back(copy)
        
        return nodes

    cpdef long perft_test(self, int depth):
        printf("\n    Performance test\n\n")
        cdef Moves move_list = self.generate_moves()

        cdef int i, result
        cdef BoardCopy copy
        cdef long nodes = 0, temp = 0

        for i in range(move_list.count):
            copy = self.copy_board()

            if not self.make_move(move_list.moves[i], all_moves):
                continue

            temp = self.perft(depth - 1)
            nodes += temp

            self.take_back(copy)
            printf("    move: %s%s%c  nodes: %ld\n", square_to_coord[get_move_source(move_list.moves[i])], square_to_coord[get_move_target(move_list.moves[i])], promoted_pieces[get_move_promoted(move_list.moves[i])], temp)

        printf("\n    Depth: %d\n", depth)
        printf("    Nodes: %d\n\n", nodes)
        
        return nodes

# cdef Board chess = Board()
# chess.parse_fen(b"r3k2r/p1ppRpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R b KQkq - 0 1 ")
# chess.print_board()

# cdef Moves move_list = chess.generate_moves()

# cdef int i, move
# cdef BoardCopy copy
# for i in range(move_list.count):
#     move = move_list.moves[i]
#     print_move(move)

#     copy = chess.copy_board()

#     if not chess.make_move(move, all_moves):
#         continue

#     chess.print_board()
#     getchar()

#     chess.take_back(copy)
#     chess.print_board()
#     getchar()
    
# move_list.print_move_list()
# cdef BoardCopy copy = chess.copy_board()
# chess.parse_fen(b"8/8/8/8/8/8/8/8 b - - ")
# chess.print_board()

# chess.take_back(copy)
# chess.print_board()

