#!/bin/python
import crypt,getpass,sys
pw=getpass.getpass()
if (pw==getpass.getpass("Confirm: ")):
   print(crypt.crypt(pw))
   sys.stdout.flush()
   exit(0)
else:
   print("Passwords did not match!")
   sys.stdout.flush()
   exit(1)
