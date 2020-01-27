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
#include <misc/TronApp.pb.h>
#include <string.h>

#include "settings.h"
#include "tokens.h"

tokenDefinition_t* getKnownToken(txContent_t *context) {
    uint8_t i;

    tokenDefinition_t *currentToken = NULL;
    for (i=0; i<NUM_TOKENS_TRC20; i++) {
        currentToken = (tokenDefinition_t *)PIC(&TOKENS_TRC20[i]);
        if (memcmp(currentToken->address, context->contractAddress, ADDRESS_SIZE) == 0) {
            PRINTF("Selected token %d\n",i);
            return currentToken;
        }
    }
    return NULL;
}

bool adjustDecimals(const char *src, uint32_t srcLength, char *target,
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
            strcpy(out, "Account Create");
            break;
        case VOTEASSETCONTRACT:
            strcpy(out, "Vote Asset");
            break;
        case VOTEWITNESSCONTRACT:
            strcpy(out,"Vote Witness");
            break;
        case WITNESSCREATECONTRACT:
            strcpy(out,"Witness Create");
            break;
        case ASSETISSUECONTRACT:
            strcpy(out,"Asset Issue");
            break;
        case WITNESSUPDATECONTRACT:
            strcpy(out,"Witness Update");
            break; 
        case PARTICIPATEASSETISSUECONTRACT:
            strcpy(out,"Participate Asset");
            break;
        case ACCOUNTUPDATECONTRACT:
            strcpy(out,"Account Update");
            break;
        case FREEZEBALANCECONTRACT:
            strcpy(out,"Freeze Balance");
            break;
        case UNFREEZEBALANCECONTRACT:
            strcpy(out,"Unfreeze Balance");
            break;
        case WITHDRAWBALANCECONTRACT:
            strcpy(out,"Withdraw Balance");
            break;
        case UNFREEZEASSETCONTRACT:
            strcpy(out,"Unfreeze Asset");
            break;
        case UPDATEASSETCONTRACT:
            strcpy(out,"Update Asset");
            break;
        case PROPOSALCREATECONTRACT:
            strcpy(out,"Proposal Create");
            break;
        case PROPOSALAPPROVECONTRACT:
            strcpy(out,"Proposal Approve");
            break;
        case PROPOSALDELETECONTRACT:
            strcpy(out,"Proposal Delete");
            break;
        default: 
            return false;
    }
    return true;
}

bool setExchangeContractDetail(uint8_t type, void * out){
    switch (type){
        case EXCHANGECREATECONTRACT:
            strcpy((void *)out,"create");
            break;
        case EXCHANGEINJECTCONTRACT:
            strcpy((void *)out,"inject");
            break;
        case EXCHANGEWITHDRAWCONTRACT:
            strcpy((void *)out,"withdraw");
            break;
        case EXCHANGETRANSACTIONCONTRACT:
            strcpy((void *)out,"transaction");
            break;
        default: 
        return false;
    }
    return true;
}


#include "../proto/core/Contract.pb.h"
#include "../proto/core/Tron.pb.h"
#include "../proto/misc/TronApp.pb.h"
#include "pb_decode.h"

// ALLOW SAME NAME TOKEN
// CHECK SIGNATURE(ID+NAME+PRECISION)
// Parse token Name and Signature
bool parseTokenName(uint8_t token_id, uint8_t *data, uint32_t dataLength, txContent_t *content) {
  TokenDetails details = {};

  pb_istream_t stream = pb_istream_from_buffer(data, dataLength);
  if (!pb_decode(&stream, TokenDetails_fields, &details)) {
    return false;
  }

  // Validate token ID + Name
  if (verifyTokenNameID((const char *)content->tokenNames[token_id],
                        details.name, details.precision,
                        details.signature.bytes, details.signature.size,
                        content->publicKeyContext) != 1) {
    return false;
  }

  // UPDATE Token with Name[ID]
  char tmp[MAX_TOKEN_LENGTH];
  snprintf(tmp, MAX_TOKEN_LENGTH, "%s[%s]", details.name,
           content->tokenNames[token_id]);
  content->tokenNamesLength[token_id] = strlen((const char *)tmp);
  strcpy((char *)content->tokenNames[token_id], tmp);
  content->decimals[token_id] = details.precision;
  return true;
}

static bool printTokenFromID(char *out, const uint8_t *data, size_t size) {
  for (unsigned int i = 0; i < 8; i++) {
    PRINTF("%02x", data[i]);
  }
  PRINTF("\n");
   if (size != TOKENID_SIZE && size != 1) {
     return false;
   }

   if (size == 1) {
     if (data[0] != '_') {
       return false;
     }
     strcpy(out, "TRX");
     return true;
   }
   strcpy(out, (char *)data);
   return true;
}

