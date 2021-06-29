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

#include <string.h>

#include "pb.h"
#include "misc/TronApp.pb.h"

#include "parse.h"
#include "settings.h"
#include "tokens.h"
#include "errors.h"

tokenDefinition_t* getKnownToken(txContent_t *context) {
    uint16_t i;

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
unsigned short print_amount(uint64_t amount, char *out,
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
        THROW(E_INCORRECT_LENGTH);
    }
    base /= 10;
    for (i = 0; i < numDigits; i++) {
        tmp[i] = '0' + ((amount / base) % 10);
        base /= 10;
    }
    tmp[i] = '\0';
    adjustDecimals(tmp, i, tmp2, 25, sun);
    if (strlen(tmp2) < outlen - 1) {
        strlcpy(out, tmp2, outlen);
    } else {
        out[0] = '\0';
    }
    return strlen(out);
}

bool setContractType(contractType_e type, char *out, size_t outlen){
    switch (type){
        case ACCOUNTCREATECONTRACT:
            strlcpy(out, "Account Create", outlen);
            break;
        case VOTEASSETCONTRACT:
            strlcpy(out, "Vote Asset", outlen);
            break;
        case WITNESSCREATECONTRACT:
            strlcpy(out,"Witness Create", outlen);
            break;
        case ASSETISSUECONTRACT:
            strlcpy(out,"Asset Issue", outlen);
            break;
        case WITNESSUPDATECONTRACT:
            strlcpy(out,"Witness Update", outlen);
            break;
        case PARTICIPATEASSETISSUECONTRACT:
            strlcpy(out,"Participate Asset", outlen);
            break;
        case ACCOUNTUPDATECONTRACT:
            strlcpy(out,"Account Update", outlen);
            break;
        case UNFREEZEBALANCECONTRACT:
            strlcpy(out,"Unfreeze Balance", outlen);
            break;
        case WITHDRAWBALANCECONTRACT:
            strlcpy(out,"Claim Rewards", outlen);
            break;
        case UNFREEZEASSETCONTRACT:
            strlcpy(out,"Unfreeze Asset", outlen);
            break;
        case UPDATEASSETCONTRACT:
            strlcpy(out,"Update Asset", outlen);
            break;
        case PROPOSALCREATECONTRACT:
            strlcpy(out,"Proposal Create", outlen);
            break;
        case PROPOSALAPPROVECONTRACT:
            strlcpy(out,"Proposal Approve", outlen);
            break;
        case PROPOSALDELETECONTRACT:
            strlcpy(out,"Proposal Delete", outlen);
            break;
        case ACCOUNTPERMISSIONUPDATECONTRACT:
            strlcpy(out, "Permission Update", outlen);
            break;
        case UNKNOWN_CONTRACT:
            strlcpy(out, "Unknown Type", outlen);
            break;
        default:
            return false;
    }
    return true;
}

bool setExchangeContractDetail(contractType_e type, char *out, size_t outlen) {
    switch (type){
        case EXCHANGECREATECONTRACT:
            strlcpy(out, "create", outlen);
            break;
        case EXCHANGEINJECTCONTRACT:
            strlcpy(out, "inject", outlen);
            break;
        case EXCHANGEWITHDRAWCONTRACT:
            strlcpy(out, "withdraw", outlen);
            break;
        case EXCHANGETRANSACTIONCONTRACT:
            strlcpy(out, "transaction", outlen);
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
  strlcpy(content->tokenNames[token_id], tmp, MAX_TOKEN_LENGTH);
  content->decimals[token_id] = details.precision;
  return true;
}

static bool printTokenFromID(char *out, size_t outlen, const uint8_t *data, size_t size) {
  if (size != TOKENID_SIZE && size != 1) {
    return false;
  }

  if (size == 1) {
    if (data[0] != '_') {
      return false;
    }
    strlcpy(out, "TRX", outlen);
    return true;
  }
  strlcpy(out, (char *)data, outlen);
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
    content->contractType = INVALID_CONTRACT;
    cx_sha256_init(sha2); //init sha
}

#define COPY_ADDRESS(a, b) memcpy((a), (b), ADDRESS_SIZE)

contract_t msg;

static bool transfer_contract(txContent_t *content, pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_TransferContract_fields,
                 &msg.transfer_contract)) {
    return false;
  }

  content->amount[0] = msg.transfer_contract.amount;

  COPY_ADDRESS(content->account, &msg.transfer_contract.owner_address);
  COPY_ADDRESS(content->destination, &msg.transfer_contract.to_address);

  content->tokenNamesLength[0] = 4;
  strcpy(content->tokenNames[0], "TRX");
  return true;
}

