# Motherboard Internship hosted by SJSU
This internship has the purpose of revamping SJSU's CMPE 127 lab, Microprocessor Design I.
Last semester, this class became notorious for having a grueling lab. So this summer, SJSU's CMPE department is sponsoring an internship hosted by Khalil Estell (kammce) to help improve the lab portion of this class, both academically and with respect to cost. 

Previously, CMPE 127's lab consisted of treating a microcontroller (LPC1758) as a processor and using it's GPIO pins to simulate a shared bus architecture. From there, we created state machines and interfaced with 2 SRAMs, a keypad, and a parallel LCD screen. However, completing this lab required us students to physically wire wrap each individual pin on all of the ICs which was proven to be quite tedious and troublesome. With over 25 ICs each with anywhere from 14-32 pins, wrapping the system together was a nightmare.

This, along with a few other reasons, is why we decided to update this lab. Us interns are tasked with creating a new Verilog project that could replace it. We were given a MIPS processor module, which we then create the system architecture and assembly code to interface with two PMOD devices. For my Project, I have chosen a rotary encoder input and 8 high-brightness LEDs as an output device to create a dial-controlled flashlight. As the rotary encoder is turned, the LEDs turn on/off as the encoded signal changes.

The overall system architecture can be seen here:

![dial controlled flashlight - system design](https://user-images.githubusercontent.com/32377973/42720616-1901921c-86df-11e8-9509-b7674d97b286.jpg)
