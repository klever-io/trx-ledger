import urllib.request, json
from urllib import request, parse
from tronapi import Tron
import binascii

import time
from secp256k1 import PrivateKey, PublicKey
import os
from pprint import pprint


def urlopen_with_retry(toread, start):
     for i in range(5):
        try:
            time.sleep(0.3) 
            req = urllib.request.Request("https://api.trongrid.io/wallet/getpaginatedassetissuelist")
            req.add_header('Content-Type', 'application/json; charset=utf-8')
            jsondata = json.dumps({"offset": start, "limit": toread})
            jsondataasbytes = jsondata.encode('utf-8')   # needs to be bytes
            req.add_header('Content-Length', len(jsondataasbytes))
            response = urllib.request.urlopen(req, jsondataasbytes)
            return response
        except Exception:
            continue
    

# GET Sign PK from Env
key=os.environ['TRONLEDGER_SIGN']

privkey = PrivateKey(bytes(bytearray.fromhex(key)), raw=True)
print(str(privkey.pubkey.serialize(compressed=False).hex()))

f= open("signedList_TRC10.txt","w+")
f.write('ID,SIG,MESSAGE\n')

fJS= open("tokens10.js","w+")
fJS.write('var tokenList = [\n');

# TRX
MESSAGE = b'TRX' + b'TRX' + bytes([6])
print(MESSAGE)
sig_check = privkey.ecdsa_sign(MESSAGE)
sig_ser = privkey.ecdsa_serialize(sig_check)
datab = bytes([(1<<3)+2]) + bytes([3]) + b'TRX' +\
        bytes([(2<<3)+0]) + bytes([6]) +\
        bytes([(3<<3)+2]) + bytes([len(sig_ser)]) + sig_ser

print('RET:{},{},{}'.format('0',sig_ser.hex(), binascii.hexlify(datab).decode("utf-8")  ))
f.write('{},{},{}\n'.format('0',sig_ser.hex(), binascii.hexlify(datab).decode("utf-8")  ))

fJS.write("{{ id: {} , message: '{}'}},\n".format('0', binascii.hexlify(datab).decode("utf-8")  ))

toread = 100
start = 0
IDField = 'id'
ItemsFields = 'assetIssue'
items = []
while (toread>0):

    url = urlopen_with_retry(toread,start)
    data = json.loads(url.read().decode())
    for T in data[ItemsFields]:
        items.append({
            'id': T[IDField],
            'name': bytes.fromhex(T['name']).decode("utf-8"),
            'precision': T['precision'] if 'precision' in T else 0
        })
    if len(data[ItemsFields])<toread:
        toread = 0
    start = start + toread

def sortFN(s):
    return int(s['id'])

print('List updated. Total {}'.format(len(items)))
itemsSorted = sorted(items, key=sortFN, reverse=True)
print('List sorted')
for T in itemsSorted:
    MESSAGE = bytes(str(T[IDField])+T['name'],'utf-8') + bytes([T['precision']])
    print(MESSAGE)
    sig_check = privkey.ecdsa_sign(MESSAGE)
    sig_ser = privkey.ecdsa_serialize(sig_check)
    datab = bytes([(1<<3)+2]) + bytes([len(T['name'])]) + bytes( T['name'],'utf-8') +\
            bytes([(2<<3)+0]) + bytes([T['precision']]) +\
            bytes([(3<<3)+2]) + bytes([len(sig_ser)]) + sig_ser

    print('RET:{},{},{}'.format(T[IDField],sig_ser.hex(), binascii.hexlify(datab).decode("utf-8")  ))
    f.write('{},{},{}\n'.format(T[IDField],sig_ser.hex(), binascii.hexlify(datab).decode("utf-8")  ))
    
    fJS.write("{{ id: {} , message: '{}'}},\n".format(T[IDField], binascii.hexlify(datab).decode("utf-8")  ))
    
f.close()

fJS.write("];\n")
fJS.write("// export it\n")
fJS.write("exports.tokenList = tokenList;")
fJS.close()
