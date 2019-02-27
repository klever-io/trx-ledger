import urllib.request, json
from tronapi import Tron
from binascii import unhexlify
import codecs
import time

def conv(string):
    ret = "0x"+string[0:2]
    for i in range(1,21):
        ret += ",0x"+string[i*2:(i+1)*2]
    return ret


def urlopen_with_retry(toread, start):
     for i in range(5):
        try:
           time.sleep(0.3) 
           return urllib.request.urlopen("https://apilist.tronscan.org/api/token_trc20?sort=issue_time&limit={}&start={}".format(toread, start))
        except Exception:
            continue

ItemsFields = 'trc20_tokens'
toread = 20
start = 0
f= open("signedList_TRC20.txt","w+")
tron = Tron()
while (toread>0):
    url = urlopen_with_retry(toread,start)
    data = json.loads(url.read().decode())

    for T in data[ItemsFields]:
        address = tron.address.to_hex(T['contract_address'])
        f.write('{}{}{}{}, \"${} \", {}{},'.format("{","{",conv(address),"}",T['symbol'],T['decimals'],"}" ))
        f.write('\n')

    if len(data[ItemsFields])<toread:
        toread = 0
    start = start + toread

f.close()