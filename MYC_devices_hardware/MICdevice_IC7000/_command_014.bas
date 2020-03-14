' Command 140 - 15F
' 200217
'
140:
   Temps = Chr(&H15) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
   Return
'
141:
   Temps = Chr(&H15) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
   Return
'
142:
   Temps = Chr(&H15) + Chr(&H11)
   Civ_len = 2
   Gosub Civ_print
   Return
'
143:
   Temps = Chr(&H15) + Chr(&H12)
   Civ_len = 2
   Gosub Civ_print
   Return
'
144:
    Temps = Chr(&H15) + Chr(&H13)
   Civ_len = 2
   Gosub Civ_print
   Return
'
145:
   Temps = Chr(&H15) + Chr(&H14)
   Civ_len = 2
   Gosub Civ_print
   Return
'
146:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H02
   B_temp1 = 2
   Gosub Civ_print_l_3
   Return
'
147:
   Temps = Chr(&H16) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
   Return
'
148:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H12
   B_temp1 = 3
   Gosub Civ_print_l_3p1
   Return
'
149:
   Temps = Chr(&H16) + Chr(&H12)
   Civ_len = 2
   Gosub Civ_print
   Return
'
14A:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H22
   B_temp1 = 2
   Gosub Civ_print_l_3
   Return
'
14B:
   Temps = Chr(&H16) + Chr(&H22)
   Civ_len = 2
   Gosub Civ_print
   Return
'
14C:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H40
   B_temp1 = 2
   Gosub Civ_print_l_3
   Return
'
14D:
   Temps = Chr(&H16) + Chr(&H40)
   Civ_len = 2
   Gosub Civ_print
   Return
'
14E:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H41
   B_temp1 = 2
   Gosub Civ_print_l_3
   Return
'
14F:
   Temps = Chr(&H16) + Chr(&H41)
   Civ_len = 2
   Gosub Civ_print
   Return
'
150:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H42
   B_temp1 = 2
   Gosub Civ_print_l_3
   Return
'
151:
   Temps = Chr(&H16) + Chr(&H42)
   Civ_len = 2
   Gosub Civ_print
   Return
'
152:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H43
   B_temp1 = 2
   Gosub Civ_print_l_3
   Return
'
153:
   Temps = Chr(&H16) + Chr(&H43)
   Civ_len = 2
   Gosub Civ_print
   Return
'
154:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H44
   B_temp1 = 2
   Gosub Civ_print_l_3
   Return
'
155:
   Temps = Chr(&H16) + Chr(&H44)
   Civ_len = 2
   Gosub Civ_print
   Return
'
156:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H45
   B_temp1 = 2
   Gosub Civ_print_l_3
   Return
'
157:
   Temps = Chr(&H16) + Chr(&H45)
   Civ_len = 2
   Gosub Civ_print
   Return
'
158:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H46
   B_temp1 = 2
   Gosub Civ_print_l_3
   Return
'
159:
   Temps = Chr(&H16) + Chr(&H46)
   Civ_len = 2
   Gosub Civ_print
   Return
'
15A:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H47
   B_temp1 = 3
   Gosub Civ_print_l_3
   Return
'
15B:
   Temps = Chr(&H16) + Chr(&H47)
   Civ_len = 2
   Gosub Civ_print
   Return
'
15C:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H48
   B_temp1 = 2
   Gosub Civ_print_l_3
   Return
'
15D:
   Temps = Chr(&H16) + Chr(&H48)
   Civ_len = 2
   Gosub Civ_print
   Return
'
15E:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H4B
   B_temp1 = 2
   Gosub Civ_print_l_3
   Return
'
15F:
   Temps = Chr(&H16) + Chr(&H4B)
   Civ_len = 2
   Gosub Civ_print
   Return
'