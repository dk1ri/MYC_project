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
'Befehl &H01
'liest Temperatur
'read temperature
'Data "1;ap,read temperature;1;12500,{-40.00 to 84.99};lin;DegC"
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
'Befehl &H02
'liest Feuchtigkeit
'read humidity
'Data "2;ap,read humidity;1;100001,{0.000 to 100.000};lin;%"
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
'Befehl &H03
'liest Druck
'read pressure
'Data "3;ap,read pressure;1;1100001,{0.000 to 1100.000};lin;hPa"
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
'Befehl &H04 0 to 5
'schreibt Oversampling Feuchte
'write Oversampling humidity
'Data "4;oa,oversampling humidity;b,{0,1,2,4,8,16}"
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
'Befehl &H05
'liest Oversampling Feuchte
'read Oversampling humidity
'Data "5;aa,as4"
      Tx_time = 1
      Tx_b(1) = &H05
      Tx_b(2) = Reg_F2
      Tx_write_pointer = 3
      If Command_mode = 1 Then Gosub Print_tx
      Gosub Command_received
Return
'
06:
'Befehl &H06 0 to 5
'schreibt Oversampling Druck
'write Oversampling pressure
'Data "6;oa,oversampling pressure;b,{0,1,2,4,8,16}"
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
'Befehl &H07
'liest Oversampling Druck
'read Oversampling pressure
'Data "7;aa,as6"
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
'Befehl &H08
'schreibt Oversampling Temperatur
'write Oversampling Temperature
'Data "8;oa,oversampling Temperatur;b,{0,1,2,4,8,16}"
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
'Befehl &H09
'liest Oversampling Temperatur
'read Oversampling Temperatur
'Data "1;aa,as8"
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
'Befehl &H0A
'schreibt Pause Zeit
'write non active time
'Data "10;oa,non activ time;b,{0.5,62.5,125,500,1000,10,20},ms"
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
'Befehl &H0B
'liest Pause Zeit
'read non active time
'Data "11;aa,as10"
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
'Befehl &H0C
'schreibt Filter
'write Filter
'Data "12;oa,filter;b,{0,2,4,8,16}"
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
'Befehl &H0D
'liest Filter
'read Filter
'Data "13;aa,as12"
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
'Befehl &H0E
'liest ID
'read ID
'Data "14;aa,read ID;b"
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
'Befehl &H0F
'Reset
'Reset
'Data "15;ot,reset;0"
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