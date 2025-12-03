' info
' 20251128
'
' This version is different to previous verionsnas not backward compatible, radio interfaces added.

' actual:
' 02511:
' nfm95, nrf24 ok
'
' 202509
' This Version (14 or later) was made for devices with wireless interface
' It requires slightly more code and RAM, but has some enhancements over previous versions.
' Previous versions will be not changed anymore (except serious errors were found)
'
' The Version number will not change (common14). so date is of interest
' 202509                1st version
'
' 202508:
' Use_wireless = 1 for wireless
' Use_i2c = 0 possible, but &HFE &HFF must not have i2c in announcements!
' similar to wireless