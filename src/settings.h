#ifndef SETTINGS_H
#define SETTINGS_H

#include <stdint.h>

extern volatile uint8_t dataAllowed;
extern volatile uint8_t customContract;
extern volatile uint8_t truncateAddress;
extern volatile uint8_t signByHash;

typedef struct internalStorage_t {
  unsigned char dataAllowed;
  unsigned char customContract;
  unsigned char truncateAddress;
  unsigned char signByHash;
  uint8_t initialized;
} internalStorage_t;

#define N_storage (*(volatile internalStorage_t *)PIC(&N_storage_real))

extern const internalStorage_t N_storage_real;

#endif