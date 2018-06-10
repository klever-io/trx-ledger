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

#include "parse.h"

#define PB_TYPE 0x07
#define PB_FIELD_R 0x03
#define PB_VARIANT_MASK 0x80

parserStatus_e parseTx(uint8_t *data, uint32_t length, txContent_t *context) {
    parserStatus_e result = USTREAM_FAULT;
    BEGIN_TRY {
        TRY {
            os_memset(context, 0, sizeof(txContent_t));
            PRINTF("Parse transacation will not be available on first release\n");
            THROW(0x6A80);
        }
        CATCH_OTHER(e) {
            result = USTREAM_FAULT;
        }
        FINALLY {
        }
    }
    END_TRY;
    return result;
}
