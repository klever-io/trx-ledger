#!/usr/bin/env python

from ledgerblue.comm import getDongle
from ledgerblue.commException import CommException
import argparse
import struct
import binascii

print("-= Tron Ledger =-")
print("Request app Version")
dongle = getDongle(True)
result = dongle.exchange(bytearray.fromhex("27060000FF"))
print('Version={:d}.{:d}.{:d}'.format(result[1],result[0],result[3]))