static bool transfer_asset_contract(txContent_t *content,
                                    pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_TransferAssetContract_fields,
                 &msg.transfer_asset_contract)) {
    return false;
  }
  content->amount[0] = msg.transfer_asset_contract.amount;

  if (!printTokenFromID(content->tokenNames[0], MAX_TOKEN_LENGTH,
                        msg.transfer_asset_contract.asset_name.bytes,
                        msg.transfer_asset_contract.asset_name.size)) {
    return false;
  }
  content->tokenNamesLength[0] = strlen(content->tokenNames[0]);

  COPY_ADDRESS(content->account, &msg.transfer_asset_contract.owner_address);
  COPY_ADDRESS(content->destination, &msg.transfer_asset_contract.to_address);
  return true;
}

static bool vote_witness_contract(txContent_t *content, pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_VoteWitnessContract_fields,
                 &msg.vote_witness_contract)) {
    return false;
  }

  COPY_ADDRESS(content->account, &msg.vote_witness_contract.owner_address);
  return true;
}

static bool freeze_balance_contract(txContent_t *content,
                                    pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_FreezeBalanceContract_fields,
                 &msg.freeze_balance_contract)) {
    return false;
  }
  /* Tron only accepts 3 days freezing */
  if (msg.freeze_balance_contract.frozen_duration != 3) {
    return false;
  }
  COPY_ADDRESS(content->account, &msg.freeze_balance_contract.owner_address);
  COPY_ADDRESS(content->destination,
               &msg.freeze_balance_contract.receiver_address);
  content->amount[0] = msg.freeze_balance_contract.frozen_balance;
  content->resource = msg.freeze_balance_contract.resource;
  return true;
}

static bool unfreeze_balance_contract(txContent_t *content,
                                      pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_UnfreezeBalanceContract_fields,
                 &msg.unfreeze_balance_contract)) {
    return false;
  }
  content->resource = msg.unfreeze_balance_contract.resource;

  COPY_ADDRESS(content->account, &msg.unfreeze_balance_contract.owner_address);
  COPY_ADDRESS(content->destination,
               &msg.unfreeze_balance_contract.receiver_address);
  return true;
}

static bool withdraw_balance_contract(txContent_t *content,
                                      pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_WithdrawBalanceContract_fields,
                 &msg.withdraw_balance_contract)) {
    return false;
  }
  COPY_ADDRESS(content->account, &msg.withdraw_balance_contract.owner_address);
  return true;
}

static bool proposal_create_contract(txContent_t *content,
                                     pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_ProposalCreateContract_fields,
                 &msg.proposal_create_contract)) {
    return false;
  }

  content->amount[0] = msg.proposal_create_contract.parameters_count;
  COPY_ADDRESS(content->account, &msg.proposal_create_contract.owner_address);
  return true;
}

static bool proposal_approve_contract(txContent_t *content,
                                      pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_ProposalApproveContract_fields,
                 &msg.proposal_approve_contract)) {
    return false;
  }

  COPY_ADDRESS(content->account, &msg.proposal_approve_contract.owner_address);
  return true;
}

static bool proposal_delete_contract(txContent_t *content,
                                     pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_ProposalDeleteContract_fields,
                 &msg.proposal_delete_contract)) {
    return false;
  }

  content->exchangeID = msg.proposal_delete_contract.proposal_id;
  COPY_ADDRESS(content->account, &msg.proposal_delete_contract.owner_address);
  return true;
}

static bool account_update_contract(txContent_t *content,
                                    pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_AccountUpdateContract_fields,
                 &msg.account_update_contract)) {
    return false;
  }
  COPY_ADDRESS(content->account, &msg.account_update_contract.owner_address);
  return true;
}

bool pb_decode_trigger_smart_contract_data(pb_istream_t *stream, const pb_field_t *field, void **arg) {
  UNUSED(field);

  if (stream->bytes_left < 4) {
    return false;
  }

  txContent_t* content = *arg;
  uint8_t buf[32];  // a single encoded TVM value

  // method selector
  if (!pb_read(stream, buf, 4)) {
    return false;
  }

  content->customSelector = U4BE(buf, 0);

  if (memcmp(buf, SELECTOR[0], 4) == 0) {
    content->TRC20Method = 1;  // a9059cbb -> transfer(address,uint256)
  } else if (memcmp(buf, SELECTOR[1], 4) == 0) {
    content->TRC20Method = 2;  // 095ea7b3 -> approve(address,uint256)
  } else {
    // arbitrary contracts
    if (stream->bytes_left % 32 != 0) {
      return false;
    }
    content->TRC20Method = 0;
    // consume this field
    return pb_read(stream, NULL, stream->bytes_left);
  }

  // TRC20 data size check: 32 + 32
  if (stream->bytes_left != 32 + 32) {
    return false;
  }

  // to address
  if (!pb_read(stream, buf, 32)) {
    return false;
  }
  memcpy(content->destination, buf + (32 - 21), ADDRESS_SIZE);
  // fix address prefix 0x41: mainnet
  content->destination[0] = ADD_PRE_FIX_BYTE_MAINNET;

  // amount
  if (!pb_read(stream, buf, 32)) {
    return false;
  }
  memmove(content->TRC20Amount, buf, 32);

  return true;
}

