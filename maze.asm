#
# FILE: $FILE$
# AUTHOR: Martin Suarez
# DESCRIPTION: 
#	This program reads a maze from a file and recreates said maze. 
#	It solves and prints the solution after printing the maze.
# ARGUMENTS:
#	None
# INPUT:
#
# OUTPUT:
#
#

# CONSTANTS
#

P_INT =		1
P_STRING = 	4
R_INT = 	5
R_STRING =	8
P_CHAR =	11
R_CHAR =	12

UP =	 0
RIGHT =  1
DOWN =	 2
LEFT =	 3


# DATA AREAS
#

	.data
maze_text:
	.ascii "=== \n"
	.ascii "=== Maze Solver\n"
	.ascii "=== by\n"
	.ascii "=== Martin Suarez\n"
	.ascii "=== \n\n"
	.asciiz "Input maze:\n\n"
solution_text:
	.asciiz "\nSolution:\n\n"
	
done_text:
	.asciiz	"Done!\n"
bug_text:
	.asciiz "\nBug Found!\nEverybody run!!!\n"
pose_text:
	.asciiz "\nPosse: "
bt_text:
	.asciiz "\nBacktrack time!\n"
		
wall:
	.ascii "#"
space:
	.ascii " "
trail:
	.ascii "."
	
crumb_up:
	.byte DOWN
crumb_right:
	.byte LEFT
crumb_down:
	.byte UP
crumb_left:
	.byte RIGHT
	
start:
	.ascii "S"
end:
	.ascii "E"
newline:
	.asciiz "\n"

height:
	.word	0	# Stores maze height (80 max) (same with scratch)
width:
	.word 	0	# Stores maze width (80 max) (same with scratch)
size:
	.word	0	# Stores size of maze (width * height) (same with scratch)
next:
	.word	m_maze	# Pointer that indicates where we are located in the maze 
	
next_s:
	.word	scratch	# Pointer that indicates where we are locaed in the scratch maze

next_t:
	.word	tracker	# Pointer that indicates where in tracker we are located
	
counter:
	.word	0	# Counter used for loops

scratch:
	.space	6600	# Copy of m_maze

m_maze:
	.space	6600

tracker:
	.space	6200	# Place to store multiple byte integers that keep track of how many
			# times it has been turned in an specific space
	
pose:
	.word 	-1	# x = 0
	.word	-1	# y = 0
	.byte	UP	# Default: facing up
	
spin_n:
	.word	0
coordinate:
	.word	-1	# X
	.word 	-1	# y
	
start_loc:
	.word	-1	# x
	.word	-1	# y

end_loc:
	.word	-1 	# x
	.word	-1	# y
	
	.align 2
	
# CODE AREAS
#
	.text
	.align 2
	.globl main
	
#
# Name:		main
# Arguments:	none
# Returns:	none
# Destroys:	
#

main:
	# Print frame
	
	li	$v0, P_STRING    # Call print string
	la	$a0, maze_text
	syscall
	
	### Call maze printer function
	addi	$sp, $sp, -4
 	sw	$ra, 0($sp)	# save current ra
 	
	jal	read_maze
	
	lw	$ra, 0($sp)	# load old ra
	addi	$sp, $sp, 4	# return stack pointer
	###
	
	### TEST
#	la	$a0, newline
#	li	$v0, P_STRING
#	syscall
#	la	$a0, scratch
#	li	$v0, P_INT
#	syscall
#	li	$a0, 1		# CHANGE to test coor x
#	li	$a1, 2		# CHANGE to test coor y
#	li	$a3, 2		# CHANGE to test direction
#	addi	$sp, $sp, -4
#	sw	$ra, 0($sp)	# save current ra
# 	la	$a2, scratch
#	jal	check_front
#	lw	$ra, 0($sp)	# load old ra
#	addi	$sp, $sp, 4	# return stack pointer
#	move	$a0, $v0
#	li	$v0, P_CHAR
#	syscall
#	la	$a0, newline
#	li	$v0, P_STRING
#	syscall
#	la	$a0, scratch
#	addi	$a0, $a0, 28	# CHANGE to test different locations
#	addi	$sp, $sp, -4
#	sw	$ra, 0($sp)	# save current ra
#	la	$a2, scratch
#	jal	mem_to_coor
#	lw	$ra, 0($sp)	# load old ra
#	addi	$sp, $sp, 4	# return stack pointer
#	move	$a0, $v0	# move x coordinate
#	move	$s0, $v1	# save y for later printing
#	li	$v0, P_INT
#	syscall
#	move	$a0, $s0	# now move y
#	li	$v0, P_INT	
#	syscall
#	la	$a0, newline
#	li	$v0, P_STRING
#	syscall	
	### TEST
	
	li	$v0, P_STRING    # Call print string
	la 	$a0, solution_text
	syscall
	
	### Call maze solver function
	addi	$sp, $sp, -4
 	sw	$ra, 0($sp)	# save current ra
 	
 	jal	solve_maze
 	
 	lw	$ra, 0($sp)	# load old ra
	addi	$sp, $sp, 4	# return stack pointer
	###

	jr	$ra


