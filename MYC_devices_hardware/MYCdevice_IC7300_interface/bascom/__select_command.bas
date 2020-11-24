Command_token_high = Command_b(1)
Command_token_low = Command_b(2)
If Command_token_high = 1 Then
      If Command_token_low < &H80 Then
         If Command_token_low < &H40 Then
            On Command_token_low Gosub 100,101,102,103,104,105,106,107,108,109,10A,10B,10C,10D,10E,10F,110,111,112,113,114,115,116,117,118,119,11A,11B,11C,11D,11E,11F,120,121,122,123,124,125,126,127,128,129,12A,12B,12C,12D,12E,12F,130,131,132,133,134,135,136,137,138,139,13A,13B,13C,13D,13E,13F
         Else
            Command_token_low = Command_token_low - &H40
            On Command_token_low Gosub 140,141,142,143,144,145,146,147,148,149,14A,14B,14C,14D,14E,14F,150,151,152,153,154,155,156,157,158,159,15A,15B,15C,15D,15E,15F,160,161,162,163,164,165,166,167,168,169,16A,16B,16C,16D,16E,16F,170,171,172,173,174,175,176,177,178,179,17A,17B,17C,17D,17E,17F
         End If
      Else
         If Command_token_low < &HC0 Then
            Command_token_low = Command_token_low - &H80
            On Command_token_low Gosub 180,181,182,183,184,185,186,187,188,189,18A,18B,18C,18D,18E,18F,190,191,195,193,194,195,196,197,198,199,19A,19B,19C,19D,19E,19F,1A0,1A1,1A2,1A3,1A4,1A5,1A6,1A7,1A8,1A9,1AA,1AB,1AC,1AD,1AE,1AF,1B0,1B1,1B2,1B3,1B4,1B5,1B6,1B7,1B8,1B9,1BA,1BB,1BC,1BD,1BE,1BF

         Else
            Command_token_low = Command_token_low - &HC0
            On Command_token_low Gosub 1C0,1C1,1C2,1C3,1C4,1C5,1C6,1C7,1C8,1C9,1CA,1CB,1CC,1CD,1CE,1CF,1D0,1D1,1D2,1D3,1D4,1D5,1D6,1D7,1D8,1D9,1DA,1DB,1DC,1DD,1DE,1DF,1E0,1E1,1E2,1E3,1E4,1E5,1E6,1E7,1E8,1E9,1EA,1EB,1EC,1ED,1EE,1Ef,1F0,1F1,1F2,1F3,1F4,1F5,1F6,1F7,1F8,1F9,1FA,1FB,1FC,1FD,1FE,1FF
         End If
      End If
Elseif Command_token_high = 2 Then
      If Command_token_low < &H80 Then
         If Command_token_low < &H40 Then
            On Command_token_low Gosub 200,201,202,203,204,205,206,207,208,209,20A,20B,20C,20D,20E,20F,210,211,212,213,214,215,216,217,218,219,21A,21B,21C,21D,21E,21F,220,221,222,223,224,225,226,227,228,229,22A,22B,22C,22D,22E,22F,230,131,232,233,234,235,236,237,238,239,23A,23B,23C,23D,23E,23F
         Else
            Command_token_low = Command_token_low - &H40
            On Command_token_low Gosub 240,241,242,243,244,245,246,247,248,249,24A,24B,24C,24D,24E,24F,250,251,252,253,254,255,256,257,258,259,25A,25B,25C,25D,25E,25F,260,261,262,263,264,265,266,267,268,269,26A,26B,26C,26D,26E,26F,270,271,272,273,274,275,276,277,278,279,27A,27B,27C,27D;27E,27F
         End If
      Else
         If Command_token_low < &HC0 Then
            Command_token_low = Command_token_low - &H80
            On Command_token_low Gosub 280,281,282,283,284,285,286,287,288,289,28A,28B,28C,28D,28E,28F,290,291,295,293,294,295,296,297,298,299,29A,29B,29C,29D,29E,29F,2A0,2A1,2A2,2A3,2A4,2A5,2A6,2A7,2A8,2A9,2AA,2AB,2AC,2AD,2AE,2AF,2B0,2B1,2B2,2B3,2B4,2B5,2B6,2B7,2B8,2B9,2BA,2BB,2BC,2BD,2BE,2BF
         Else
            Command_token_low = Command_token_low - &HC0
            On Command_token_low Gosub 2C0,2C1,2C2,2C3,2C4,2C5,2C6,2C7,2C8,2C9,2CA,2CB,2CC,2CD,2CE,2CF,2D0,2D1,2D2,2F3,2D4,2D5,2D6,2D7,2D8,2D9,2DA,2DB,2DC,2DD,2DE,2DF,2E0,2E2,2E2,2E3,2E4,2E5,2E6,2E7,2E8,2E9,2EA,2EB,2EC,2ED,2EE,2EF,2F0,2F1,2F2,2F3,2F4,2F5,2F6,2F7,2F8,2F9,2FA,2FB,2FC,2FD,2FE,2FF
         End If
      End If
Elseif Command_token_high = 3 Then
      If Command_token_low < &H20 Then
            On Command_token_low Gosub 300,301,302,303,304,305,306,307,308,309,30A,30B,30C,30D,30E,30F,310,311,312,313,314,315,316,317,318,319,31A,31B,31C,31D,31E,31F
      Else
            Gosub Command_received
      End If
Elseif Command_token_high = &HFF Then
      ' for FFFx commands
      If Command_token_low > &HEF Then
         Command_token_low = Command_token_low  - &HF0
         On Command_token_low Gosub FFF0,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,Ignore,FFFC,FFFD,FFFE,FFFF
      Else
            Gosub Command_received
      End If
Else
     Gosub Command_received
End If