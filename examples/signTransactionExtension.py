#!/usr/bin/env python

from ledgerblue.comm import getDongle
import argparse
from base import parse_bip32_path
import binascii

parser = argparse.ArgumentParser()
parser.add_argument('--path', help="BIP32 path to retrieve. e.g. \"44'/195'/0'/0/0\".")
args = parser.parse_args()

if args.path == None:
	args.path = "44'/195'/0'/0/0"

donglePath = parse_bip32_path(args.path)


transactionRaw = "0a02ee332208c90c7f40dfbdc51540e0dfe3ada62d5a860108041281010a30747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e566f74655769746e657373436f6e7472616374124d0a15417773ff0ebd2d2c85761db01ae2b00c417bf1539312190a154167e39013be3cdd3814bed152d7439fb5b6791409100212190a1541c189fa6fc9ed7a3580c3fe291915d5c6a6259be710027089a2e0ada62d"
transactionRawFIRST = "0a02ee332208c90c7f40dfbdc51540e0dfe3ada62d5a860108041281010a30747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e566f74655769746e657373436f6e7472616374124d0a15417773ff0ebd2d2c85761db01ae2b00c417bf1539312190a154167e39013be3cdd3814"
transactionRawEND = "bed152d7439fb5b6791409100212190a1541c189fa6fc9ed7a3580c3fe291915d5c6a6259be710027089a2e0ada62d"


transactionBIG1 = "0a02edd92208ac1579fd507b8c8b40b0a2d3ada62d5af301080412ee010a30747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e566f74655769746e657373436f6e747261637412b9010a15417773ff0ebd2d2c85761db01ae2b00c417bf1539312190a154167e39013be3cdd38"
transactionBIG2 = "14bed152d7439fb5b6791409100112190a15414d1ef8673f916debb7e2515a8f3ecaf2611034aa100112190a154184399fc6c110"
transactionBIG3 = "1541b3ee0112190aa98edc11a6efb146e86a3e153d0a0933100112190a1541496e85711fa3b7ba5a093af635269a67230ac2c714"
transactionBIG4 = "81e8864f0fc1f601b836b74c40548287100112190a1541c189fa6fc9ed7a3580c3fe291915d5c6a6259be710017082f1cfada62d"

signatureTest = "7b74891516d57580ab669d8d4dd84cbf202108affd9d7102b33b6d81c8fa3796678512f6e6db923bac96f20fa3ba5f06fab3007678ce354f0a4ef7d37e3f7dcd01"

# Create APDU message.
# CLA 0xE0
# INS 0x04 	SIGN
# P1 = P1_SIGN = 0x10
dongle = getDongle(True)

apduMessage = "E0041000" + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionRaw) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionRaw
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


# Sign in 4 batch
# P1 = P1_FIRST = 0x00
apduMessage = "E0040000" + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionBIG1) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionBIG1
result1 = dongle.exchange(bytearray.fromhex(apduMessage))
# P1 = P1_MODE = 0x80
apduMessage = "E0048000" + '{:02x}'.format(  int(len(transactionBIG2) / 2)) +  transactionBIG2
result2 = dongle.exchange(bytearray.fromhex(apduMessage))
# P1 = P1_MODE = 0x80
apduMessage = "E0048000" + '{:02x}'.format(  int(len(transactionBIG3) / 2)) +  transactionBIG3
result3 = dongle.exchange(bytearray.fromhex(apduMessage))
# P1 = P1_LAST = 0x90
apduMessage = "E0049000" + '{:02x}'.format(  int(len(transactionBIG4) / 2)) +  transactionBIG4
result4 = dongle.exchange(bytearray.fromhex(apduMessage))

if (binascii.hexlify(result4[0:65]).decode()==signatureTest):
	print("Hash signature match")
else:
	print("Hash signature error")