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

dongle = getDongle(True)

# Create APDU message.
transactionRaw = "0a02313e22082b3a7ced42b3ae5c4080f8c4c6a62d5a68082c12640a38747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e45786368616e67655472616e73616374696f6e436f6e747261637412280a15417773ff0ebd2d2c85761db01ae2b00c417bf1539310051a0731303030393333200128cef5227083b8c1c6a62d"
# Exchange 5 TWM-TRX
exchangeInfo = "08051207313030303933331a0f54726f6e57617463684d61726b657420002a015f32035452583806424730450221008a271b066b25717d15e750e8d50dab84144c3ff453989be118561ed43c8976a2022040965941a6590cde4989896312aa58e1f8d3b9ac9501b4e641825f3e12c7c50c"

signatureCheck = "a1b321a521ff05b7159fee36c34c5918a7082125ef4152debf4ab73ffd366e8f4beec9d21c35c3d0c90db6de36f3b408a3f1449dc28f08b2a5a8ff04c95c007801"

# P1 = 0x00 - first message
apduMessage1 = "E004{:02x}00".format(0x00) + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionRaw) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionRaw
# Exchange info
# To add info P1 = 0xA0 | 0x08 END | Index = 0
apduMessage2 = "E004{:02x}00".format(0xA0 | 0x08 | 0x00) +  '{:02x}'.format(int(len(exchangeInfo) / 2) ) + exchangeInfo

print("-= Tron Ledger =-")
print("Sign Exchange Transaction")

result = dongle.exchange(bytearray.fromhex(apduMessage1))
print(apduMessage2.strip())
result = dongle.exchange(bytearray.fromhex(apduMessage2))
print(binascii.hexlify(result[0:65]))
if binascii.hexlify(result[0:65]).decode()==signatureCheck:
	print("Signature Validated!")
else:
	print("Signature Error!")