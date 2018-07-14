# 16384 - Quadrature Decoder Address
# 18432 - LED Register Address
# 2730 	- Arbitrary RAM Address\
# $t0   - contains current decoder value
# $t1   - contains previous decoder value
# $t2   - contains current LED register value
# $t3   - contains the change in decoder values
main:
	li $t0, 0			#Initialize $t0 to zero
	li $t1, 0			#Initialize $t1 to zero
	li $t2, 0			#Initialize $t2 to zero	
					#fall through to readEncoder	
						#may need to initialize Decoder module by writing to it first???				

readEncoder:
	lw  $t0, 16384($t0)		#read decoder value
	beq $t0, $t1, readEncoder	#continue reading if no change
	
	bgt $t0, 8, readEncoder		#check for overflow
	blt $t0, 0, readEncoder		#check for underflow
	
updateLed:
	sub $t3, $t0, $t1		#calculate the change in decoder value
	add $t2, $t2, $t3		#update led register
	sw $t2, 18432($t0)		#update physical LEDs
	move $t1, $t0			#update previous decoder value
	j readEncoder			#Resume checking Decoder
