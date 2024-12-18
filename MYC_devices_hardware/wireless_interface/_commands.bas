' Commands
' 20241210
'
00:
Return
'
EB:
   If Myc_mode = 1 Then
      Tx_time = 1
      Tx_b(1) = &HEB
      Tx_b(2) = Myc_mode
      Tx_write_pointer = 3
      Gosub Print_tx
      Gosub Command_received
   End If
Return
'
EC:
   If Myc_mode = 1 And wireless_active = 0 Then
      If Commandpointer >= 2 Then
         If Command_b(2) < 2 Then
            Enable_switch_over = Command_b(2)
            Enable_switch_over_eram = Command_b(2)
            B_temp1 = Command_b(2) + 2
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
   Else
      Parameter_error
      Gosub Command_received
   End If
Return
'
ED:
   If Myc_mode = 1 Then
      Tx_time = 1
      Tx_b(1) = &HED
      Tx_b(2) = Enable_switch_over
      Tx_write_pointer = 3
      Gosub Print_tx
      Gosub Command_received
   End If
Return
'
EE:
   If Myc_mode = 1 Then
      Tx_time = 1
      Tx_b(1) = &H0E
      Tx_b(2) = Radiotype
      Tx_write_pointer = 3
      Gosub Print_tx
      Gosub Command_received
   End If
Return
'
EF:
   If Myc_mode = 1 Then
      Tx_time = 1
      Tx_b(1) = &HEF
      Tx_b(2) = len(Radio_name)
      B_temp2 = 3
      For B_temp1 = 1 to Tx_b(2)
          Tx_b(B_temp2) = Tx_b(B_temp1)
          Incr B_temp2
      Next B_temp1
      Tx_write_pointer = B_temp2
      Gosub Print_tx
      Gosub Command_received
   End If
Return
'
F8:
   If Myc_mode = 1 Then
      'server
      If Commandpointer >= 2 Then
         If Command_b(2) = 0 Then
            If wireless_active = 0 Then
               'Switch to transparent mode, server only
               Myc_mode = 0
            Else
               Parameter_error
            End If
            Gosub Command_received
         Else
            If Command_b(2) <= Name_len Then
               ' change name
               B_temp1 = Command_b(2)
               If Commandpointer >= B_temp1 Then
                  Radio_name = String(4,&H878) ' "x"
                  B_temp2 = 1
                  For B_temp1 = 3 to Commandpointer
                     Radio_name_b(B_temp2) = Command_b(B_temp1)
                     B_temp2 = B_temp2 + 1
                  Next B_temp1
                  #IF RadioType = 2
                     Gosub Write_id
                  #EndIF
                  Radio_name_eram = Radio_name
                  Gosub Command_received
               Else
                  Parameter_error
                  Gosub Command_received
               End If
            Else
               Parameter_error
               Gosub Command_received
            End If
         End If
      End If
   End If
Return
'