static bool set_token_info(txContent_t *content, unsigned int token_index,
                           const char *name, const char *id, int precision) {
  if (token_index >= 2) {
    return false;
  }

  /* Ugly, but snprintf does not have a return value... */
  snprintf((char *)content->tokenNames[token_index], MAX_TOKEN_LENGTH, "%s[%s]",
           name, id);
  content->tokenNamesLength[token_index] =
      strlen((char *)content->tokenNames[token_index]);
  content->decimals[token_index] = precision;
  return true;
}

// Exchange Token ID + Name
// CHECK SIGNATURE(EXCHANGEID+TOKEN1ID+NAME1+PRECISION1+TOKEN2ID+NAME2+PRECISION2)
// Parse token Name and Signature
bool parseExchange(const uint8_t *data,
                    size_t length, txContent_t *content) {
  ExchangeDetails details;
  char buffer[90];

  pb_istream_t stream = pb_istream_from_buffer(data, length);
  if (!pb_decode(&stream, ExchangeDetails_fields, &details)) {
    return false;
  }

  if (content->exchangeID != details.exchangeId) {
    return false;
  }

  /* Replace token ID with Name[ID] */
  if (strlen(details.token1Id) != 1 && strlen(details.token1Id) != 7) {
    return false;
  }
  if (strlen(details.token2Id) != 1 && strlen(details.token2Id) != 7) {
    return false;
  }

  /* Check provided signature. Strange serialization, it would have been
   * easier to sign the whole protobuf data...
   *
   * exchangeId is casted to int32_t as the custom snprintf implementation does
   * not seem to support %lld. Moreover, two calls to snprintf are made as
   * implementation does not return the number of written chars...
   */
  size_t msg_size;
  snprintf(buffer, sizeof(buffer), "%d", (int32_t)details.exchangeId);
  msg_size = strlen(buffer);

  snprintf(buffer, sizeof(buffer), "%d%s%s%c%s%s%c",
           (int32_t)details.exchangeId, details.token1Id, details.token1Name,
           details.token1Precision, details.token2Id, details.token2Name,
           details.token2Precision);
  msg_size += strlen(details.token1Id) + strlen(details.token1Name) + 1;
  msg_size += strlen(details.token2Id) + strlen(details.token2Name) + 1;

  if (!verifyExchangeID((uint8_t *)buffer, msg_size,
                        details.signature.bytes, details.signature.size,
                        content->publicKeyContext)) {
    return false;
  }

  int first_token = 0, second_token = 0;
  if (strcmp((char *)content->tokenNames[0], details.token1Id) == 0) {
    first_token = 0;
    second_token = 1;
  } else if (strcmp((char *)content->tokenNames[0], details.token2Id) == 0) {
    first_token = 1;
    second_token = 0;
  } else {
    return false;
  }

  if (!set_token_info(content, first_token, details.token1Name,
                      details.token1Id, details.token1Precision) ||
      !set_token_info(content, second_token, details.token2Name,
                      details.token2Id, details.token2Precision)) {
    return false;
  }

  PRINTF("Lengths: %d,%d\n", content->tokenNamesLength[first_token],
         content->tokenNamesLength[second_token]);
  return true;
}

void initTx(txContext_t *context, cx_sha256_t *sha2, txContent_t *content) {
    memset(context, 0, sizeof(txContext_t));
    memset(content, 0, sizeof(txContent_t));
    context->sha2 = sha2;
    context->initialized = true;
    cx_sha256_init(sha2); //init sha
}

static bool copy_address(uint8_t *dest, pb_bytes_array_t *src) {
  if (src->size != ADDRESS_SIZE) {
    return false;
  }
  memcpy(dest, src->bytes, ADDRESS_SIZE);
  return true;
}

#define COPY_ADDRESS(a, b) copy_address((a), (pb_bytes_array_t *)(b))

#define INIT_STREAM(tx)                                                        \
  pb_istream_from_buffer(tx->contract->parameter.value.bytes,                  \
                         tx->contract->parameter.value.size)

contract_t msg;

static bool transfer_contract(txContent_t *content,
                              const protocol_Transaction_raw *transaction) {
  pb_istream_t stream;

  stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_TransferContract_fields,
                 &msg.transfer_contract)) {
    return false;
  }
  content->amount = msg.transfer_contract.amount;

  if (!COPY_ADDRESS(content->account, &msg.transfer_contract.owner_address)) {
    return false;
  }
  if (!COPY_ADDRESS(content->destination, &msg.transfer_contract.to_address)) {
    return false;
  }

  content->tokenNamesLength[0] = 4;
  strcpy((char *)content->tokenNames[0], "TRX");
  return true;
}

