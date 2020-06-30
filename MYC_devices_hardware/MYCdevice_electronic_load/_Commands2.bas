' commands
' 201002
'
E3:
'Befehl &HE3; 3 byte / -
'Maximale Leistung pro Fet
'maximum power per FET
'Data "227;kp;maximum power per FET;1;150001,15000.{0 to 150,000};lin;Watt"
   If Commandpointer >= 4 Then
      Temp_dw = 0
      Temp_dw_b1 = command_b(4)
      'low byte first
      Temp_dw_b2 = command_b(3)
      Temp_dw_b3 = command_b(2)
      Temp_single = Temp_dw / 1000
      ' W
      If Temp_single <= 150000 Then
         Max_power = Temp_single
         Max_power_eeram = Max_power
         Gosub Reset_load
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
E4:
'Befehl &HE4 0 to 6 , 0 to 4095; 4 byte / -
'Fet control register einstellen
'set fet control register
'Data "228;km,set fet control register;6;w,{0 To 4095}"
   If Commandpointer >= 4 Then
      If Command_b(2) < 7 Then
         W_temp1 = Command_b(3) * 256
         W_temp1 = W_temp1 + Command_b(4)
         If W_temp1 <= Da_resolution Then
            Gosub Is_fet_active
            If Error_req = 0 Then
               Gosub Reset_load
               Fet_number = Command_b(2) + 1
               Dac_out_voltage(Fet_number) = W_temp1
               Gosub Send_to_fet
               El_mode = 5
            Else
               Fet_not_active
            End If
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
E5:
'Befehl &HE5; 2 byte / 4 byte
'Fet control register lesen
'read fet control register
'Data "229; lm,as228"
   If Commandpointer >= 2 Then
      If Command_b(2) < 7 Then
         Gosub Is_fet_active
         If Error_req = 0 Then
            Tx_time = 1
            Tx_b(1) = &HE5
            Tx_b(2) = Command_b(2)
            B_temp1 = Command_b(2) + 1
            Tx_b(3) = High(Dac_out_voltage(B_temp1))
            Tx_b(4) = Low(Dac_out_voltage(B_temp1))
            Tx_write_pointer = 5
            If Command_mode = 1 Then Gosub Print_tx
         Else
            Fet_not_active
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
E6:
'Befehl &HE6 0 to 90000; 4 byte / -
'Spannung für Spannungseichung schreiben
'write voltage for voltage calibration
'Data "230;ap,calibration voltage;1;70001,{20000 To 90000};lin:mV"
   If Commandpointer >= 4 Then
      Temp_dw_b1 = command_b(4)
      'low byte first
      Temp_dw_b2 = command_b(3)
      Temp_dw_b3 = command_b(2)
      Temp_dw_b4 = 0
       'mV
      If Temp_dw < 70000 Then
         Temp_dw = Temp_dw + 20000
         Temp_single = Temp_dw
         Calibrate_u = Temp_single / 1000
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
E7:
'Befehl &HE7; 1 byte / 4 byte
'Spannung für Spannungseichung lesen
'read voltage for calibration
'Data "231;la,as230"
   Temp_single = Calibrate_u
   Temp_single = Temp_single * 1000
   Temp_single = Temp_single - 20000
   Temp_dw = Temp_single
   Tx_time = 1
   Tx_b(1) = &HE7
   Tx_b(2) = Temp_dw_b3
   Tx_b(3) = Temp_dw_b2
   Tx_b(4) = Temp_dw_b1
   Tx_write_pointer = 5
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
E8:
'Befehl &HE8; 1 byte / -
'Spannung eichen
'calibrate Voltage
'Data "232;ku,calibrate voltage;1;0,,idle;1 calibrate voltage"
   If Voltage > Minimum_voltage Then
      Gosub Reset_load
      El_mode = 6
      Gosub Next_fet_to_use
   Else
      Voltage_too_low
   End If
   Gosub Command_received
Return
'
E9:
'Befehl &HE9:1 byte / 2 byte
'Spannungseichung lesen
'read voltage calibration
'Data "234;lp,read voltage calibration;1;4000,{0.8000 To 1.2000};lin;-" :
   Tx_time = 1
   Temp_single = Correction_u + 0.2
   Temp_single =  Correction_u * 10000
   Temp_single = Temp_single - 8000
   If Temp_single < 0 Then Temp_single = 0
   Temp_w = Temp_single
   Tx_b(1) = &HE9
   Tx_b(2) = High(Temp_w)
   Tx_b(3) = Low(Temp_w)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
EA:
'Befehl &HEA 0 to 30000; 3 byte / -
'Strom für Stromeichung schreiben
'write current for current calibration
'Data "234;op,current for calibration;1;20001,{2000 To 22000};lin:mA"
   If Commandpointer >= 3 Then
      Temp_w = Command_b(2) * 256
      Temp_w = Temp_w + Command_b(3)
      If Temp_w < 20000 Then
         Temp_w = Temp_w + 2000
         Temp_single = Temp_w
         Calibrate_i = Temp_single / 1000
         ' Ampere
      Else
         Calibrate_current_too_low
      End If
      Gosub Command_received
   End If
Return
'
EB:
'Befehl &HEB; 1 byte / 3 byte
'Strom für Stromeichung lesen
'read current for calibration
'Data "235;ap,as234"
   Temp_single =  Calibrate_i * 1000
   Temp_w = Temp_single
   Temp_w = Temp_w - 2000
   Tx_time = 1
   Tx_b(1) = &HEB
   Tx_b(2) = High(Temp_w)
   Tx_b(3) = Low(Temp_w)
   Tx_write_pointer = 4
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
EC:
'Befehl &HEC 0 - 6 ; 2 byte / -
'Fet kurzschliessen
'shorten FET
'Data "236;ku,shorten Fet;0,FET1;1,FET2;2,FET3;3FET4;4,FET5;5,FET6;6,FET7"
   If Commandpointer >= 2 Then
      If Command_b(2) < 7 Then
         Gosub Reset_load
         Gosub Is_fet_active
         If Error_req = 0 Then
            Fet_number = Command_b(2) + 1
            Dac_out_voltage(Fet_number) = 0
            Gosub Send_to_fet
            El_mode = 5
            Gosub Next_fet_to_use
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
ED:
'Befehl &HED 0 - 6 ; 2 byte / -
'Strom eichen
'calibrate Current
'Data "236;ku,calibrate current;0,FET1;1,FET2;2,FET3;3FET4;4,FET5;5,FET6;6,FET7"
   If Commandpointer >= 2 Then
      If Command_b(2) < 7 Then
         Gosub Is_fet_active
         If Error_req = 0 Then
            Fet_number = Command_b(2) + 1
            El_mode = 7
         Else
            Fet_not_active
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
EE:
'Befehl &HEE; 2 byte / 4 byte
'Stromeichung lesen
'read current calibration
'Data "237;lp,read current calibration;7;4000,{0.8000 To 1.2000};lin;-" :
   If Commandpointer >= 2 Then
      If Command_b(2) < 7 Then
         Tx_time = 1
         B_temp1 = Command_b(2) + 1
         Temp_single = Correction_i(B_temp1)
         Temp_single = Temp_single * 10000
         Temp_single =Temp_single - 8000
         If Temp_single < 0 Then Temp_single = 0
         Temp_w = Temp_single
         Tx_b(1) = &HEE
         Tx_b(2) = Command_b(2)
         Tx_b(3) = High(Temp_w)
         Tx_b(4) = Low(Temp_w)
         Tx_write_pointer = 5
         If Command_mode = 1 Then Gosub Print_tx
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return