' Introduction
' 20200730
'
' This programm supports the MYC protocol
' Slave max length of I2C and  serial input string is 253 Bytes.
' Please modify clock frequency and processor type, if necessary
' The Input (serial and I2C) uses interupt
'
' When doing modifying, please check / modify:
' Const No_of_announcelines =
' number of announcements in the 0 and 240 command announcements
' Const I2c_address =
' check Const Tx_factor =
' check all files in the prgramm directory
'
' Developed with Bascom 2.08.2
'
' Fuse Bits :
' External Crystal, high frequency
' clock output disabled
' divide by 8 disabled
' JTAG Disabled (if applicable)
'
' Master (template):
' 1.11
'
' copyright : DK1RI
' some parts are copied from Bascom Manual
' If no other rights are affected, this programm can be used
' under GPLV3 (Gnu public licence)