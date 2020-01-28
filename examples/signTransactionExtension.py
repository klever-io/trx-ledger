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


transactionBIG1 = "0a02e85a2208c2b05ed1144dbfb240d8b9c98bf52d5ad901080412d4010a30747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e566f74655769746e657373436f6e7472616374129f010a1541978dbd103cfe59c35e753d09dd44ae1ae64621c7121a0a154167e39013be3cdd38"
transactionBIG2 = "14bed152d7439fb5b679140910e80712190a15412d7bdb9846499a2e5e6c5a7e6fb05731c83107c7106412190a1541c189fa6fc9"
transactionBIG3 = "ed7a3580c3fe291915d5c6a6259be7100a12190a154138e3e3a163163db1f6cfceca1d1c64594dd1f0ca100112190a154178c842"
transactionBIG4 = "ee63b253f8f0d2955bbc582c661a078c9d100170aa80c68bf52d"

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

print("Signature: {}".format(binascii.hexlify(result4[0:65]).decode()))
