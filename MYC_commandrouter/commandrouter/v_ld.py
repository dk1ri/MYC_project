""""
name: v_sld.py
last edited: 201803
parameters for LD interface
"""
data_to_ld = bytearray([])              # data from CR (valid command) from SK
data_to_cr = bytearray([])              # data to CR, info or command, routing kernel handles bytearrays
ld_available = 0
len = [0,0,0,0,0]                       # linelength parameters modified at real time: number of byte for next action
