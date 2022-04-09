from libc.stdio cimport printf
from helper cimport U64, print_bitboard, set_bit
from attack cimport pawn_attacks, knight_attacks, king_attacks, get_bishop_attacks, get_rook_attacks
from const cimport ascii_pieces, char_to_piece


cdef class Board:
    def __init__(self):
        self.side = -1
        self.enpassant = no_sq
        self.castling = 0

cdef Board chess = Board()
chess.bitboards[P] = set_bit(chess.bitboards[P], e2)
print_bitboard(chess.bitboards[P])

printf("%c\n", ascii_pieces[P]) 
printf("%c\n", ascii_pieces[char_to_piece("K")]) 
printf("%d\n", char_to_piece("P")) 
printf("%d\n", char_to_piece("K")) 
