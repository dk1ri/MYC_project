#stores different comm items per device
name=[]                                       	#name of that device (devicegroup and indiv)
interface=[]                                    #interfaceparameters of device
commandtokenlength=[]                           #length of commandtoken for devce commands
actual_token=[]                                 #actual commandtoken in work, 0, nothing actual
input=[]                                        #data from input_buffer of CR, when command is ready
wait_for_answer=[]                         	    #actual need to wait for answer? as int
                                                #4: ??? actual received commands buffer after command is ready, to be sent to device
answer=[]                                       #actual received answer buffer from device
                                                #6: ??? actual interfacebuffer index, which send and get data
                                                #7: ??? length of commandtoken with device