static bool transfer_asset_contract(txContent_t *content,
                              const protocol_Transaction_raw *transaction) {
  pb_istream_t stream;

  stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_TransferAssetContract_fields,
                 &msg.transfer_asset_contract)) {
    return false;
  }
  content->amount = msg.transfer_asset_contract.amount;

  if (!printTokenFromID((char *)content->tokenNames[0],
                        msg.transfer_asset_contract.asset_name.bytes,
                        msg.transfer_asset_contract.asset_name.size)) {
    return false;
  }
  content->tokenNamesLength[0] = strlen((char *)content->tokenNames[0]);

  if (!COPY_ADDRESS(content->account, &msg.transfer_asset_contract.owner_address)) {
    return false;
  }
  if (!COPY_ADDRESS(content->destination, &msg.transfer_asset_contract.to_address)) {
    return false;
  }

  return true;
}

static bool vote_witness_contract(txContent_t *content,
                                  const protocol_Transaction_raw *transaction) {
  pb_istream_t stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_VoteWitnessContract_fields,
                 &msg.vote_witness_contract)) {
    return false;
  }

  content->amount = msg.vote_witness_contract.votes_count;
  return COPY_ADDRESS(content->account,
                      &msg.vote_witness_contract.owner_address);
}

static bool
freeze_balance_contract(txContent_t *content,
                        const protocol_Transaction_raw *transaction) {
  pb_istream_t stream;
  protocol_FreezeBalanceContract contract = {};

  stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_FreezeBalanceContract_fields, &contract)) {
    return false;
  }
  if (!COPY_ADDRESS(content->account, &contract.owner_address)) {
    return false;
  }

  if (contract.receiver_address.size != 0) {
    if (!COPY_ADDRESS(content->destination, &contract.receiver_address)) {
      return false;
    }
  }
  content->resource = contract.resource;
  return true;
}

static bool
unfreeze_balance_contract(txContent_t *content,
                          const protocol_Transaction_raw *transaction) {
  pb_istream_t stream;
  protocol_UnfreezeBalanceContract contract = {};

  stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_UnfreezeBalanceContract_fields, &contract)) {
    return false;
  }
  content->resource = contract.resource;

  if (!COPY_ADDRESS(content->account, &contract.owner_address)) {
    return false;
  }

  if (contract.receiver_address.size != 0) {
    return COPY_ADDRESS(content->destination, &contract.receiver_address);
  }
  return true;
}

static bool
withdraw_balance_contract(txContent_t *content,
                          const protocol_Transaction_raw *transaction) {
  pb_istream_t stream;
  protocol_WithdrawBalanceContract contract = {};

  stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_WithdrawBalanceContract_fields, &contract)) {
    return false;
  }
  return COPY_ADDRESS(content->account, &contract.owner_address);
}

static bool
proposal_create_contract(txContent_t *content,
                         const protocol_Transaction_raw *transaction) {
  pb_istream_t stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_ProposalCreateContract_fields,
                 &msg.proposal_create_contract)) {
    return false;
  }

  content->amount = msg.proposal_create_contract.parameters_count;
  return COPY_ADDRESS(content->account,
                      &msg.proposal_create_contract.owner_address);
}

static bool
proposal_approve_contract(txContent_t *content,
                          const protocol_Transaction_raw *transaction) {
  pb_istream_t stream;
  protocol_ProposalApproveContract contract = {};

  stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_ProposalApproveContract_fields, &contract)) {
    return false;
  }

  return COPY_ADDRESS(content->account, &contract.owner_address);
}

static bool
proposal_delete_contract(txContent_t *content,
                         const protocol_Transaction_raw *transaction) {
  pb_istream_t stream;
  protocol_ProposalDeleteContract contract = {};

  stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_ProposalDeleteContract_fields, &contract)) {
    return false;
  }

  content->exchangeID = contract.proposal_id;
  return COPY_ADDRESS(content->account, &contract.owner_address);
}

static bool
account_update_contract(txContent_t *content,
                        const protocol_Transaction_raw *transaction) {
  pb_istream_t stream;
  protocol_AccountUpdateContract contract = {};

  stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_AccountUpdateContract_fields, &contract)) {
    return false;
  }
  return COPY_ADDRESS(content->account, &contract.owner_address);
}

