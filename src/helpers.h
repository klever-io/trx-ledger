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

#include "os.h"
#include "cx.h"

#ifndef HELPER_H
#define HELPER_H





unsigned short public_key_to_encoded_base58(
    unsigned char WIDE *in, unsigned short inlen, unsigned char *out,
    unsigned short outlen, unsigned short version, unsigned char alreadyHashed);

unsigned short decode_base58_address(unsigned char WIDE *in,
                                         unsigned short inlen,
                                         unsigned char *out,
                                         unsigned short outlen);

unsigned short compress_public_key(cx_ecfp_public_key_t *publicKey,
                                       uint8_t *out, uint32_t outlen);

unsigned short print_amount(uint64_t amount, uint8_t *out, uint32_t outlen);


#define ADD_PRE_FIX_STRING "T"
#define ADDRESS_SIZE 21
#define BASE58CHECK_ADDRESS_SIZE 34
#define BASE58CHECK_PK_SIZE 64

#define DROP 1000000L

#define ADD_PRE_FIX_BYTE_MAINNET 0x41

#define MAX_RAW_TX 200



void getEthAddressFromKey(cx_ecfp_public_key_t *publicKey, uint8_t *out,
                          cx_sha3_t *sha3Context);

void getEthAddressStringFromKey(cx_ecfp_public_key_t *publicKey, uint8_t *out,
                                cx_sha3_t *sha3Context);

#endif