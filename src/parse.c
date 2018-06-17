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
#include <string.h>



parserStatus_e parseTx(uint8_t *data, uint32_t dataLength, txContent_t *context) {
    parserStatus_e result = USTREAM_FAULT;
    uint8_t *pos;
    uint8_t p;
    uint8_t search[] = "type.googleapis";
    uint8_t b128=0;
    BEGIN_TRY {
        TRY {
            os_memset(context, 0, sizeof(txContent_t));

           
            pos = strstr(data, search);
            p = (pos-data)+*(pos-1);
            // contact type
            context->contractType = *(pos-5);
            if (p>dataLength) THROW(0x6a80);
            if (*(data+p)>>PB_FIELD_R!=2 || *(data+p)&PB_TYPE!=2 ) THROW(0x6a80);
            p+=2; if (p>dataLength) THROW(0x6a80);  
            switch (context->contractType){
                case 1:
                    context->tokenNameLength=4;
                    os_memmove(context->tokenName,"TRX\0",context->tokenNameLength);
                    // address 1
                    if ((*(data+p)>>PB_FIELD_R)!=1 || (*(data+p)&PB_TYPE)!=2 ) THROW(0x6a80);
                    p++;if (p>dataLength) THROW(0x6a80); 
                    if (*(data+p)!=ADDRESS_SIZE ) THROW(0x6a80);
                    p++;if (p+ADDRESS_SIZE>dataLength) THROW(0x6a80); 
                    os_memmove(context->account,data+p,ADDRESS_SIZE);
                    p+=ADDRESS_SIZE;if (p>dataLength) THROW(0x6a80); 
                    // address 2
                    if ((*(data+p)>>PB_FIELD_R)!=2 || (*(data+p)&PB_TYPE)!=2 ) THROW(0x6a80);
                    p++;if (p>dataLength) THROW(0x6a80); 
                    if (*(data+p)!=ADDRESS_SIZE ) THROW(0x6a80);
                    p++;if (p+ADDRESS_SIZE>dataLength) THROW(0x6a80); 
                    os_memmove(context->destination,data+p,ADDRESS_SIZE);
                    p+=ADDRESS_SIZE;if (p>dataLength) THROW(0x6a80); 
                    // Amount 
                    if ((*(data+p)>>PB_FIELD_R)!=3 || (*(data+p)&PB_TYPE)!=0 ) THROW(0x6a80);
                    p++;if (p>dataLength) THROW(0x6a80);
                    // find end of base128
                    while(p<dataLength){
                        context->amount += ((uint64_t)( (*(data+p))& PB_BASE128DATA) << b128) ;
                        if ((*(data+p)&PB_BASE128)==0) break;
                        p++; if (p>dataLength) THROW(0x6a88);
                        b128+=7;
                    }
                    // Bandwidth estimation
                    context->bandwidth = dataLength  // raw data length
                                                +70; //signature length
                    // DONE
                break;
                case 2:
                    // Token Name
                    if ((*(data+p)>>PB_FIELD_R)!=1 || (*(data+p)&PB_TYPE)!=2 ) THROW(0x6a80);
                    p++;if (p>dataLength) THROW(0x6a80); 
                    context->tokenNameLength=*(data+p);
                    p++;if (p+context->tokenNameLength>dataLength) THROW(0x6a80); 
                    os_memmove(context->tokenName,data+p,context->tokenNameLength);
                    context->tokenName[context->tokenNameLength]='\0';
                    p+=context->tokenNameLength;if (p>dataLength) THROW(0x6a80); 
                    // address 1
                    if ((*(data+p)>>PB_FIELD_R)!=2 || (*(data+p)&PB_TYPE)!=2 ) THROW(0x6a80);
                    p++;if (p>dataLength) THROW(0x6a80); 
                    if (*(data+p)!=ADDRESS_SIZE ) THROW(0x6a80);
                    p++;if (p+ADDRESS_SIZE>dataLength) THROW(0x6a80); 
                    os_memmove(context->account,data+p,ADDRESS_SIZE);
                    p+=ADDRESS_SIZE;if (p>dataLength) THROW(0x6a80); 
                    // address 2
                    if ((*(data+p)>>PB_FIELD_R)!=3 || (*(data+p)&PB_TYPE)!=2 ) THROW(0x6a80);
                    p++;if (p>dataLength) THROW(0x6a80); 
                    if (*(data+p)!=ADDRESS_SIZE ) THROW(0x6a80);
                    p++;if (p+ADDRESS_SIZE>dataLength) THROW(0x6a80); 
                    os_memmove(context->destination,data+p,ADDRESS_SIZE);
                    p+=ADDRESS_SIZE;if (p>dataLength) THROW(0x6a80); 
                    // Amount 
                    if ((*(data+p)>>PB_FIELD_R)!=4 || (*(data+p)&PB_TYPE)!=0 ) THROW(0x6a80);
                    p++;if (p>dataLength) THROW(0x6a80);
                    // find end of base128
                    while(p<dataLength){
                        context->amount += ((uint64_t)( (*(data+p))& PB_BASE128DATA) << b128) ;
                        if ((*(data+p)&PB_BASE128)==0) break;
                        p++; if (p>dataLength) THROW(0x6a88);
                        b128+=7;
                    }
                    // Bandwidth estimation
                    context->bandwidth = dataLength  // raw data length
                                                +70; //signature length
                    // DONE
                break;
                default:
                    result = USTREAM_FINISHED;
            }
            result = USTREAM_FINISHED;
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

bool adjustDecimals(char *src, uint32_t srcLength, char *target,
                    uint32_t targetLength, uint8_t decimals) {
    uint32_t startOffset;
    uint32_t lastZeroOffset = 0;
    uint32_t offset = 0;

    if ((srcLength == 1) && (*src == '0')) {
        if (targetLength < 2) {
            return false;
        }
        target[offset++] = '0';
        target[offset++] = '\0';
        return true;
    }
    if (srcLength <= decimals) {
        uint32_t delta = decimals - srcLength;
        if (targetLength < srcLength + 1 + 2 + delta) {
            return false;
        }
        target[offset++] = '0';
        target[offset++] = '.';
        for (uint32_t i = 0; i < delta; i++) {
            target[offset++] = '0';
        }
        startOffset = offset;
        for (uint32_t i = 0; i < srcLength; i++) {
            target[offset++] = src[i];
        }
        target[offset] = '\0';
    } else {
        uint32_t sourceOffset = 0;
        uint32_t delta = srcLength - decimals;
        if (targetLength < srcLength + 1 + 1) {
            return false;
        }
        while (offset < delta) {
            target[offset++] = src[sourceOffset++];
        }
        if (decimals != 0) {
            target[offset++] = '.';
        }
        startOffset = offset;
        while (sourceOffset < srcLength) {
            target[offset++] = src[sourceOffset++];
        }
        target[offset] = '\0';
    }
    for (uint32_t i = startOffset; i < offset; i++) {
        if (target[i] == '0') {
            if (lastZeroOffset == 0) {
                lastZeroOffset = i;
            }
        } else {
            lastZeroOffset = 0;
        }
    }
    if (lastZeroOffset != 0) {
        target[lastZeroOffset] = '\0';
        if (target[lastZeroOffset - 1] == '.') {
            target[lastZeroOffset - 1] = '\0';
        }
    }
    return true;
}
unsigned short print_amount(uint64_t amount, uint8_t *out,
                                uint32_t outlen, uint8_t sun) {
    char tmp[20];
    char tmp2[25];
    uint32_t numDigits = 0, i;
    uint64_t base = 1;
    while (base <= amount) {
        base *= 10;
        numDigits++;
    }
    if (numDigits > sizeof(tmp) - 1) {
        THROW(0x6a80);
    }
    base /= 10;
    for (i = 0; i < numDigits; i++) {
        tmp[i] = '0' + ((amount / base) % 10);
        base /= 10;
    }
    tmp[i] = '\0';
    adjustDecimals(tmp, i, tmp2, 25, sun);
    if (strlen(tmp2) < outlen - 1) {
        strcpy(out, tmp2);
    } else {
        out[0] = '\0';
    }
    return strlen(out);
}