static bool
trigger_smart_contract(txContent_t *content,
                       const protocol_Transaction_raw *transaction) {
  pb_istream_t stream;

  stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_TriggerSmartContract_fields,
                 &msg.trigger_smart_contract)) {
    return false;
  }

  if (!COPY_ADDRESS(content->account,
                    &msg.trigger_smart_contract.owner_address) ||
      !COPY_ADDRESS(content->contractAddress,
                    &msg.trigger_smart_contract.contract_address)) {
    return false;
  }
  content->amount = msg.trigger_smart_contract.call_value;

  // Parse smart contract
  if (msg.trigger_smart_contract.data.size < 4) {
    return false;
  }

  if (memcmp(msg.trigger_smart_contract.data.bytes, SELECTOR[0], 4) == 0) {
    content->TRC20Method = 1; // check if transfer(address, uint256) function
  } else if (memcmp(msg.trigger_smart_contract.data.bytes, SELECTOR[1], 4) ==
             0) {
    content->TRC20Method = 2; // check if approve(address, uint256) function
  } else {
    // Processing custom contracts
    // TODO: add switch to disable support for custom contracts
    if ((msg.trigger_smart_contract.data.size - 4) % 32 != 0) {
      return false;
    }
    content->TRC20Method = 0;
    content->customSelector = U4BE(msg.trigger_smart_contract.data.bytes, 0);
    return true;
  }

  // check if DATA field size matchs TRC20 Transfer/Approve
  if (msg.trigger_smart_contract.data.size != TRC20_DATA_FIELD_SIZE) {
    return false;
  }
  // TO Address
  memcpy(content->destination, msg.trigger_smart_contract.data.bytes + 15,
         ADDRESS_SIZE);
  // set MainNet PREFIX
  content->destination[0] = ADD_PRE_FIX_BYTE_MAINNET;
  // Amount
  memmove(content->TRC20Amount, msg.trigger_smart_contract.data.bytes + 36, 32);
  tokenDefinition_t *TRC20 = getKnownToken(content);
  if (TRC20 == NULL) {
    return false;
  }
  content->decimals[0] = TRC20->decimals;
  content->tokenNamesLength[0] = strlen((const char *)TRC20->ticker) + 1;
  memmove(content->tokenNames[0], TRC20->ticker, content->tokenNamesLength[0]);
  return true;
}

static bool
exchange_create_contract(txContent_t *content,
                         const protocol_Transaction_raw *transaction) {
  pb_istream_t stream;

  stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_ExchangeCreateContract_fields,
                 &msg.exchange_create_contract)) {
    return false;
  }

  if (!COPY_ADDRESS(content->account,
                    &msg.exchange_create_contract.owner_address)) {
    return false;
  }
  if (!printTokenFromID((char *)content->tokenNames[0],
                        msg.exchange_create_contract.first_token_id.bytes,
                        msg.exchange_create_contract.first_token_id.size)) {
    return false;
  }
  content->tokenNamesLength[0] = strlen((char *)content->tokenNames[0]);

  if (!printTokenFromID((char *)content->tokenNames[1],
                        msg.exchange_create_contract.second_token_id.bytes,
                        msg.exchange_create_contract.second_token_id.size)) {
    return false;
  }
  content->tokenNamesLength[1] = strlen((char *)content->tokenNames[1]);

  content->amount = msg.exchange_create_contract.first_token_balance;
  content->amount2 = msg.exchange_create_contract.second_token_balance;
  return true;
}

static bool
exchange_inject_contract(txContent_t *content,
                         const protocol_Transaction_raw *transaction) {
  pb_istream_t stream;

  stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_ExchangeInjectContract_fields,
                 &msg.exchange_inject_contract)) {
    return false;
  }
  if (!COPY_ADDRESS(content->account,
                    &msg.exchange_inject_contract.owner_address)) {
    return false;
  }
  content->exchangeID = msg.exchange_inject_contract.exchange_id;

  if (!printTokenFromID((char *)content->tokenNames[0],
                        msg.exchange_inject_contract.token_id.bytes,
                        msg.exchange_inject_contract.token_id.size)) {
    return false;
  }
  content->tokenNamesLength[0] = strlen((char *)content->tokenNames[0]);

  content->amount = msg.exchange_inject_contract.quant;
  return true;
}

static bool
exchange_withdraw_contract(txContent_t *content,
                           const protocol_Transaction_raw *transaction) {
  pb_istream_t stream;

  stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_ExchangeWithdrawContract_fields,
                 &msg.exchange_withdraw_contract)) {
    return false;
  }
  if (!COPY_ADDRESS(content->account,
                    &msg.exchange_withdraw_contract.owner_address)) {
    return false;
  }
  content->exchangeID = msg.exchange_withdraw_contract.exchange_id;

  if (!printTokenFromID((char *)content->tokenNames[0],
                        msg.exchange_withdraw_contract.token_id.bytes,
                        msg.exchange_withdraw_contract.token_id.size)) {
    return false;
  }
  content->tokenNamesLength[0] = strlen((char *)content->tokenNames[0]);

  content->amount = msg.exchange_withdraw_contract.quant;
  return true;
}

