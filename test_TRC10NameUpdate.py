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

transactionRaw = "0A028C0022087B12C1947304CCBE40E8C4BBFE842D5A730802126F0A32747970652E676F6F676C65617069732E636F6D2F70726F746F636F6C2E5472616E736665724173736574436F6E747261637412390A0731303030303430121541C8599111F29C1E1E061265B4AF93EA1F274AD78A1A154167E39013BE3CDD3814BED152D7439FB5B6791409200170CB80B8FE842D"

EXTRA = "520a4c656467657254657374580062463044022039e55698ec49d5580c89f47565820ab17175493a7d313005d47f99f595dc1772022017ab363b0130ca33a30f7175d1784006637623eed50166eeb3f356dc6dabf6e8"
1000040
# Create APDU message.
# CLA 0xE0
# INS 0x07 	SIGN_TRC10
# P1 0x00	NO USER CONFIRMATION
# P2 0x00  	NO CHAIN CODE
apduMessage1 = "E0040000" + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionRaw) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionRaw
apduMessage2 = "E004A800" +  '{:02x}'.format(int(len(EXTRA) / 2) ) + EXTRA

print("-= Tron Ledger =-")
print("Request Signature")

dongle = getDongle(True)

# Have ledger sign Test Transaction.
#result = dongle.exchange(bytearray.fromhex(apduMessage))
#print("Result:")
#print(binascii.hexlify(result).decode())
result = dongle.exchange(bytearray.fromhex(apduMessage1))
result = dongle.exchange(bytearray.fromhex(apduMessage2))
print("Result:")
print(binascii.hexlify(result).decode())
	
