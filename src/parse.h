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
#define HASH_SIZE 32

#define DROP_DIG 6
#define ADD_PRE_FIX_BYTE_MAINNET 0x41
#define MAX_RAW_TX 200

#define PB_TYPE 0x07
#define PB_FIELD_R 0x03
#define PB_VARIANT_MASK 0x80
#define PB_BASE128 0x80
#define PB_BASE128DATA 0x7F


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
    uint8_t tokenName[32];
    uint8_t tokenNameLength;
    uint8_t contractType;
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
    uint16_t rawTxLength;
    uint8_t hash[HASH_SIZE];
    uint8_t signature[MAX_RAW_TX];
    uint8_t signatureLength;
} transactionContext_t;

parserStatus_e parseTx(uint8_t *data, uint32_t dataLength, txContent_t *context);

unsigned short print_amount(uint64_t amount, uint8_t *out,
                                uint32_t outlen, uint8_t drop);

#endif
