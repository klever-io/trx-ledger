#ifndef SETTINGS_H
#define SETTINGS_H

#include <stdint.h>

typedef struct internalStorage_t {
  uint8_t dataAllowed;
  uint8_t customContract;
  uint8_t truncateAddress;
  uint8_t signByHash;
  uint8_t initialized;
} internalStorage_t;

#define N_storage (*(volatile internalStorage_t *)PIC(&N_storage_real))

extern const internalStorage_t N_storage_real;

#endif