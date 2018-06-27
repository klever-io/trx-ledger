/*******************************************************************************
*   TRON Ledger
*   (c) 2018 Ledger
*
*  Licensed under the Apache License, Version 2.0 (the "License");
*  you may not use this file except in compliance with the License.
*  You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
*  Unless required by applicable law or agreed to in writing, software
*  distributed under the License is distributed on an "AS IS" BASIS,
*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*  See the License for the specific language governing permissions and
*  limitations under the License.
********************************************************************************/

#include "helpers.h"
#include "base58.h"
#include <stdbool.h>

void getAddressFromKey(cx_ecfp_public_key_t *publicKey, uint8_t *address,
                                cx_sha3_t *sha3Context) {
    uint8_t hashAddress[32];

    cx_keccak_init(sha3Context, 256);
    cx_hash((cx_hash_t *)sha3Context, CX_LAST, publicKey->W + 1, 64,
            hashAddress);
    
    os_memmove(address, hashAddress + 11, 21);
    address[0] = ADD_PRE_FIX_BYTE_MAINNET;
    
}

void getBase58FromAddres(uint8_t *address, uint8_t *out,
                                cx_sha256_t* sha2) {
    uint8_t sha256[32];
    uint8_t checkSum[4];
    uint8_t addchecksum[ADDRESS_SIZE+4];
    
    cx_sha256_init(sha2);
    cx_hash(sha2, CX_LAST, address, 21, sha256);
    cx_sha256_init(sha2);
    cx_hash(sha2, CX_LAST, sha256, 32, sha256);
    
    os_memmove(addchecksum, address , ADDRESS_SIZE);
    os_memmove(addchecksum+ADDRESS_SIZE, sha256, 4);
    
    
    encode_base_58(&addchecksum[0],25,out,BASE58CHECK_ADDRESS_SIZE);
    
}

void transactionHash(uint8_t *raw, uint16_t dataLength,
                        uint8_t *out, cx_sha256_t* sha2) {
   
    cx_sha256_init(sha2);
    cx_hash(sha2, CX_LAST, raw, dataLength, out);    
}

void signTransaction(transactionContext_t *transactionContext) {
   
    uint8_t privateKeyData[32];
    cx_ecfp_private_key_t privateKey;
    uint8_t rLength, sLength, rOffset, sOffset;
    uint8_t signature[100];
    unsigned int info = 0;

    // Get Private key from BIP32 path
    os_perso_derive_node_bip32(
        CX_CURVE_256K1, transactionContext->bip32Path,
        transactionContext->pathLength, privateKeyData, NULL);
    cx_ecfp_init_private_key(CX_CURVE_256K1, privateKeyData, 32, &privateKey);
    os_memset(privateKeyData, 0, sizeof(privateKeyData));
    // Sign transaction hash
    cx_ecdsa_sign(&privateKey, CX_RND_RFC6979 | CX_LAST, CX_SHA256,
                      transactionContext->hash, sizeof(transactionContext->hash),
                      signature, &info);
    os_memset(&privateKey, 0, sizeof(privateKey));
    // recover signature
    rLength = signature[3];
    sLength = signature[4 + rLength + 1];
    rOffset = (rLength == 33 ? 1 : 0);
    sOffset = (sLength == 33 ? 1 : 0);
    os_memmove(transactionContext->signature, signature + 4 + rOffset, 32);
    os_memmove(transactionContext->signature + 32, signature + 4 + rLength + 2 + sOffset, 32);
    transactionContext->signature[64] = 0x00;
    if (info & CX_ECCINFO_PARITY_ODD) {
        transactionContext->signature[64] |= 0x01;
    }
    transactionContext->signatureLength = 65
    ;

    return;

}