#
# Name:		read_maze
# Arguments:	none
# Returns:	none
# Destroys:	
#
read_maze:
	# Read height
	li	$v0, R_INT
	la	$a0, height
	syscall
	sw	$v0, 0($a0) 	# v0 = height loc, so store result

	# Read width
	li	$v0, R_INT
	la	$a0, width
	syscall
	addi	$v0, $v0, 1	# Add one to width to include \n
	sw	$v0, 0($a0)	# v0 = width_loc, so store width res

	# Calculate space
	la	$t0, height
	la	$t1, width
	lw	$t0, 0($t0)
	lw	$t1, 0($t1)
	mul	$t3, $t0, $t1 	# t3 = width * height
	la	$t0, size
	sw	$t3, 0($t0)	# Store t3 in size
	
	
	
	# Set counter to zero
	la	$t0, counter
	sw	$zero, 0($t0)
	
	# Set move address equal to maze's
	la	$t0, m_maze
	la	$t1, next
	sw	$t0, 0($t1)
	
	
# Loop
rchar_l: 
	
	la	$t2, counter	# load counter
	lw	$t2, 0($t2)
	la	$t3, size	# load size
	lw	$t3, 0($t3)
	
	li	$v0, R_CHAR	# v0 = chara
	syscall			# Store v0 in current
	
	beq	$t2, $t3, rchar_1d
	la	$t0, next	# t0 = address of next, 
	lw	$t0, 0($t0)	# begins as a pointer to maze
	sb	$v0, 0($t0)	# store at maze address
	
	la	$t0, next_s	# t0 = address of next, 
	lw	$t0, 0($t0)	# begins as a pointer to scratch
	sb	$v0, 0($t0)	# store at scratch address
	
	### CHECK FOR START OR END
	la	$s1, start
 	lb	$s1, 0($s1)	# s1 = 'S'
 	la	$s0, next_s
 	lw	$s0, 0($s0)	# s0 = current address
 	lb	$s2, 0($s0)	# S2 = current chracter
 	
 	bne	$s1, $s2, no_start	# is s1 not equal to 'S'? 
## 	# Do if start is found
	la	$a2, scratch
 	addi	$sp, $sp, -4
 	sw	$ra, 0($sp)	# save current ra
 	move	$a0, $s0
	jal	mem_to_coor	# v0 = x, v1 = y
	la	$t0, start_loc
	sw	$v0, 0($t0)	# x = v0
	sw	$v1, 4($t0)	# y = v1
	lw	$ra, 0($sp)	# load old ra
	addi	$sp, $sp, 4	# return stack pointer
no_start:# end if start is found or continuation if not
 	
 	la	$s0, end
 	lb	$s0, 0($s0)	# s0 = 'E'
 	la	$s1, next_s
 	lw	$s1, 0($s1)	# s1 = current address
 	lb	$s2, 0($s1)	# s2 = current character
	bne	$s2, $s0, no_end	#is s0 equal to 'E'?
 	
## 	# Do if end is found
	la	$a2, scratch
 	addi	$sp, $sp, -4
 	sw	$ra, 0($sp)	# save current ra
 	move	$a0, $s1
	jal	mem_to_coor	# v0 = x, v1 = y
	la	$t0, end_loc
	sw	$v0, 0($t0)	# x = v0
	sw	$v1, 4($t0)	# y = v1
	lw	$ra, 0($sp)	# load old ra
	addi	$sp, $sp, 4	# return stack pointer
