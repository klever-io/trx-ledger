import urllib.request, json
from tronapi import Tron
from binascii import unhexlify
import codecs

def conv(string):
    ret = "0x"+string[0:2]
    for i in range(1,21):
        ret += ",0x"+string[i*2:(i+1)*2]
    return ret

with urllib.request.urlopen("https://api.tronscan.org/api/token_trc20?sort=issue_time&start=0&limit=100") as url:
    data = json.loads(url.read().decode())

    f= open("TRC20_out.txt","w+")
    tron = Tron()
    for T in data['trc20_tokens']:
        address = tron.address.to_hex(T['contract_address'])
        f.write('{}{}{}{}, \"${} \", {}{},'.format("{","{",conv(address),"}",T['symbol'],T['decimals'],"}" ))
        f.write('\n')
    f.close()