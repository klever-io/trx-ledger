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
# Compare two signatures using chunk send data
# Contract Type Freeze Asset
transactionRaw = "5A6A080412660A30747970652E676F6F676C65617069732E636F6D2F70726F746F636F6C2E566F74655769746E657373436F6E747261637412320A154167E39013BE3CDD3814BED152D7439FB5B679140912190A154167E39013BE3CDD3814BED152D7439FB5B67914091064"

transactionRawFIRST = "5A6A080412660A30747970652E676F6F676C65617069732E636F6D2F70726F746F636F6C2E566F74655769746E657373436F6E747261637412320A154167E39013BE3CDD3814BED152D7439FB5B679140912190A154167E39013BE3CDD3814BED152D7439F"
transactionRawEND = "B5B67914091064"

# Create APDU message.
# CLA 0xE0
# INS 0x04 	SIGN
# P1 = P1_SIGN = 0x10
apduMessage = "E0041000" + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionRaw) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionRaw
dongle = getDongle(True)
result1 = dongle.exchange(bytearray.fromhex(apduMessage))
# P1 = P1_FIRST = 0x00
apduMessage = "E0040000" + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionRawFIRST) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionRawFIRST
result = dongle.exchange(bytearray.fromhex(apduMessage))
# P1 = P1_LAST = 0x90
apduMessage = "E0049000" + '{:02x}'.format(  int(len(transactionRawEND) / 2)) +  transactionRawEND
result2 = dongle.exchange(bytearray.fromhex(apduMessage))

if (binascii.hexlify(result1[0:65]).decode()==binascii.hexlify(result2[0:65]).decode()):
	print("Hash signature match")
else:
	print("Hash signature error")


#7f778af3dfdf41207301e4a05b2371737a57aff6eaf40b74bcedd737c26b7f390fb663e7087d6a49d8d304189e52e08bfbeeba713d8dca95cacf2388aaa01c4800
