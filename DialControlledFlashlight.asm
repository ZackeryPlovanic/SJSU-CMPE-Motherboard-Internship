# 16384 - Quadrature Decoder Address
# 18432 - LED Register Address
# 2730 	- Arbitrary RAM Address
# $t1   - contains current LED register value
main:
	li  $t1, 0			#Initialize $t1 to zero	
					#fall through to readEncoder					

readEncoder:
	lw  $t0, 16384			#read decoder value
	beq $t0, $t1, readEncoder	#continue reading of no change
					#if change, fall through to updateLED

updateLed:
	move $t1, $t0		#update led register
	sw $t1, 18432		#update physical LEDs
	j readEncoder		#Resume checking Decoder