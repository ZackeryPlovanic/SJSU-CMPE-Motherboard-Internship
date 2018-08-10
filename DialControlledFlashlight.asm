# 16384 - Quadrature Decoder Address
# 18432 - LED Register Address
# $a0   - contains current decoder value
# $a1   - contains previous decoder value
# $a2   - contains current LED register value
# $a3   - contains the change in decoder values
main:
	li $a0, 0			#Initialize $a0 to zero
	li $a1, 0			#Initialize $a1 to zero
	li $a2, 0			#Initialize $a2 to zero	
					#fall through to readEncoder	

readEncoder:
	lw  $a0, 16384($0)		#read decoder value
	beq $a0, $a1, readEncoder	#continue reading if no change
	bgt $a0, 255, readEncoder	#check for overflow
	blt $a0, 0, readEncoder		#check for underflow

	bgt $t0, 8, readEncoder		#check for overflow
	blt $t0, 0, readEncoder		#check for underflow
	
		#update the LED values
	sub $t3, $t0, $t1		#calculate the change in decoder value
	add $t2, $t2, $t3		#update led register
	sw $t2, 18432($t0)		#update physical LEDs
	move $t1, $t0			#update previous decoder value
	j readEncoder			#Resume checking Decoder

