#ifndef SETTINGS_H
#define SETTINGS_H

#include <stdint.h>

typedef uint8_t internal_storage_t;

#define N_settings (*(volatile internal_storage_t *)PIC(&N_storage_real))

// the settings, stored in NVRAM. Initializer is ignored by ledger.
extern const internal_storage_t N_storage_real;

// flip a bit k = 0 to 7 for u8
#define _FLIP_BIT(n, k)  (((n) ^ (1 << (k))))

// toggle a setting item
#define SETTING_TOGGLE(_set) do {\
    internal_storage_t _temp_settings = _FLIP_BIT(N_settings, _set); \
    nvm_write((void*)&N_settings, (void*)&_temp_settings, sizeof(internal_storage_t)); \
  } while(0)

// check a setting item
#define HAS_SETTING(k)  ((N_settings & (1 << (k))) >> (k))


#define S_DATA_ALLOWED     0
#define S_CUSTOM_CONTRACT  1
#define S_TRUNCATE_ADDRESS 2
#define S_SIGN_BY_HASH     3

#define S_INITIALIZED      7


#endif