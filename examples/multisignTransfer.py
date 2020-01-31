#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
sys.path.append("./examples/proto")

from pprint import pprint
import logging
import time

from ledgerblue.comm import getDongle
import argparse
from base import parse_bip32_path

import validateSignature
import binascii
import base58

logging.basicConfig(level=logging.DEBUG, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger()

# Start Ledger
dongle = getDongle(True)


def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in range(0, len(l), n):
        yield l[i:i + n]

def apduMessage(INS, P1, P2, PATH, MESSAGE):
    hexString = ""
    if PATH:
        hexString = "E0{:02x}{:02x}{:02x}{:02x}{:02x}{}".format(INS,P1,P2,(len(PATH)+len(MESSAGE))//2+1,len(PATH)//4//2,PATH+MESSAGE)
    else:
        hexString = "E0{:02x}{:02x}{:02x}{:02x}{}".format(INS,P1,P2,len(MESSAGE)//2,MESSAGE)
    print(hexString)
    return bytearray.fromhex(hexString)

def ledgerSign(PATH, tx, tokenSignature=[]):
    raw_tx = tx.raw_data.SerializeToString().hex()
    # Sign in chunks
    chunkList = list(chunks(raw_tx,420))
    if len(tokenSignature)>0:
        chunkList.extend(tokenSignature)

    # P1 = P1_FIRST = 0x00
    if len(chunkList)>1:
        result = dongle.exchange(apduMessage(0x04,0x00,0x00, PATH, chunkList[0]))
    else:
        result = dongle.exchange(apduMessage(0x04,0x10,0x00, PATH, chunkList[0]))

    for i in range(1,len(chunkList)-1-len(tokenSignature)):
        # P1 = P1_MODE = 0x80
        result = dongle.exchange(apduMessage(0x04,0x80,0x00, None, chunkList[i]))
    
    for i in range(0,len(tokenSignature)-1):
        result = dongle.exchange(apduMessage(0x04,0xA0 | (0x00+i), 0x00, None, tokenSignature[i]))
       
    # P1 = P1_LAST = 0x90
    if len(chunkList)>1:
        if len(tokenSignature)>0:
            result = dongle.exchange(apduMessage(0x04,0xA0 | 0x08 | (0x00+len(tokenSignature)-1),0x00, None, chunkList[len(chunkList)-1]))
        else:
            result = dongle.exchange(apduMessage(0x04,0x90,0x00, None, chunkList[len(chunkList)-1]))

    return raw_tx, result

def address_hex(address):
    return base58.b58decode_check(address).hex().upper()

# Get Addresses
logger.debug('-= Tron Ledger =-')

'''
Tron Protobuf
'''
from api import api_pb2 as api
from core import Contract_pb2 as contract
from api.api_pb2_grpc import WalletStub
from core import Tron_pb2 as tron
from google.protobuf.any_pb2 import Any
import grpc

# Start Channel and WalletStub
channel = grpc.insecure_channel("grpc.trongrid.io:50051")
stub = WalletStub(channel)

logger.debug('''
   Tron MultiSign tests
''')

tx = stub.CreateTransaction2(
        contract.TransferContract(
            owner_address=bytes.fromhex(address_hex("TUEZSdKsoDHQMeZwihtdoBiN46zxhGWYdH")),
            to_address=bytes.fromhex(address_hex("TPnYqC2ukKyhEDAjqRRobSVygMAb8nAcXM")),
            amount=100000
        )
    )  
# use permission 2
tx.transaction.raw_data.contract[0].Permission_id=2



raw_tx, sign1 = ledgerSign(parse_bip32_path("44'/195'/0'/0/0"),tx.transaction)
raw_tx, sign2 = ledgerSign(parse_bip32_path("44'/195'/1'/0/0"),tx.transaction)

tx.transaction.signature.extend([bytes(sign1[0:65])])
tx.transaction.signature.extend([bytes(sign2[0:65])])

r = stub.BroadcastTransaction(tx.transaction)

if r.result == True:
	print("Success")
else:
	print("Fail")
