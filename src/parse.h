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


/*
# https://developers.google.com/protocol-buffers/docs/encoding#structure
# How to decode transaction Message
# Message
# 0a0248f12208df3e5ffe7c9762a140d881dedabd2c5a67080112630a2d747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e5472616e73666572436f6e747261637412320a15a0a99930dbebff557f9efc0b9aaf3ba26e8f65231b1215a04f560eb4182ca53757f905609e226e96e8e1a80c18c0843d708cbcb5a5be2c
# T: 0a -> 1 | 010 -> type 2 Length-delimited id 1
# 02-48f1   length 2 BlockBytes 48f1
# 22    -> 100 | 010 -> type 2 Length-delimited id 4
# 08-df3e5ffe7c9762a1  length 8 BlockHash df3e5ffe7c9762a1  
# 40    -> 1000 | 000 -> type 0 Variant id 8
## Look for bin 1XXX-XXXX, continue, 0XXX-XXXX, ends
## d8 81 de da bd 2c
## 58 01 5E 5A 3D 2c
## 128^0 128^1 128^2 28^3 28^4 28^5 = 1528393335000
# 5a -> 1011 | 010 -> type 2 Length-delimited id 11
# 67-080112630a2d747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e5472616e73666572436f6e747261637412320a15a0a99930dbebff557f9efc0b9aaf3ba26e8f65231b1215a04f560eb4182ca53757f905609e226e96e8e1a80c18c0843d
## 08 -> 1 | 000 -> type 0 Variant id 1
## 01   ContractType TransferContract = 1;
## 12 -> 10 | 010 -> type 2 Length-delimited id 2
## 63-0a2d747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e5472616e73666572436f6e747261637412320a15a0a99930dbebff557f9efc0b9aaf3ba26e8f65231b1215a04f560eb4182ca53757f905609e226e96e8e1a80c18c0843d
### 0a -> 1 | 010 -> type 2 Length-delimited id 1
### 2d 747970652e676f6f676c65617069732e636f6d2f70726f746f636f6c2e5472616e73666572436f6e7472616374
###     type.googleapis.com/protocol.TransferContract
### 12 -> 10 | 010 -> type 2 Length-delimited id 2
### 32 0a15a0a99930dbebff557f9efc0b9aaf3ba26e8f65231b1215a04f560eb4182ca53757f905609e226e96e8e1a80c18c0843d
#### 0a -> 1 | 010 -> type 2 Length-delimited id 1
#### 15-a0a99930dbebff557f9efc0b9aaf3ba26e8f65231b
#### 12 -> 10 | 010 -> type 2 Length-delimited id 2
#### 15-a04f560eb4182ca53757f905609e226e96e8e1a80c
#### 18 -> 1 | 010 -> type 2 Length-delimited id 1
#### c0843d
##### 80 04 3d
##### 128^0 128^1 128^2  = 1000000
# 70 -> 1110 | 000 -> type 0 Variant id 14
## Look for bin 1XXX-XXXX, continue, 0XXX-XXXX, ends
## 8c bc b5 a5 be 2c
## 0C 3C 35 25 3E 2c 
## 128^0 128^1 128^2 28^3 28^4 28^5 = 1528549957132
*/