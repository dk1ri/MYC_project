#one buffer for each HI / PR
name=[]                                                         #interface type as Terminal, Ethernet I2C,...
actual_token=[]                                                 #actual commandtoken as int (for non local commands), 0: array cleared
actual_token_string=[]                                          #actual commandtoken as string
inputline=[]                                                    #actual input buffer, got from HI...
answerline=[]                                                   #actual answer buffer
answer_ready=[]                                                 #actual aswer ready
device_index=[]                                                 #actual index to device involved
original_command_index=[]                                       #actual index to command within device
starttime=[]                                                    #starttime
delete=[]                                                       #delete these number of bytes with finnish_command
last_error=[]                                                   #last error message
wait=[]                                                         #real time value: wait until len(input_line) is higher