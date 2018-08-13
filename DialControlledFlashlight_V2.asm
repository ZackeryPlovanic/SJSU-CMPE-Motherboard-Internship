# The 3 least significant bits read from the decoder represent the Duty cycle that is to be sent the corresponding PWM Driver.
# The specific Diver that is going to be written to is determined by the next 3 significant bits

# ******* Module Addresses *****
# Driver0 - 16384
# Driver1 - 16512
# Driver2 - 16640
# Driver3 - 16768
# Driver4 - 16896
# Driver5 - 17024
# Driver6 - 17152
# Driver7 - 17280
# Quad Decoder - 17408
# Frequency Register - 17536

# $t0   - contains current decoder value
# $t1   - contains previous decoder value
# a1	- contains PWM value to be sent to a Driver

main:
	li $t0, 0x01
	sw $t0, 17536($0)		#set PWM frequency
	li $t0, 0			#Initialize $t0 to zero
	li $t1, 0			#Initialize $t1 to zero
	li $t2, 0			#Initialize $t2 to zero	 
					#fall through to readEncoder	

readDecoder:
	lw  $t0, 17408 			#read decoder value
	beq $t0, $t1, readDecoder	#continue reading if no change
	bgt $t0, 63, readDecoder	#check for overflow
	blt $t0, 0, readDecoder		#check for underflow
	
	# Extend 3 bits from Decoder into an 8 bit duty cycle to send to the proper driver
	andi $a1, $t0, 0x7
	sll $a1, $a1, 0x5
	ori $a1, $a1, 0x1f
	move $t1, $t0			#update previous decoder value
	
setDriver7:
	blt $t0, 56, setDriver6		#if below Driver7 range, jump to check subsequent ranges
	sw $a1, 17280($0)		#else, its in Driver7 range so update pwm
	j readDecoder

setDriver6:
	blt $t0, 48, setDriver5		#if below Driver6 range, jump to check subsequent ranges
	sw $a1, 17152($0)		#else, its in Driver6 range so update pwm
	j readDecoder
	
setDriver5:
	blt $t0, 40, setDriver4		#if below Driver5 range, jump to check subsequent ranges
	sw $a1, 17024($0)		#else, its in Driver5 range so update pwm
	j readDecoder

setDriver4:
	blt $t0, 32, setDriver3		#if below Driver4 range, jump to check subsequent ranges
	sw $a1, 16896($0)		#else, its in Driver4 range so update pwm
	j readDecoder

setDriver3:
	blt $t0, 24, setDriver2		#if below Driver3 range, jump to check subsequent ranges
	sw $a1, 16768($0)		#else, its in Driver3 range so update pwm
	j readDecoder

setDriver2:
	blt $t0, 16, setDriver1		#if below Driver2 range, jump to check subsequent ranges
	sw $a1, 16640($0)		#else, its in Driver2 range so update pwm
	j readDecoder
	
setDriver1:
	blt $t0, 9, setDriver0		#if below Driver1 range, jump to check subsequent ranges
	sw $a1, 16512($0)		#else, its in Driver1 range so update pwm
	j readDecoder

setDriver0:
	sw $a1, 16384($0)
	j readDecoder
	
