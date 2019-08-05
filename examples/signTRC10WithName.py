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
transactionRaw = "0a02348322084be5ea8bc5bd43a940c0dfdec7a62d5a730802126f0a32747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e5472616e736665724173736574436f6e747261637412390a07313030303136361215417773ff0ebd2d2c85761db01ae2b00c417bf153931a1541c8599111f29c1e1e061265b4af93ea1f274ad78a200a70e6a6dbc7a62d"
# Token Name: CryptoChainToken Code: 1000166 Decimals: 0
tokenInfo = "0a0b43727970746f436861696e10001a4730450221008417d04d1caeae31f591ae50f7d19e53e0dfb827bd51c18e66081941bf04639802203c73361a521c969e3fd7f62e62b46d61aad00e47d41e7da108546d954278a6b1"

signatureCheck = "c1a32ee50f112f2c38fd7f75961412f9af60d69adb822c507e2442a01275ff3738447c9392aaaaebefde0768936958cbf78c04a896c36b453a220ad5d07d555a00"

# P1 = 0x00 - first message
apduMessage1 = "E004{:02x}00".format(0x00) + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(transactionRaw) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) + donglePath + transactionRaw
# Token info
# To add info P1 = 0xA0 | 0x08 END | Index = 0
apduMessage2 = "E004{:02x}00".format(0xA0 | 0x08 | 0x00) +  '{:02x}'.format(int(len(tokenInfo) / 2) ) + tokenInfo

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