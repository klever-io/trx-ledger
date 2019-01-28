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

#include "tokens.h"

const char *sstrstr(const char *haystack, const char *needle, size_t length)
{
    size_t needle_length = strlen(needle);
    size_t i;
    for (i = 0; i < length; i++)
    {
        if (i + needle_length > length) return NULL;
        if (strncmp(&haystack[i], needle, needle_length) == 0) return &haystack[i];
    }
    return NULL;
}

tokenDefinition_t* getKnownToken(txContent_t *context) {
    uint8_t i;

    tokenDefinition_t *currentToken = NULL;
    for (i=0; i<NUM_TOKENS_TRC20; i++) {
        currentToken = (tokenDefinition_t *)PIC(&TOKENS_TRC20[i]);
        if (os_memcmp(currentToken->address, context->contractAddress, ADDRESS_SIZE) == 0) {
            return currentToken;
        }
    }
    return NULL;
}

parserStatus_e parseTx(uint8_t *data, uint32_t dataLength, txContent_t *context) {
    parserStatus_e result = USTREAM_FAULT;
    uint8_t *pos;
    uint8_t index;
    uint8_t search[] = "type.googleapis";
    uint8_t b128=0;
    const uint8_t SELECTOR[] = {0xA9,0x05,0x9C,0xBB};
    tokenDefinition_t* TRC20;
    BEGIN_TRY {
        TRY {
            os_memset(context, 0, sizeof(txContent_t));
            //tokens decimals
            context->decimals[0] = 0;
            context->decimals[1] = 0;

            // check that input data is null terminated
            /*for(index=0; index<dataLength; ++index)
            {
                if(data[index]== '\0') break;
            }
            if(index == dataLength) THROW(0x6a80);
            */
            pos = (uint8_t *)sstrstr((const char *)data, (const char *)search, dataLength);
            if (pos == NULL) THROW(0x6a80);
            index = (pos-data)+*(pos-1);
            // contact type
            if ((*(pos-4)&PB_BASE128)==0) // quick fix for longer contracts... TODO: 
               context->contractType = *(pos-5); //get contract type
            else
                context->contractType = *(pos-6); //get contract type
            if (index>dataLength) THROW(0x6a80);
            if (data[index]>>PB_FIELD_R!=2 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
            index+=2; if (index>dataLength) THROW(0x6a80);  
            switch (context->contractType){
                case 1: // Send TRX
                    context->tokenNamesLength[0]=4;
                    os_memmove(context->tokenNames[0],"TRX\0",context->tokenNamesLength[0]);
                    // address 1
                    if ((data[index]>>PB_FIELD_R)!=1 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    if (data[index]!=ADDRESS_SIZE ) THROW(0x6a80);
                    index++;if (index+ADDRESS_SIZE>dataLength) THROW(0x6a80); 
                    os_memmove(context->account,data+index,ADDRESS_SIZE);
                    index+=ADDRESS_SIZE;if (index>dataLength) THROW(0x6a80); 
                    // address 2
                    if ((data[index]>>PB_FIELD_R)!=2 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    if (data[index]!=ADDRESS_SIZE ) THROW(0x6a80);
                    index++;if (index+ADDRESS_SIZE>dataLength) THROW(0x6a80); 
                    os_memmove(context->destination,data+index,ADDRESS_SIZE);
                    index+=ADDRESS_SIZE;if (index>dataLength) THROW(0x6a80); 
                    // Amount 
                    if ((data[index]>>PB_FIELD_R)!=3 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80);
                    // find end of base128
                    for(b128=0; index<dataLength; ++index){
                        context->amount += ((uint64_t)( data[index] & PB_BASE128DATA) << b128) ;
                        if ((data[index]&PB_BASE128) == 0) break;
                        b128+=7;
                    }
                    if (index > dataLength) THROW(0x6a88);
                    // Bandwidth estimation
                    context->bandwidth = dataLength  // raw data length
                                                +70; //signature length
                    // DONE
                break;
                case 2: //Send Asset
                    // Token ID
                    if ((data[index]>>PB_FIELD_R)!=1 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    context->tokenNamesLength[0]=data[index]; if (context->tokenNamesLength[0] > 32) THROW(0x6a80); 
                    index++;if (index+context->tokenNamesLength[0] > dataLength) THROW(0x6a80); 
                    os_memmove(context->tokenNames[0],data+index,context->tokenNamesLength[0]);
                    context->tokenNames[0][context->tokenNamesLength[0]]='\0';
                    index+=context->tokenNamesLength[0]; if (index>dataLength) THROW(0x6a80); 
                    // address 1
                    if ((data[index]>>PB_FIELD_R)!=2 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    if (data[index]!=ADDRESS_SIZE ) THROW(0x6a80);
                    index++;if (index+ADDRESS_SIZE>dataLength) THROW(0x6a80); 
                    os_memmove(context->account,data+index,ADDRESS_SIZE);
                    index+=ADDRESS_SIZE;if (index>dataLength) THROW(0x6a80); 
                    // address 2
                    if ((data[index]>>PB_FIELD_R)!=3 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    if (data[index]!=ADDRESS_SIZE ) THROW(0x6a80);
                    index++;if (index+ADDRESS_SIZE>dataLength) THROW(0x6a80); 
                    os_memmove(context->destination,data+index,ADDRESS_SIZE);
                    index+=ADDRESS_SIZE;if (index>dataLength) THROW(0x6a80); 
                    // Amount 
                    if ((data[index]>>PB_FIELD_R)!=4 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80);
                    // find end of base128
                    while(index<dataLength){
                        context->amount += ((uint64_t)( (data[index])& PB_BASE128DATA) << b128) ;
                        if ((data[index]&PB_BASE128)==0) break;
                        index++; if (index>dataLength) THROW(0x6a88);
                        b128+=7;
                    }
                    // Bandwidth estimation
                    context->bandwidth = dataLength  // raw data length
                                                +70; //signature length
                    // DONE
                break;
                case 31: // TriggerSmartContract TRC20 transafer
                    // address from
                    if ((data[index]>>PB_FIELD_R)!=1 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    if (data[index]!=ADDRESS_SIZE ) THROW(0x6a80);
                    index++;if (index+ADDRESS_SIZE>dataLength) THROW(0x6a80); 
                    os_memmove(context->account,data+index,ADDRESS_SIZE);
                    index+=ADDRESS_SIZE;if (index>dataLength) THROW(0x6a80); 
                    // contract address 
                    if ((data[index]>>PB_FIELD_R)!=2 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    if (data[index]!=ADDRESS_SIZE ) THROW(0x6a80);
                    index++;if (index+ADDRESS_SIZE>dataLength) THROW(0x6a80); 
                    os_memmove(context->contractAddress,data+index,ADDRESS_SIZE);
                    index+=ADDRESS_SIZE;if (index>dataLength) THROW(0x6a80); 
                    // field 3 - callValue 
                    /*
                    if ((data[index]>>PB_FIELD_R)!=3 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80);
                    // find end of base128
                    while(index<dataLength){
                        //NONEED += ((uint64_t)( (data[index])& PB_BASE128DATA) << b128) ;
                        if ((data[index]&PB_BASE128)==0) break;
                        index++; if (index>dataLength) THROW(0x6a88);
                        b128+=7;
                    }
                    index++;if (index>dataLength) THROW(0x6a80);
                    */
                    // field 4 - data
                    if ((data[index]>>PB_FIELD_R)!=4 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80);
                    if (data[index]!=TRC20_DATA_FIELD_SIZE ) THROW(0x6a80);
                    index++;if (index+TRC20_DATA_FIELD_SIZE>dataLength) THROW(0x6a80);
                    // check if transfer(address, uint256) function
                    if (os_memcmp(&data[index], SELECTOR, 4) != 0) THROW(0x6a80);
                    // TO Address
                    os_memmove(context->destination, data+index+15, ADDRESS_SIZE);
                    //set MainNet PREFIX
                    context->destination[0]=ADD_PRE_FIX_BYTE_MAINNET;
                    // Amount
                    os_memmove(context->TRC20Amount, data+index+36, 32);
                    
                    TRC20 = getKnownToken(context);
                    if (TRC20 == NULL) THROW(0x6a80);
                    context->decimals[0] = TRC20->decimals;
                    context->tokenNamesLength[0] = strlen((const char *)TRC20->ticker)+1;
                    os_memmove(context->tokenNames[0], TRC20->ticker, context->tokenNamesLength[0]);

                    // Bandwidth estimation
                    context->bandwidth = dataLength  // raw data length
                                                +70; //signature length
                    // DONE
                break;
                case 41: // Create Exchange
                    // owner_address
                    if ((data[index]>>PB_FIELD_R)!=1 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    if (data[index]!=ADDRESS_SIZE ) THROW(0x6a80);
                    index++;if (index+ADDRESS_SIZE>dataLength) THROW(0x6a80); 
                    os_memmove(context->account,data+index,ADDRESS_SIZE);
                    index+=ADDRESS_SIZE;if (index>dataLength) THROW(0x6a80); 
                    // first_token_id 
                    if ((data[index]>>PB_FIELD_R)!=2 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    context->tokenNamesLength[0]=data[index]; if (context->tokenNamesLength[0] > 32) THROW(0x6a80); 
                    index++;if (index+context->tokenNamesLength[0] > dataLength) THROW(0x6a80); 
                    os_memmove(context->tokenNames[0],data+index,context->tokenNamesLength[0]);
                    context->tokenNames[0][context->tokenNamesLength[0]]='\0';
                    index+=context->tokenNamesLength[0]; if (index>dataLength) THROW(0x6a80);
                    // first_token_balance 
                    if ((data[index]>>PB_FIELD_R)!=3 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80);
                    // find end of base128
                    for(b128=0; index<dataLength; ++index){
                        context->amount += ((uint64_t)( data[index] & PB_BASE128DATA) << b128) ;
                        if ((data[index]&PB_BASE128) == 0) break;
                        b128+=7;
                    }
                    index++;if (index > dataLength) THROW(0x6a88);
                    if (context->tokenNames[0][0]=='_'){
                        os_memmove(context->tokenNames[0],"TRX\0",4);
                        context->tokenNamesLength[0]=3;
                    }
                    // second_token_id 
                    if ((data[index]>>PB_FIELD_R)!=4 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    context->tokenNamesLength[1]=data[index]; if (context->tokenNamesLength[1] > 32) THROW(0x6a80); 
                    index++;if (index+context->tokenNamesLength[1] > dataLength) THROW(0x6a80); 
                    os_memmove(context->tokenNames[1],data+index,context->tokenNamesLength[1]);
                    context->tokenNames[1][context->tokenNamesLength[1]]='\0';
                    index+=context->tokenNamesLength[1]; if (index>dataLength) THROW(0x6a80);
                    // second_token_balance 
                    if ((data[index]>>PB_FIELD_R)!=5 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80);
                    // find end of base128
                    for(b128=0; index<dataLength; ++index){
                        context->amount2 += ((uint64_t)( data[index] & PB_BASE128DATA) << b128) ;
                        if ((data[index]&PB_BASE128) == 0) break;
                        b128+=7;
                    }
                    if (index > dataLength) THROW(0x6a88);
                    // Check if TRX
                    if (context->tokenNames[0][0]==(uint8_t)'_'){
                        os_memmove(context->tokenNames[0],"TRX\0",4);
                        context->tokenNamesLength[0]=4;
                    }
                    if (context->tokenNames[1][0]==(uint8_t)'_'){
                        os_memmove(context->tokenNames[1],"TRX\0",4);
                        context->tokenNamesLength[1]=4;
                    }

                    // Bandwidth estimation
                    context->bandwidth = dataLength  // raw data length
                                                +70; //signature length
                break;
                case 42: // Exchange Inject
                case 43: // Exchange Withdraw
                    // owner_address
                    if ((data[index]>>PB_FIELD_R)!=1 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    if (data[index]!=ADDRESS_SIZE ) THROW(0x6a80);
                    index++;if (index+ADDRESS_SIZE>dataLength) THROW(0x6a80); 
                    os_memmove(context->account,data+index,ADDRESS_SIZE);
                    index+=ADDRESS_SIZE;if (index>dataLength) THROW(0x6a80); 
                    // Exchange ID
                    if ((data[index]>>PB_FIELD_R)!=2 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80);
                    // find end of base128
                    for(b128=0; index<dataLength; ++index){
                        context->exchangeID += ((uint64_t)( data[index] & PB_BASE128DATA) << b128) ;
                        if ((data[index]&PB_BASE128) == 0) break;
                        b128+=7;
                    }
                    index++;if (index > dataLength) THROW(0x6a88);
                    // token_id 
                    if ((data[index]>>PB_FIELD_R)!=3 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    context->tokenNamesLength[0]=data[index]; if (context->tokenNamesLength[0] > 32) THROW(0x6a80); 
                    index++;if (index+context->tokenNamesLength[0] > dataLength) THROW(0x6a80); 
                    os_memmove(context->tokenNames[0],data+index,context->tokenNamesLength[0]);
                    context->tokenNames[0][context->tokenNamesLength[0]]='\0';
                    index+=context->tokenNamesLength[0]; if (index>dataLength) THROW(0x6a80);
                    // quant 
                    if ((data[index]>>PB_FIELD_R)!=4 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80);
                    // find end of base128
                    for(b128=0; index<dataLength; ++index){
                        context->amount += ((uint64_t)( data[index] & PB_BASE128DATA) << b128) ;
                        if ((data[index]&PB_BASE128) == 0) break;
                        b128+=7;
                    }
                    index++;if (index > dataLength) THROW(0x6a88);
                    // Check if TRX
                    if (context->tokenNames[0][0]==(uint8_t)'_'){
                        os_memmove(context->tokenNames[0],"TRX\0",4);
                        context->tokenNamesLength[0]=4;
                    }
                break;
                case 44: // Exchange Transaction
                    // owner_address
                    if ((data[index]>>PB_FIELD_R)!=1 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    if (data[index]!=ADDRESS_SIZE ) THROW(0x6a80);
                    index++;if (index+ADDRESS_SIZE>dataLength) THROW(0x6a80); 
                    os_memmove(context->account,data+index,ADDRESS_SIZE);
                    index+=ADDRESS_SIZE;if (index>dataLength) THROW(0x6a80); 
                    // Exchange ID
                    if ((data[index]>>PB_FIELD_R)!=2 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80);
                    // find end of base128
                    for(b128=0; index<dataLength; ++index){
                        context->exchangeID += ((uint64_t)( data[index] & PB_BASE128DATA) << b128) ;
                        if ((data[index]&PB_BASE128) == 0) break;
                        b128+=7;
                    }
                    index++;if (index > dataLength) THROW(0x6a88);
                    // token_id 
                    if ((data[index]>>PB_FIELD_R)!=3 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80); 
                    context->tokenNamesLength[0]=data[index]; if (context->tokenNamesLength[0] > 32) THROW(0x6a80); 
                    index++;if (index+context->tokenNamesLength[0] > dataLength) THROW(0x6a80); 
                    os_memmove(context->tokenNames[0],data+index,context->tokenNamesLength[0]);
                    context->tokenNames[0][context->tokenNamesLength[0]]='\0';
                    index+=context->tokenNamesLength[0]; if (index>dataLength) THROW(0x6a80);
                    // quant 
                    if ((data[index]>>PB_FIELD_R)!=4 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80);
                    // find end of base128
                    for(b128=0; index<dataLength; ++index){
                        context->amount += ((uint64_t)( data[index] & PB_BASE128DATA) << b128) ;
                        if ((data[index]&PB_BASE128) == 0) break;
                        b128+=7;
                    }
                    index++;if (index > dataLength) THROW(0x6a88);
                    // expected amount 
                    if ((data[index]>>PB_FIELD_R)!=5 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
                    index++;if (index>dataLength) THROW(0x6a80);
                    // find end of base128
                    for(b128=0; index<dataLength; ++index){
                        context->amount2 += ((uint64_t)( data[index] & PB_BASE128DATA) << b128) ;
                        if ((data[index]&PB_BASE128) == 0) break;
                        b128+=7;
                    }
                    
                    index++;if (index > dataLength) THROW(0x6a88);
                    // Check if TRX
                    /*if (context->tokenNames[0][0]==(uint8_t)'_'){
                        os_memmove(context->tokenNames[0],"TRX\0",4);
                        context->tokenNamesLength[0]=4;
                    }*/
                break;
                case 4: // Vote Witness
                case 11: // Freeze Balance Contract
                case 12: // Unfreeze Balance Contract
                case 13: // Withdraw Balance Contract
                case 16: // Proposal Create Contract
                case 17: // Proposal Approve Contract
                case 18: // Proposal Delete Contract
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
/*
message ExchangeInjectContract {
  bytes owner_address = 1;
  int64 exchange_id = 2;
  bytes token_id = 3;
  int64 quant = 4;
}

message ExchangeWithdrawContract {
  bytes owner_address = 1;
  int64 exchange_id = 2;
  bytes token_id = 3;
  int64 quant = 4;
}

message ExchangeTransactionContract {
  bytes owner_address = 1;
  int64 exchange_id = 2;
  bytes token_id = 3;
  int64 quant = 4;
  int64 expected = 5;
}
*/

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
        strcpy((char *)out, tmp2);
    } else {
        out[0] = '\0';
    }
    return strlen((char *)out);
}

bool setContractType(uint8_t type, void * out){
    switch (type){
        case 0:
            os_memmove(out,"Account Create\0", 15);
            break;
        case 3:
            os_memmove(out,"Vote Asset\0", 11);
            break;
        case 4:
            os_memmove(out,"Vote Witness\0", 13);
            break;
        case 5:
            os_memmove(out,"Witness Create\0", 15);
            break;
        case 6:
            os_memmove(out,"Asset Issue\0", 13);
            break;
        case 7:
            os_memmove(out,"Deploy Contract\0",  17);
            break;
        case 8:
            os_memmove(out,"Witness Update\0", 15);
            break; 
        case 9:
            os_memmove(out,"Participate Asset\0", 18);
            break;
        case 10:
            os_memmove(out,"Account Update\0", 15);
            break;
        case 11:
            os_memmove(out,"Freeze Balance\0", 15);
            break;
        case 12:
            os_memmove(out,"Unfreeze Balance\0", 17);
            break;
        case 13:
            os_memmove(out,"Withdraw Balance\0", 17);
            break;
        case 14:
            os_memmove(out,"Unfreeze Asset\0", 15);
            break;
        case 15:
            os_memmove(out,"Update Asset\0", 13);
            break;
        case 16:
            os_memmove(out,"Proposal Create\0", 16);
            break;
        case 17:
            os_memmove(out,"Proposal Approve\0", 17);
            break;
        case 18:
            os_memmove(out,"Proposal Delete\0", 16);
            break;
        default: 
        return false;
    };
    return true;
}

bool setExchangeContractDetail(uint8_t type, void * out){
    switch (type){
        case 41:
            os_memmove((void *)out,"create\0", 7);
            break;
        case 42:
            os_memmove((void *)out,"inject\0", 7);
            break;
        case 43:
            os_memmove((void *)out,"withdraw\0", 9);
            break;
        case 44:
            os_memmove((void *)out,"transaction\0", 12);
            break;
        default: 
        return false;
    };
    return true;
}
//exchangeContractDetails

// ALLOW SAME NAME TOKEN
// CHECK SIGNATURE(ID+NAME+PRECISION)
// Parse token Name and Signature
parserStatus_e parseTokenName(uint8_t token_id, uint8_t *data, uint32_t dataLength, txContent_t *context) {
    parserStatus_e result = USTREAM_FAULT;
    uint8_t index = 0;
    uint8_t tokenNameValidation[33];
    uint8_t tokenNameValidationLength = 0;
    BEGIN_TRY {
        TRY {
            // Get Token Name
            if ((data[index]>>PB_FIELD_R)!=1 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
            index++;if (index>dataLength) THROW(0x6a80); 
            tokenNameValidationLength=data[index]; if (tokenNameValidationLength > 32) THROW(0x6a80); 
            index++;if (index+tokenNameValidationLength > dataLength) THROW(0x6a80);
            os_memmove(tokenNameValidation,data+index,tokenNameValidationLength);
            tokenNameValidation[tokenNameValidationLength]='\0';
            index+=tokenNameValidationLength; if (index>dataLength) THROW(0x6a80);
            // Get decimals
            if ((data[index]>>PB_FIELD_R)!=2 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
            index++;if (index>dataLength) THROW(0x6a80);
            // find end of base128
            uint8_t decimals = 0;
            // find end of base128
            for(int b128=0; index<dataLength; ++index){
                decimals += ((uint8_t)( data[index] & PB_BASE128DATA) << b128) ;
                if ((data[index]&PB_BASE128) == 0) break;
                b128+=7;
            }
            index++;if (index > dataLength) THROW(0x6a88);
            // Get Signature
            if ((data[index]>>PB_FIELD_R)!=3 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
            index++;if (index>dataLength) THROW(0x6a80); 
            index++;if (index+data[index-1] > dataLength) THROW(0x6a80);
            // Validate token ID + Name
            int ret = verifyTokenNameID((const char *)context->tokenNames[token_id],(const char *)tokenNameValidation,decimals,(uint8_t *)data+index, data[index-1]);
            if (ret!=1)
                THROW(0x6a80);
            
            // UPDATE Token with Name[ID]
            uint8_t tmp[MAX_TOKEN_LENGTH];

            snprintf((char *)tmp, MAX_TOKEN_LENGTH,"%s[%s]",
                tokenNameValidation, context->tokenNames[token_id]);
            context->tokenNamesLength[token_id] = strlen((const char *)tmp);
            os_memmove(context->tokenNames[token_id], tmp, context->tokenNamesLength[token_id]+1);
            context->decimals[token_id]=decimals;
            

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

// Exchange Token ID + Name
// CHECK SIGNATURE(EXCHANGEID+TOKEN1ID+NAME1+PRECISION1+TOKEN2ID+NAME2+PRECISION2)
// Parse token Name and Signature
parserStatus_e parseExchange(uint8_t token_id, uint8_t *data, uint32_t dataLength, txContent_t *context) {
    parserStatus_e result = USTREAM_FAULT;
    uint8_t index = 0;
    uint8_t tokenID[2][8];
    uint8_t tokenNAME[2][33];
    uint8_t tokenDecimals[2];
    uint8_t buffer[90];
    uint8_t len = 0;
    BEGIN_TRY {
        TRY {
            // Get Exchange ID
            if ((data[index]>>PB_FIELD_R)!=1 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
            index++;if (index>dataLength) THROW(0x6a80);
            // find end of base128
            uint32_t ID = 0;
            // find end of base128
            for(int b128=0; index<dataLength; ++index){
                ID += ((uint32_t)( data[index] & PB_BASE128DATA) << b128) ;
                if ((data[index]&PB_BASE128) == 0) break;
                b128+=7;
            }
            index++;if (index > dataLength) THROW(0x6a88);
            if (context->exchangeID!= ID) THROW(0x6a80);
            // Get Token ID 1
            if ((data[index]>>PB_FIELD_R)!=2 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
            index++;if (index>dataLength) THROW(0x6a80); 
            if ((data[index] != 7) && (data[index] != 1) ) THROW(0x6a80); 
            index++;if (index+data[index-1] > dataLength) THROW(0x6a80);
            os_memmove(tokenID[0],data+index,data[index-1]);
            len += data[index-1];
            tokenID[0][data[index-1]] = '\0';
            index+=data[index-1]; if (index>dataLength) THROW(0x6a80);
            // Get Token 1 Name
            if ((data[index]>>PB_FIELD_R)!=3 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
            index++;if (index>dataLength) THROW(0x6a80); 
            if (data[index] > 32) THROW(0x6a80); 
            index++;if (index+data[index-1] > dataLength) THROW(0x6a80);
            os_memmove(tokenNAME[0],data+index,data[index-1]);
            len += data[index-1];
            tokenNAME[0][data[index-1]]='\0';
            index+=data[index-1]; if (index>dataLength) THROW(0x6a80);
            // Get decimals 1
            if ((data[index]>>PB_FIELD_R)!=4 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
            index++;if (index>dataLength) THROW(0x6a80);
            // find end of base128
            tokenDecimals[0] = 0;
            // find end of base128
            for(int b128=0; index<dataLength; ++index){
                tokenDecimals[0] += ((uint8_t)( data[index] & PB_BASE128DATA) << b128) ;
                if ((data[index]&PB_BASE128) == 0) break;
                b128+=7;
            }
            index++;if (index > dataLength) THROW(0x6a88);

            // Get Token ID 2
            if ((data[index]>>PB_FIELD_R)!=5 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
            index++;if (index>dataLength) THROW(0x6a80); 
            if ((data[index] != 7) && (data[index] != 1) ) THROW(0x6a80); 
            index++;if (index+data[index-1] > dataLength) THROW(0x6a80);
            os_memmove(tokenID[1],data+index,data[index-1]);
            len += data[index-1];
            tokenID[1][data[index-1]] = '\0';
            index+=data[index-1]; if (index>dataLength) THROW(0x6a80);
            // Get Token 2 Name
            if ((data[index]>>PB_FIELD_R)!=6 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
            index++;if (index>dataLength) THROW(0x6a80); 
            if (data[index] > 32) THROW(0x6a80); 
            index++;if (index+data[index-1] > dataLength) THROW(0x6a80);
            os_memmove(tokenNAME[1],data+index,data[index-1]);
            len += data[index-1];
            tokenNAME[1][data[index-1]]='\0';
            index+=data[index-1]; if (index>dataLength) THROW(0x6a80);
            // Get decimals 2
            if ((data[index]>>PB_FIELD_R)!=7 || (data[index]&PB_TYPE)!=0 ) THROW(0x6a80);
            index++;if (index>dataLength) THROW(0x6a80);
            // find end of base128
            tokenDecimals[1] = 0;
            // find end of base128
            for(int b128=0; index<dataLength; ++index){
                tokenDecimals[1] += ((uint8_t)( data[index] & PB_BASE128DATA) << b128) ;
                if ((data[index]&PB_BASE128) == 0) break;
                b128+=7;
            }
            index++;if (index > dataLength) THROW(0x6a88);

            // Get Signature
            if ((data[index]>>PB_FIELD_R)!=8 || (data[index]&PB_TYPE)!=2 ) THROW(0x6a80);
            index++;if (index>dataLength) THROW(0x6a80); 
            index++;if (index+data[index-1] > dataLength) THROW(0x6a80);

            snprintf((char *)buffer, sizeof(buffer), "%d", ID);
            len += strlen(buffer);
            snprintf((char *)buffer, sizeof(buffer), "%d%s%s%c%s%s%c", ID,
                        tokenID[0], tokenNAME[0], tokenDecimals[0],
                        tokenID[1], tokenNAME[1], tokenDecimals[1]);

            // Validate token ID + Name
            int ret = verifyExchangeID((const unsigned char *)buffer, len + 2, (uint8_t *)data+index, data[index-1]);
            if (ret!=1)
                THROW(0x6a80);
            
            // UPDATE Token with Name[ID]
            uint8_t tmp[MAX_TOKEN_LENGTH];
            uint8_t firtToken = 0;
            uint8_t secondToken = 0;
            if (strcmp((const char *)context->tokenNames[0], (const char *)tokenID[0])==0){
                firtToken = 0;
                secondToken = 1;
            }else if (strcmp((const char *)context->tokenNames[0], (const char *)tokenID[1])==0){
                firtToken = 1;
                secondToken = 0;
            }else{
                THROW(0x6a80);
            }
            
            snprintf((char *)tmp, MAX_TOKEN_LENGTH,"%s[%s]",
                tokenNAME[0], tokenID[0]);
            os_memmove(context->tokenNames[firtToken], tmp, strlen((const char *)tmp)+1);
            context->tokenNamesLength[firtToken] = strlen((const char *)tmp);
            context->decimals[firtToken]=tokenDecimals[0];

            snprintf((char *)tmp, MAX_TOKEN_LENGTH,"%s[%s]",
                tokenNAME[1], tokenID[1]);
            os_memmove(context->tokenNames[secondToken], tmp, strlen((const char *)tmp)+1);
            context->tokenNamesLength[secondToken] = strlen((const char *)tmp);
            context->decimals[secondToken]=tokenDecimals[1];


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