""""
name: v_token_params.py
last edited: 20260414
per commandtoken of full list (R, I Q lines skipped)
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""

cr_token = []                               # CR_tok for device_tok per device cr_token is != index (tok)
dev_token = {}                              # original commandtoken for a CR tok
device = {}                                 # device, that tok should be sent to
a_to_o = {}
o_to_a = {}