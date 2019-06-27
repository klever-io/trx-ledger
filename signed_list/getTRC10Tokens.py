import urllib.request, json
from tronapi import Tron
import binascii

import time
from secp256k1 import PrivateKey, PublicKey
import os


def urlopen_with_retry(toread, start):
     for i in range(5):
        try:
            time.sleep(0.3) 
            #return urllib.request.urlopen("https://apilist.tronscan.org/api/token?sort=-name&limit={}&start={}&totalAll=1".format(toread, start))
            return urllib.request.urlopen("https://api.trxplorer.io/v2/tokens?type=0&limit={}&start={}".format(toread, start))
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

toread = 50
start = 0
IDField = 'id'
ItemsFields = 'items'
while (toread>0):
    
    url = urlopen_with_retry(toread,start)
    data = json.loads(url.read().decode())
    for T in data[ItemsFields]:
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
    if len(data[ItemsFields])<toread:
        toread = 0
    start = start + toread
f.close()

fJS.write("];\n")
fJS.write("// export it\n")
fJS.write("exports.tokenList = tokenList;")
fJS.close()
