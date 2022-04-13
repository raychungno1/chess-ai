from libc.stdio cimport printf
from const cimport square_to_coord, ascii_pieces


cpdef int encode_move(int source, int target, int piece, int promoted, int capture, int double_pawn, int enpassant, int castling):
    return (
        source |
        (target << 6) |
        (piece << 12) |
        (promoted << 16) |
        (capture << 20) |
        (double_pawn << 21) |
        (enpassant << 22) |
        (castling << 23)
    )

cpdef int get_move_source(int move):
    return move & 0x3f

cpdef int get_move_target(int move):
    return (move & 0xfc0) >> 6

cpdef int get_move_piece(int move):
    return (move & 0xf000) >> 12

cpdef int get_move_promoted(int move):
    return (move & 0xf0000) >> 16

cpdef int get_move_capture(int move):
    return move & 0x100000

cpdef int get_move_double(int move):
    return move & 0x200000

cpdef int get_move_enpassant(int move):
    return move & 0x400000

cpdef int get_move_castling(int move):
    return move & 0x800000

promoted_pieces[:] = [
    " ", "n", "b", "r", "q", " ",
    " ", "n", "b", "r", "q", " "
]

# for UCI purposes
cpdef print_move(int move):
    printf("%s%s%c\n", square_to_coord[get_move_source(move)], square_to_coord[get_move_target(move)], promoted_pieces[get_move_promoted(move)])

cdef class Moves:
    def __init__(self):
        self.count = 0

    cpdef add_move(self, int move):
        self.moves[self.count] = move
        self.count += 1

    # for debug purposes
    cpdef print_move_list(self):
        if not self.count:
            printf("\n    Empty move list!\n\n")
            return

        printf("\n    move    piece   capture   double   enpass   castling\n\n")
        
        cdef int i, move
        for i in range(self.count):
            move = self.moves[i]

            printf("    %s%s%c   %c       %d         %d        %d        %d\n", square_to_coord[get_move_source(move)],
                                                                                square_to_coord[get_move_target(move)],
                                                                                promoted_pieces[get_move_promoted(move)],
                                                                                ascii_pieces[get_move_piece(move)],
                                                                                1 if get_move_capture(move) else 0,
                                                                                1 if get_move_double(move) else 0,
                                                                                1 if get_move_enpassant(move) else 0,
                                                                                1 if get_move_castling(move) else 0)
        printf("\n\n    Total # of moves: %d\n\n", self.count)

