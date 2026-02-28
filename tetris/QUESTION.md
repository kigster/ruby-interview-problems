
#
# ******** PREMISE *********
# ***************************
#
# Say we wanted to build a simplified game of Tetris.Given the way the grid based nature of the game, we can model
# the board as a 2D array. For example, if the board was 20x10:
# + `0` indicates absence of a tetromino piece segment
# + `1` indicates presence of a tetromino piece segment
#
#
#  for illustrative purposes:
#      const BOARD_WITH_ACTIVE_PIECE =
#                [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
#                 [0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]];
#
#   + Plan to implement left() and rotate() on the Game/Piece classes.
#   + Your focus should be on model design, separation of concerns, and cleanliness.

#   TERMINOLOGY
#   ------------------------------------------------------
#   + "piece" represents a single tetromino piece
#   + "segment" represents one of four units that make up a piece
#   + "board" is the game board
#
#
#   PHASE I
#   ------------------------------------------------------
#
#   (a) consider how to store different types of tetromino pieces
#   (b) design the `Piece` class to support these types
#
#   PHASE II
#   ------------------------------------------------------
#
#   (c) left() moves the currently active piece left
#   (d) rotate() will rotate the active piece clockwise
#
#   PHASE III
#   ------------------------------------------------------
#   (e) tick() will advance the game one time unit forward
#
#  /
#
# 0 XOR 0 = 0
# 0 XOR 1 = 1
# 1 XOR 0 = 1
# 1 XOR 1 = 0
#
