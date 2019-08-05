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

accounts = [{
        "path": parse_bip32_path("44'/195'/0'/0/0"),
        },
        {
        "path": parse_bip32_path("44'/195'/1'/0/0"),
        }]

# Get Addresses
logger.debug('-= Tron Ledger =-')
logger.debug('Requesting Public Keys...')
dongle = getDongle(True)
for i in range(2):
    result = dongle.exchange(apduMessage(0x02,0x00,0x00,accounts[i]['path'], ""))
    size=result[0]
    if size == 65 :
        accounts[i]['publicKey'] = result[1:1+size].hex()
        size=result[size+1]
        if size == 34 :
            accounts[i]['address'] = result[67:67+size].decode()
            accounts[i]['addressHex'] = address_hex(accounts[i]['address'])
        else:
            logger.error('Error... Address Size: {:d}'.format(size))
    else:
        logger.error('Error... Public Key Size: {:d}'.format(size))
        

logger.debug('Test Accounts:')
for i in range(2):
    logger.debug('- Public Key {}: {}'.format(i, accounts[i]['publicKey']))
    logger.debug('- Address {}: {}'.format(i,accounts[i]['address']))


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
   Tron SmartContract Custom Messages tests
''')

# check if device have custom contracts enable
result = dongle.exchange(bytearray.fromhex("E0060000FF"))
customAllowed = result[0] & 0x02
if customAllowed==0:
    print("Custom Contract not allowed, test should fail...")
    sys.exit(0)

####################
# TWM Deposit TRX  #
####################
logger.debug('\n\SmartContract Trigger: Deposit TRX in TWM Contract')
data = '{:08x}'.format(0xd0e30db0)
tx = stub.TriggerContract(contract.TriggerSmartContract(
        owner_address=bytes.fromhex(accounts[1]['addressHex']),
        contract_address=bytes.fromhex(address_hex("TTg3AAJBYsDNjx5Moc5EPNsgJSa4anJQ3M")),
        call_value=1000000,
        data=bytes.fromhex(data)
        ))

raw_tx, result = ledgerSign(accounts[1]['path'],tx.transaction)
tx.transaction.signature.extend([bytes(result[0:65])])
#r = stub.BroadcastTransaction(tx.transaction)

validSignature, txID = validateSignature.validate(raw_tx,result[0:65],accounts[1]['publicKey'][2:])
logger.debug('- RAW: {}'.format(raw_tx))
logger.debug('- txID: {}'.format(txID))
logger.debug('- Signature: {}'.format(binascii.hexlify(result[0:65])))
if (validSignature):
    logger.debug('- Valid: {}'.format(validSignature))
else:
    logger.error('- Valid: {}'.format(validSignature))
    sys.exit(0)


######################
# TWM Deposit Token  #
######################
logger.debug('\n\SmartContract Trigger: Deposit BTT in TWM Contract')
data = '{:08x}'.format(0xd0e30db0)
tx = stub.TriggerContract(contract.TriggerSmartContract(
        owner_address=bytes.fromhex(accounts[1]['addressHex']),
        contract_address=bytes.fromhex(address_hex("TTg3AAJBYsDNjx5Moc5EPNsgJSa4anJQ3M")),
        call_token_value=1000000,
        token_id=1002000,
        data=bytes.fromhex(data)
        ))

raw_tx, result = ledgerSign(accounts[1]['path'],tx.transaction)
tx.transaction.signature.extend([bytes(result[0:65])])
#r = stub.BroadcastTransaction(tx.transaction)

validSignature, txID = validateSignature.validate(raw_tx,result[0:65],accounts[1]['publicKey'][2:])
logger.debug('- RAW: {}'.format(raw_tx))
logger.debug('- txID: {}'.format(txID))
logger.debug('- Signature: {}'.format(binascii.hexlify(result[0:65])))
if (validSignature):
    logger.debug('- Valid: {}'.format(validSignature))
else:
    logger.error('- Valid: {}'.format(validSignature))
    sys.exit(0)

####################
# TWM Withdraw TRX #
####################
logger.debug('\n\SmartContract Trigger: Withdraw TRX in TWM Contract')
data = '{:08x}{:064x}'.format(
    0x0a857040,
    int(10000)
    )
tx = stub.TriggerContract(contract.TriggerSmartContract(
        owner_address=bytes.fromhex(accounts[1]['addressHex']),
        contract_address=bytes.fromhex(address_hex("TTg3AAJBYsDNjx5Moc5EPNsgJSa4anJQ3M")),
        data=bytes.fromhex(data)
        ))

raw_tx, result = ledgerSign(accounts[1]['path'],tx.transaction)
tx.transaction.signature.extend([bytes(result[0:65])])
#r = stub.BroadcastTransaction(tx.transaction)

validSignature, txID = validateSignature.validate(raw_tx,result[0:65],accounts[1]['publicKey'][2:])
logger.debug('- RAW: {}'.format(raw_tx))
logger.debug('- txID: {}'.format(txID))
logger.debug('- Signature: {}'.format(binascii.hexlify(result[0:65])))
if (validSignature):
    logger.debug('- Valid: {}'.format(validSignature))
else:
    logger.error('- Valid: {}'.format(validSignature))
    sys.exit(0)



#######################
# TWM Withdraw Token  #
#######################
logger.debug('\n\SmartContract Trigger: Withdraw BTT in TWM Contract')
data = '{:08x}{:064x}{:064x}'.format(
    0xa1afaf8e,
    int(1002000),
    int(1000000),
    )
tx = stub.TriggerContract(contract.TriggerSmartContract(
        owner_address=bytes.fromhex(accounts[1]['addressHex']),
        contract_address=bytes.fromhex(address_hex("TTg3AAJBYsDNjx5Moc5EPNsgJSa4anJQ3M")),
        data=bytes.fromhex(data)
        ))

raw_tx, result = ledgerSign(accounts[1]['path'],tx.transaction)
tx.transaction.signature.extend([bytes(result[0:65])])
#r = stub.BroadcastTransaction(tx.transaction)

validSignature, txID = validateSignature.validate(raw_tx,result[0:65],accounts[1]['publicKey'][2:])
logger.debug('- RAW: {}'.format(raw_tx))
logger.debug('- txID: {}'.format(txID))
logger.debug('- Signature: {}'.format(binascii.hexlify(result[0:65])))
if (validSignature):
    logger.debug('- Valid: {}'.format(validSignature))
else:
    logger.error('- Valid: {}'.format(validSignature))
    sys.exit(0)
