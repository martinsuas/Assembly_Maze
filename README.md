# Assembly_Maze
Solves a text-made maze using assembly language.

.in files specify the input maze.

.out files specify the solution.

`S` - Starting point.

`E` - Ending point.

`#` - Wall.

`.` - Solving path.

Example:

sample4.in

```
13
23
#######################
# #     #         #   #
# # # # # ####### ### #
#   # # #     #     # #
##### # # ##### # # # #
# #   #   #E  # # #   #
# # # #####   # # #####
#   # #       # #     #
### # # ####### ### # #
# # # # #     #   # # #
# # ### ### # ##### # #
#           #       #S#
#######################
```

sample4.out
```
===
=== Maze Solver
=== by
=== Maze Solution
===


Input Maze:

#######################
# #     #         #   #
# # # # # ####### ### #
#   # # #     #     # #
##### # # ##### # # # #
# #   #   #E  # # #   #
# # # #####   # # #####
#   # #       # #     #
### # # ####### ### # #
# # # # #     #   # # #
# # ### ### # ##### # #
#           #       #S#
#######################


Solution:

#######################
# #  ...#.........#   #
# # #.#.#.#######.### #
#   #.#.#.    #  .  # #
#####.#.#.##### #.# # #
# #...#...#E..# #.#   #
# #.# #####  .# #.#####
#  .# #.......# #.....#
###.# #.####### ### #.#
# #.# #.#     #   # #.#
# #.###.### # ##### #.#
#  .....    #       #S#
#######################
```
