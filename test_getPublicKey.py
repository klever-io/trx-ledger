#!/usr/bin/env python

from ledgerblue.comm import getDongle
import argparse
import struct

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
parser.add_argument('--path', help="BIP32 path to retrieve. e.g. \"44'/195'/0'/0/0\".")
args = parser.parse_args()

if args.path == None:
	args.path = "44'/195'/0'/0/0"

donglePath = parse_bip32_path(args.path)

# Create APDU message.
# CLA 0x27
# INS 0x02  GET_PUBLIC_KEY
# P1 0x00   NO USER CONFIRMATION
# P2 0x00   NO CHAIN CODE
# Ask for confirmation
# txt = "27020100" + '{:02x}'.format(len(donglePath) + 1) + '{:02x}'.format( int(len(donglePath) / 4 / 2)) + donglePath
# No confirmation
apduMessage = "27020000" + '{:02x}'.format(len(donglePath) + 1) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath
apdu = bytearray.fromhex(apduMessage)

print("-= Tron Ledger =-")
print("Request Public Key")

dongle = getDongle(True)
result = dongle.exchange(apdu)
size=result[0]
if size == 65 :
	print("Public Key: " + result[1:1+size].hex())
else:
	print("Error... Public Key Size: {:d}".format(size))

size=result[size+1]
if size == 34 :
	print("Address: " + result[67:67+size].decode())
	if (result[67:67+size].decode()=="TUEZSdKsoDHQMeZwihtdoBiN46zxhGWYdH"):
		print("Address match with test case!")
else:
	print("Error... Address Size: {:d}".format(size))