static bool
exchange_transaction_contract(txContent_t *content,
                           const protocol_Transaction_raw *transaction) {
  pb_istream_t stream;

  stream = INIT_STREAM(transaction);
  if (!pb_decode(&stream, protocol_ExchangeTransactionContract_fields,
                 &msg.exchange_transaction_contract)) {
    return false;
  }
  if (!COPY_ADDRESS(content->account,
                    &msg.exchange_transaction_contract.owner_address)) {
    return false;
  }
  content->exchangeID = msg.exchange_transaction_contract.exchange_id;

  if (!printTokenFromID((char *)content->tokenNames[0],
                        msg.exchange_transaction_contract.token_id.bytes,
                        msg.exchange_transaction_contract.token_id.size)) {
    return false;
  }
  content->tokenNamesLength[0] = strlen((char *)content->tokenNames[0]);

  content->amount = msg.exchange_transaction_contract.quant;
  content->amount2 = msg.exchange_transaction_contract.expected;
  return true;
}

protocol_Transaction_raw transaction;

parserStatus_e processTx(uint8_t *buffer, uint32_t length, txContent_t *content) {
  bool ret;

  if (length == 0) {
    return USTREAM_FINISHED;
  }

  memset(&transaction, 0, sizeof(transaction));
  pb_istream_t stream = pb_istream_from_buffer(buffer, length);

  if (!pb_decode(&stream, protocol_Transaction_raw_fields, &transaction)) {
    return USTREAM_FAULT;
  }

  // Contract must have a parameter
  if (!transaction.contract->has_parameter) {
    return USTREAM_FAULT;
  }

  content->contractType = (contractType_e)transaction.contract->type;

  /* Transaction data */
  if (transaction.data.size != 0) {
    // TODO
    // if (!dataAllowed)
    //   THROW(0x6a80);
    content->dataBytes = transaction.data.size;
  }

  switch (transaction.contract->type) {
  case protocol_Transaction_Contract_ContractType_TransferContract:
    ret = transfer_contract(content, &transaction);
    break;

  case protocol_Transaction_Contract_ContractType_TransferAssetContract:
    ret = transfer_asset_contract(content, &transaction);
    break;

  case protocol_Transaction_Contract_ContractType_VoteWitnessContract: {
    ret = vote_witness_contract(content, &transaction);
    break;
  }
  case protocol_Transaction_Contract_ContractType_FreezeBalanceContract:
    ret = freeze_balance_contract(content, &transaction);
    break;
  case protocol_Transaction_Contract_ContractType_UnfreezeBalanceContract:
    ret = unfreeze_balance_contract(content, &transaction);
    break;
  case protocol_Transaction_Contract_ContractType_WithdrawBalanceContract:
    ret = withdraw_balance_contract(content, &transaction);
    break;
  case protocol_Transaction_Contract_ContractType_ProposalCreateContract:
    ret = proposal_create_contract(content, &transaction);
    break;
  case protocol_Transaction_Contract_ContractType_ProposalApproveContract:
    ret = proposal_approve_contract(content, &transaction);
    break;
  case protocol_Transaction_Contract_ContractType_ProposalDeleteContract:
    ret = proposal_delete_contract(content, &transaction);
    break;
  case protocol_Transaction_Contract_ContractType_AccountUpdateContract:
    ret = account_update_contract(content, &transaction);
    break;
  case protocol_Transaction_Contract_ContractType_TriggerSmartContract:
    ret = trigger_smart_contract(content, &transaction);
    break;
  case protocol_Transaction_Contract_ContractType_ExchangeCreateContract:
    ret = exchange_create_contract(content, &transaction);
    break;
  case protocol_Transaction_Contract_ContractType_ExchangeInjectContract:
    ret = exchange_inject_contract(content, &transaction);
    break;
  case protocol_Transaction_Contract_ContractType_ExchangeWithdrawContract:
    ret = exchange_withdraw_contract(content, &transaction);
    break;
  case protocol_Transaction_Contract_ContractType_ExchangeTransactionContract:
    ret = exchange_transaction_contract(content, &transaction);
    break;
  default:
    return USTREAM_FAULT;
  }

  return ret ? USTREAM_PROCESSING : USTREAM_FAULT;
}