no_end:# end if end is found or continuation if not
	
	la	$t0, next	# load next address
	lw	$t1, 0($t0)	# store current value in t1
	addi	$t1, $t1, 1	# Increase current by 1
	sw	$t1, 0($t0)	# Store increased address in 'next' address
	
	la	$t0, next_s	# load next address
	lw	$t1, 0($t0)	# store current value in t1
	addi	$t1, $t1, 1	# Increase current by 1
	sw	$t1, 0($t0)	# Store increased address in 'next' address
	
	la	$t0, counter	# load counter
	lw	$t1, 0($t0)	# store current count in t1
	addi	$t1, $t1, 1	# Increase current counter by 1
	sw	$t1, 0($t0)	# Store increased counter at 'counter'

	j 	rchar_l
	
rchar_1d:
# Loop done
	la	$t0, next
	sb	$zero, 0($t0)	# Store null character at the end
	la	$t0, next_s
	sb	$zero, 0($t0)	# Store null character at the end of scratch
	
	### Print maze
	li	$v0, P_STRING
	la	$a0, m_maze
	syscall
	
########### TEST: print start and end coordinates
#	la	$t0, start_loc
#	li	$v0, P_INT
#	lw	$a0, 0($t0)
#	syscall
#	la	$t0, start_loc
#	li	$v0, P_INT
#	lw	$a0, 4($t0)
#	syscall
#	
#	la	$t0, end_loc
#	li	$v0, P_INT
#	lw	$a0, 0($t0)
#	syscall
#	la	$t0, end_loc
#	li	$v0, P_INT
#	lw	$a0, 4($t0)
#	syscall
	####### TEST 	

	jr	$ra

	

#
# Name:		mem_to_coor
# Arguments:	a0 = location using next or next_s, a2 = address of either maze or scratch
# Returns:	v0 = x, v1 = y
# Destroys:	
#
mem_to_coor:
	sub	$t1, $a0, $a2 	# t1 = maze_loc - maze
	la	$t2, width
	lw	$t2, 0($t2)	# t2 = width
	
	div	$t1, $t2
	# location % width = x  = $t1
 	mfhi	$v0
	# location / width = y = $t2
	mflo	$v1
	jr	$ra
	
#
# Name:		coor_to_mem
# Arguments:	a0 = x, a1 = y, a2 = address of either m_maze or scratch
# Returns:	v0 = address of location
# Destroys:	
#
coor_to_mem:
	la	$t0, height
	la	$t1, width
	lw	$t0, 0($t0) # $t0 = height
	lw	$t1, 0($t1) # $t1 = width
	mul	$t2, $t1, $a1 	# t2 =  width * y
	add	$v0, $t2, $a0	# v0 = t2 + x
	add	$v0, $v0, $a2
	jr	$ra
	
	
#
# Name:		solve_maze
# Arguments:	none
# Returns:	none
# Destroys:	
#
# s7 - designated turn tracker
solve_maze:
step_1: 
	# Step 1: Set pose location
	####### TEST ###
	#li	$v0, P_INT
	#li	$a0, 1
	#syscall
	######## TESTE ###

	la	$t0, start_loc
	lw	$s0, 0($t0)	#  s0 = Load x coordinate
	lw	$s1, 4($t0)	#  s1 = Load y coordinate
	la	$t0, pose
	sw	$s0, 0($t0)	#  Store x coordinate in pose
	sw	$s1, 4($t0)	#  Store y coordinate in pose
	li	$s3, UP		#  Default facing
	sw	$s3, 8($t0)
step_2: # done!
	# Step 2: Check the contents of the maze at current location
	####### TEST ###
	#li	$v0, P_INT
	#li	$a0, 2
	#syscall
	######## TESTE ###

	la	$t0, pose
	lw	$a0, 0($t0)	# Load x
	lw	$a1, 4($t0)	# Load y
	la	$a2, m_maze
	addi	$sp, $sp, -4
 	sw	$ra, 0($sp)	# save current ra
 	jal	coor_to_mem	# Get address
 	lw	$ra, 0($sp)	# load old ra
	addi	$sp, $sp, 4	# return stack pointer

	lb	$s0, 0($v0)	# Get symbol from current location
		
	####### TEST ###
	#li	$v0, P_CHAR
	#move	$a0, $s0
	#syscall
	######## TESTE ###

	la	$s1, end
	lb	$s1, 0($s1)	# Get 'E'
	beq	$s1, $s0, step_5	
	la	$s1, space	

	# Store 4 in tracker, represents how many turns we can make in this spot
	li	$t0, 4
	la	$t1, next_t
	lw	$t1, 0($t1)	# load current turn tracker address
	sb	$t0, 0($t1)	# store 4 in there
	
	lb	$s1, 0($s1)	# Get ' '
	beq	$s1, $s0, step_3
	la	$s1, start	
	lb	$s1, 0($s1)	# Get 'S'
	beq	$s1, $s0, step_3
	
	j	bug
