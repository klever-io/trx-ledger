#!/usr/bin/env python
from ledgerblue.comm import getDongle
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
parser.add_argument('--path', help="BIP32 path to retrieve. e.g. \"44'/195'/0'/0/0\".")
args = parser.parse_args()

if args.path == None:
	args.path = "44'/195'/0'/0/0"

donglePath = parse_bip32_path(args.path)
print(donglePath)

# Test Cases
# Test Transaction 1 as Protobuf 2.
tokenID = "31303030303430" # 1000040
tokenName = "4c4544474552" # Ledger
testSignature = "304502210099e4965459a3f320af283a7c23da1c83f14fe033471b4c713c673c4b09821f0d02200c9dc4889894e4d500cc3d9feea9a336ee2347ff1ccb2f0c0ffe091b539b6acb"

transactionRaw = "0a02e7c3220869e2abb19969f1e740f0bbd3fabf2c5a7c080212780a32747970"   \
					 "652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e5472616e7366"\
					 "65724173736574436f6e747261637412420a1043727970746f436861696e546f"\
					 "6b656e121541c8599111f29c1e1e061265b4af93ea1f274ad78a1a15414f560e"\
					 "b4182ca53757f905609e226e96e8e1a80c200170b7f5cffabf2c"

EXTRA = "520731303030313636"
EXTRA += "5800"
EXTRA += "6246304402206d63bb309ba9be02ab99705b6aeb38eb67791ef621f71c291f354a5c37f72cff022012b991f673940f98967d39ff3cddeb555022575d34180c4a567397cdd2b2da52"

EXTRA = "520a4c65646765725465737458006246304402207b8ee24dde3f4fd0057e23b134848beb13f8ad3d5ab27b4e91cdcc202ac84c0602202026ec2dfb8f356af5217cb90c8dbabfb77869e9490cee18dee00f6ddd99e1f8"

# Create APDU message.
# CLA 0xE0
# INS 0x07 	SIGN_TRC10
# P1 0x00	NO USER CONFIRMATION
# P2 0x00  	NO CHAIN CODE
apduMessage = "E0041000" + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionRaw) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionRaw
apduMessage1 = "E0040000" + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionRaw) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionRaw
apduMessage2 = "E004A800" +  '{:02x}'.format(int(len(EXTRA) / 2) ) + EXTRA

print("-= Tron Ledger =-")
print("Request Signature")

dongle = getDongle(True)
print(apduMessage.strip())

# Have ledger sign Test Transaction.
#result = dongle.exchange(bytearray.fromhex(apduMessage))
#print("Result:")
#print(binascii.hexlify(result).decode())
result = dongle.exchange(bytearray.fromhex(apduMessage1))
result = dongle.exchange(bytearray.fromhex(apduMessage2))
print("Result:")
print(binascii.hexlify(result).decode())
	
