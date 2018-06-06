#!/usr/bin/env python

from ledgerblue.comm import getDongle
from ledgerblue.commException import CommException
import argparse
import struct
import binascii

def parse_bip32_path(path):
	if len(path) == 0:
		return ""
	result = ""
	elements = path.split('/')
	for pathElement in elements:
		element = pathElement.split('\'')
		if len(element) == 1:
			result = result + struct.pack(">I", int(element[0])).hex()
		else:
			result = result + struct.pack(">I", 0x80000000 | int(element[0])).hex()
	return result

parser = argparse.ArgumentParser()
parser.add_argument('--path', help="BIP 32 path to retrieve")
args = parser.parse_args()

if args.path == None:
	args.path = "44'/195'/0'/0/0"

donglePath = parse_bip32_path(args.path)
# Ask for confirmation
# txt = "27020100" + '{:02x}'.format(len(donglePath) + 1) + '{:02x}'.format( int(len(donglePath) / 4)) + donglePath
# No confirmation
txt = "27020000" + '{:02x}'.format(len(donglePath)+1) + '{:02x}'.format( int(len(donglePath) / 4)) + donglePath
#txt = "E0020000" + '{:02x}'.format(00) + '{:02x}'.format( int(len(donglePath) / 4)) + donglePath
print(txt)
apdu = bytearray.fromhex(txt)



print("-= Tron Ledger =-")
print("Request Public Key")
dongle = getDongle(True)
result = dongle.exchange(apdu)
size=result[1]
if size == 34 :
	print("Address: " + result[1:size].decode())
else:
	print("Error... Size: {:d}".format(size))




