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
transactionRaw = "0A7A0A024166220832A4175F2B12471540E0D49DBDC32C5A59080B12550A32747970652E676F6F676C65617069732E636F6D2F70726F746F636F6C2E467265657A6542616C616E6365436F6E7472616374121F0A154167E39013BE3CDD3814BED152D7439FB5B6791409108094EBDC03180370809AB2F491BEDC9D15"

transactionRawFIRST = "0A7A0A024166220832A4175F2B12475F2B12471540E0D49DBDC32C5A59080B12550A32747970652E676F6F676C65617069732E636F6D2F70726F746F636F6C2E467265657A6542616C616E6365436F6E7472616374121F0A154167"
transactionRawEND = "E39013BE3CDD3814BED152D7439FB5B6791409108094EBDC03180370809AB2F491BEDC9D15"

# Create APDU message.
# CLA 0xE0
# INS 0x04 	SIGN
apduMessage = "E0041000" + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionRaw) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionRaw
dongle = getDongle(True)
result = dongle.exchange(bytearray.fromhex(apduMessage))
print(binascii.hexlify(result[0:65]).decode())


apduMessage = "E0040000" + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionRawFIRST) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionRawFIRST
result = dongle.exchange(bytearray.fromhex(apduMessage))
print(binascii.hexlify(result[0:65]).decode())

apduMessage = "E0049000" + '{:02x}'.format(  int(len(transactionRawEND) / 2)) +  transactionRawEND
result = dongle.exchange(bytearray.fromhex(apduMessage))
print(binascii.hexlify(result[0:65]).decode())



#7f778af3dfdf41207301e4a05b2371737a57aff6eaf40b74bcedd737c26b7f390fb663e7087d6a49d8d304189e52e08bfbeeba713d8dca95cacf2388aaa01c4800
