' Analyze_civ
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
               If Read_memory_counter < 108 Then
                  Gosub Memory_read_and_fill
               Else
                  Gosub Memory_read
               End If
            Case &H01
               If Copy_band_stack > 0 Then
                  Temps = Chr(&H1A) + Chr(&H01)
                  Temps_b(3) = Copy_band_stack
                  ' copy to 1:
                  Temps_b(4) = 1
                  For B_temp1 = 1 To 14
                     Temps_b(B_temp1 + 4)= Civ_in_b(B_temp1 + 8)
                  Next B_temp1
                  print "test"
                  Civ_len = 18
                  Gosub Civ_print
                  Tx_write_pointer = 1
                  Copy_band_stack = 0
               End If
            Case &H02
                Tx_b(2) = &HC5
                Tx_b(3) = 0
                For B_temp1 = 7 To CiV_pointer
                   Tx_b(B_temp1 - 4) = CiV_in_b(B_temp1)
                   Incr Tx_b(3)
                Next B_temp1
                Tx_write_pointer = Tx_b(3) + 3
       '
            Case &H03
                Tx_b(2) = Last_command_l
                Tx_b(3) = Civ_in_b(7)
                Tx_write_pointer = 4
       '
             Case &H04
                Tx_b(2) = Last_command_l
                Tx_b(3) = Civ_in_b(7)
                Tx_write_pointer = 4
          End Select
      Else
         If Civ_in_b(6) = &H05 Then
            '1A05
            Civ_sub_cmd = Civ_in_b(7) * 100
            Civ_sub_cmd = Civ_sub_cmd + Makedec(Civ_in_b(8))
            Select Case Civ_sub_cmd
               Case 1 To 100
                  Civ_sub_cmd = Civ_sub_cmd - 1
                  On Civ_sub_cmd Gosub s01,s02,s03,s04,s05,s06,s07,s08,s09,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,s31,s32,s33,s34,s35,s36,s37,s38,s39,s40,s41,s42,s43,s44,s45,s46,s47,s48,s49,s50,s51,s52,s53,s54,s55,s56,s57,s58,s59,s60,s61,s62,s63,s64,s65,s66,s67,s68,s69,s70,s71,s72,s73,s74,s75,s76,s77,s78,s79,s80,s81,s82,s83,s84,s85,s86,s87,s88,s89,s90,s91,s92,s93,s94,s95,s96,s97,s98,s99
               Case 101 To 199
                  Civ_sub_cmd = Civ_sub_cmd - 100
                  On Civ_sub_cmd Gosub s100,s101,s102,s103,s104,s105,s106,s107,s108,s109,s110,s111,s112,s113,s114,s115,s116,s117,s118,s119,s120,s121,s122,s123,s124,s125,s126,s127,s128,s129,s130,s131,s132,s133,s134,s135,s136,s137,s138,s139,s140,s141,s142,s143,s144,s145,s146,s147,s148,s149,s150,s151,s152,s153,s154,s155,s156,s157,s158,s159,s160,s161,s162,s163,s164,s165,s166,s167,s168,s169,s170,s171,s172,s173,s174,s175,s176,s177,s178,s179,s180,s181,s182,s183,s184,s185,s186,s187,s188,s189,s190,s191,s192,s193,s194,s195,s196,s197,s198,s199
               Case 201 To 299
                  Civ_sub_cmd = Civ_sub_cmd - 200
                  On Civ_sub_cmd Gosub s200,s201,s202,s203,s204,s205,s206,s207,s208,s209,s210,s211,s212,s213,s214,s215,s216,s217,s218,s219,s220,s221,s222,s223,s224,s225,s226,s227,s228,s229,s230,s231,s232,s233,s234,s235,s236,s237,s238,s239,s240,s241,s242,s243,s244,s245,s246,s247,s248,s249,s250,s251,s252,s253,s254,s255,s256,s257,s258,s259,s260,s261,s262,s263,s264,s265,s266,s267,s268,s269,s270,s271,s272,s273,s274,s275,s276,s277,s278,s279,s280,s281,s282,s283,s284,s285,s286,s287,s288,s289,s290,s291,s292,s293,s294,s295,s296,s297,s298,s299
               Case 301 To 339
                  Civ_sub_cmd = Civ_sub_cmd - 300
                  On Civ_sub_cmd Gosub s300,s301,s302,s303,s304,s305,s306,s307,s308,s309,s310,s311,s312,s313,s314,s315,s316,s317,s318,s319,s320,s321,s322,s323,s324,s325,s326,s327,s328,s329,s330,s331,s332,s333,s334,s335,s336,s337,s338,s339
            End Select
         Else
            $include _analyze_civ_1a06_1a07.bas
         End If
       End If
   Else
      Select Case Civ_in_b(5)
         Case &H1B
            $include _analyze_civ_1B.bas
         Case &H1C
            $include _analyze_civ_1C.bas
         Case &H1E
            $include _analyze_civ_1E.bas
         Case &H1F
            $include _analyze_civ_1F.bas
         Case &H20
            $include _analyze_civ_20.bas
         Case &H27
            $include _analyze_civ_27.bas
         Case Else
            $include _analyze_civ_rest.bas
      End Select
   End If
End If
Return
'