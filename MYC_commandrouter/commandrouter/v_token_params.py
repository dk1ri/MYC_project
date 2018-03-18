""""
name: v_token_params.py
last edited: 201802
per commandtoken of full list (R, I Q lines skipped)
"""
dev_token = []                              # original commandtoken (used by a device) for a tok
token_number = []                           # tokennumber is != index (tok) for multibyte commandtoken
device = []                                 # device, that tok should be send to
index_of_cr_commands = {}                   # directory 240 -> tok, nextline of full list -> 1 ... for CR commands
index_of_cr_commands_r = {}                 # directory tok -> 240, 1 -> nextline of full list ... for CR commands
announcements ={}                           # tok -> announcement (because of "R" and "I" lines)  (???stimmt nicht??)
