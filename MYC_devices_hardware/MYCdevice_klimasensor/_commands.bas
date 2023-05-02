' Commands
' 20200504
'
00:
   Tx_time = 1
   A_line = 0
   Number_of_lines = 1
   Send_line_gaps = 2
   Gosub Sub_restore
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
01:
      Tx_time = 1
      Tx_b(1) = &H01
      Tx_b(2) = Temperature_b(2)
      Tx_b(3) = Temperature_b(1)
      Tx_write_pointer = 4
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
02:
      Tx_time = 1
      Tx_b(1) = &H02
      Tx_b(2) = Humidity_b(3)
      Tx_b(3) = Humidity_b(2)
      Tx_b(4) = Humidity_b(1)
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
03:
      Tx_time = 1
      Tx_b(1) = &H03
      Tx_b(2) = Pressure_b(3)
      Tx_b(3) = Pressure_b(2)
      Tx_b(4) = Pressure_b(1)
      Tx_write_pointer = 5
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
04:
      If Commandpointer = 2 Then
         If Command_b(2) < 6 Then
            Reg_F2 = Command_b(2)
            Reg_F2_eeram = Reg_F2
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
Return
'
05:
      Tx_time = 1
      Tx_b(1) = &H05
      Tx_b(2) = Reg_F2
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
06:
       If Commandpointer >= 2 Then
         If Command_b(2) < 6 Then
            Shift Command_b(2), Left, 2
            Reg_F4 = Reg_F4 And &B11100011
            Reg_F4 = Reg_F4 Or Command_b(2)
            Reg_F4_eeram = Reg_F4
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
Return
'
07:
      Tx_time = 1
      Tx_b(1) = &H07
      B_temp1 = Reg_F4
      B_temp1 = B_temp1 And &B00011100
      Shift B_temp1, Right, 2
      Tx_b(2) = B_temp1
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
08:
      If Commandpointer >= 2 Then
         If Command_b(2) < 6 Then
            Shift Command_b(2), Left, 5
            Reg_F4 = Reg_F4 And &B00011111
            Reg_F4 = Reg_F4 Or Command_b(2)
            Reg_F4_eeram = Reg_F4
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
Return
'
09:
      Tx_time = 1
      Tx_b(1) = &H09
      B_temp1 = Reg_F4
      B_temp1 = B_temp1 AND &B11100000
      Shift B_temp1, Right, 5
      Tx_b(2) = B_temp1
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
0A:
      If Commandpointer = 2 Then
         If Command_b(2) < 8 Then
            Shift Command_b(2), Left, 5
            Reg_F5 = Reg_F5 And &B00011111
            Reg_F5 = Reg_F5 Or Command_b(2)
            Reg_F5_eeram = Reg_F5
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
Return
'
0B:
      Tx_time = 1
      Tx_b(1) = &H0B
      B_temp1 = Reg_F5
      B_temp1 = B_temp1 And &B11100000
      Shift B_temp1, Right, 5
      Tx_b(2) = B_temp1
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
0C:
      If Commandpointer = 2 Then
         If Command_b(2) < 5 Then
            Shift Command_b(2), Left, 2
            Reg_F5 = Reg_F5 And &B11100011
            Reg_F5 = Reg_F5 OR Command_b(2)
            Reg_F5_eeram = Reg_F5
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
Return
'
0D:
      Tx_time = 1
      Tx_b(1) = &H0D
      B_temp1 = Reg_F5
      B_temp1 = B_temp1 And &B00011100
      Shift B_temp1, Right, 2
      Tx_b(2) = B_temp1
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
0E:
      Spi_buffer(1) = &HD0
      Reset Spi_cs
      Spiout Spi_buffer(1) , 1
      Spiin Spi_buffer_in(1) , 1
      Set Spi_cs
      Tx_time = 1
      Tx_b(1) = &H0E
      Tx_b(2) = Spi_buffer_in(1)
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
0F:
      Stop Watchdog
      Spi_buffer(1) = &H60
      'E0 MSB reset for write -> 60
      Reset Spi_cs
      Spi_buffer(2) = &HB6
      Spiout Spi_buffer(1) , 2
      Set Spi_cs
      Reg_F2_eeram = Reg_F2_default
      Reg_F4_eeram = Reg_F4_default
      Reg_F5_eeram = Reg_F5_default
      Reg_F2 = Reg_F2_eeram
      Reg_F4 = Reg_F4_eeram
      Reg_F5 = Reg_F5_eeram
      'to start BM280
      Gosub Start_BM280
      Gosub Write_config
      Gosub Read_correction
      Start Watchdog
      Gosub Command_received
Return
'