/*******************************************************************************
*   Ledger Blue
*   (c) 2016 Ledger
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

int verifyTokenNameID(const char *tokenId, const char *tokenName, uint8_t decimals, uint8_t *signature, uint8_t signatureLength);
int verifyExchangeID(const unsigned char *exchangeValidation,  uint8_t datLength, uint8_t *signature, uint8_t signatureLength);

typedef struct tokenDefinition_t {
    uint8_t address[21];
    uint8_t ticker[10];
    uint8_t decimals;
} tokenDefinition_t;

#define NUM_TOKENS_TRC20 65

extern tokenDefinition_t const TOKENS_TRC20[NUM_TOKENS_TRC20];
