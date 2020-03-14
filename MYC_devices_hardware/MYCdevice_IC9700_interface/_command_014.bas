' IC7300 Command 140 - 15F
' 191129
'
140:
   Temps = Chr(&H14) + Chr(&H19)
   Civ_len = 2
   Gosub Civ_print
Return
'
141:
   Temps = Chr(&H15) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
Return
'
142:
   Temps = Chr(&H15) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
Return
'
143:
   Temps = Chr(&H15) + Chr(&H05)
   Civ_len = 2
   Gosub Civ_print
Return
'
144:
   Temps = Chr(&H15) + Chr(&H07)
   Civ_len = 2
   Gosub Civ_print
Return
'
145:
   Temps = Chr(&H15) + Chr(&H11)
   Civ_len = 2
   Gosub Civ_print
Return
'
146:
   Temps = Chr(&H15) + Chr(&H12)
   Civ_len = 2
   Gosub Civ_print
Return
'
147:
Temps = Chr(&H15) + Chr(&H13)
   Civ_len = 2
   Gosub Civ_print
   Return
'
148:
   Temps = Chr(&H15) + Chr(&H14)
   Civ_len = 2
   Gosub Civ_print
Return
'
149:
    Temps = Chr(&H15) + Chr(&H15)
   Civ_len = 2
   Gosub Civ_print
Return
'
14A:
   Temps = Chr(&H15) + Chr(&H16)
   Civ_len = 2
   Gosub Civ_print
Return
'
14B:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H02
   B_temp1 = 4
   Gosub Civ_print_l_3
Return
'
14C:
   Temps = Chr(&H16) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
Return
'
14D:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H12
   B_temp1 = 4
   Gosub Civ_print_l_3
   Return
'
14E:
   Temps = Chr(&H16) + Chr(&H12)
   Civ_len = 2
   Gosub Civ_print
   Return
'
14F:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H22
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
150:
   Temps = Chr(&H16) + Chr(&H22)
   Civ_len = 2
   Gosub Civ_print
Return
'
151:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H40
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
152:
   Temps = Chr(&H16) + Chr(&H40)
   Civ_len = 2
   Gosub Civ_print
Return
'
153:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H41
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
154:
   Temps = Chr(&H16) + Chr(&H41)
   Civ_len = 2
   Gosub Civ_print
Return
'
155:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H42
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
156:
   Temps = Chr(&H16) + Chr(&H42)
   Civ_len = 2
   Gosub Civ_print
Return
'
157:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H43
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
158:
   Temps = Chr(&H16) + Chr(&H43)
   Civ_len = 2
   Gosub Civ_print
Return
'
159:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H44
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
15A:
   Temps = Chr(&H16) + Chr(&H44)
   Civ_len = 2
   Gosub Civ_print
Return
'
15B:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H45
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
15C:
   Temps = Chr(&H16) + Chr(&H45)
   Civ_len = 2
   Gosub Civ_print
Return
'
15D:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H46
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
15E:
   Temps = Chr(&H16) + Chr(&H46)
   Civ_len = 2
   Gosub Civ_print
Return
'
15F:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H47
   B_temp1 = 3
   Gosub Civ_print_l_3
Return
'