step_3:
	# Step 3 - Look for next character you are facing in both mazes.
	# Step 3 A
	####### TEST ###
	#li	$v0, P_INT
	#li	$a0, 3
	#syscall
	######## TESTE ###

	# Set end as blank temporarily
	la	$t0, end_loc
	lw	$a0, 0($t0)	#x
	lw	$a1, 4($t0)	#y
	la	$a2, m_maze
	addi	$sp, $sp, -4
 	sw	$ra, 0($sp)	# save current ra
	jal	coor_to_mem	# v0 = end_loc memory
	lw	$ra, 0($sp)	# load old ra
	addi	$sp, $sp, 4	# return stack pointer
	la	$t0, space	
	lb	$t0, 0($t0)	# t0 = ' '
	sb	$t0, 0($v0)	


	la	$t0, pose
	lw	$a0, 0($t0)	# Load x
	lw	$a1, 4($t0)	# Load y
	lb	$a3, 8($t0)	# Load direction
	la	$a2, m_maze	# Checking original maze

	addi	$sp, $sp, -4
 	sw	$ra, 0($sp)	# save current ra
	jal	check_front	# v0 = front symbol
	lw	$ra, 0($sp)	# load old ra
	addi	$sp, $sp, 4	# return stack pointer
	
	la	$t0, space
	lb	$t0, 0($t0)	# load space
	bne	$v0, $t0, turn	# if loc on m_maze not empty, turn

	# is space, set end back to 'E'
	la	$t0, end_loc
	lw	$a0, 0($t0)	#x
	lw	$a1, 4($t0)	#y
	la	$a2, m_maze
	addi	$sp, $sp, -4
 	sw	$ra, 0($sp)	# save current ra
	jal	coor_to_mem	# v0 = end_loc memory
	lw	$ra, 0($sp)	# load old ra
	addi	$sp, $sp, 4	# return stack pointer
	la	$t0, end	
	lb	$t0, 0($t0)	# t0 = 'E'
	sb	$t0, 0($v0)	

	la	$t0, pose
	lw	$a0, 0($t0)	# Load x
	lw	$a1, 4($t0)	# Load y
	lb	$a3, 8($t0)	# Load direction
	la	$a2, scratch	# Checking scratch maze
	addi	$sp, $sp, -4
 	sw	$ra, 0($sp)	# save current ra
	jal	check_front	# v0 = front symbol
	lw	$ra, 0($sp)	# load old ra
	addi	$sp, $sp, 4	# return stack pointer
	
	
	la	$t0, crumb_up
	lb	$t0, 0($t0)	# load crumb
	beq	$v0, $t0, turn
	
	la	$t0, crumb_right
	lb	$t0, 0($t0)	# load crumb
	beq	$v0, $t0, turn
	
	la	$t0, crumb_down
	lb	$t0, 0($t0)	# load crumb
	beq	$v0, $t0, turn
	
	la	$t0, crumb_left
	lb	$t0, 0($t0)	# load crumb
	beq	$v0, $t0, turn
	
	##### POSSE #####
#	li	$v0, P_STRING
#	la	$a0, pose_text
#	syscall
#	li	$v0, P_INT
#	la	$s5, pose
#	lw	$a0, 0($s5)
#	syscall
#	li	$v0, P_INT
#	la	$s5, pose
#	lw	$a0, 4($s5)
#	syscall
#	li	$v0, P_INT
#	la	$s5, pose
#	lb	$a0, 8($s5)
#	syscall
#	li	$v0, P_STRING
#	la	$a0, newline
#	syscall
	##### POSSE #####

	
	# Passed all tests, may proceed to step 4. Good luck warrior.
	
	# Increase next_t to next location
	la	$t0, next_t
	lw	$t1, 0($t0)	# load current turn tracker address
	addi	$t1, $t1, 1	# Add one to tracker address
	sw	$t1, 0($t0)	# Store it back

	j	step_4	

	# Step 3 B	
