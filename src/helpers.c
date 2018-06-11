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
    uint8_t sha256_0[32];
    uint8_t sha256_1[32];
    uint8_t checkSum[4];
    uint8_t addchecksum[ADDRESS_SIZE+4];
    
    cx_sha256_init(sha2);
    cx_hash(sha2, CX_LAST, address, 21, sha256_0);
    cx_sha256_init(sha2);
    cx_hash(sha2, CX_LAST, &sha256_0[0], 32, sha256_1);
    
    os_memmove(addchecksum, address , ADDRESS_SIZE);
    os_memmove(addchecksum+ADDRESS_SIZE, sha256_1, 4);
    
    
    encode_base_58(&addchecksum[0],25,out,BASE58CHECK_ADDRESS_SIZE);
    
}

