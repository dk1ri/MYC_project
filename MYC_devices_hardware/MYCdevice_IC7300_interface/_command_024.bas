' IC7300 Command 240 - 25F
' 191129
 '
240:
   Civ_cmd4 = &H02
   Gosub Civ_print_l_5_1a0501
Return
241:
   B_temp1 = 2
   Civ_cmd4 = &H03
   Gosub Civ_print_l_5_1a0501
Return
242:
   Civ_cmd4 = &H03
   Gosub Civ_print_l_5_1a0501
Return
243:
   Civ_cmd4 = &H04
   Gosub Spectrum
Return
244:
   Civ_cmd4 = &H04
   Gosub Civ_print_l_5_1a0501
Return
245:
   Civ_cmd4 = &H05
   Gosub Spectrum
Return
246:
   Civ_cmd4 = &H05
   Gosub Civ_print_l_5_1a0501
Return
247:
   Civ_cmd4 = &H06
   Gosub Spectrum
Return
248:
   Civ_cmd4 = &H06
   Gosub Civ_print_l_5_1a0501
Return
249:
   B_temp1 = 2
   Civ_cmd4 = &H07
   Gosub Civ_print_l_5_1a0501
Return
24A:
   Civ_cmd4 = &H07
   Gosub Civ_print_l_5_1a0501
Return
24B:
   B_temp1 = 3
   Civ_cmd4 = &H08
   Gosub Civ_print_l_5_1a0501
Return
24C:
   Civ_cmd4 = &H08
   Gosub Civ_print_l_5_1a0501
Return
24D:
   B_temp1 = 3
   Civ_cmd4 = &H09
   Gosub Civ_print_l_5_1a0501
Return
24E:
   Civ_cmd4 = &H09
   Gosub Civ_print_l_5_1a0501
Return
24F:
   B_temp1 = 8
   Civ_cmd4 = &H10
   Gosub Civ_print_l_5_1a0501
Return
250:
   Civ_cmd4 = &H10
   Gosub Civ_print_l_5_1a0501
Return
251:
   B_temp1 = 2
   Civ_cmd4 = &H11
   Gosub Civ_print_l_5_1a0501
Return
252:
   Civ_cmd4 = &H11
   Gosub Civ_print_l_5_1a0501
Return
253:
   F_offset = 30
   D_temp1 = 1600
   Civ_cmd4 = &H12
   Gosub S_scope_edge
Return
254:
   B_temp1 = 3
   Civ_cmd4 = &H12
   Gosub Civ_print_l_5_1a0501_answer1
Return
255:
   F_offset = 1600
   D_temp1 = 2000
   Civ_cmd4 = &H15
   Gosub S_scope_edge
Return
256:
   B_temp1 = 3
   Civ_cmd4 = &H15
   Gosub Civ_print_l_5_1a0501_answer1
Return
257:
   F_offset = 2000
   D_temp1 = 6000
   Civ_cmd4 = &H18
   Gosub S_scope_edge
Return
258:
   B_temp1 = 3
   Civ_cmd4 = &H18
   Gosub Civ_print_l_5_1a0501_answer1
Return
259:
   F_offset = 6000
   D_temp1 = 8000
   Civ_cmd4 = &H21
   Gosub S_scope_edge
Return
25A:
   B_temp1 = 3
   Civ_cmd4 = &H21
   Gosub Civ_print_l_5_1a0501_answer1
Return
25B:
   F_offset = 8000
   D_temp1 = 11000
   Civ_cmd4 = &H24
   Gosub S_scope_edge
Return
25C:
   B_temp1 = 3
   Civ_cmd4 = &H24
   Gosub Civ_print_l_5_1a0501_answer1
Return
25D:
   F_offset = 11000
   D_temp1 = 15000
   Civ_cmd4 = &H27
   Gosub S_scope_edge
Return
25E:
   B_temp1 = 3  
   Civ_cmd4 = &H27
   Gosub Civ_print_l_5_1a0501_answer1
Return
25F:
   F_offset = 15000
   D_temp1 = 20000
   Civ_cmd4 = &H30
   Gosub S_scope_edge
Return