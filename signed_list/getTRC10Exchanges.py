import urllib.request, json
from tronapi import Tron
import binascii
import codecs
import os

from secp256k1 import PrivateKey, PublicKey

# GET Sign PK from Env
key=os.environ['TRONLEDGER_SIGN']

privkey = PrivateKey(bytes(bytearray.fromhex(key)), raw=True)
print("Public key: {}".format(str(privkey.pubkey.serialize(compressed=False).hex())))


full_node = 'https://api.trongrid.io'
solidity_node = 'https://api.trongrid.io'
event_server = 'https://api.trongrid.io'

tron = Tron(full_node=full_node,
        solidity_node=solidity_node,
        event_server=event_server)

def int_to_bytes(x):
    return x.to_bytes((x.bit_length() + 7) // 8, 'big')

def getVariant(value):
    out = bytes()
    while True:
        byte = value & 0x7F
        value = value >> 7
        if value == 0:
            out += bytes([byte])
            break
        else:
            out += bytes([byte | 0x80])
    return out

f= open("signedList_Exchanges.txt","w+")
f.write('ID,SIG,MESSAGE\n')

fJS= open("exchanges10.js","w+")
fJS.write('var exchangeList = [\n');

exchanges = tron.trx.get_list_exchangers()


for E in exchanges['exchanges']:
    # get token by ID
    #token1 = tron.trx.get_token_by_id(tron.toText(E['first_token_id']))
    #token2 = tron.trx.get_token_by_id(tron.toText(E['second_token_id']))
    token1 = {}
    token2 = {}
    if tron.toText(E['first_token_id'])=='_':
        token1 = {
            "name": "545258",
            "precision": 6
        }
    else:
        data = urllib.request.urlopen("{}/wallet/getassetissuebyid?value={}".format(full_node,tron.toText(E['first_token_id'])))
        token1 = json.loads(data.read().decode())
    
    if tron.toText(E['second_token_id'])=='_':
        token2 = {
            "name": "545258",
            "precision": 6
        }
    else:
        data = urllib.request.urlopen("{}/wallet/getassetissuebyid?value={}".format(full_node,tron.toText(E['second_token_id'])))
        token2 = json.loads(data.read().decode())

    #exchange_id
    MESSAGE = str(E['exchange_id']).encode() +\
        binascii.unhexlify(E['first_token_id']) + binascii.unhexlify(token1['name']) + bytes([token1['precision'] if 'precision' in token1 else 0]) +\
        binascii.unhexlify(E['second_token_id']) + binascii.unhexlify(token2['name']) + bytes([token2['precision'] if 'precision' in token2 else 0])

    sig_check = privkey.ecdsa_sign(MESSAGE)
    sig_ser = privkey.ecdsa_serialize(sig_check)
    
    datab = bytes([(1<<3)+0]) + getVariant(E['exchange_id']) +\
            bytes([(2<<3)+2]) + bytes([len(binascii.unhexlify(E['first_token_id']))]) + binascii.unhexlify(E['first_token_id']) +\
            bytes([(3<<3)+2]) + bytes([len(binascii.unhexlify(token1['name']))]) + binascii.unhexlify(token1['name']) +\
            bytes([(4<<3)+0]) + getVariant(token1['precision'] if 'precision' in token1 else 0) +\
            bytes([(5<<3)+2]) + bytes([len(binascii.unhexlify(E['second_token_id']))]) + binascii.unhexlify(E['second_token_id']) +\
            bytes([(6<<3)+2]) + bytes([len(binascii.unhexlify(token2['name']))]) + binascii.unhexlify(token2['name']) +\
            bytes([(7<<3)+0]) + getVariant(token2['precision'] if 'precision' in token2 else 0) +\
            bytes([(8<<3)+2]) + bytes([len(sig_ser)]) + sig_ser
    
    print('RET:{},{},{}'.format(E['exchange_id'], sig_ser.hex(), binascii.hexlify(datab).decode("utf-8")  ))
    f.write('{},{},{}\n'.format(E['exchange_id'], sig_ser.hex(), binascii.hexlify(datab).decode("utf-8")  ))
    
    fJS.write("{{ id: {} , message: '{}', firstToken: '{}', pair: '{}', decimals1: {}, decimals2: {} }},\n".format(
        E['exchange_id'], binascii.hexlify(datab).decode("utf-8"), E['first_token_id'],
        codecs.decode(token1['name'], "hex").decode('utf-8') + "/" + codecs.decode(token2['name'], "hex").decode('utf-8'),
        token1['precision'] if 'precision' in token1 else 0, token2['precision'] if 'precision' in token2 else 0 ))

f.close()

fJS.write("];\n")
fJS.write("// export it\n")
fJS.write("exports.exchangeList = exchangeList;")
fJS.close()
