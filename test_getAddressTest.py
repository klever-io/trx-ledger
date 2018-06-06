#!/usr/bin/env python

from ledgerblue.comm import getDongle
from ledgerblue.commException import CommException
import argparse
import struct
import binascii

'''
Test CASE
Public Key: 040defc55df809cca94abce297d432863bd8c9049fb420b1106cf53bfb4b85e0184802c495337c7a407e2b68ebd2323df2a8198d860df103de6496bd139ed24094
sha3 = SHA3(Public Key[1, 65)): 673f5c16982796e7bff195245a523b449890854c8fc460ab602df9f31fe4293f
MainNet:
address = 41||sha3[12,32): 415a523b449890854c8fc460ab602df9f31fe4293f
sha256_0 = sha256(address): 06672d677b33045c16d53dbfb1abda1902125cb3a7519dc2a6c202e3d38d3322
sha256_1 = sha256(sha256_0): 9b07d5619882ac91dbe59910499b6948eb3019fafc4f5d05d9ed589bb932a1b4
checkSum = sha256_1[0, 4): 9b07d561
addchecksum = address || checkSum: 415a523b449890854c8fc460ab602df9f31fe4293f9b07d561
base58Address = Base58(addchecksum): TJCnKsPa7y5okkXvQAidZBzqx3QyQ6sxMW
'''

txt = "2707040defc55df809cca94abce297d432863bd8c9049fb420b1106cf53bfb4b85e0184802c495337c7a407e2b68ebd2323df2a8198d860df103de6496bd139ed24094"
apdu = bytearray.fromhex(txt)

print("-= Tron Ledger =-")
print("Request Public Key")
dongle = getDongle(True)
result = dongle.exchange(apdu)
print("Bytes: " + binascii.hexlify(result).decode())
print("Address: " + result.decode())



