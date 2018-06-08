#include "os.h"
#include "cx.h"
#include <stdbool.h>

#ifndef PARSE_H
#define PARSE_H

#define MAX_BIP32_PATH 10

#define ADD_PRE_FIX_STRING "T"
#define ADDRESS_SIZE 21
#define BASE58CHECK_ADDRESS_SIZE 34
#define BASE58CHECK_PK_SIZE 64

#define DROP 1000000L
#define ADD_PRE_FIX_BYTE_MAINNET 0x41
#define MAX_RAW_TX 200


typedef enum parserStatus_e {
    USTREAM_PROCESSING,
    USTREAM_FINISHED,
    USTREAM_FAULT
} parserStatus_e;

typedef struct txContent_t {
    uint64_t amount;
    uint64_t bandwidth;
    uint8_t account[ADDRESS_SIZE];
    uint8_t destination[ADDRESS_SIZE];
} txContent_t;

typedef struct publicKeyContext_t {
    cx_ecfp_public_key_t publicKey;
    uint8_t address[ADDRESS_SIZE];
    uint8_t address58[BASE58CHECK_ADDRESS_SIZE];
    uint8_t chainCode[32]; 
    bool getChaincode;
} publicKeyContext_t;

typedef struct transactionContext_t {
    cx_curve_t curve;
    uint8_t pathLength;
    uint32_t bip32Path[MAX_BIP32_PATH];
    uint8_t rawTx[MAX_RAW_TX];
    uint32_t rawTxLength;
} transactionContext_t;

parserStatus_e parseTx(uint8_t *data, uint32_t length, txContent_t *context);



#endif