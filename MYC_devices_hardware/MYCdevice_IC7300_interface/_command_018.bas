' IC7300 Command 180 - 19F
' 191129
'
180:
   Civ_cmd4 = &H06
   Gosub Civ_print4_1a0500
Return
181:
   Civ_cmd4 = &H07
   Gosub Hpf_lpf
Return
182:
   Civ_cmd4 = &H07
   Gosub Civ_print4_1a0500
Return
183:
   B_temp1 = 11
   Civ_cmd4 = &H08
   Gosub Civ_print_l_5_1a0500_bcd
Return
184:
   Civ_cmd4 = &H08
   Gosub Civ_print4_1a0500
Return
185:
   B_temp1 = 11
   Civ_cmd4 = &H09
   Gosub Civ_print_l_5_1a0500_bcd
Return
186:
   Civ_cmd4 = &H09
   Gosub Civ_print4_1a0500
Return
187:
   Civ_cmd4 = &H10
   Gosub Hpf_lpf
Return
188:
   Civ_cmd4 = &H10
   Gosub Civ_print4_1a0500
Return
189:
   Civ_cmd4 = &H11
   Gosub Hpf_lpf
Return
18A:
   Civ_cmd4 = &H11
   Gosub Civ_print4_1a0500
Return
18B:
   B_temp1 = 11
   Civ_cmd4 = &H12
   Gosub Civ_print_l_5_1a0500_bcd
Return
18C:
   Civ_cmd4 = &H12
   Gosub Civ_print4_1a0500
Return
18D:
   B_temp1 = 11
   Civ_cmd4 = &H13
   Gosub Civ_print_l_5_1a0500_bcd
Return
18E:
   Civ_cmd4 = &H13
   Gosub Civ_print4_1a0500
Return
18F:
   Civ_cmd4 = &H14
   Gosub Ssb_tx_bw
Return
190:
   Civ_cmd4 = &H14
   Gosub Civ_print4_1a0500
Return
191:
   Civ_cmd4 = &H15
   Gosub Ssb_tx_bw
Return
192:
   Civ_cmd4 = &H15
   Gosub Civ_print4_1a0500
Return
193:
   Civ_cmd4 = &H16
   Gosub Ssb_tx_bw
Return
194:
   Civ_cmd4 = &H16
   Gosub Civ_print4_1a0500
Return
195:
   B_temp1 = 10
   Civ_cmd4 = &H17
   Gosub Civ_print_l_5_1a0500_bcd:
Return
196:
   Civ_cmd4 = &H17
   Gosub Civ_print4_1a0500
Return
197:
   B_temp1 = 10
   Civ_cmd4 = &H18
   Gosub Civ_print_l_5_1a0500_bcd
Return
198:
   Civ_cmd4 = &H18
   Gosub Civ_print4_1a0500
Return
199:
   B_temp1 = 10
   Civ_cmd4 = &H19
   Gosub Civ_print_l_5_1a0500_bcd
Return
19A:
   Civ_cmd4 = &H19
   Gosub Civ_print4_1a0500
Return
19B:
   B_temp1 = 10
   Civ_cmd4 = &H20
   Gosub Civ_print_l_5_1a0500_bcd
Return
19C:
   Civ_cmd4 = &H20
   Gosub Civ_print4_1a0500
Return
19D:
   Civ_cmd4 = &H21
   Gosub Civ_print_255_6_1a0500_bcd
Return
19E:
   Civ_cmd4 = &H21
   Gosub Civ_print4_1a0500
Return
 19F:
   B_temp1 = 2
   Civ_cmd4 = &H22
   Gosub Civ_print_l_5_1a0500
Return