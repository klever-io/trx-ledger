#!/usr/bin/env python3
'''
Ensure speculos is running...
export LEDGER_MNEMONIC="abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
./speculos.py --model nanos apps/app.elf --sdk 1.6 --seed "$LEDGER_MNEMONIC"
Usage: pytest -v -s ./tests/test_trx.py
'''

import binascii
import pytest
import os
import socket
import sys
import base58
import time
import struct

from bip32utils import BIP32Key, BIP32_HARDEN
from mnemonic import Mnemonic
from eth_keys import keys
from Crypto.Hash import keccak

from ledgerblue.comm import getDongle

sys.path.append("../examples")
sys.path.append("../examples/proto")
from base import parse_bip32_path
import validateSignature

'''
Tron Protobuf
'''
from core import Contract_pb2 as contract
from core import Tron_pb2 as tron
from google.protobuf.any_pb2 import Any

class App:
    # default APDU TCP server
    HOST, PORT = ('127.0.0.1', 9999)

    def __init__(self):
        self.accounts = [None, None]
        self.hardware = True
        # Init account with default address to compare with ledger
        for i in range(2):
            HD = self.getPrivateKey(self._mnemonic(), i, 0, 0)
            key = keys.PrivateKey(HD.PrivateKey())
            self.accounts[i] = {
                    "path": parse_bip32_path("44'/195'/{}'/0/0".format(i)),
                    "privateKeyHex": HD.PrivateKey().hex(),
                    "key": key,
                    "addressHex": "41" + key.public_key.to_checksum_address()[2:].upper(),
                    "publicKey": key.public_key.to_hex().upper()
                }

    def address_hex(self, address):
        return base58.b58decode_check(address).hex().upper()

    def _mnemonic(self):
        MNEMONIC = os.getenv("LEDGER_MNEMONIC")
        if MNEMONIC is None:
            return "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        return MNEMONIC

    def getPrivateKey(self, seed, account, change, address_index):
        m = BIP32Key.fromEntropy(Mnemonic.to_seed(seed))
        m = m.ChildKey(44 + BIP32_HARDEN)
        m = m.ChildKey(195 + BIP32_HARDEN)
        m = m.ChildKey(account + BIP32_HARDEN)
        m = m.ChildKey(change)
        m = m.ChildKey(address_index)
        return m

    def encodeVariant(self, value):
        out = bytes()
        while True:
            byte = value & 0x7F
            value = value >> 7
            if value == 0:
                out += bytes([byte])
                break
            else:
                out += bytes([byte | 0x80])
        return out.hex()

    def _recvall(self, s, size):
        data = b''
        while size > 0:
            try:
                tmp = s.recv(size)
            except ConnectionResetError:
                tmp = b''
            if len(tmp) == 0:
                print("[-] connection with client closed", file=sys.stderr)
                return None
            data += tmp
            size -= len(tmp)
        return data

    def apduMessage(self, INS, P1, P2, PATH, MESSAGE):
        hexString = ""
        if PATH:
            hexString = "E0{:02x}{:02x}{:02x}{}{:02x}{}".format(INS,P1,P2,self.encodeVariant((len(PATH)+len(MESSAGE))//2+1),len(PATH)//4//2,PATH+MESSAGE)
        else:
            hexString = "E0{:02x}{:02x}{:02x}{}{}".format(INS,P1,P2,self.encodeVariant(len(MESSAGE)//2),MESSAGE)
        print(hexString)
        return binascii.unhexlify(hexString)
    
    def getAccount(self, number):
        return self.accounts[number]

    def packContract(self, contractType, newContract, data = None):
        tx = tron.Transaction()
        tx.raw_data.timestamp = 1575712492061
        tx.raw_data.expiration = 1575712551000
        tx.raw_data.ref_block_hash = binascii.unhexlify("95DA42177DB00507")
        tx.raw_data.ref_block_bytes = binascii.unhexlify("3DCE")
        if data:
            tx.raw_data.data = data

        c = tx.raw_data.contract.add()
        c.type = contractType
        param = Any()
        param.Pack(newContract)
        c.parameter.CopyFrom(param)
        return tx.raw_data.SerializeToString().hex()



    def _recv_packet(self, s):
        data = self._recvall(s, 4)
        if data is None:
            return None

        size = int.from_bytes(data, byteorder='big')
        packet = self._recvall(s, size)
        status = int.from_bytes(self._recvall(s, 2), 'big')
        return packet, status

    def _exchange(self, s, packet, verbose):
        packet = len(packet).to_bytes(4, 'big') + packet
        if verbose:
            print('[>]', binascii.hexlify(packet))
        s.sendall(packet)

        data, status = self._recv_packet(s)
        if verbose:
            print('[<]', binascii.hexlify(data), hex(status))

        return data, status

    def exchangeD(self, packet, verbose=False):
        dongle = getDongle(verbose)
        try:
            resp = dongle.exchange(packet)
            dongle.close()
            return resp, 0x9000
        except:
            dongle.close()
            return "", 0x6800

    def exchange(self, packet, verbose=False):
        if (self.hardware): return self.exchangeD(packet, verbose)
        '''Exchange a packet with the app APDU TCP server.'''

        for i in range(0, 5):
            try:
                s = socket.create_connection((self.HOST, self.PORT), timeout=1.0)
                connected = True
                break
            except ConnectionRefusedError:
                time.sleep(0.2)
                connected = False

        assert connected
        s.settimeout(0.5)

        try:
            data, status = self._exchange(s, packet, verbose)
        except socket.timeout:
            # unfortunately, the app can take some time to start...
            # let's give a 2nd try in that case
            data, status = self._exchange(s, packet, verbose)

        s.close()
        return data, status


class TestTRX:
    '''Test TRX app.'''
    
    '''Send a get_version APDU to the TRX app.'''
    def test_trx_get_version(self, app):    
        packet = binascii.unhexlify('E0060000FF')
        data, status = app.exchange(packet)
        assert(data[1:].hex() == "000105")


    def test_trx_get_addresses(self, app):
        for i in range(2):
            pack = app.apduMessage(0x02,0x00,0x00,app.getAccount(i)['path'], "")
            data, status = app.exchange(pack)
            assert(data[0] == 65)
            assert(app.accounts[i]['publicKey'][2:] == data[2:66].hex().upper())
            assert(data[66] == 34)
            assert(app.accounts[i]['addressHex'] == app.address_hex(data[67:101].decode()))


    def test_trx_send(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.TransferContract,
            contract.TransferContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                to_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                amount=100000000
            )
        )
        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        assert(status == 0x9000)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_send_with_data_field(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.TransferContract,
            contract.TransferContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                to_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                amount=100000000
            ),
            b'CryptoChain-TronSR Ledger Transactions Tests'
        )
        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_send_wrong_path(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.TransferContract,
            contract.TransferContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                to_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                amount=100000000
            )
        )
        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(1)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == False)


    def test_trx_send_asset_without_name(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.TransferAssetContract,
            contract.TransferAssetContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                to_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                amount=1000000,
                asset_name="1002000".encode()
            )
        )
        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_send_asset_with_name(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.TransferAssetContract,
            contract.TransferAssetContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                to_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                amount=1000000,
                asset_name="1002000".encode()
            )
        )
        # BTT token ID 1002000 - 6 decimals
        tokenSignature = "0a0a426974546f7272656e7410061a46304402202e2502f36b00e57be785fc79ec4043abcdd4fdd1b58d737ce123599dffad2cb602201702c307f009d014a553503b499591558b3634ceee4c054c61cedd8aca94c02b"
        pack = app.apduMessage(0x04,0x00,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        pack = app.apduMessage(0x04,0xA0 | 0x08 | 0x00,0x00, None, tokenSignature)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_send_asset_with_name_wrong_signature(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.TransferAssetContract,
            contract.TransferAssetContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                to_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                amount=1000000,
                asset_name="1002000".encode()
            )
        )
        # BTT token ID 1002000 - 6 decimals
        tokenSignature = "0a0a4e6577416765436f696e10001a473045022100d8d73b4fad5200aa40b5cdbe369172b5c3259c10f1fb17dfb9c3fa6aa934ace702204e7ef9284969c74a0e80b7b7c17e027d671f3a9b3556c05269e15f7ce45986c8"
        pack = app.apduMessage(0x04,0x00,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        pack = app.apduMessage(0x04,0xA0 | 0x08 | 0x00,0x00,None, tokenSignature)
        data, status = app.exchange(pack)
        # expected fail
        assert( status == 0x6800 )


    def test_trx_exchange_create(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.ExchangeCreateContract,
            contract.ExchangeCreateContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                first_token_id="_".encode(),
                first_token_balance=10000000000,
                second_token_id="1000166".encode(),
                second_token_balance=10000000
            )
        )
        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_exchange_create_with_token_name(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.ExchangeCreateContract,
            contract.ExchangeCreateContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                first_token_id="_".encode(),
                first_token_balance=10000000000,
                second_token_id="1000166".encode(),
                second_token_balance=10000000
            )
        )
        pack = app.apduMessage(0x04,0x00,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        tokenSignature = ["0a0354525810061a463044022037c53ecb06abe1bfd708bd7afd047720b72e2bfc0a2e4b6ade9a33ae813565a802200a7d5086dc08c4a6f866aad803ac7438942c3c0a6371adcb6992db94487f66c7",
                  "0a0b43727970746f436861696e10001a4730450221008417d04d1caeae31f591ae50f7d19e53e0dfb827bd51c18e66081941bf04639802203c73361a521c969e3fd7f62e62b46d61aad00e47d41e7da108546d954278a6b1"]
        pack = app.apduMessage(0x04,0xA0 | 0x00 | 0x00, 0x00, None, tokenSignature[0])
        data, status = app.exchange(pack)
        pack = app.apduMessage(0x04,0xA0 | 0x08 | 0x01, 0x00, None, tokenSignature[1])
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_exchange_inject(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.ExchangeInjectContract,
            contract.ExchangeInjectContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                exchange_id=6,
                token_id="1000166".encode(),
                quant=10000000
                )
        )
        pack = app.apduMessage(0x04,0x00,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        exchangeSignature = "08061207313030303136361a0b43727970746f436861696e20002a015f3203545258380642473045022100fe276f30a63173b2440991affbbdc5d6d2d22b61b306b24e535a2fb866518d9c02205f7f41254201131382ec6c8b3c78276a2bb136f910b9a1f37bfde192fc448793"
        pack = app.apduMessage(0x04,0xA0 | 0x08 | 0x00, 0x00, None, exchangeSignature)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_exchange_withdraw(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.ExchangeWithdrawContract,
            contract.ExchangeWithdrawContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                exchange_id=6,
                token_id="1000166".encode(),
                quant=1000000
                )
        )
        pack = app.apduMessage(0x04,0x00,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        exchangeSignature = "08061207313030303136361a0b43727970746f436861696e20002a015f3203545258380642473045022100fe276f30a63173b2440991affbbdc5d6d2d22b61b306b24e535a2fb866518d9c02205f7f41254201131382ec6c8b3c78276a2bb136f910b9a1f37bfde192fc448793"
        pack = app.apduMessage(0x04,0xA0 | 0x08 | 0x00, 0x00, None, exchangeSignature)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_exchange_transaction(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.ExchangeTransactionContract,
            contract.ExchangeTransactionContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                exchange_id=6,
                token_id="1000166".encode(),
                quant=10000,
                expected=100
                )
        )
        pack = app.apduMessage(0x04,0x00,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        exchangeSignature = "08061207313030303136361a0b43727970746f436861696e20002a015f3203545258380642473045022100fe276f30a63173b2440991affbbdc5d6d2d22b61b306b24e535a2fb866518d9c02205f7f41254201131382ec6c8b3c78276a2bb136f910b9a1f37bfde192fc448793"
        pack = app.apduMessage(0x04,0xA0 | 0x08 | 0x00, 0x00, None, exchangeSignature)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)

    def test_trx_vote_witness(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.VoteWitnessContract,
            contract.VoteWitnessContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                votes=[
                    contract.VoteWitnessContract.Vote(
                        vote_address=bytes.fromhex(app.address_hex("TKSXDA8HfE9E1y39RczVQ1ZascUEtaSToF")),
                        vote_count=100
                    ),
                    contract.VoteWitnessContract.Vote(
                        vote_address=bytes.fromhex(app.address_hex("TE7hnUtWRRBz3SkFrX8JESWUmEvxxAhoPt")),
                        vote_count=100
                    ),
                    contract.VoteWitnessContract.Vote(
                        vote_address=bytes.fromhex(app.address_hex("TTcYhypP8m4phDhN6oRexz2174zAerjEWP")),
                        vote_count=100
                    ),
                    contract.VoteWitnessContract.Vote(
                        vote_address=bytes.fromhex(app.address_hex("TY65QiDt4hLTMpf3WRzcX357BnmdxT2sw9")),
                        vote_count=100
                    ),
                ]
            )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_vote_witness_more_than_5(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.VoteWitnessContract,
            contract.VoteWitnessContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                votes=[
                    contract.VoteWitnessContract.Vote(
                        vote_address=bytes.fromhex(app.address_hex("TKSXDA8HfE9E1y39RczVQ1ZascUEtaSToF")),
                        vote_count=100
                    ),
                    contract.VoteWitnessContract.Vote(
                        vote_address=bytes.fromhex(app.address_hex("TE7hnUtWRRBz3SkFrX8JESWUmEvxxAhoPt")),
                        vote_count=100
                    ),
                    contract.VoteWitnessContract.Vote(
                        vote_address=bytes.fromhex(app.address_hex("TTcYhypP8m4phDhN6oRexz2174zAerjEWP")),
                        vote_count=100
                    ),
                    contract.VoteWitnessContract.Vote(
                        vote_address=bytes.fromhex(app.address_hex("TY65QiDt4hLTMpf3WRzcX357BnmdxT2sw9")),
                        vote_count=100
                    ),
                    contract.VoteWitnessContract.Vote(
                        vote_address=bytes.fromhex(app.address_hex("TSzoLaVCdSNDpNxgChcFt9rSRF5wWAZiR4")),
                        vote_count=100
                    ),
                    contract.VoteWitnessContract.Vote(
                        vote_address=bytes.fromhex(app.address_hex("TSNbzxac4WhxN91XvaUfPTKP2jNT18mP6T")),
                        vote_count=100
                    ),
                ]
            )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        assert(status == 0x6800)


    def test_trx_freeze_balance_bw(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.FreezeBalanceContract,
            contract.FreezeBalanceContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                frozen_balance=10000000000,
                frozen_duration=3,
                resource=contract.BANDWIDTH
                )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_freeze_balance_energy(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.FreezeBalanceContract,
            contract.FreezeBalanceContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                frozen_balance=10000000000,
                frozen_duration=3,
                resource=contract.ENERGY
                )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_freeze_balance_delegate_energy(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.FreezeBalanceContract,
            contract.FreezeBalanceContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                frozen_balance=10000000000,
                frozen_duration=3,
                resource=contract.ENERGY,
                receiver_address=bytes.fromhex(app.getAccount(1)['addressHex']),
            )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_unfreeze_balance_bw(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.UnfreezeBalanceContract,
            contract.UnfreezeBalanceContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                resource=contract.BANDWIDTH,
            )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_unfreeze_balance_delegate_energy(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.UnfreezeBalanceContract,
            contract.UnfreezeBalanceContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                resource=contract.ENERGY,
                receiver_address=bytes.fromhex(app.getAccount(1)['addressHex']),
            )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_withdraw_balance(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.WithdrawBalanceContract,
            contract.WithdrawBalanceContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex'])
            )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_proposal_create(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.ProposalCreateContract,
            contract.ProposalCreateContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                parameters={1: 100000, 2: 400000}
            )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_proposal_approve(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.ProposalApproveContract,
            contract.ProposalApproveContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                proposal_id=10,
                is_add_approval=True
            )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_proposal_delete(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.ProposalDeleteContract,
            contract.ProposalDeleteContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                proposal_id=10,
            )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_account_update(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.AccountUpdateContract,
            contract.AccountUpdateContract(
                account_name=b'CryptoChainTest',
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
            )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_trc20_send(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.TriggerSmartContract,
            contract.TriggerSmartContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                contract_address=bytes.fromhex(app.address_hex("TBoTZcARzWVgnNuB9SyE3S5g1RwsXoQL16")),
                data=bytes.fromhex("a9059cbb000000000000000000000000364b03e0815687edaf90b81ff58e496dea7383d700000000000000000000000000000000000000000000000000000000000f4240")
            )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_trc20_approve(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.TriggerSmartContract,
            contract.TriggerSmartContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                contract_address=bytes.fromhex(app.address_hex("TBoTZcARzWVgnNuB9SyE3S5g1RwsXoQL16")),
                data=bytes.fromhex("095ea7b3000000000000000000000000364b03e0815687edaf90b81ff58e496dea7383d700000000000000000000000000000000000000000000000000000000000f4240")
            )
        )

        pack = app.apduMessage(0x04,0x10,0x00,app.getAccount(0)['path'], tx)
        data, status = app.exchange(pack)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_sign_message(self, app):
        # Magic define
        SIGN_MAGIC = b'\x19TRON Signed Message:\n'
        message = 'CryptoChain-TronSR Ledger Transactions Tests'.encode()
        encodedTx = struct.pack(">I", len(message)) + message

        pack = app.apduMessage(0x08,0x00,0x00,app.getAccount(0)['path'], encodedTx.hex())
        data, status = app.exchange(pack)
        
        signedMessage = SIGN_MAGIC + str(len(message)).encode() + message
        keccak_hash = keccak.new(digest_bits=256)
        keccak_hash.update(signedMessage)
        hash = keccak_hash.digest()
        
        validSignature = validateSignature.validateHASH(hash,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)

    # TODO: ECDH secrets


def pytest_generate_tests(metafunc):
    metafunc.parametrize('app', [App()], scope='class')