static bool trigger_smart_contract(txContent_t *content, pb_istream_t *stream) {
  msg.trigger_smart_contract.data.funcs.decode = pb_decode_trigger_smart_contract_data;
  msg.trigger_smart_contract.data.arg = content;

  if (!pb_decode(stream, protocol_TriggerSmartContract_fields, &msg.trigger_smart_contract)) {
    return false;
  }

  COPY_ADDRESS(content->account, &msg.trigger_smart_contract.owner_address);
  COPY_ADDRESS(content->contractAddress, &msg.trigger_smart_contract.contract_address);
  content->amount[0] = msg.trigger_smart_contract.call_value;

  tokenDefinition_t *trc20 = getKnownToken(content);

  if (trc20 == NULL) {
    // treat unknown TRC20 token as arbitrary contract
    content->TRC20Method = 0;
    return true;
  }

  content->decimals[0] = trc20->decimals;
  content->tokenNamesLength[0] = strlen(trc20->ticker) + 1;
  memmove(content->tokenNames[0], trc20->ticker, content->tokenNamesLength[0]);

  return true;
}

static bool exchange_create_contract(txContent_t *content,
                                     pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_ExchangeCreateContract_fields,
                 &msg.exchange_create_contract)) {
    return false;
  }

  COPY_ADDRESS(content->account, &msg.exchange_create_contract.owner_address);

  if (!printTokenFromID(content->tokenNames[0], MAX_TOKEN_LENGTH,
                        msg.exchange_create_contract.first_token_id.bytes,
                        msg.exchange_create_contract.first_token_id.size)) {
    return false;
  }
  content->tokenNamesLength[0] = strlen(content->tokenNames[0]);

  if (!printTokenFromID(content->tokenNames[1], MAX_TOKEN_LENGTH,
                        msg.exchange_create_contract.second_token_id.bytes,
                        msg.exchange_create_contract.second_token_id.size)) {
    return false;
  }
  content->tokenNamesLength[1] = strlen(content->tokenNames[1]);

  content->amount[0] = msg.exchange_create_contract.first_token_balance;
  content->amount[1] = msg.exchange_create_contract.second_token_balance;
  return true;
}

static bool exchange_inject_contract(txContent_t *content,
                                     pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_ExchangeInjectContract_fields,
                 &msg.exchange_inject_contract)) {
    return false;
  }
  COPY_ADDRESS(content->account, &msg.exchange_inject_contract.owner_address);
  content->exchangeID = msg.exchange_inject_contract.exchange_id;

  if (!printTokenFromID(content->tokenNames[0], MAX_TOKEN_LENGTH,
                        msg.exchange_inject_contract.token_id.bytes,
                        msg.exchange_inject_contract.token_id.size)) {
    return false;
  }
  content->tokenNamesLength[0] = strlen(content->tokenNames[0]);

  content->amount[0] = msg.exchange_inject_contract.quant;
  return true;
}

static bool exchange_withdraw_contract(txContent_t *content,
                                       pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_ExchangeWithdrawContract_fields,
                 &msg.exchange_withdraw_contract)) {
    return false;
  }
  COPY_ADDRESS(content->account, &msg.exchange_withdraw_contract.owner_address);
  content->exchangeID = msg.exchange_withdraw_contract.exchange_id;

  if (!printTokenFromID(content->tokenNames[0], MAX_TOKEN_LENGTH,
                        msg.exchange_withdraw_contract.token_id.bytes,
                        msg.exchange_withdraw_contract.token_id.size)) {
    return false;
  }
  content->tokenNamesLength[0] = strlen(content->tokenNames[0]);

  content->amount[0] = msg.exchange_withdraw_contract.quant;
  return true;
}

static bool exchange_transaction_contract(txContent_t *content,
                                          pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_ExchangeTransactionContract_fields,
                 &msg.exchange_transaction_contract)) {
    return false;
  }
  COPY_ADDRESS(content->account,
               &msg.exchange_transaction_contract.owner_address);
  content->exchangeID = msg.exchange_transaction_contract.exchange_id;

  if (!printTokenFromID(content->tokenNames[0], MAX_TOKEN_LENGTH,
                        msg.exchange_transaction_contract.token_id.bytes,
                        msg.exchange_transaction_contract.token_id.size)) {
    return false;
  }
  content->tokenNamesLength[0] = strlen(content->tokenNames[0]);

  content->amount[0] = msg.exchange_transaction_contract.quant;
  content->amount[1] = msg.exchange_transaction_contract.expected;
  return true;
}

