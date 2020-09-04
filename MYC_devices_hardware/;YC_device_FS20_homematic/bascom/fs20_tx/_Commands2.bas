' Commands2
' 200104
'
E9:
'Befehl &HE9
'Hauscode eingeben (8 byte 1 - 4)
'housecode (8 byte 1 to 4)
'Data "233;ka,housecode;1;8,{1 to 4}"
   If Commandpointer >= 9 Then
      W_temp1 = 0
      B_temp3 = 0
      For B_temp1 = 2 to 9
         B_temp2 = Command_b(B_temp1)
         If B_temp2 < 49 Or B_temp2 > 52 Then B_temp3 = 1
         ' Error
         B_temp2 = B_temp2 - 49
         ' 0 - 3
         W_temp1 = W_temp1 + B_temp2
         If B_temp1 <> 9 Then Shift W_temp1, Left, 2
      Next B_temp1
      If B_temp3 = 0 Then
         Housecode = W_temp1
         Housecode_eeram = Housecode
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
EA:
'Befehl &HEA
'Hauscode lesen (8 byte 1 - 4)
'read housecode (8 byte 1 to 4)
'Data "234;la,as233"
   Tx_time = 1
   Tx_b(1) = &HEA
   W_temp1 = Housecode
   For B_temp1 = 9 to 2 Step - 1
      B_temp2 = W_temp1 And &H0003
      Tx_b(B_temp1) = B_temp2 + 49
      Shift W_temp1, Right, 2
   Next B_temp1
   Tx_write_pointer = 10
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
EB:
'Befehl &HEB
'Adresse eingeben für Kanal 1 - 4 und set 0 - 9: 4 byte 0 - 3
'adress, for chanal 1 - 4 and set 0 - 9: 4 byte: 0 - 3
'Data "235;km,adress, chanal 1 - 4, 10 sets;1;4,{1 to 4};4,{1 to 4},chanal;10,set"
   If Commandpointer >= 6 Then
      If Command_b(2) < 40 Then
         B_temp4 = 0
         B_temp3 = 0
         For B_temp1 = 3 to 6
            B_temp2 = Command_b(B_temp1)
         If B_temp2 < 49 Or B_temp2 > 52 Then B_temp3 = 1
            ' Error
            B_temp2 = B_temp2 - 49
            ' 0 - 3
            B_temp4 = B_temp4 + B_temp2
            If B_temp1 <> 6 Then Shift B_temp4, Left, 2
         Next B_temp1
         If B_temp3 = 0 Then
            B_temp1 = Command_b(2) + 1
            Code4(B_temp1) = B_temp4
         Else
            Parameter_error
         End If
      Else
          Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
EC:
'Befehl &HEC
'Adresse lesen für Kanal 1 - 4 und set 0 - 9: 4 byte 0 - 3
'read adress, for chanal 1 - 4 and set 0 - 9  4 byte: 0 to 3
'Data "236;lm,as235"
   If Commandpointer >= 2 Then
      If Command_b(2) < 40 Then
         Tx_time = 1
         Tx_b(1) = &HEC
         Tx_b(2) = Command_b(2)
         B_temp1 = Command_b(2) + 1
         B_temp3 = Code4(B_temp1)
         For B_temp1 = 6 to 3 Step -1
            B_temp2 = B_temp3 And &B00000011
            Tx_b(B_temp1) = B_temp2 + 49
            Shift B_temp3, Right, 2
         Next B_temp1
         Tx_write_pointer = 7
         If Command_mode = 1 Then Gosub Print_tx
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
ED:
'Befehl &HED
'Adresse eingeben für Taste 1 - 8 und set 0 - 9: 4 byte 0 - 3
'adress,for Button 1 - 8 and set 0 - 9 4 byte: 0 to 3
'Data "237;km,adress, button 1 to 8 10 sets;1;4,{1 to 4};8,{1 to 8},chanal;10,set" "
   If Commandpointer >= 6 Then
      If Command_b(2) < 80 Then
         B_temp4 = 0
         B_temp3 = 0
         For B_temp1 = 3 to 6
            B_temp2 = Command_b(B_temp1)
         If B_temp2 < 49 Or B_temp2 > 52 Then B_temp3 = 1
            ' Error
            B_temp2 = B_temp2 - 49
            ' 0 - 3
            B_temp4 = B_temp4 + B_temp2
            If B_temp1 <> 6 Then Shift B_temp4, Left, 2
         Next B_temp1
         If B_temp3 = 0 Then
            B_temp1 = Command_b(2) + 1
            Code8(B_temp1) = B_temp4
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
EE:
'Befehl &HEE
'Adresse lesen für Taste 1 - 8 und set 0 - 9: 4 byte 0 - 3
'read adress,for Button 1 - 8 and set 0 -9  4 byte: 0 to 3
'Data "238;lm,as237"
   If Commandpointer >= 2 Then
      If Command_b(2) < 80 then
         Tx_time = 1
         Tx_b(1) = &HEE
         Tx_b(2) = Command_b(2)
         B_temp1 = Command_b(2) + 1
         B_temp3 = Code8(B_temp1)
         For B_temp1 = 6 to 3 Step -1
            B_temp2 = B_temp3 And &B00000011
            Tx_b(B_temp1) = B_temp2 + 49
            Shift B_temp3, Right, 2
         Next B_temp1
         Tx_write_pointer = 7
         If Command_mode = 1 Then Gosub Print_tx
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
EF:
'Befehl &HEF
'Hauscode konfigurieren
'configure housecode
'Data "239;ka,set housecode"
       Send_code(1) = 1
   Send_code(2) = 4
   Send_code(3) = T_modus
   W_temp1 = Housecode
   B_temp3 = 4
   For B_temp1 = 1 to 8
      B_temp2 = W_temp1 And &H0003
      Send_code(B_temp3) = B_temp2 + 1
      Shift W_temp1, Right, 2
      Incr B_temp3
      Send_code(B_temp3) = 0
      Incr B_temp3
      Send_code(B_temp3) = T_short
      Incr B_temp3
   Next B_temp1
   Codepointer = 1
   Codelength = 10
   Gosub Command_received
Return
'