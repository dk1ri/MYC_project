' wireless_constants
' 20250605
'
Const default_f_rfm95_150 = 150000000
Const default_f_rfm95_430 = 434000000
Const default_f_rfm95_900 = 900000000
'
' RFM95_constants:
' all registers valid for rfm95 are mentioned here
' default values are used except
' register 01
' all names end with 0
'
   Const Reg_fifo0 =          &B00000000
   Const Reg_fifo_w0 =        &B10000000
   Const Reg_fifo_start_tx0 = &H80
   Const Reg_fifo_start_rx0 = &H00
   Const RegOpMode0   =       &B00000001
   Const RegOpMode_w0 =       &B10000001
   'sleep lora
   Const RegOpMode_sleep0 =   &B10000000
   'standby lora
   Const RegOpMode_standby0 = &B10000001
   'Tx lora
   Const RegOpMode_tx0 =      &B10000011
   'Rx lora continous
   Const RegOpMode_rx0 =      &B10000101
   ' register 2 - 5: reserved
   Const RegFrMsb0 =          &B00000110
   Const RegFrMsb_w0 =        &B10000110
   Const RegFrMid0=           &B00000111
   Const RegFrMid_w0=         &B10000111
   Const RegFrLsb0 =          &B00001000
   Const RegFrLsb_w0 =        &B10001000
   ' default 434Mz
   Const RegPaConfig0 =       &B00001001
   ' default power
   Const RegPaRamp0 =         &B00001010
   ' default
   Const RegOcp0 =            &B00001011
   ' default
   Const RegLna0 =            &B00001100
   ' default
   Const RegFifoAddrPtr0 =    &B00001101
   Const RegFifoAddrPtr_w0 =  &B10001101
   ' SPIFiFO read write adress
   Const RegFifoTxBaseAddr0 = &B00001110
   ' FIFO address for send
   Const RegFifoRxBaseAd0 =   &B00001111
   ' RX FIFO  RX Adress base
   Const FifoRxCurrentAddr0 = &B00010000
   ' current FIFO RX address
   Const RegIrqFlagsMask0 =   &B00010001
   ' wie IRQ
   Const RegIrqFlags0 =       &B00010010
   ' IRQ
   Const FifoRxBytesNb_Bytes0=&B00010011
   ' number of byte received read
   Const ValidHeaderCntMsb0 = &B00010100
   Const ValidHeaderCntLsb0 = &B00010101
   ' Headercount read
   Const ValidHeaderCntMsb10 =&B00010110
   Const ValidHeaderCntLsb10 =&B00010111
   'read
   Const RegModemStat0 = &H18
   ' read
   Const PacketSnr0 = &H19
   'read
   Const PacketRssi0 = &H1A
   ' read
   Const Rssi0 = &H1B
   ' read
   Const RegHopChannel0 = &H1C
   ' read
   Const Bw0 = &H1D
   ' default
   Const RegModemConfig20 = &H1E
   Const RegModemConfig2_w0 = &B10011110
   ' spreading 128,CRC off
   ' default
   Const SymbTimeout0 = &H1F
   ' default
   Const RegPreambleMsb0 = &H20
   Const RegPreambleLSb0 = &H21
   ' default
   Const RegPayloadLength0 = &H22
   Const RegPayloadLength_w0 = &B10100010
   'default  (not implicit mode)
   Const RegMaxPayloadLength0 = &H23
   ' default
   Const FreqHoppingPeriod0 = &H24
   ' default not used
   Const RegFifoRxByteAddr0 = &H25
   ' read
   Const RegModemConfig30 = &H26
   ' default
   '- 2F read
'
 nRF24l1_constants:
' all registers valid for rfm95 are mentioned here
' default values are used except
' register 01
' all names end with 4
Const Config4 =      &B00000000
Const EN_AA4 =       &B00000001
Const NRX_ADDR4 =    &B00000010
Const SETUP_AW4 =    &B00000011
Const SETUP_RETR4 =  &B00000100
Const RF_CH4 =       &B00000101
Const RF_Setup4 =    &B00000110
Const STATUS4 =      &B00000111
Const OBSERVE_TX4 =  &B00001000
Const RPD4 =         &B00001001
Const RX_ADDR_P04 =  &B00001010
' 6 Byte
'
Const TX_ADDR4 =     &B00010000
Const RX_PW_P04 =    &B00010001
' to &H16
Const FIFO_STATUS4 = &B00010111
Const DYNPD4 =       &B00001100
'
Const R_RX_PAYLOAD4 =       &B01100001
Const W_TX_PAYLOAD4 =       &B10100000
Const FLUSH_TX4 =           &B11100001
Const FLUSH_RX4 =           &B11100010
Const REUSE_TX_PL4 =        &B11100011
Const R_RX_PL_WI4 =         &B01100000
Const W_TX_PAYLOAD_NOACK4 = &B10110000