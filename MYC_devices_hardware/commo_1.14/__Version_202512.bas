' 20251207
'
' Description:
'
' If a command is recognized, it will be handled within this loop.
'
' Different IO Buffers for TX / RX are necessary, due to input data by interrupt at any time
'
' When a command is recognized, the commandpointer is stored. So multiple command are allowed
'
' Detailed description
' There are different "modes" for InterfaceFU = 0 (Interface);
' Interface_transparent_active = 1 (default, Mode_in = 1, Jumper open):
'     wireless_active parameter is ignored (always wireless)
'
' Interface_transparent_active = 0 (default, Mode_in = 0, Jumper bridged):
'     workes identical to FU
'
' There are different "modes" for InterfaceFU = 1 (FU);
' always: Interface_transparent_active = 0
' InterfaceFU = 1 (other devices; clients for interface device))
'        all activ interfaces can be used
'        Mode_in = 1, Jumper open default
'        some commands are blocked (especialy radio configuration):
'           command to modify wireless are not allowed
'
'        Mode_in = 0, Jumper closed :
'           Configuration Mode, all commands are allowed