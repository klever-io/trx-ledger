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
# Test Transaction Freeze
transactionFreeze = "0B"+"57d909b4f73245c72c6ed37505b4ed3bcd5f08ea1ca7b148aeb3902a723c5991"
transactionFreezeSignature = "fc9066cf4ad72a339d5762579366347bd4252997ea83e953f31f58d9066ffeb60986a18ba9e6b10df05cbbf0c5f877f38fe9e2cba75e7c8c928753f75afb45e101"
# Test Transaction UnFreeze
transactionUnFreeze = "0C"+"0A740A02C0092208DB191266D08A99FB40C8D18BECBF2C5A53080C124F0A34747970652E676F6F676C65617069732E636F6D2F70726F746F636F6C2E556E667265657A6542616C616E6365436F6E747261637412170A1541C8599111F29C1E1E061265B4AF93EA1F274AD78A70809AE4EC9DD8FE9B15"
transactionUnSignature = "4fe3aa450b89ff6108233685f758d0ddb78d299efe23bcda756d064e4451fa310f55710d739a950c1c36a558eb6edaa7a7dcd796f72688bbfa0cdfc6620dbc8c01"
# Test Create Token
transactionNewToken = "06"+"3241c33288fc14c9c78fd451d4fe7c6353aecb697bfb68afdb2a1237a18b2482"
transactionNewTokenSignature = "448813c74ef59f2e06f7877eb45f778db799713c3a61b4418e38d683f206ae2b415add15c939f0f247c9e272f2516891b2424b8186804d0f860c025bb49dc76401"
# Test Vote
transactionVote = "08"+"2f8c9acad4c25061c058ce5e26f671eade1ef8e854f37be5c6f03f941014e290"
transactionVoteSignature = "d7a295f9ca8a059f22b4ff1b02715876c2d006614c9bb242afc0df64f56043fe42d9f8ab15d275ca270cc09fb4082fa9852e7533148a9e2855b53377855700de01"
# Test Participate Token
transactionParticipateToken = "09"+""
transactionParticipateTokenSignature = ""
# Test Create Witness
transactionCreateWitness = "05"+"f789ad4342e87d318311010398b9a3be258cc01e3021f1c888ee981274137bd8"
transactionCreateWitnessSignature = "d07c25ce50b225f9b9ab014f3b4cc4b5aeb9242fd341dbd9a8a047f5d15bb25359f80b1f04ba731f8ca8b620d6122d95ecc37f32793179f3421031665947aeaa01"

transactionHash = list()
transactionHash.append(transactionFreeze)
transactionHash.append(transactionUnFreeze)
transactionHash.append(transactionNewToken)
transactionHash.append(transactionVote)
#transactionHash.append(transactionParticipateToken)
transactionHash.append(transactionCreateWitness)

transactionHashSignature = list()
transactionHashSignature.append(transactionFreezeSignature)
transactionHashSignature.append(transactionUnSignature)
transactionHashSignature.append(transactionNewTokenSignature)
transactionHashSignature.append(transactionVoteSignature)
#transactionHashSignature.append(transactionParticipateTokenSignature)
transactionHashSignature.append(transactionCreateWitnessSignature)

print("-= Tron Ledger =-")
print("Request Signature")

dongle = getDongle(True)
for idx, message in enumerate(transactionHash):
	# Create APDU message.
	# CLA 0xE0
	# INS 0x07 	SIGN Hash
	# P1 0x00	NO USER CONFIRMATION
	# P2 0x00  	NO CHAIN CODE
	apduMessage = "E0070000" + '{:02x}'.format(int(len(donglePath) / 2) + 1 + int(len(message) / 2)) + '{:02x}'.format(int(len(donglePath) / 4 / 2)) +  donglePath + message
	result = dongle.exchange(bytearray.fromhex(apduMessage))
	if binascii.hexlify(result[0:65]).decode()==transactionHashSignature[idx]:
		print("Signature Validated!")
	else:
		print("Signature Error! "+ idx)


