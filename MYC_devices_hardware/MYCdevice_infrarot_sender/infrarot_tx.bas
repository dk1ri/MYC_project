'name : infrarot_tx.bas
'Version V05.1, 20200614
'purpose : Programm to send RC5 Codes
'This Programm workes as I2C slave or serial interface
'Can be used with hardware rs232_i2c_interface Version V04.0 by DK1RI
'
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
' To run the compiler the directory comon_1,10 must be copied to the directory of this file!
'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'
'----------------------------------------------------
$include "common_1.10\_Introduction_master_copyright.bas"
'
'----------------------------------------------------
'
'Used Hardware:
' serial
' I2C
'-----------------------------------------------------
' Inputs / Outputs : see file __config.bas
'
'------------------------------------------------------
'Missing/errors:
'
'------------------------------------------------------
'
' Detailed description
'
'----------------------------------------------------
$regfile = "m88pdef.dat"
'$regfile = "m328pdef.dat"
$crystal = 20000000
'
'-----------------------------------------------------
$include "common_1.10\_Processor.bas"
'
'----------------------------------------------------
'
'1...128:
Const I2c_address = 10
Const No_of_announcelines =14
Const Tx_factor = 15
' For Test:15 (~ 10 seconds), real usage:2 (~ 1 second)
Const S_length = 32
'
'----------------------------------------------------
$include "__use.bas"
$include "common_1.10\_Constants_and_variables.bas"
'
' Specific  Constatns and Variables´
Dim Togglebit As Byte
Dim Rc5_adress As Byte
Dim Rc6_adress As Byte
Dim Rc5_byte As Byte
Dim Rc5_part As Byte
'
'----------------------------------------------------
$include "common_1.10\_Macros.bas"
'
'----------------------------------------------------
$include "common_1.10\_Config.bas"
'
'----------------------------------------------------
$include "common_1.10\_Main.bas"
'
'----------------------------------------------------
$include "common_1.10\_Loop_start.bas"
'
'----------------------------------------------------
'RS232 got data?
If New_data > 0 Then
   New_data = 0
   If Tx_write_pointer > 1 Then
      Command_pointer = 0
      Not_valid_at_this_time
   Else
      If no_myc = 1 Then
         If Command_b(1) = 32 Then
            'switch to myc mode again
             no_myc=0
             no_myc_eeram = no_myc
             Command_pointer = 0
         Else
            If Command_pointer >= 2 Then
               If Command_b(1) < 58 And Command_b(1) > 47 Then
                  Rc5_byte = Command_b(1) - 48
                  Rc5_byte = Rc5_byte * 10
                  If Command_b(2) < 58 And Command_b(2) > 47 Then
                     B_temp1 = Command_b(2) - 48
                     Rc5_byte = Rc5_byte + B_temp1
                     If Rc5_byte < 64 Then Rc5send Togglebit, Rc5_adress, Rc5_byte
                  End If
               End If
               Command_pointer = 0
            End If
         End If
      Else
         ' start Cmd_watchdog:
         If Cmd_watchdog = 0 Then Incr Cmd_watchdog
         If Command_b(1) = 254 Then
            Commandpointer = Command_pointer
            Gosub Commandparser
         Else
            If Serial_active = 1 And Command_mode = 1 Then
               Commandpointer = Command_pointer
               Gosub Commandparser
            Else
               If I2c_active = 1 And Command_mode = 2 Then
                  Commandpointer = Command_pointer
                  Gosub Commandparser
               Else
                  Command_pointer = 0
                  Not_valid_at_this_time
               End If
            End If
         End If
      End If
   End If
End If
'
Reset Watchdog                                           '
Goto Loop_
'
'----------------------------------------------------
'
' End Main start subs
'
'----------------------------------------------------
$include "common_1.10\_Reset.bas"
'
'----------------------------------------------------
$include "common_1.10\_Init.bas"
'
'----------------------------------------------------
$include "common_1.10\_Subs.bas"
'
'----------------------------------------------------
'
' ---> Specific subs
'
'----------------------------------------------------
$include "_Commands.bas"
$include "common_1.10\_Commands_required.bas"
'
$include "common_1.10\_Commandparser.bas"
'
'-----------------------------------------------------
' End
'
$include "_announcements.bas"
'