turn:
	la	$t0, next_t
	lw	$t0, 0($t0)	# Load turn tracker address
	lb	$t0, 0($t0)	# Load turn tracker
	li	$t1, 0
	beq	$t0, $t1, backtrack	# 4 turns done, backtrack!
	addi	$t0, $t0, 1	# Add 1 to change direction
	li	$t1, 4		# Load 4 to mod result by 4
	div	$t0, $t1
	mfhi	$t0		# t0 = (D + 1) % 4
	# Store new direction
	la	$t1, pose
	sb	$t0, 8($t1)
	# Decrease turn tracker
	la	$t0, next_t
	lw	$t0, 0($t0)	# load current turn tracker address
	lb	$t1, 0($t0)	# t0 = turn tracker
	addi	$t1, $t1, -1	# Subtract one from tracker
	sb	$t1, 0($t0)	# Store it back
	### TEST
	li	$v0, P_INT
	move	$a0, $t0
	syscall
	### TEST

	
	j	step_3

	# Step 3 C
backtrack:
	### TEST
	li	$v0, P_STRING
	la	$a0, bt_text
	syscall
	### TEST
	la	$t0, pose
	lw	$a0, 0($t0)	# Load x
	lw	$a1, 4($t0)	# Load y
	lb	$s7, 8($t0)	# Load current direction to be reapplied later
	la	$a2, scratch	
	# Get new location memory
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	coor_to_mem
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	# Get crumbs! v0 = current address
	lb	$s0, 0($v0)	# s0 = current crumb

	# Prepare arguments to move forward
	la	$t0, pose
	sb	$s0, 8($t0)	# Store new direction to go back	
	lw	$a0, 0($t0)	# Load x
	lw	$a1, 4($t0)	# Load y
	move	$a3, $s0	# Pass direction as parameter
	la	$a2, scratch	
	# Move forward
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	check_front
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
		# a0 (x) and a1 (y) changed accordingly
	la	$t0, pose
	sw	$a0, 0($t0)	# Store new x
	sw	$a1, 4($t0)	# Store new y
	sb	$s7, 8($t0)	# Restore default direction
	# Return turn tracker to previous byte location
	la	$t1, next_t
	lw	$t0, 0($t1)	# Load current turn tracker address
	addi	$t0, $t0, -1	# Decrease byte location by one.
	sw	$t0, 0($t1)	# Store new address in next_t
	
	j	step_3


step_4: 
	# Step 4: Move into space, drop bread crumb. 
	####### TEST ###
	#li	$v0, P_INT
	#li	$a0, 4
	#syscall
	######## TESTE ###
	la	$t0, pose
	lw	$a0, 0($t0)
	lw	$a1, 4($t0)
	lb	$a3, 8($t0)
	la	$a2, scratch

	addi	$sp, $sp, -4
 	sw	$ra, 0($sp)	# save current ra
	jal	check_front	# v0 = front symbol, but also a0 and a1 are modified
	lw	$ra, 0($sp)	# load old ra
	addi	$sp, $sp, 4	# return stack pointer

	la	$t0, pose
	sw	$a0, 0($t0)	# store x
	sw	$a1, 4($t0)	# store y
	# Facing remains the same

	##### POSSE #####
#	li	$v0, P_STRING
#	la	$a0, pose_text
#	syscall
#	li	$v0, P_INT
#	la	$s5, pose
#	lw	$a0, 0($s5)
#	syscall
#	li	$v0, P_INT
#	la	$s5, pose
#	lw	$a0, 4($s5)
#	syscall
#	li	$v0, P_INT
#	la	$s5, pose
#	lb	$a0, 8($s5)
#	syscall
#	li	$v0, P_STRING
#	la	$a0, newline
#	syscall
	##### POSSE #####


	la	$t1, pose
	lb	$t1, 8($t1)	# t1 = direction
	# Get appropiate crumb: stored in $s0
	li	$t2, UP
	bne	$t1, $t2, nc_up
	# If facing up
	la	$s0, crumb_up
	lb	$s0, 0($s0)	# loads crumb (comes from DOWN)
nc_up:

	li	$t2, RIGHT
	bne	$t1, $t2, nc_right
	# If facing right
	la	$s0, crumb_right
	lb	$s0, 0($s0)	# loads crumb (comes from LEFT)
nc_right:

	li	$t2, DOWN
	bne	$t1, $t2, nc_down
	# If facing down
	la	$s0, crumb_down
	lb	$s0, 0($s0)	# loads crumb (comes from UP)
nc_down:

	li	$t2, LEFT
	bne	$t1, $t2, nc_left
	# If facing right
	la	$s0, crumb_left
	lb	$s0, 0($s0)	# loads crumb (comes from RIGHT)
