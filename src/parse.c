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
#include "settings.h"

tokenDefinition_t* getKnownToken(txContent_t *context) {
    uint8_t i;

    tokenDefinition_t *currentToken = NULL;
    for (i=0; i<NUM_TOKENS_TRC20; i++) {
        currentToken = (tokenDefinition_t *)PIC(&TOKENS_TRC20[i]);
        if (os_memcmp(currentToken->address, context->contractAddress, ADDRESS_SIZE) == 0) {
            PRINTF("Selected token %d\n",i);
            return currentToken;
        }
    }
    return NULL;
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
        strcpy((char *)out, tmp2);
    } else {
        out[0] = '\0';
    }
    return strlen((char *)out);
}

bool setContractType(uint8_t type, void * out){
    switch (type){
        case ACCOUNTCREATECONTRACT:
            os_memmove(out,"Account Create\0", 15);
            break;
        case VOTEASSETCONTRACT:
            os_memmove(out,"Vote Asset\0", 11);
            break;
        case VOTEWITNESSCONTRACT:
            os_memmove(out,"Vote Witness\0", 13);
            break;
        case WITNESSCREATECONTRACT:
            os_memmove(out,"Witness Create\0", 15);
            break;
        case ASSETISSUECONTRACT:
            os_memmove(out,"Asset Issue\0", 13);
            break;
        case WITNESSUPDATECONTRACT:
            os_memmove(out,"Witness Update\0", 15);
            break; 
        case PARTICIPATEASSETISSUECONTRACT:
            os_memmove(out,"Participate Asset\0", 18);
            break;
        case ACCOUNTUPDATECONTRACT:
            os_memmove(out,"Account Update\0", 15);
            break;
        case FREEZEBALANCECONTRACT:
            os_memmove(out,"Freeze Balance\0", 15);
            break;
        case UNFREEZEBALANCECONTRACT:
            os_memmove(out,"Unfreeze Balance\0", 17);
            break;
        case WITHDRAWBALANCECONTRACT:
            os_memmove(out,"Withdraw Balance\0", 17);
            break;
        case UNFREEZEASSETCONTRACT:
            os_memmove(out,"Unfreeze Asset\0", 15);
            break;
        case UPDATEASSETCONTRACT:
            os_memmove(out,"Update Asset\0", 13);
            break;
        case PROPOSALCREATECONTRACT:
            os_memmove(out,"Proposal Create\0", 16);
            break;
        case PROPOSALAPPROVECONTRACT:
            os_memmove(out,"Proposal Approve\0", 17);
            break;
        case PROPOSALDELETECONTRACT:
            os_memmove(out,"Proposal Delete\0", 16);
            break;
        default: 
        return false;
    };
    return true;
}

bool setExchangeContractDetail(uint8_t type, void * out){
    switch (type){
        case EXCHANGECREATECONTRACT:
            os_memmove((void *)out,"create\0", 7);
            break;
        case EXCHANGEINJECTCONTRACT:
            os_memmove((void *)out,"inject\0", 7);
            break;
        case EXCHANGEWITHDRAWCONTRACT:
            os_memmove((void *)out,"withdraw\0", 9);
            break;
        case EXCHANGETRANSACTIONCONTRACT:
            os_memmove((void *)out,"transaction\0", 12);
            break;
        default: 
        return false;
    };
    return true;
}