static bool account_permission_update_contract(txContent_t *content, pb_istream_t *stream) {
  if (!pb_decode(stream, protocol_AccountPermissionUpdateContract_fields,
                 &msg.account_permission_update_contract)) {
    return false;
  }

  COPY_ADDRESS(content->account, &msg.account_permission_update_contract.owner_address);
  // TODO: Update tx content
  return true;
}

typedef struct {
    const uint8_t *buf;
    size_t size;
} buffer_t;

bool pb_decode_contract_parameter(pb_istream_t *stream, const pb_field_t *field, void **arg) {
  PB_UNUSED(field);
  buffer_t *buffer = *arg;

  buffer->buf = stream->state;
  buffer->size = stream->bytes_left;
  return true;
}

bool pb_get_tx_data_size(pb_istream_t *stream, const pb_field_t *field, void **arg) {
  PB_UNUSED(field);
  uint64_t *data_size = *arg;
  *data_size = (uint64_t)stream->bytes_left;
  return true;
}

parserStatus_e processTx(uint8_t *buffer, uint32_t length,
                         txContent_t *content) {
  protocol_Transaction_raw transaction;

  if (length == 0) {
    return USTREAM_FINISHED;
  }

  memset(&transaction, 0, sizeof(transaction));
  memset(&msg, 0, sizeof(msg));

  pb_istream_t stream = pb_istream_from_buffer(buffer, length);

  /* Set callbacks to retrieve "Contract" message bounds.
   * This is required because contract type is not necessarily parsed at the
   * time of the transaction is decoded (fields are not required to be ordered)
   * and deserializing the nested contract inside the message requires too much
   * stack for Nano S
   */
  buffer_t contract_buffer;
  transaction.contract->parameter.value.funcs.decode =
      pb_decode_contract_parameter;
  transaction.contract->parameter.value.arg = &contract_buffer;

  /* Set callback to determine if transaction contains custom data.
   * This allows to retrieve the size of arbitrary data. */
  transaction.data.funcs.decode = pb_get_tx_data_size;
  transaction.data.arg = &content->dataBytes;

  if (!pb_decode(&stream, protocol_Transaction_raw_fields, &transaction)) {
    return USTREAM_FAULT;
  }

  if (!HAS_SETTING(S_DATA_ALLOWED) && content->dataBytes != 0) {
    THROW(E_MISSING_SETTING_DATA_ALLOWED);
  }


  /* Parse contract parameters if any...
     and it may come in different message chunk
     so test if chunk has the contract
   */
  if (transaction.contract->has_parameter) {
    content->permission_id = transaction.contract->Permission_id;
    content->contractType = (contractType_e)transaction.contract->type;

    pb_istream_t tx_stream =
        pb_istream_from_buffer(contract_buffer.buf, contract_buffer.size);
    bool ret;

    switch (transaction.contract->type) {
      case protocol_Transaction_Contract_ContractType_TransferContract:
        ret = transfer_contract(content, &tx_stream);
        break;

      case protocol_Transaction_Contract_ContractType_TransferAssetContract:
        ret = transfer_asset_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_VoteWitnessContract:
        ret = vote_witness_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_FreezeBalanceContract:
        ret = freeze_balance_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_UnfreezeBalanceContract:
        ret = unfreeze_balance_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_WithdrawBalanceContract:
        ret = withdraw_balance_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_ProposalCreateContract:
        ret = proposal_create_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_ProposalApproveContract:
        ret = proposal_approve_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_ProposalDeleteContract:
        ret = proposal_delete_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_AccountUpdateContract:
        ret = account_update_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_TriggerSmartContract:
        ret = trigger_smart_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_ExchangeCreateContract:
        ret = exchange_create_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_ExchangeInjectContract:
        ret = exchange_inject_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_ExchangeWithdrawContract:
        ret = exchange_withdraw_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_ExchangeTransactionContract:
        ret = exchange_transaction_contract(content, &tx_stream);
        break;
      case protocol_Transaction_Contract_ContractType_AccountPermissionUpdateContract:
        ret = account_permission_update_contract(content, &tx_stream);
        break;
      default:
        return USTREAM_FAULT;
    }
    return ret ? USTREAM_PROCESSING : USTREAM_FAULT;
  }

  return USTREAM_PROCESSING;
}
