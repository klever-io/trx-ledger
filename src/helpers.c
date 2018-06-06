/*******************************************************************************
*   Ripple Wallet
*   (c) 2017 Ledger
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

unsigned short decode_base58_address(unsigned char WIDE *in,
                                         unsigned short inlen,
                                         unsigned char *out,
                                         unsigned short outlen) {
    unsigned char hashBuffer[32];
    cx_sha256_t hash;
    outlen = decode_base58(in, inlen, out, outlen);

    // Compute hash to verify address
    cx_sha256_init(&hash);
    cx_hash(&hash.header, CX_LAST, out, outlen - 4, hashBuffer);
    cx_sha256_init(&hash);
    cx_hash(&hash.header, CX_LAST, hashBuffer, 32, hashBuffer);

    if (os_memcmp(out + outlen - 4, hashBuffer, 4)) {
        THROW(INVALID_CHECKSUM);
    }

    return outlen;
}


void getAddressStringFromKey(cx_ecfp_public_key_t *publicKey, uint8_t *out,
                                cx_sha3_t *sha3Context) {
    
    // Todo: From prublickey to address

    
}

