#!/usr/bin/env python

from ledgerblue.comm import getDongle
from ledgerblue.commException import CommException
import argparse
import struct
import binascii


txt = "2707040defc55df809cca94abce297d432863bd8c9049fb420b1106cf53bfb4b85e0184802c495337c7a407e2b68ebd2323df2a8198d860df103de6496bd139ed24094"
apdu = bytearray.fromhex(txt)

print("-= Tron Ledger =-")
print("Request Public Key")
dongle = getDongle(True)
result = dongle.exchange(apdu)
print("Bytes: " + binascii.hexlify(result).decode())
print("Address: " + result.decode())



