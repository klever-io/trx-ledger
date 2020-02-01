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

#include "os.h"
#include "cx.h"

#include "parse.h"

#ifndef HELPER_H
#define HELPER_H

void getAddressFromKey(cx_ecfp_public_key_t *publicKey, uint8_t *out);

void getAddressFromPublicKey(const uint8_t *publicKey, uint8_t *address);

void getBase58FromAddress(uint8_t *address, uint8_t *out,
                                cx_sha256_t* sha2);

void transactionHash(uint8_t *raw, uint16_t dataLength,
                        uint8_t *out, cx_sha256_t* sha2);

void signTransaction(transactionContext_t *transactionContext);

void array_hexstr(char *strbuf, const void *bin, unsigned int len);

#endif