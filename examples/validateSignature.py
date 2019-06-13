from eth_keys import KeyAPI
from eth_keys.datatypes import Signature
from eth_keys.datatypes import PublicKey
import hashlib
import logging

logging.basicConfig(level=logging.DEBUG, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger()


def getPublicKey(transaction, signature):
    s = Signature(signature_bytes=bytes.fromhex(signature))
    txID = hashlib.sha256(bytes.fromhex(transaction)).digest()
    keys = KeyAPI('eth_keys.backends.NativeECCBackend')
    public_key = keys.ecdsa_recover(txID,s)
    logger.debug(' PublicKey: {}'.format(public_key))
    return public_key

def validate(transaction, signature, public_key):
    s = Signature(signature_bytes=signature)
    txID = hashlib.sha256(bytes.fromhex(transaction)).digest()
    keys = KeyAPI('eth_keys.backends.NativeECCBackend')
    publicKey = PublicKey(bytes.fromhex(public_key))
    return keys.ecdsa_verify(txID,s,publicKey), txID.hex()

