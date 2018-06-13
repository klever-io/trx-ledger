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
transactionRaw1 = "0a027d52220889fd90c45b71f24740e0bcb0f2be2c5a67080112630a2d747970"   \
                     "652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e5472616e7366"\
                     "6572436f6e747261637412320a1541c8599111f29c1e1e061265b4af93ea1f27"\
                     "4ad78a1215414f560eb4182ca53757f905609e226e96e8e1a80c18c0843d70d0"\
                     "f5acf2be2c"
# Hash1: 1275c8c9cd5889997bfce9b877b258e7524c19eec0067c131abfa0d2c91c16ab

signatureCheck1 = "cd01fcd0a4f0bb9a55a43d57ae1c955374f2540ff931307029e4c1fb80a6dc91"   \
                     "3185edd8a4dfda2d03aad569b856cfb3ed9db387b6589451797ff01c9c353583"\
                     "01"

# Test Transaction 2 as Protobuf 2.
transactionRaw2 = "0a02c56522086cd623dbe83075d8409089e88dbf2c5a67080112630a2d747970"   \
                     "652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e5472616e7366"\
                     "6572436f6e747261637412320a1541c8599111f29c1e1e061265b4af93ea1f27"\
                     "4ad78a1215414f560eb4182ca53757f905609e226e96e8e1a80c1880897a70f3"\
                     "c3e48dbf2c"

signatureCheck2 = "1de95be5dcfa5382e6ad3b814321935912408f8c7731a0b07c39591b498ca8fb"   \
                     "663a984fa2864e95b69617c8a02a1a7e46ae9e128429b4d3c539219f2624c174"\
                     "00"

# Create APDU message.
# CLA 0x27
# INS 0x04 	SIGN
# P1 0x00	NO USER CONFIRMATION
# P2 0x00  	NO CHAIN CODE
apduMessage1 = "27040000" + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionRaw1) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionRaw1
apduMessage2 = "27040000" + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionRaw2) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionRaw2

print("-= Tron Ledger =-")
print("Request Signature")

dongle = getDongle(True)
print(apduMessage1.strip())
# Have ledger sign Test Transaction 1.
result = dongle.exchange(bytearray.fromhex(apduMessage1))
if binascii.hexlify(result[0:65]).decode()==signatureCheck1:
	print("Signature Validated!")
else:
	print("Signature Error!")

# Have ledger sign Test Transaction 2.
result = dongle.exchange(bytearray.fromhex(apduMessage2))
if binascii.hexlify(result[0:65]).decode()==signatureCheck2:
	print("Signature Validated!")
else:
	print("Signature Error!")