nc_left:

	# Store crumb
	la	$t0, pose
	lw	$a0, 0($t0)	# Load x
	lw	$a1, 4($t0)	# Load y
	la	$a2, scratch	
	# Get new location memory
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	coor_to_mem
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	# Store crumb in said location
	sb	$s0, 0($v0)

	####### TEST ###
	li	$v0, P_STRING
	la	$a0, newline
	syscall
	li	$v0, P_STRING
	la	$a0, scratch
	syscall
	######## TESTE ###


	j	step_2

		
step_5: 
	# Step 5: Exit found! Follow the trail!
	####### TEST ###
	#li	$v0, P_INT
	#li	$a0, 5
	#syscall
	######## TESTE ###

	la	$t0, pose
	lw	$a0, 0($t0)	# Load x
	lw	$a1, 4($t0)	# Load y
	la	$a2, scratch	
	# Get new location memory
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	coor_to_mem
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	# Get crumbs! v0 = current address
	lb	$s0, 0($v0)	# s0 = current crumb
	la	$s1, start
	lb	$s1, 0($s1)	# s1 = S
	beq	$s0, $s1, step_6	# DONE! Go to step 6

	# Set trail in this location on main map
	la	$t0, pose
	lw	$a0, 0($t0)	# x
	lw	$a1, 4($t0)	# y
	la	$a2, m_maze
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	coor_to_mem
	  # v0 = coor location
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	la	$t1, trail
	lb	$t1, 0($t1)	# t1 = '.'
	sb	$t1, 0($v0)	# Store

	# Prepare arguments to move forward
	la	$t0, pose
	sb	$s0, 8($t0)	# Store new direction to go back	
	lw	$a0, 0($t0)	# Load x
	lw	$a1, 4($t0)	# Load y
	move	$a3, $s0	# Pass direction as parameter
	la	$a2, scratch	
	# Move forward
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	check_front
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
		# a0 (x) and a1 (y) changed accordingly
	la	$t0, pose
	sw	$a0, 0($t0)	# Store new x
	sw	$a1, 4($t0)	# Store new y
	
	j	step_5
	
step_6:
	# Step 6
	####### TEST ###
	#li	$v0, P_INT
	#li	$a0, 6
	#syscall
	######## TESTE ###

	#set end back to 'E'
	la	$t0, end_loc
	lw	$a0, 0($t0)	#x
	lw	$a1, 4($t0)	#y
	la	$a2, m_maze
	addi	$sp, $sp, -4
 	sw	$ra, 0($sp)	# save current ra
	jal	coor_to_mem	# v0 = end_loc memory
	lw	$ra, 0($sp)	# load old ra
	addi	$sp, $sp, 4	# return stack pointer
	la	$t0, end	
	lb	$t0, 0($t0)	# t0 = 'E'
	sb	$t0, 0($v0)	
	# Print final result
	li	$v0, P_STRING
	la	$a0, m_maze
	syscall
	jr	$ra

	

#
# Name:		check_front
# Arguments:	a0 = x, a1 = y, a2 = m_maze/scratch address, a3 = facing
# Returns:	v0 = item in front ( #, , E, ., etc.)
# TESTED = WORKS
#
check_front:
	li	$t0, UP
	bne	$t0, $a3, not_up
	# if up
	addi	$a1, $a1, -1	# Decrease y
not_up:	

	li	$t0, RIGHT
	bne	$t0, $a3, not_right
	# if right
	addi	$a0, $a0, 1	# Increase x
not_right:

	li	$t0, DOWN
	bne	$t0, $a3, not_down
	# if down
	addi	$a1, $a1, 1	# Increase y
not_down:

	li	$t0, LEFT
	bne	$t0, $a3, not_left
	# if left
	addi	$a0, $a0, -1	# Decrease x
not_left:
	# Done modifying x and y

	addi	$sp, $sp, -4
 	sw	$ra, 0($sp)	# save current ra
	jal	coor_to_mem
	lw	$ra, 0($sp)	# load old ra
	addi	$sp, $sp, 4	# return stack pointer
	lb	$v0, 0($v0)	# Set return address to what it represents (#, , ., etc)
	
	jr	$ra

#
# Name:		bug
# Error: Invalid character, exit program. 
#
bug:
	la	$a0, bug_text
	li	$v0, P_STRING
	syscall
	


