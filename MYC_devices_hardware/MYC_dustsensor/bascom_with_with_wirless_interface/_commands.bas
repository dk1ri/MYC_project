' Commands
' 20250731
'
00:
Tx_time = 1
   A_line = 0
   Number_of_lines = 1
   Send_line_gaps = 2
   Gosub Sub_restore
   Gosub Print_tx
   Gosub Command_received
Return

'
01:
   Gosub Send_memory_content
Return
'
02:
   Gosub Send_memory_content
Return
'
03:
   Gosub Send_memory_content
Return
'
04:
   Gosub Send_memory_content
Return
'
05:
   Gosub Send_memory_content
Return
'
06:
   Gosub Send_memory_content
Return
'
07:
   Gosub Send_memory_content
Return
'
08:
   Gosub Send_memory_content
Return
'
09:
   Gosub Send_memory_content
Return
'
10:

   Gosub Send_memory_content
Return
'
11:
   Tx_b(1) = &H0B
   Tx_b(2) = High(Memory_pointer)
   Tx_b(3) = Low(Memory_pointer)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'

12:
   'start stop
   If Commandpointer >= 2 Then
      If Command_b(3) < 2 Then
         Temps_b(1) = &H7E
         Temps_b(2) = &H00
         If Command_b(2) = 1 Then
            Temps_b(3) = &H00
            Temps_b(4) = &H02
            Temps_b(5) = &H01
            ' 16 bit unsigned
            Temps_b(6) = &H05
            Temps_b(7) = &HF7
            Temps_b(8) = &H7E
            Send_len = 8
            M_timer = 0
            Rx_started = 1
         Else
            Temps_b(3) = &H01
            Temps_b(4) = &H00
            Temps_b(5) = &HFE
            Temps_b(6) = &H7E
            Send_len = 6
            Rx_started = 0
            Gosub Clear_memory
         End If
         Gosub Send_data
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
13:
   If Commandpointer >= 2 Then
      If Command_b(2) < 7 Then
         Measure_time = Command_b(2)
         Select Case Measure_time
            Case 0
               ' 3s
               M_time = 1
            Case 1
               ' 10 s
               M_time = 3
            Case 2
               ' 30 s
               M_time = 9
            Case 3
               ' 1 min
               M_time = 18
            Case 4
               ' 10 min
               M_time = 180
            Case 5
               ' 30 min
               M_time = 540
            Case 6
               ' 60 min
               M_time = 1080
         End select
         Measure_time_eeram = Measure_time
         M_time_eeram = M_time
         Gosub Clear_memory
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
14:
   Tx_b(1) = &H0E
   Tx_b(2) = Measure_time
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'
15:
   If Commandpointer >= 4 Then
      D_temp1_b(4) = 0
      D_temp1_b(3) = Command_b(2)
      D_temp1_b(2) = Command_b(3)
      D_temp1_b(1) = Command_b(4)
      If D_temp1 < 700001 Then
         Cleaning_intervall = D_temp1
         Temps_b(1) = &H7E
         Temps_b(2) = &H00
         Temps_b(3) = &H80
         Temps_b(4) = &H05
         Temps_b(5) = &H00
         Temps_b(6) = &H00
         Stuffing_pointer = 7
         Temps_b(Stuffing_pointer) = Command_b(2)
         Gosub Byte_stuffing_send
         Temps_b(Stuffing_pointer) = Command_b(3)
         Gosub Byte_stuffing_send
         Temps_b(Stuffing_pointer) = Command_b(4)
         Gosub Byte_stuffing_send
         Sum = 133 + Command_b(2)
         Sum = Sum + Command_b(3)
         Sum = Sum + Command_b(4)
         Sum = Sum + Command_b(5)
         B_temp1 = Low(Sum)
         Temps_b(Stuffing_pointer) = &HFF - B_temp1
         Incr Stuffing_pointer
         Temps_b(Stuffing_pointer) = &H7E
         Send_len = Stuffing_pointer
         Gosub Send_data
      Else
         Parameter_error
      End If
   End If
Return
'
16:
   Tx_b(1) = &H1A
   Tx_b(2) = Cleaning_intervall_b(3)
   Tx_b(3) = Cleaning_intervall_b(2)
   Tx_b(4) = Cleaning_intervall_b(1)
   Tx_write_pointer = 5
   Gosub Print_tx
   Gosub Command_received
Return
'
17:
   Temps_b(1) = &H7E
   Temps_b(2) = &H00
   Temps_b(3) = &H56
   Temps_b(4) = &H00
   Temps_b(5) = &HA9
   Temps_b(6) = &H7E
   Send_len = 6
   Gosub Send_data
Return
'
18:
   Temps_b(1) = &H7E
   Temps_b(2) = &H00
   Temps_b(3) = &HD0
   Temps_b(4) = &H01
   Temps_b(5) = &H00
   Temps_b(6) = &H2E
   Temps_b(7) = &H7E
   Send_len = 7
   Gosub Send_data
Return
'
19:
   Temps_b(1) = &H7E
   Temps_b(2) = &H00
   Temps_b(3) = &HD0
   Temps_b(4) = &H01
   Temps_b(5) = &H03
   Temps_b(6) = &H2B
   Temps_b(7) = &H7E
   Send_len = 7
   Gosub Send_data
Return
'
20:
   Temps_b(1) = &H7E
   Temps_b(2) = &H00
   Temps_b(3) = &HD1
   Temps_b(4) = &H00
   Temps_b(5) = &H2E
   Temps_b(6) = &H7E
   Send_len = 6
   Gosub Send_data
Return
'
21:
   Temps_b(1) = &H7E
   Temps_b(2) = &H00
   Temps_b(3) = &HD3
   Temps_b(4) = &H00
   Temps_b(5) = &H2C
   Temps_b(6) = &H7E
   Send_len = 6
   Gosub Send_data
Gosub Clear_memory
Return
'
22:
   Temps_b(1) = &H7E
   Temps_b(2) = &H00
   Temps_b(3) = &HD2
   Temps_b(4) = &H01
   Temps_b(5) = &H00
   Temps_b(6) = &H2C
   Temps_b(7) = &H7E
   Send_len = 7
   Gosub Send_data
Return
'