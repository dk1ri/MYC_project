' Introduction
'1.7.0, 190512
'
'The Programm supports the MYC protocol
'Slave max length of I2C and  serial input string is 253 Bytes.
'Please modify clock frequency and processor type, if necessary
'
'When doing modifying, please check / modify:
' Const No_of_announcelines =
' Const Aline_length (also in F0 command)
' number of announcements in the 0 and 240 command announcements
' add lines in Sub_restore
' IC2 Adress in reset
' announcements
' check Const Tx_factor
'
'Developed with Bascom 2.08.1
'
'Fuse Bits :
'External Crystal, high frequency
'clock output disabled
'divide by 8 disabled
'JTAG Disabled (if applicable)
'
' For announcements and rules see Data section at the end      
'
'Master (termplate):
' 1.7
'
'copyright : DK1RI
'some parts are copied from Bascom Manual
'If no other rights are affected, this programm can be used
'under GPL (Gnu public licence)