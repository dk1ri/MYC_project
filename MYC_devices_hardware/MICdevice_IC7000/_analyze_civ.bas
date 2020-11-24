' Ic7300 Analyze_civ
' 20200314
'
Analyze_civ:
'CiV received, analyze data
' some commands do answer with ok /nok only!!
'Civ_in contain the complete answer with header and trailer
'Civ_pointer points to last element before trailer (&HFD)
'Civ code 0 and 1 appear with transceive = on on radio only
'Correct Length of Civ string is not checked
'
If Civ_in_b(5) < &H1A Then
   $include _analyze_civ_00_H19.bas
Else
   If Civ_in_b(5) < &H1B Then
      If Civ_in_b(6) < &H05 Then
         '&H1A00 ... &H1A04
         Tx_b(1) = 1
         Select Case Civ_in_b(6)
            Case &H00
                  Gosub Memory_read
            Case &H01
               If Copy_band_stack > 0 Then
                  Temps = Chr(&H1A) + Chr(&H01)
                  Temps_b(3) = Copy_band_stack
                  ' copy to 1:
                  Temps_b(4) = 1
                  For B_temp1 = 1 To 14
                     Temps_b(B_temp1 + 4)= Civ_in_b(B_temp1 + 8)
                  Next B_temp1
                  Civ_len = 18
                  Gosub Civ_print
                  Tx_write_pointer = 1
                  Copy_band_stack = 0
               End If
            Case &H03
                Tx_b(2) = Last_command
                Tx_b(3) = Makedec(Civ_in_b(7))
                Tx_write_pointer = 4
       '
             Case &H04
                Tx_b(2) = Last_command
                Tx_b(3) = Makedec(Civ_in_b(7))
                Tx_write_pointer = 4
          End Select
      Else
         If Civ_in_b(6) = &H05 Then
            '1A05
            Civ_sub_cmd = Civ_in_b(7) * 100
            Civ_sub_cmd = Civ_sub_cmd + Makedec(Civ_in_b(8))
            If Civ_sub_cmd < 100 Then
               If Civ_sub_cmd < 50 Then
                  Civ_sub_cmd = Civ_sub_cmd - 3
                  On Civ_sub_cmd Gosub s03,s04,s05,s06,s07,s08,s09,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32,s33,s34,s35,s36,s37,s38,s39,s40,s41,s42,s43,s44,s45,s46,s47,s48,s49
               Else
                  Civ_sub_cmd = Civ_sub_cmd - 50
                  On Civ_sub_cmd Gosub s50,s51,s52,s53,s54,s55,s56,s57,s58,s59,s60,s61,s62,s63,s64,s65,s66,s67,s68,s69,s70,s71,s72,s73,s74,s75,s76,s77,s78,s79,s80,s81,s82,s83,s84,s85,s86,s87,s88,s89,s90,s91,s92,s93,s94,s95,s96,s97,s98,s99
               End If
            Else
               Civ_sub_cmd = Civ_sub_cmd - 100
               On Civ_sub_cmd Gosub s100,s101,s102,s103,s104,s105,s106,s107,s108,s109,s110,s111,s112,s113,s114,s115,s116,s117,s118,s119
            End If
         Else
            $include _analyze_civ_1a06_1a1c.bas
         End If
       End If
   End If
End If
Return
'