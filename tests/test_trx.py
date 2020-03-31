#!/usr/bin/env python3
'''
Ensure speculos is running...
export LEDGER_MNEMONIC="abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
./speculos.py --model nanos apps/app.elf --sdk 1.6 --seed "$LEDGER_MNEMONIC"
Usage: pytest -v -s ./tests/test_trx.py
'''

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
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import ec

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
from google.protobuf.internal.decoder import _DecodeVarint32

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
            diffieHellman = ec.derive_private_key(int.from_bytes(HD.PrivateKey(), "big"), ec.SECP256K1(), default_backend())
            self.accounts[i] = {
                    "path": parse_bip32_path("44'/195'/{}'/0/0".format(i)),
                    "privateKeyHex": HD.PrivateKey().hex(),
                    "key": key,
                    "addressHex": "41" + key.public_key.to_checksum_address()[2:].upper(),
                    "publicKey": key.public_key.to_hex().upper(),
                    "dh": diffieHellman,
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

    def apduMessage(self, INS, P1, P2, MESSAGE):
        hexString = "E0{:02x}{:02x}{:02x}{:02x}{}".format(INS,P1,P2,len(MESSAGE)//2,MESSAGE)
        return bytes.fromhex(hexString)
    
    def getAccount(self, number):
        return self.accounts[number]

    def packContract(self, contractType, newContract, data = None, permission_id = None):
        tx = tron.Transaction()
        tx.raw_data.timestamp = 1575712492061
        tx.raw_data.expiration = 1575712551000
        tx.raw_data.ref_block_hash = bytes.fromhex("95DA42177DB00507")
        tx.raw_data.ref_block_bytes = bytes.fromhex("3DCE")
        if data:
            tx.raw_data.data = data

        c = tx.raw_data.contract.add()
        c.type = contractType
        param = Any()
        param.Pack(newContract)
        c.parameter.CopyFrom(param)

        if permission_id:
            c.Permission_id = permission_id

        return tx.raw_data.SerializeToString()

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
            print('[>]', packet.hex())
        s.sendall(packet)

        data, status = self._recv_packet(s)
        if verbose:
            print('[<]', data.hex(), hex(status))

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
    
    def get_next_length(self,tx):
        field, pos = _DecodeVarint32(tx,0)
        size, newpos = _DecodeVarint32(tx,pos)
        if (field&0x07==0): return newpos
        return size + newpos

    def sign(self, path, tx, signatures=[], verbose=False):
        max_length = 255
        offset = 0
        to_send = []
        start_bytes = []

        data = bytearray.fromhex(f"05{path}")
        while len(tx)>0:
            # get next message field
            newpos = self.get_next_length(tx)
            assert(newpos<max_length)
            if (len(data)+newpos) > max_length:
                # add chunk
                to_send.append(data.hex())
                data = bytearray()
                continue
            # append to data
            data.extend(tx[:newpos])
            tx = tx[newpos:]
        # append last
        to_send.append(data.hex())
        token_pos = len(to_send)
        to_send.extend(signatures)

        if len(to_send)==1:
            start_bytes.append(0x10)
        else:
            start_bytes.append(0x00)
            for i in range(1, len(to_send) - 1):
                if (i>=token_pos):
                    start_bytes.append(0xA0 | 0X00 | i-token_pos )
                else:
                    start_bytes.append(0x80)
            
            if not(signatures==None) and len(signatures)>0:
                start_bytes.append(0xa0 | 0x08 | len(signatures)-1)
            else:
                start_bytes.append(0x90)

        result = None
        for i in range(len(to_send)):
            pack = self.apduMessage(
                0x04,
                start_bytes[i],
                0x00,
                to_send[i]
            )
            result, status = self.exchange(pack, True)
            if not(status == 0x9000):
                return None, status

        return result, 0x9000
        # send signature if any


class TestTRX:
    '''Test TRX app.'''
    
    '''Send a get_version APDU to the TRX app.'''
    def test_trx_get_version(self, app):    
        pack = app.apduMessage(0x06,0x00,0x00,"FF")
        data, status = app.exchange(pack)
        assert(data[1:].hex() == "000105")


    def test_trx_get_addresses(self, app):
        for i in range(2):
            pack = app.apduMessage(0x02,0x00,0x00,f"05{app.getAccount(i)['path']}")
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
        data, status = app.sign(app.getAccount(0)['path'], tx)
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
        data, status = app.sign(app.getAccount(0)['path'], tx)
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
        data, status = app.sign(app.getAccount(0)['path'], tx)
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
        data, status = app.sign(app.getAccount(0)['path'], tx)
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
        tokenSignature = ["0a0a426974546f7272656e7410061a46304402202e2502f36b00e57be785fc79ec4043abcdd4fdd1b58d737ce123599dffad2cb602201702c307f009d014a553503b499591558b3634ceee4c054c61cedd8aca94c02b"]
        data, status = app.sign(app.getAccount(0)['path'], tx, tokenSignature)
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
        tokenSignature = ["0a0a4e6577416765436f696e10001a473045022100d8d73b4fad5200aa40b5cdbe369172b5c3259c10f1fb17dfb9c3fa6aa934ace702204e7ef9284969c74a0e80b7b7c17e027d671f3a9b3556c05269e15f7ce45986c8"]
        data, status = app.sign(app.getAccount(0)['path'], tx, tokenSignature)
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
        data, status = app.sign(app.getAccount(0)['path'], tx)
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
        tokenSignature = ["0a0354525810061a463044022037c53ecb06abe1bfd708bd7afd047720b72e2bfc0a2e4b6ade9a33ae813565a802200a7d5086dc08c4a6f866aad803ac7438942c3c0a6371adcb6992db94487f66c7",
                  "0a0b43727970746f436861696e10001a4730450221008417d04d1caeae31f591ae50f7d19e53e0dfb827bd51c18e66081941bf04639802203c73361a521c969e3fd7f62e62b46d61aad00e47d41e7da108546d954278a6b1"]
        data, status = app.sign(app.getAccount(0)['path'], tx, tokenSignature)
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
        exchangeSignature = ["08061207313030303136361a0b43727970746f436861696e20002a015f3203545258380642473045022100fe276f30a63173b2440991affbbdc5d6d2d22b61b306b24e535a2fb866518d9c02205f7f41254201131382ec6c8b3c78276a2bb136f910b9a1f37bfde192fc448793"]
        data, status = app.sign(app.getAccount(0)['path'], tx, exchangeSignature)
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
        exchangeSignature = ["08061207313030303136361a0b43727970746f436861696e20002a015f3203545258380642473045022100fe276f30a63173b2440991affbbdc5d6d2d22b61b306b24e535a2fb866518d9c02205f7f41254201131382ec6c8b3c78276a2bb136f910b9a1f37bfde192fc448793"]
        data, status = app.sign(app.getAccount(0)['path'], tx, exchangeSignature)
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
        exchangeSignature = ["08061207313030303136361a0b43727970746f436861696e20002a015f3203545258380642473045022100fe276f30a63173b2440991affbbdc5d6d2d22b61b306b24e535a2fb866518d9c02205f7f41254201131382ec6c8b3c78276a2bb136f910b9a1f37bfde192fc448793"]
        data, status = app.sign(app.getAccount(0)['path'], tx, exchangeSignature)
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

        data, status = app.sign(app.getAccount(0)['path'], tx)
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

        data, status = app.sign(app.getAccount(0)['path'], tx)
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

        data, status = app.sign(app.getAccount(0)['path'], tx)
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

        data, status = app.sign(app.getAccount(0)['path'], tx)
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

        data, status = app.sign(app.getAccount(0)['path'], tx)
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

        data, status = app.sign(app.getAccount(0)['path'], tx)
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

        data, status = app.sign(app.getAccount(0)['path'], tx)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_withdraw_balance(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.WithdrawBalanceContract,
            contract.WithdrawBalanceContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex'])
            )
        )

        data, status = app.sign(app.getAccount(0)['path'], tx)
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

        data, status = app.sign(app.getAccount(0)['path'], tx)
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

        data, status = app.sign(app.getAccount(0)['path'], tx)
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

        data, status = app.sign(app.getAccount(0)['path'], tx)
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

        data, status = app.sign(app.getAccount(0)['path'], tx)
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

        data, status = app.sign(app.getAccount(0)['path'], tx)
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

        data, status = app.sign(app.getAccount(0)['path'], tx)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_sign_message(self, app):
        # Magic define
        SIGN_MAGIC = b'\x19TRON Signed Message:\n'
        message = 'CryptoChain-TronSR Ledger Transactions Tests'.encode()
        encodedTx = struct.pack(">I", len(message)) + message

        pack = app.apduMessage(0x08,0x00,0x00,f"05{app.getAccount(0)['path']}{encodedTx.hex()}")
        data, status = app.exchange(pack)
        signedMessage = SIGN_MAGIC + str(len(message)).encode() + message
        keccak_hash = keccak.new(digest_bits=256)
        keccak_hash.update(signedMessage)
        hash = keccak_hash.digest()
        
        validSignature = validateSignature.validateHASH(hash,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_send_permissioned(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.TransferContract,
            contract.TransferContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                to_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                amount=100000000
            ),
            None,
            2
        )
        data, status = app.sign(app.getAccount(0)['path'], tx)
        assert(status == 0x9000)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_ecdh_key(self, app):
        # get ledger public key
        pack = app.apduMessage(0x02,0x00,0x00,f"05{app.getAccount(0)['path']}")
        data, status = app.exchange(pack)
        assert(data[0] == 65)
        pubKey = bytes(data[1:66])

        # get pair key
        pack = app.apduMessage(0x0A,0x00,0x01,f"05{app.getAccount(0)['path']}04{app.getAccount(1)['publicKey'][2:]}")
        data, status = app.exchange(pack)
        assert(status == 0x9000)

        # check if pair key matchs
        pubKeyDH = ec.EllipticCurvePublicKey.from_encoded_point(ec.SECP256K1(), pubKey)
        shared_key = app.getAccount(1)['dh'].exchange(ec.ECDH(), pubKeyDH)
        assert(shared_key.hex() == data[1:33].hex())

    
    def test_trx_custom_contract(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.TriggerSmartContract,
            contract.TriggerSmartContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                contract_address=bytes.fromhex(app.address_hex("TTg3AAJBYsDNjx5Moc5EPNsgJSa4anJQ3M")),
                data=bytes.fromhex('{:08x}{:064x}'.format(
                    0x0a857040,
                    int(10001)
                    ))
            )
        )
        
        data, status = app.sign(app.getAccount(0)['path'], tx)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


    def test_trx_unknown_trc20_send(self, app):
        tx = app.packContract(
            tron.Transaction.Contract.TriggerSmartContract,
            contract.TriggerSmartContract(
                owner_address=bytes.fromhex(app.getAccount(0)['addressHex']),
                contract_address=bytes.fromhex(app.address_hex("TVGLX58e3uBx1fmmwLCENkrgKqmpEjhtfG")),
                data=bytes.fromhex("a9059cbb000000000000000000000000364b03e0815687edaf90b81ff58e496dea7383d700000000000000000000000000000000000000000000000000000000000f4240")
            )
        )

        data, status = app.sign(app.getAccount(0)['path'], tx)
        validSignature, txID = validateSignature.validate(tx,data[0:65],app.getAccount(0)['publicKey'][2:])
        assert(validSignature == True)


def pytest_generate_tests(metafunc):
    metafunc.parametrize('app', [App()], scope='class')
