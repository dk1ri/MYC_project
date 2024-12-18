' LoRa Setup
' 20201025
' all registers valid for Lora are mentioned here
'
Lora_setup:
   Const Reg_fifo = 0
   Const Reg_fifo_w = &B10000000
   Const Reg_fifo_start_tx = &H80
   Const Reg_fifo_start_rx = &H00
   const RegOpMode   = &B00000001
   const RegOpMode_w = &B11000001
   'Lora sleep
   Const RegOpMode_lora_sleep = &B10000001
   ' Lora standby
   Const RegOpMode_lora_standby = &B10000000
   ' Lora Tx
   Const RegOpMode_lora_tx = &B10000011
   ' Lora Rx cont
   Const RegOpMode_lora_rxcont = &B10000101
   'standby mode to set registers in Lora
   Register_b(1)  = RegOpMode_w
   Register_b(2) = RegOpMode_lora_standby
   gosub Write_register
   ' register 2 - 5: reserved
   Const RegFrMsb = 6
   Const RegFrMid = 7
   Const RegFrLsb = 8
   ' default 434Mz
   Const RegPaConfig = 9
   ' default power
   Const RegPaRamp =&H0A
   ' default
   Const RegOcp = &H0B
   ' default
   Const RegLna = &H0C
   ' default
   Const RegFifoAddrPtr = &H0D
   Const RegFifoAddrPtr_w = &B10001100
   ' SPIFiFO read write adress
   Const RegFifoTxBaseAddr = &H0E
   ' FIFO address for send
   Const RegFifoRxBaseAd = &H0F
   ' RX FIFO  RX Adress base
   Const FifoRxCurrentAddr = &H10
   ' current FIFO RX address
   Const RegIrqFlagsMask = &H11
   ' wie IRQ
   Const RegIrqFlags = &H12
   ' IRQ
   Const FifoRxBytesNb_Bytes = &H13
   ' number of byte received read
   Const ValidHeaderCntMsb = &H14
   Const ValidHeaderCntLsb = &H15
   ' Headercount read
   Const ValidHeaderCntMsb1 = &H16
   Const ValidHeaderCntLsb1 = &H17
   'read
   Const RegModemStat = &H18
   ' read
   Const PacketSnr = &H19
   'read
   Const PacketRssi = &H1A
   ' read
   Const Rssi = &H1B
   ' read
   Const RegHopChannel = &H1C
   ' read
   Const Bw = &H1D
   ' default
   Const RegModemConfig2 = &H1E
   Const RegModemConfig2_w = &B10011110
   ' spreading 128,CRC off
   ' default
   Const SymbTimeout = &H1F
   ' default
   Const RegPreambleMsb = &H20
   Const RegPreambleLSb = &H21
   ' default
   Const RegPayloadLength = &H22
   Const RegPayloadLength_w = &B10100010
   'default  (not implicit mode)
   Const RegMaxPayloadLength = &H23
   ' default
   Const FreqHoppingPeriod = &H24
   ' default not used
   Const RegFifoRxByteAddr = &H25
   ' read
   Const RegModemConfig3 = &H26
   ' default
   '- 2F read
   '
   ' rx continous Mode
   Register_b(1) = RegOpMode_w
   Register_b(2) = RegOpMode_lora_rxcont
   Gosub Write_register
'
Return