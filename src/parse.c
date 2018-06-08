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

#define STI_UINT16 0x01
#define STI_UINT32 0x02
#define STI_AMOUNT 0x06
#define STI_VL 0x07
#define STI_ACCOUNT 0x08


parserStatus_e parseTxInternal(uint8_t *data, uint32_t length,
                               txContent_t *context) {
    uint32_t offset = 0;
    parserStatus_e result = USTREAM_FAULT;
    while (offset != length) {
        if (offset > length) {
            goto error;
        }
        uint8_t dataType = data[offset] >> 4;
        switch (dataType) {
        case STI_UINT16:
            result = processUint16(data, length, context, &offset);
            break;
        case STI_UINT32:
            result = processUint32(data, length, context, &offset);
            break;
        case STI_AMOUNT:
            result = processAmount(data, length, context, &offset);
            break;
        case STI_VL:
            result = processVl(data, length, context, &offset);
            break;
        case STI_ACCOUNT:
            result = processAccount(data, length, context, &offset);
            break;
        default:
            goto error;
        }
        if (result != USTREAM_FINISHED) {
            goto error;
        }
        result = USTREAM_FAULT;
    }
    result = USTREAM_FINISHED;
error:
    return result;
}

parserStatus_e parseTx(uint8_t *data, uint32_t length, txContent_t *context) {
    parserStatus_e result;
    BEGIN_TRY {
        TRY {
            os_memset(context, 0, sizeof(txContent_t));
            result = parseTxInternal(data, length, context);
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