// ALLOW SAME NAME TOKEN
// CHECK SIGNATURE(ID+NAME+PRECISION)
// Parse token Name and Signature
parserStatus_e parseTokenName(uint8_t token_id, uint8_t *data, uint32_t dataLength, txContent_t *content) {
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
            int ret = verifyTokenNameID((const char *)content->tokenNames[token_id],(const char *)tokenNameValidation,
                        decimals,(uint8_t *)data+index, data[index-1], content->publicKeyContext);
            if (ret!=1)
                THROW(0x6a80);
            
            // UPDATE Token with Name[ID]
            uint8_t tmp[MAX_TOKEN_LENGTH];

            snprintf((char *)tmp, MAX_TOKEN_LENGTH,"%s[%s]",
                tokenNameValidation, content->tokenNames[token_id]);
            content->tokenNamesLength[token_id] = strlen((const char *)tmp);
            os_memmove(content->tokenNames[token_id], tmp, content->tokenNamesLength[token_id]+1);
            content->decimals[token_id]=decimals;
            

            result = USTREAM_FINISHED;
        }
        CATCH(EXCEPTION_IO_RESET) {
            result = EXCEPTION_IO_RESET;
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
parserStatus_e parseExchange(uint8_t token_id, uint8_t *data, uint32_t dataLength, txContent_t *content) {
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
            if (content->exchangeID!= ID) THROW(0x6a80);
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
            len += strlen((const char *)buffer);
            snprintf((char *)buffer, sizeof(buffer), "%d%s%s%c%s%s%c", ID,
                        tokenID[0], tokenNAME[0], tokenDecimals[0],
                        tokenID[1], tokenNAME[1], tokenDecimals[1]);

            // Validate token ID + Name
            int ret = verifyExchangeID((const unsigned char *)buffer, len + 2, 
                            (uint8_t *)data+index, data[index-1], content->publicKeyContext);
            if (ret!=1)
                THROW(0x6a80);
            
            // UPDATE Token with Name[ID]
            uint8_t firstToken = 0;
            uint8_t secondToken = 0;
            if (strcmp((const char *)content->tokenNames[0], (const char *)tokenID[0])==0){
                firstToken = 0;
                secondToken = 1;
            }else if (strcmp((const char *)content->tokenNames[0], (const char *)tokenID[1])==0){
                firstToken = 1;
                secondToken = 0;
            }else{
                THROW(0x6a80);
            }
            
            snprintf((char *)buffer, MAX_TOKEN_LENGTH,"%s[%s]",
                tokenNAME[0], tokenID[0]);
            os_memmove(content->tokenNames[firstToken], buffer, strlen((const char *)buffer)+1);
            content->tokenNamesLength[firstToken] = strlen((const char *)buffer);
            content->decimals[firstToken]=tokenDecimals[0];

            snprintf((char *)buffer, MAX_TOKEN_LENGTH,"%s[%s]",
                tokenNAME[1], tokenID[1]);
            os_memmove(content->tokenNames[secondToken], buffer, strlen((const char *)buffer)+1);
            content->tokenNamesLength[secondToken] = strlen((const char *)buffer);
            content->decimals[secondToken]=tokenDecimals[1];
            PRINTF("Lenths: %d,%d\n",content->tokenNamesLength[firstToken] ,content->tokenNamesLength[secondToken]);

            result = USTREAM_FINISHED;
        }
        CATCH(EXCEPTION_IO_RESET) {
            result = EXCEPTION_IO_RESET;
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

 void initTx(txContext_t *context, cx_sha256_t *sha2, txContent_t *content) {
    os_memset(context, 0, sizeof(txContext_t));
    os_memset(content, 0, sizeof(txContent_t));
    context->sha2 = sha2;
    context->initialized = true;
    cx_sha256_init(sha2); //init sha
}

uint8_t parseVariant(txContext_t *context, uint8_t *data, 
    uint8_t *index, uint8_t dataLength, uint64_t *result){
    uint8_t count = 0;
    if (result!= NULL) *result = 0;
    // find end of base128
    for(int b128=0; (*index+count)<dataLength; count++){
        if (result!= NULL)
             *result += ((uint64_t)( data[*index+count] & PB_BASE128DATA) << b128) ;
        if ((data[*index+count]&PB_BASE128) == 0){
            *index+=(count+1);
            return count+1;
        } 
        b128+=7;
    }
    PRINTF("Error parsing variant...\n");
    THROW(0x6a80);
}

bool addToQueue(txContext_t *context, uint8_t *buffer, uint8_t length){
    if (length<=60 && context->queueBufferLength==0) {
        os_memmove(context->queueBuffer,
            buffer, length);
        context->queueBufferLength = length;
        return true;
    }
    return false;
}

uint8_t parseTokenID(txContext_t *context, uint8_t *data, uint8_t *index,
    uint8_t dataLength, uint8_t *out, uint8_t *outLength){

        PRINTF("TokenID size: %02x\n",data[*index]);
        *outLength=data[*index];
        if (*outLength!=TOKENID_SIZE && *outLength!=1) THROW(0x6a80);
        (*index)++;
        if ((*index+*outLength)>dataLength ) {
            if (addToQueue(context, data+(*index)-2, (dataLength-(*index)+2) )){
                *index=dataLength;
                return 0;
            }else THROW(0x6a80);
        }
        if (*outLength==1){
            if (data[*index]=='_'){
                *outLength=3;
                os_memmove(out,"TRX\0",4);
                (*index) += 1;
                return 1;
            }else THROW(0x6a80);
        }
        os_memmove(out,data+(*index),*outLength);
        out[*outLength]=0;
        (*index) += (*outLength);
        return *outLength;
        
}

uint8_t parseAddress(txContext_t *context, uint8_t *data, uint8_t *index,
    uint8_t dataLength, uint8_t *out){

        if (data[*index]!=ADDRESS_SIZE) THROW(0x6a80);
        (*index)++;
        if ((*index+ADDRESS_SIZE)>dataLength ) {
            if (addToQueue(context, data+(*index)-2, (dataLength-(*index)+2) )){
                *index=dataLength;
                return 0;
            }else THROW(0x6a80);
        }
        os_memmove(out,data+(*index),ADDRESS_SIZE);
        out[ADDRESS_SIZE]=0;
        (*index) += (ADDRESS_SIZE);
        return ADDRESS_SIZE;
}

uint16_t processTx(txContext_t *context, uint8_t *buffer,
                         uint32_t length, txContent_t *content) {
    uint8_t offset = 0;
    uint16_t result;

    if (length==0) return USTREAM_FINISHED;

    BEGIN_TRY { 
        TRY {

            if (context->getNext>0){
                // only for long  data field
                if (context->getNext>length){
                    context->getNext=context->getNext-length;
                    return USTREAM_PROCESSING;
                }
                offset = (uint8_t)(context->getNext&0xFF);
                context->getNext = 0;
            }
                    
            while (offset != length) {
                uint64_t tmpNumber = 0;
                uint8_t count = 0;

                if (offset > length) {
                    PRINTF("ERROR offset > length [%d,%d]\n",offset, length);
                    THROW(0x6a80);
                }
                uint8_t field = (buffer[offset]>>PB_FIELD_R);
                uint8_t type = (buffer[offset]&PB_TYPE);
                offset++;
                
                PRINTF("Stage: %d, Case: %d, Type: %d \n",context->stage, field, type);
                switch(context->stage) {
                    case 0:
                        // raw transaction
                        switch(field) {
                            case 1: //ref_block_bytes
                                if (type!=2) THROW(0x6a80);
                                count = parseVariant(context, buffer, &offset, 
                                                        length, &tmpNumber);
                                offset += (uint8_t)(tmpNumber&0xFF);
                                break; //skip
                            case 3: //ref_block_num
                                count = parseVariant(context, buffer, &offset, 
                                                        length, NULL);
                                break; //skip
                            case 4: //ref_block_hash
                                if (type!=2) THROW(0x6a80);
                                count = parseVariant(context, buffer, &offset, 
                                                        length, &tmpNumber);
                                offset += (uint8_t)(tmpNumber&0xFF);
                                break; //skip
                            case 8: //expiration
                                count = parseVariant(context, buffer, &offset, 
                                                        length, NULL);
                                break; //skip
                            case 10:
                                // Check permissions Allo data
                                if (!dataAllowed) THROW(0x6a80);
                                // parse data
                                if (type!=2) THROW(0x6a80);
                                count = parseVariant(context, buffer, &offset, 
                                                        length, &tmpNumber);
                                content->dataBytes = tmpNumber;
                                
                                if (tmpNumber>255 || (tmpNumber+offset)>length) {
                                    context->getNext = (uint32_t)(tmpNumber);
                                    context->getNext += offset;
                                    context->getNext -= length;
                                    offset=length;
                                }else{
                                    offset += (uint8_t)(tmpNumber&0xFF);
                                }
                                break;
                            case 11:
                                // parse contract
                                if (type!=2) THROW(0x6a80);
                                count = parseVariant(context, buffer, &offset, 
                                                        length, &tmpNumber);
                                context->stageQueue[0].total = (uint16_t)(tmpNumber&0xFFFF);
                                context->stageQueue[0].count = 0;
                                context->stage = 1; 
                                break;
                            case 12: // scripts
                                if (type!=2) THROW(0x6a80);
                                count = parseVariant(context, buffer, &offset, 
                                                        length, &tmpNumber);
                                if (tmpNumber>255) THROW(0x6a80);    
                                offset += (uint8_t)(tmpNumber&0xFF);
                                break; //skip
                            case 14: // timestamp
                            case 18: // fee_limit
                                count = parseVariant(context, buffer, &offset, 
                                                        length, NULL);
                                break; //skip
                        }
                    break;
                    case 1:
                        // Contract
                        switch(field) {
                            case 1: //ContractType
                                if (type!=0) THROW(0x6a80);
                                count = parseVariant(context, buffer, &offset, 
                                                        length, &tmpNumber);
                                count++;
                                content->contractType = (uint8_t)(tmpNumber&0xFF);
                                PRINTF("Contract Type: %d\n",content->contractType);
                                break;
                            case 2: // parameter
                                if (type!=2) THROW(0x6a80);
                                count = parseVariant(context, buffer, &offset, 
                                                        length, NULL);
                                // Get Payload type.googleapis
                                if (buffer[offset]!=0x0A) THROW(0x6a80);
                                offset++; count++;
                                count += parseVariant(context, buffer, &offset, 
                                                        length, &tmpNumber);

                                if ((tmpNumber)>255) THROW(0x6a80);
                                count += (uint8_t)(tmpNumber&0xFF);
                                offset += (uint8_t)(tmpNumber&0xFF);
                                if (offset>length) {
                                    uint8_t pending = (offset-length);
                                    if (!addToQueue(context,buffer+offset-count-1, count-pending+1)) THROW(0x6a80);
                                    count = 0;
                                    offset=length;
                                    break;
                                }
                                // Contract Details
                                // Check length
                                if (buffer[offset]!=0x12) THROW(0x6a80); // 0x12 Field 2 type String
                                offset++; count++; 
                                count += parseVariant(context, buffer, &offset, 
                                                        length, &tmpNumber);
                                PRINTF("Contract Size: %d\n",(uint32_t)tmpNumber);
                                context->stageQueue[1].total = (uint16_t)(tmpNumber&0xFFFF);
                                context->stageQueue[1].count = 0;
                                context->stage = 2; 
                                count++;
                                break;
                                
                            case 3: //provider
                            case 4: //ContractName
                                if (type!=2) THROW(0x6a80);
                                count = parseVariant(context, buffer, &offset, 
                                                        length, &tmpNumber);
                                if ((offset+tmpNumber)>255) THROW(0x6a80);
                                offset += (uint8_t)(tmpNumber&0xFF);
                                count += (uint8_t)(tmpNumber&0xFF)+1;
                                break;
                            case 5: //Permission_id
                                if (type!=0) THROW(0x6a80);
                                // get id
                                count = parseVariant(context, buffer, &offset, 
                                            length, &tmpNumber);
                                if (tmpNumber>9) THROW(0x6a80); // Valid only from 0 - 9
                                content->permission_id = (uint8_t)(tmpNumber&0xFF);
                                count += 1;
                                break;
                        }
                        PRINTF("Stage end %d,%d,%d\n",context->stageQueue[0].total,context->stageQueue[0].count,count);
                        context->stageQueue[0].count += count;
                        if (context->stageQueue[0].count>context->stageQueue[0].total) THROW(0x6a81);
                        if (context->stageQueue[0].count==context->stageQueue[0].total){
                            context->stage = 0;
                        }
                    break;
                    case 2:
                        // Contract
                        switch (content->contractType){
                            case TRANSFERCONTRACT: // Send TRX
                                switch(field) {
                                    case 1: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        // set TRX token name
                                        content->tokenNamesLength[0]=4;
                                        os_memmove(content->tokenNames[0],"TRX\0",content->tokenNamesLength[0]);
                                        // get owner address
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 2: //to_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->destination);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 3: //amount
                                        if (type!=0) THROW(0x6a80);
                                        // get amount
                                        count = parseVariant(context, buffer, &offset, 
                                                        length, &content->amount);
                                        count += 1;
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            case TRANSFERASSETCONTRACT:
                                switch(field) {
                                    case 1: // Token ID
                                        if (type!=2) THROW(0x6a80);
                                        count = parseTokenID(context, buffer, &offset, length, 
                                                content->tokenNames[0], &content->tokenNamesLength[0]);
                                        if (count==0) break;
                                        content->tokenNamesLength[0]=TOKENID_SIZE;
                                        count+=2;
                                        break;
                                    case 2: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 3: //to_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->destination);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 4: //amount
                                        if (type!=0) THROW(0x6a80);
                                        // get amount
                                        count = parseVariant(context, buffer, &offset, 
                                                        length, &content->amount);
                                        count += 1;
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            case TRIGGERSMARTCONTRACT:
                            switch(field) {
                                    case 1: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 2: //contract_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->contractAddress);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 3: //call_value
                                        if (type!=0) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                                        length, &content->amount);
                                        count += 1;
                                        break;
                                    case 4: //data
                                        PRINTF("Parsing SmartContract DATA\n");
                                        if (type!=2) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                                    length, &tmpNumber);
                                        PRINTF("COUNT: %d, contract length: %d\n",count,(uint32_t)tmpNumber);
                                        // check if data is complete, if not add to queue buffer
                                        if (tmpNumber>255 || (tmpNumber+offset)>length) {
                                            if (addToQueue(context, buffer+offset-count-1, length-offset+count+1 )){
                                                count =0;
                                                offset = length;
                                                break;
                                            }else THROW(0x6a80);
                                        }
                                        // data fit buffer, process data
                                        // get selector
                                        PRINTF("Selector: %08x\n",U4BE(buffer, offset));
                                        if (os_memcmp(&buffer[offset], SELECTOR[0], 4) == 0) content->TRC20Method = 1; // check if transfer(address, uint256) function
                                        else if (os_memcmp(&buffer[offset], SELECTOR[1], 4) == 0) content->TRC20Method = 2; // check if approve(address, uint256) function
                                        else {
                                            if (!customContract) {
                                                // NOT ALLOWED
                                                PRINTF("Custom contracts NOT ALLOWED\n");
                                                THROW(0x6a80);
                                            }
                                            PRINTF("Processing custom contract\n");
                                            // check if length is divided by 32bytes
                                            if ( (tmpNumber-4)%32 !=0 ) THROW(0x6a80);
                                            content->TRC20Method=0;
                                            // if custom contracts allowed
                                            content->customSelector = U4BE(buffer, offset);
                                            offset += (uint8_t)(tmpNumber&0xFF);
                                            count += (uint8_t)(tmpNumber&0xFF)+1;
                                            break;
                                        }
                                        // check if DATA field size matchs TRC20 Transfer/Approve
                                        if (tmpNumber!=TRC20_DATA_FIELD_SIZE) THROW(0x6a80);
                                        // TO Address
                                        os_memmove(content->destination, buffer+offset+15, ADDRESS_SIZE);
                                        //set MainNet PREFIX
                                        content->destination[0]=ADD_PRE_FIX_BYTE_MAINNET;
                                        // Amount
                                        os_memmove(content->TRC20Amount, buffer+offset+36, 32);
                                        tokenDefinition_t* TRC20 = getKnownToken(content);
                                        if (TRC20 == NULL) THROW(0x6a80);
                                        content->decimals[0] = TRC20->decimals;
                                        content->tokenNamesLength[0] = strlen((const char *)TRC20->ticker)+1;
                                        os_memmove(content->tokenNames[0], TRC20->ticker, content->tokenNamesLength[0]);

                                        offset += (uint8_t)(tmpNumber&0xFF);
                                        count += (uint8_t)(tmpNumber&0xFF)+1;
                                        break;

                                    case 5: //call_token_value
                                        if (type!=0) THROW(0x6a80);
                                        // get amount
                                        count = parseVariant(context, buffer, &offset, 
                                                        length, &content->amount2);
                                        count += 1;
                                        break;
                                    case 6: //token_id
                                        if (type!=0) THROW(0x6a80);
                                        // get token id
                                        count = parseVariant(context, buffer, &offset, 
                                                        length, &tmpNumber);
                                        count += 1;
                                        snprintf((char *)content->tokenNames[0], MAX_TOKEN_LENGTH,
                                                "%d",(uint32_t)tmpNumber);                                                
                                        content->tokenNamesLength[0] = strlen((const char *)content->tokenNames[0]);                                        
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            case EXCHANGECREATECONTRACT: 
                                switch(field) {
                                    case 1: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 2: //First Token
                                        if (type!=2) THROW(0x6a80);
                                        count = parseTokenID(context, buffer, &offset, length, 
                                                content->tokenNames[0], &content->tokenNamesLength[0]);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 3: //First Token Amount
                                        if (type!=0) THROW(0x6a80);
                                        // get amount
                                        count = parseVariant(context, buffer, &offset, 
                                                        length, &content->amount);
                                        count += 1;
                                        break;
                                    case 4: //First Token
                                        if (type!=2) THROW(0x6a80);
                                        count = parseTokenID(context, buffer, &offset, length, 
                                                content->tokenNames[1], &content->tokenNamesLength[1]);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 5: //First Token Amount
                                        if (type!=0) THROW(0x6a80);
                                        // get amount
                                        count = parseVariant(context, buffer, &offset, 
                                                        length, &content->amount2);
                                        count += 1;
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            case EXCHANGEINJECTCONTRACT:
                            case EXCHANGEWITHDRAWCONTRACT:
                                switch(field) {
                                    case 1: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 2: //Exchange id
                                        if (type!=0) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                                        length, &content->exchangeID);
                                        count += 1;
                                        break;
                                    case 3: //Token ID
                                        if (type!=2) THROW(0x6a80);
                                        count = parseTokenID(context, buffer, &offset, length, 
                                                content->tokenNames[0], &content->tokenNamesLength[0]);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 4: //Token Amount
                                        if (type!=0) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                                        length, &content->amount);
                                        count += 1;
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            case EXCHANGETRANSACTIONCONTRACT:
                                switch(field) {
                                    case 1: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 2: //Exchange id
                                        if (type!=0) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                                        length, &content->exchangeID);
                                        count += 1;
                                        break;
                                    case 3: //Token ID
                                        if (type!=2) THROW(0x6a80);
                                        count = parseTokenID(context, buffer, &offset, length, 
                                                content->tokenNames[0], &content->tokenNamesLength[0]);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 4: //Token Amount
                                        if (type!=0) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                                        length, &content->amount);
                                        count += 1;
                                        break;
                                    case 5: //Expected Amount
                                        if (type!=0) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                                        length, &content->amount2);
                                        count += 1;
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            case VOTEWITNESSCONTRACT: // Vote Witness
                                switch(field) {
                                    case 1: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        content->amount=0;
                                        break;
                                    case 2: //votes
                                        if (type!=2) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                                                length, &tmpNumber);
                                        if (tmpNumber>255 || (tmpNumber+offset)>length) {
                                            if (addToQueue(context, buffer+offset-count-1, length-offset+count+1 )){
                                                count =0;
                                                offset = length;
                                                break;
                                            }else THROW(0x6a80);
                                        }else{
                                            content->amount++;
                                            count += (uint8_t)(tmpNumber&0xFF)+1;
                                            offset += (uint8_t)(tmpNumber&0xFF);
                                        }
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            case FREEZEBALANCECONTRACT: // Freeze Balance Contract
                                switch(field) {
                                    case 1: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 2: //frozen_balance
                                        if (type!=0) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                            length, NULL);
                                        count += 1;
                                        break;
                                    case 3: //frozen_duration
                                        if (type!=0) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                            length, NULL);
                                        count += 1;
                                        break;
                                    case 10: //ResourceCode
                                        if (type!=0) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                            length, &tmpNumber);
                                        if (tmpNumber>1) THROW(0x6a80);
                                        content->resource=(uint8_t)(tmpNumber&0xFF);
                                        count += 1;
                                        break;
                                    case 15: //receiver_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->destination);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            case UNFREEZEBALANCECONTRACT: // Unfreeze Balance Contract
                                switch(field) {
                                    case 1: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 10: //ResourceCode
                                        if (type!=0) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                            length, &tmpNumber);
                                        if (tmpNumber>1) THROW(0x6a80);
                                        content->resource=(uint8_t)tmpNumber;
                                        count += 1;
                                        break;
                                    case 15: //receiver_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            case WITHDRAWBALANCECONTRACT: // Withdraw Balance Contract
                                switch(field) {
                                    case 1: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            case PROPOSALCREATECONTRACT: // Proposal Create Contract
                                switch(field) {
                                    case 1: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 2: //parameters
                                        if (type!=2) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                                                length, &tmpNumber);
                                        if (tmpNumber>255 || (tmpNumber+offset)>length) {
                                            if (addToQueue(context, buffer+offset-count-1, length-offset+count+1 )){
                                                count =0;
                                                offset = length;
                                                break;
                                            }else THROW(0x6a80);
                                        }else{
                                            content->amount++;
                                            count += (uint8_t)(tmpNumber&0xFF)+1;
                                            offset += (uint8_t)(tmpNumber&0xFF);
                                        }
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            case PROPOSALAPPROVECONTRACT: // Proposal Approve Contract
                                switch(field) {
                                    case 1: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 2: //proposal id
                                        if (type!=0) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                            length, NULL);
                                        count += 1;
                                        break;
                                    case 3: //approval
                                        if (type!=0) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                            length, NULL);
                                        count += 1;
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            case PROPOSALDELETECONTRACT: // Proposal Delete Contract
                                switch(field) {
                                    case 1: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    case 2: //Proposal id
                                        if (type!=0) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                            length, &content->exchangeID);
                                        count += 1;
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            case ACCOUNTUPDATECONTRACT:
                                switch(field) {
                                    case 1: //account_name
                                        if (type!=2) THROW(0x6a80);
                                        count = parseVariant(context, buffer, &offset, 
                                                    length, &tmpNumber);
                                        offset += (uint8_t)(tmpNumber&0xFF);
                                        count += (uint8_t)(tmpNumber&0xFF)+1;
                                        break;
                                    case 2: //owner_address
                                        if (type!=2) THROW(0x6a80);
                                        count = parseAddress(context, buffer, &offset, length, 
                                                content->account);
                                        if (count==0) break;
                                        count+=2;
                                        break;
                                    default:
                                        // INVALID
                                        THROW(0x6a80);
                                }
                            break;
                            default:
                                // INVALID
                                THROW(0x6a80);
                        }
                        PRINTF("Stage end %d,%d\n",context->stageQueue[1].count,count);
                        context->stageQueue[1].count += count;
                        if (context->stageQueue[1].count>context->stageQueue[1].total) THROW(0x6a81);
                        if (context->stageQueue[1].count==context->stageQueue[1].total){
                            context->stage = 1;
                            context->stageQueue[0].count += context->stageQueue[1].total;
                            PRINTF("Stage end0 %d,%d\n",context->stageQueue[0].count,context->stageQueue[0].total);
                            if (context->stageQueue[0].count>context->stageQueue[0].total) THROW(0x6a81);
                            if (context->stageQueue[0].count==context->stageQueue[0].total){
                                context->stage = 0;
                            }
                        }
                    break;
                }
            }
            result = USTREAM_PROCESSING;
        }
        CATCH(EXCEPTION_IO_RESET) {
            PRINTF("processTx IOERROR: %04x\n",EXCEPTION_IO_RESET);
            return EXCEPTION_IO_RESET;
        }
        CATCH_OTHER(e) {
            PRINTF("processTx ERROR %04x\n",e);
            return e;
        }
        FINALLY {
        }
    }
    END_TRY;
    
    PRINTF("processTx RESULT: %04x\n",result);
    return result;
}
