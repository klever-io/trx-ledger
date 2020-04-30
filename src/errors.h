
// Adapted from:
// https://github.com/LedgerHQ/ledgerjs/blob/master/packages/errors/src/index.ts

#ifndef _ERRORS_H
#define _ERRORS_H

#define E_OK 0x9000

// NOTE: The follow codes have alt status messages defined.
// "Incorrect length"
#define E_INCORRECT_LENGTH 0x6700
// "Missing critical parameter"
#define E_MISSING_CRITICAL_PARAMETER 0x6800
// "Security not satisfied (dongle locked or have invalid access rights)"
#define E_SECURITY_STATUS_NOT_SATISFIED 0x6982
// "Condition of use not satisfied (denied by the user?)";
#define E_CONDITIONS_OF_USE_NOT_SATISFIED 0x6985
// "Invalid data received"
#define E_INCORRECT_DATA 0x6a80
// "Invalid parameter received"
#define E_INCORRECT_P1_P2 0x6b00

// TRON defined:
#define E_INCORRECT_BIP32_PATH 0x6a8a
#define E_MISSING_SETTING_DATA_ALLOWED 0x6a8b
#define E_MISSING_SETTING_SIGN_BY_HASH 0x6a8c
#define E_MISSING_SETTING_CUSTOM_CONTRACT 0x6a8d

// Official:
#define E_PIN_REMAINING_ATTEMPTS 0x63c0
#define E_COMMAND_INCOMPATIBLE_FILE_STRUCTURE 0x6981
#define E_NOT_ENOUGH_MEMORY_SPACE 0x6a84
#define E_REFERENCED_DATA_NOT_FOUND 0x6a88
#define E_FILE_ALREADY_EXISTS 0x6a89
#define E_INS_NOT_SUPPORTED 0x6d00
#define E_CLA_NOT_SUPPORTED 0x6e00
#define E_TECHNICAL_PROBLEM 0x6f00
#define E_MEMORY_PROBLEM 0x9240
#define E_NO_EF_SELECTED 0x9400
#define E_INVALID_OFFSET 0x9402
#define E_FILE_NOT_FOUND 0x9404
#define E_INCONSISTENT_FILE 0x9408
#define E_ALGORITHM_NOT_SUPPORTED 0x9484
#define E_INVALID_KCV 0x9485
#define E_CODE_NOT_INITIALIZED 0x9802
#define E_ACCESS_CONDITION_NOT_FULFILLED 0x9804
#define E_CONTRADICTION_SECRET_CODE_STATUS 0x9808
#define E_CONTRADICTION_INVALIDATION 0x9810
#define E_CODE_BLOCKED 0x9840
#define E_MAX_VALUE_REACHED 0x9850
#define E_GP_AUTH_FAILED 0x6300
#define E_LICENSING 0x6f42
#define E_HALTED 0x6faa

#endif // once
