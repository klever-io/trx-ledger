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


# Create APDU message.
transactionRaw = "0a027d52220889fd90c45b71f24740e0bcb0f2be2c5a67080112630a2d747970"   \
                     "652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e5472616e7366"\
                     "6572436f6e747261637412320a1541c8599111f29c1e1e061265b4af93ea1f27"\
                     "4ad78a1215414f560eb4182ca53757f905609e226e96e8e1a80c18c0843d70d0"\
                     "f5acf2be2c"

signatureCheck = "cd01fcd0a4f0bb9a55a43d57ae1c955374f2540ff931307029e4c1fb80a6dc91"   \
                     "3185edd8a4dfda2d03aad569b856cfb3ed9db387b6589451797ff01c9c353583"\
                     "01"

apduMessage = "E0041000" + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionRaw) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionRaw
apdu = bytearray.fromhex(apduMessage)

print("-= Tron Ledger =-")
print("Sign Transaction")

dongle = getDongle(True)
print(apduMessage.strip())
result = dongle.exchange(bytearray.fromhex(apduMessage))
print(binascii.hexlify(result[0:65]))
if binascii.hexlify(result[0:65]).decode()==signatureCheck:
	print("Signature Validated!")
else:
	print("Signature Error!")