# per commandtoken of full list as index
dev_token = []                              # original commandtoken in a device for which it is valid
device = []                                 # device, that token should be send to; for basic command it is device 0 always
index_of_cr_commands = {}                   # directory 240 -> tok, nextline of full list -> 1 ... for cr commands
index_of_cr_commands_r = {}                 # directory tok -> 240, 1 -> nextline of full list ... for CR commands
announcements ={}                           # tok -> nouncement (because of "R" and "I" lines
