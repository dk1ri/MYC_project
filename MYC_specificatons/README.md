# MYC, a protocol and system to control things, apps and programs

The MYC protocol is a  OSI layer 7 protocol, it handles abstract, generic functions. 

A MYC system contain up to three programs, which handle the system. It also contain controlled and controlling devices.

## What a MYC system can do?
Originally the idea was to control different hardware by a user defined graphical interface; without the need of programming the GUI.
But the protocol is so universal and flexible, that you can use it for apps as well. If you split a app into its real function (func) and the User Interface (the MYC system) no more GUI programming is necessary.
And in a MYC system the user can mix func of different programs with hardware control as he like it.
Same principle apply for programs.
MYC is an attempt to merge different systems by using a universal and in fact very simple and easy protocol

## What MYC not is

MYC is not a ready system by itself. The protocol is a OSI layer 7 protocol. The other layers must be chosen by demand.
Error correction, encryption and the other underlaying protocols are not fixed and will be defined by the implementation of the four programs mentioned below.

## The protocol

There are three documents, which describe the protocol (and partly the system): 

commands: This is the main document, describing the announcement and command syntax with some explanation, how to use the commands.

reserved token: describe the syntax and the meaning of reserved commands (token)

rules: describe the syntax for rules.

The "original" of these three specification are Open office documents. Because I do not know, weather git can handle this document type, git will hold converted txt documents.

A more detailed description of the MYC system can be found in www.dk1ri.de -> MYC

## The MYC System

### The main system
The three programs for a MYC sytem are:

(they are in different repositories)

MYCsystem_commandrouter

MYCsystem_logicdevice

MYCsystem_rulesdevice

### Devices

Devices understand the MYC protocol and can be hardware or software.

One device is the userinterface. This programm  is handled in a different repository.

Other devices and interfaces to other systems can be found in the other repositories
