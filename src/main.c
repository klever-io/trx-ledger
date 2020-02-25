/*******************************************************************************
 *   Tron Ledger Wallet
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

#include "os.h"
#include "cx.h"
#include <stdbool.h>
#include <sys/types.h>
#include "helpers.h"

#include "os_io_seproxyhal.h"
#include "string.h"

#include "glyphs.h"

#include "settings.h"

#include "parse.h"
#include "uint256.h"

#include "tokens.h"

extern bool fidoActivated;

bagl_element_t tmp_element;
unsigned char G_io_seproxyhal_spi_buffer[IO_SEPROXYHAL_BUFFER_SIZE_B];

uint32_t set_result_get_publicKey(void);


// Define command events
#define CLA 0xE0                        // Start byte for any communications

#define INS_GET_PUBLIC_KEY 0x02
#define INS_SIGN 0x04
#define INS_GET_APP_CONFIGURATION 0x06  // version
#define INS_SIGN_PERSONAL_MESSAGE 0x08
#define INS_GET_ECDH_SECRET 0x0A

#define P1_CONFIRM 0x01
#define P1_NON_CONFIRM 0x00

#define P1_SIGN 0x10
#define P1_FIRST 0x00
#define P1_MORE 0x80
#define P1_LAST 0x90

#define P1_TRC10_NAME 0xA0

#define P2_NO_CHAINCODE 0x00
#define P2_CHAINCODE 0x01

#define OFFSET_CLA 0
#define OFFSET_INS 1
#define OFFSET_P1 2
#define OFFSET_P2 3
#define OFFSET_LC 4
#define OFFSET_CDATA 5

publicKeyContext_t publicKeyContext;
transactionContext_t transactionContext;
txContent_t txContent;
txContext_t txContext;

cx_sha256_t sha2;

volatile uint8_t dataAllowed;
volatile uint8_t customContract;
volatile uint8_t truncateAddress;
volatile uint8_t customContractField;
volatile char fromAddress[BASE58CHECK_ADDRESS_SIZE+1+5]; // 5 extra bytes used to inform MultSign ID
volatile char toAddress[BASE58CHECK_ADDRESS_SIZE+1];
volatile char addressSummary[35];
volatile char fullContract[MAX_TOKEN_LENGTH];
volatile char TRC20Action[9];
volatile char TRC20ActionSendAllow[8];
volatile char fullHash[HASH_SIZE*2+1];
volatile char exchangeContractDetail[50];

static const char const SIGN_MAGIC[] = "\x19TRON Signed Message:\n";

bagl_element_t tmp_element;


const internalStorage_t N_storage_real;

unsigned int io_seproxyhal_touch_settings(const bagl_element_t *e);
unsigned int io_seproxyhal_touch_exit(const bagl_element_t *e);
unsigned int io_seproxyhal_touch_tx_ok(const bagl_element_t *e);
unsigned int io_seproxyhal_touch_cancel(const bagl_element_t *e);
unsigned int io_seproxyhal_touch_address_ok(const bagl_element_t *e);
unsigned int io_seproxyhal_touch_signMessage_ok(const bagl_element_t *e);

#define VOTE_ADDRESS 0
#define VOTE_ADDRESS_SIZE 15
#define VOTE_AMOUNT VOTE_ADDRESS_SIZE
#define VOTE_AMOUNT_SIZE 15
#define VOTE_PACK (VOTE_ADDRESS_SIZE+VOTE_AMOUNT_SIZE)
#define voteSlot(index, type) ( (index*VOTE_PACK)+type )

void fillVoteAddressSlot(void *destination, const char * from, uint8_t index) {
    os_memset(destination+voteSlot(index, VOTE_ADDRESS), 0, VOTE_PACK);
    os_memmove(destination+voteSlot(index, VOTE_ADDRESS), from, 5);
    os_memmove(destination+5+voteSlot(index, VOTE_ADDRESS), "...", 3);
    os_memmove(destination+8+voteSlot(index, VOTE_ADDRESS), from+(BASE58CHECK_ADDRESS_SIZE-5), 5);
    PRINTF("Vote Address: %d - %s\n", index, destination+(voteSlot(index, VOTE_ADDRESS)));
}

void fillVoteAmountSlot(void *destination, uint64_t value, uint8_t index) {
    print_amount(value,destination+voteSlot(index, VOTE_AMOUNT),VOTE_AMOUNT_SIZE, 0);
    PRINTF("Amount: %d - %s\n", index, destination+(voteSlot(index, VOTE_AMOUNT)));
}

void ui_idle(void);
#ifdef HAVE_UX_FLOW
#include "ux.h"
ux_state_t G_ux;
bolos_ux_params_t G_ux_params;
#else // HAVE_UX_FLOW
ux_state_t ux;
// display stepped screens
unsigned int ux_step;
unsigned int ux_step_count;
#endif // HAVE_UX_FLOW

const bagl_element_t *ui_menu_item_out_over(const bagl_element_t *e) {
    // the selection rectangle is after the none|touchable
    e = (const bagl_element_t *)(((unsigned int)e) + sizeof(bagl_element_t));
    return e;
}

#define BAGL_FONT_OPEN_SANS_LIGHT_16_22PX_AVG_WIDTH 10
#define BAGL_FONT_OPEN_SANS_REGULAR_10_13PX_AVG_WIDTH 8
#define MAX_CHAR_PER_LINE 32

#define COLOR_BG_1 0xF9F9F9
#define COLOR_APP 0xe70015
#define COLOR_APP_LIGHT 0xe5929a

#if defined(TARGET_BLUE)
const bagl_element_t ui_idle_blue[] = {
    // type                               userid    x    y   w    h  str rad
    // fill      fg        bg      fid iid  txt   touchparams...       ]
    {{BAGL_RECTANGLE, 0x00, 0, 68, 320, 413, 0, 0, BAGL_FILL, COLOR_BG_1,
      0x000000, 0, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    // erase screen (only under the status bar)
    {{BAGL_RECTANGLE, 0x00, 0, 20, 320, 48, 0, 0, BAGL_FILL, COLOR_APP,
      COLOR_APP, 0, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    /// TOP STATUS BAR
    {{BAGL_LABELINE, 0x00, 0, 45, 320, 30, 0, 0, BAGL_FILL, 0xFFFFFF, COLOR_APP,
      BAGL_FONT_OPEN_SANS_SEMIBOLD_10_13PX | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "TRON",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_RECTANGLE | BAGL_FLAG_TOUCHABLE, 0x00, 0, 19, 56, 44, 0, 0,
      BAGL_FILL, COLOR_APP, COLOR_APP_LIGHT,
      BAGL_FONT_SYMBOLS_0 | BAGL_FONT_ALIGNMENT_CENTER |
          BAGL_FONT_ALIGNMENT_MIDDLE,
      0},
     BAGL_FONT_SYMBOLS_0_SETTINGS,
     0,
     COLOR_APP,
     0xFFFFFF,
     io_seproxyhal_touch_settings,
     NULL,
     NULL},
    {{BAGL_RECTANGLE | BAGL_FLAG_TOUCHABLE, 0x00, 264, 19, 56, 44, 0, 0,
      BAGL_FILL, COLOR_APP, COLOR_APP_LIGHT,
      BAGL_FONT_SYMBOLS_0 | BAGL_FONT_ALIGNMENT_CENTER |
          BAGL_FONT_ALIGNMENT_MIDDLE,
      0},
     BAGL_FONT_SYMBOLS_0_DASHBOARD,
     0,
     COLOR_APP,
     0xFFFFFF,
     io_seproxyhal_touch_exit,
     NULL,
     NULL},

    // BADGE_TRON.GIF
    {{BAGL_ICON, 0x00, 135, 178, 50, 50, 0, 0, BAGL_FILL, 0, COLOR_BG_1, 0, 0},
     (const char *)&C_badge_tron,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x00, 0, 270, 320, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_LIGHT_16_22PX | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "Open TRON wallet",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x00, 0, 308, 320, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_REGULAR_10_13PX | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "Connect your Ledger Blue and open your",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x00, 0, 331, 320, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_REGULAR_10_13PX | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "preferred wallet to view your accounts.",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x00, 0, 450, 320, 14, 0, 0, 0, 0x999999, COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_REGULAR_8_11PX | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "Validation requests will show automatically.",
     10,
     0,
     COLOR_BG_1,
     NULL,
     NULL,
     NULL},
};

unsigned int ui_idle_blue_button(unsigned int button_mask,
                                 unsigned int button_mask_counter) {
    return 0;
}
#endif // #if TARGET_BLUE

#if defined(TARGET_BLUE)
const bagl_element_t * ui_settings_blue_toggle_data(const bagl_element_t * e) {
  // swap setting and request redraw of settings elements
  uint8_t setting = N_storage.dataAllowed?0:1;
  dataAllowed = setting;
  nvm_write((void*)&N_storage.dataAllowed, (void*)&setting, sizeof(uint8_t));

  // only refresh settings mutable drawn elements
  UX_REDISPLAY_IDX(7);

  // won't redisplay the bagl_none
  return 0;
}

const bagl_element_t * ui_settings_blue_toggle_custom(const bagl_element_t * e) {
  // swap setting and request redraw of settings elements
  uint8_t setting = N_storage.customContract?0:1;
  customContract = setting;
  nvm_write((void*)&N_storage.customContract, (void*)&setting, sizeof(uint8_t));

  // only refresh settings mutable drawn elements
  UX_REDISPLAY_IDX(7);

  // won't redisplay the bagl_none
  return 0;
}

// don't perform any draw/color change upon finger event over settings
const bagl_element_t *ui_settings_out_over(const bagl_element_t *e) {
    return NULL;
}

unsigned int ui_settings_back_callback(const bagl_element_t *e) {
    // go back to idle
    ui_idle();
    return 0;
}

const bagl_element_t ui_settings_blue[] = {
    // type                               userid    x    y   w    h  str rad
    // fill      fg        bg      fid iid  txt   touchparams...       ]
    {{BAGL_RECTANGLE, 0x00, 0, 68, 320, 413, 0, 0, BAGL_FILL, COLOR_BG_1,
      0x000000, 0, 0},
     NULL, 0, 0, 0, NULL, NULL, NULL},

    // erase screen (only under the status bar)
    {{BAGL_RECTANGLE, 0x00, 0, 20, 320, 48, 0, 0, BAGL_FILL, COLOR_APP,
      COLOR_APP, 0, 0},
     NULL, 0, 0, 0, NULL, NULL, NULL},

    /// TOP STATUS BAR
    {{BAGL_LABELINE, 0x00, 0, 45, 320, 30, 0, 0, BAGL_FILL, 0xFFFFFF, COLOR_APP,
      BAGL_FONT_OPEN_SANS_SEMIBOLD_10_13PX | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "SETTINGS", 0, 0, 0, NULL, NULL, NULL},

    {{BAGL_RECTANGLE | BAGL_FLAG_TOUCHABLE, 0x00, 0, 19, 50, 44, 0, 0,
      BAGL_FILL, COLOR_APP, COLOR_APP_LIGHT,
      BAGL_FONT_SYMBOLS_0 | BAGL_FONT_ALIGNMENT_CENTER |
          BAGL_FONT_ALIGNMENT_MIDDLE,
      0},
     BAGL_FONT_SYMBOLS_0_LEFT,
     0,
     COLOR_APP,
     0xFFFFFF,
     ui_settings_back_callback,
     NULL,
     NULL},
    {{BAGL_RECTANGLE | BAGL_FLAG_TOUCHABLE, 0x00, 264, 19, 56, 44, 0, 0,
      BAGL_FILL, COLOR_APP, COLOR_APP_LIGHT,
      BAGL_FONT_SYMBOLS_0 | BAGL_FONT_ALIGNMENT_CENTER |
          BAGL_FONT_ALIGNMENT_MIDDLE,
      0},
     BAGL_FONT_SYMBOLS_0_DASHBOARD,
     0,
     COLOR_APP,
     0xFFFFFF,
     io_seproxyhal_touch_exit,
     NULL,
     NULL},

    {{BAGL_LABELINE                       , 0x00,  30, 105, 160,  30, 0, 0, BAGL_FILL, 0x000000, COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0   }, "Allow data", 0, 0, 0, NULL, NULL, NULL},
    {{BAGL_LABELINE                       , 0x00,  30, 126, 260,  30, 0, 0, BAGL_FILL, 0x999999, COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_8_11PX, 0   }, "Allow data field in transactions", 0, 0, 0, NULL, NULL, NULL},
    {{BAGL_NONE   | BAGL_FLAG_TOUCHABLE   , 0x00,   0,  78, 320,  68, 0, 0, BAGL_FILL, 0xFFFFFF, 0x000000, 0, 0   }, NULL, 0, 0xEEEEEE, 0x000000, ui_settings_blue_toggle_data, ui_settings_out_over, ui_settings_out_over },

    {{BAGL_RECTANGLE, 0x00, 30, 146, 260, 1, 1, 0, 0, 0xEEEEEE, COLOR_BG_1, 0, 0}, NULL, 0, 0, 0, NULL, NULL, NULL},
    {{BAGL_LABELINE, 0x00, 30, 174, 160, 30, 0, 0, BAGL_FILL, 0x000000, COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0}, "Allow contracts", 0, 0, 0, NULL, NULL, NULL},
    {{BAGL_LABELINE, 0x00, 30, 195, 260, 30, 0, 0, BAGL_FILL, 0x999999, COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_8_11PX, 0}, "Allow custom contracts", 0, 0, 0, NULL, NULL, NULL},

    {{BAGL_NONE | BAGL_FLAG_TOUCHABLE, 0x00, 0, 147, 320, 68, 0, 0, BAGL_FILL, 0xFFFFFF, 0x000000, 0, 0}, NULL, 0, 0xEEEEEE, 0x000000, ui_settings_blue_toggle_custom, ui_settings_out_over, ui_settings_out_over},

    {{BAGL_ICON, 0x02, 258, 167, 32, 18, 0, 0, BAGL_FILL, 0x000000, COLOR_BG_1, 0, 0}, NULL, 0, 0, 0, NULL, NULL, NULL},
    {{BAGL_ICON                           , 0x01, 258,  98,  32,  18, 0, 0, BAGL_FILL, 0x000000, COLOR_BG_1, 0, 0   }, NULL, 0, 0, 0, NULL, NULL, NULL},
};

const bagl_element_t *ui_settings_blue_prepro(const bagl_element_t *e) {
    // none elements are skipped
    if ((e->component.type & (~BAGL_FLAG_TOUCHABLE)) == BAGL_NONE) {
        return 0;
    }
    // swap icon buffer to be displayed depending on if corresponding setting is
    // enabled or not.
    if (e->component.userid) {
        os_memmove(&tmp_element, e, sizeof(bagl_element_t));
        switch (e->component.userid) {
            case 0x01:
                // swap icon content
                if (N_storage.dataAllowed) {
                    tmp_element.text = &C_icon_toggle_set;
                }
                else {
                    tmp_element.text = &C_icon_toggle_reset;
                }
                break;
            case 0x02:
                // swap icon content
                if (N_storage.customContract) {
                    tmp_element.text = &C_icon_toggle_set;
                }
                else {
                    tmp_element.text = &C_icon_toggle_reset;
                }
                break;
        }
        return &tmp_element;
    }
    return 1;
}

unsigned int ui_settings_blue_button(unsigned int button_mask,
                                     unsigned int button_mask_counter) {
    return 0;
}
#endif // #if defined(TARGET_BLUE)

#if defined(TARGET_BLUE)
const bagl_element_t ui_address_blue[] = {
    {{BAGL_RECTANGLE, 0x00, 0, 68, 320, 413, 0, 0, BAGL_FILL, COLOR_BG_1,
      0x000000, 0, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    // erase screen (only under the status bar)
    {{BAGL_RECTANGLE, 0x00, 0, 20, 320, 48, 0, 0, BAGL_FILL, COLOR_APP,
      COLOR_APP, 0, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    /// TOP STATUS BAR
    {{BAGL_LABELINE, 0x00, 0, 45, 320, 30, 0, 0, BAGL_FILL, 0xFFFFFF, COLOR_APP,
      BAGL_FONT_OPEN_SANS_SEMIBOLD_10_13PX | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "CONFIRM ADDRESS",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x00, 30, 106, 320, 30, 0, 0, BAGL_FILL, 0x999999,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_SEMIBOLD_8_11PX, 0},
     "ADDRESS",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x10, 30, 136, 260, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0},
     (const char *)addressSummary,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x11, 30, 159, 260, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0},
     (const char *)addressSummary,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_RECTANGLE | BAGL_FLAG_TOUCHABLE, 0x00, 40, 414, 115, 36, 0, 18,
      BAGL_FILL, 0xCCCCCC, COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_REGULAR_11_14PX | BAGL_FONT_ALIGNMENT_CENTER |
          BAGL_FONT_ALIGNMENT_MIDDLE,
      0},
     "REJECT",
     0,
     0xB7B7B7,
     COLOR_BG_1,
     io_seproxyhal_touch_cancel,
     NULL,
     NULL},
    {{BAGL_RECTANGLE | BAGL_FLAG_TOUCHABLE, 0x00, 165, 414, 115, 36, 0, 18,
      BAGL_FILL, 0x41ccb4, COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_REGULAR_11_14PX | BAGL_FONT_ALIGNMENT_CENTER |
          BAGL_FONT_ALIGNMENT_MIDDLE,
      0},
     "CONFIRM",
     0,
     0x3ab7a2,
     COLOR_BG_1,
     io_seproxyhal_touch_address_ok,
     NULL,
     NULL},
};

unsigned int ui_address_blue_prepro(const bagl_element_t *element) {
    if (element->component.userid > 0) {
        unsigned int length = strlen((const char *)toAddress);
        if (length >= (element->component.userid & 0xF) * MAX_CHAR_PER_LINE) {
            os_memset((void *)addressSummary, 0, MAX_CHAR_PER_LINE + 1);
            os_memmove((void *)addressSummary,
                       (const char *) (toAddress + (element->component.userid & 0xF) *
                                         MAX_CHAR_PER_LINE),
                       MIN(length - (element->component.userid & 0xF) *
                                        MAX_CHAR_PER_LINE,
                           MAX_CHAR_PER_LINE));
            return 1;
        }
        // nothing to draw for this line
        return 0;
    }
    return 1;
}
unsigned int ui_address_blue_button(unsigned int button_mask,
                                    unsigned int button_mask_counter) {
    return 0;
}
#endif // #if defined(TARGET_BLUE)


#if defined(TARGET_BLUE)
// reuse addressSummary for each line content
char *ui_details_title;
char *ui_details_content;
typedef void (*callback_t)(void);
callback_t ui_details_back_callback;

const bagl_element_t *
ui_details_blue_back_callback(const bagl_element_t *element) {
    ui_details_back_callback();
    return 0;
}

const bagl_element_t ui_details_blue[] = {
    // erase screen (only under the status bar)
    {{BAGL_RECTANGLE, 0x00, 0, 68, 320, 413, 0, 0, BAGL_FILL, COLOR_BG_1,
      0x000000, 0, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_RECTANGLE, 0x00, 0, 20, 320, 48, 0, 0, BAGL_FILL, COLOR_APP,
      COLOR_APP, 0, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    /// TOP STATUS BAR
    {{BAGL_LABELINE, 0x01, 0, 45, 320, 30, 0, 0, BAGL_FILL, 0xFFFFFF, COLOR_APP,
      BAGL_FONT_OPEN_SANS_SEMIBOLD_10_13PX | BAGL_FONT_ALIGNMENT_CENTER, 0},
     (const char*)addressSummary,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_RECTANGLE | BAGL_FLAG_TOUCHABLE, 0x00, 0, 19, 50, 44, 0, 0,
      BAGL_FILL, COLOR_APP, COLOR_APP_LIGHT,
      BAGL_FONT_SYMBOLS_0 | BAGL_FONT_ALIGNMENT_CENTER |
          BAGL_FONT_ALIGNMENT_MIDDLE,
      0},
     BAGL_FONT_SYMBOLS_0_LEFT,
     0,
     COLOR_APP,
     0xFFFFFF,
     ui_details_blue_back_callback,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x00, 30, 106, 320, 30, 0, 0, BAGL_FILL, 0x999999,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_SEMIBOLD_8_11PX, 0},
     "VALUE",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x10, 30, 136, 260, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0},
     (const char*)addressSummary,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x11, 30, 159, 260, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0},
     (const char*)addressSummary,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x12, 30, 182, 260, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0},
     (const char*)addressSummary,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x13, 30, 205, 260, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0},
     (const char*)addressSummary,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x14, 30, 228, 260, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0},
     (const char*)addressSummary,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x15, 30, 251, 260, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0},
     (const char *)addressSummary,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x16, 30, 274, 260, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0},
     (const char *)addressSummary,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x17, 30, 297, 260, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0},
     (const char *)addressSummary,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x18, 30, 320, 260, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0},
     (const char *)addressSummary,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    //"..." at the end if too much
    {{BAGL_LABELINE, 0x19, 30, 343, 260, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0},
     (const char *)addressSummary,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x00, 0, 450, 320, 14, 0, 0, 0, 0x999999, COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_REGULAR_8_11PX | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "Review the whole value before continuing.",
     10,
     0,
     COLOR_BG_1,
     NULL,
     NULL,
     NULL},
};

unsigned int ui_details_blue_prepro(const bagl_element_t *element) {
    if (element->component.userid == 1) {
        strcpy((char *)addressSummary, (const char *)PIC(ui_details_title));
    } else if (element->component.userid > 0) {
        unsigned int length = strlen(ui_details_content);
        if (length >= (element->component.userid & 0xF) * MAX_CHAR_PER_LINE) {
            os_memset((void *)addressSummary, 0, MAX_CHAR_PER_LINE + 1);
            os_memmove((void *)addressSummary,
                       (const char *) (ui_details_content + (element->component.userid & 0xF) *
                                                MAX_CHAR_PER_LINE),
                       MIN(length - (element->component.userid & 0xF) *
                                        MAX_CHAR_PER_LINE,
                           MAX_CHAR_PER_LINE));
            return 1;
        }
        // nothing to draw for this line
        return 0;
    }
    return 1;
}

unsigned int ui_details_blue_button(unsigned int button_mask,
                                    unsigned int button_mask_counter) {
    return 0;
}

void ui_details_init(const char *title, const char *content,
                     callback_t back_callback) {
    ui_details_title = (char *)title;
    ui_details_content = (char *)content;
    ui_details_back_callback = back_callback;
    UX_DISPLAY(ui_details_blue, ui_details_blue_prepro);
}

// Approval BLUE Transaction
void ui_approval_blue_init(void);

bagl_element_callback_t ui_approval_blue_ok;
bagl_element_callback_t ui_approval_blue_cancel;

const bagl_element_t *ui_approval_blue_ok_callback(const bagl_element_t *e) {
    return ui_approval_blue_ok(e);
}

const bagl_element_t *
ui_approval_blue_cancel_callback(const bagl_element_t *e) {
    return ui_approval_blue_cancel(e);
}

typedef enum {
    APPROVAL_TRANSFER,
    APPROVAL_TRANSACTION,
    APPROVAL_EXCHANGE_CREATE,
    APPROVAL_EXCHANGE_TRANSACTION,
    APPROVAL_EXCHANGE_WITHDRAW_INJECT,
    APPROVAL_WITNESSVOTE_TRANSACTION,
    APPROVAL_FREEZEASSET_TRANSACTION,
    APPROVAL_UNFREEZEASSET_TRANSACTION,
    APPROVAL_WITHDRAWBALANCE_TRANSACTION,
    APPROVAL_SIGN_PERSONAL_MESSAGE,
    APPROVAL_CUSTOM_CONTRACT,
} ui_approval_blue_state_t;
ui_approval_blue_state_t G_ui_approval_blue_state;
// pointer to value to be displayed
const char *ui_approval_blue_values[5];
// variable part of the structureconst char *ui_approval_blue_values[5];

const char *const ui_approval_blue_details_name[][7] = {
    /*APPROVAL_TRANSFER*/
    {
        "AMOUNT",
        "TOKEN",
        (const char *)TRC20ActionSendAllow,
        "FROM",
        NULL,
        "CONFIRM TRANSFER",
        "Transfer details",
    },
    /*APPROVAL_TRANSACTION*/
    {
        "TYPE",
        "HASH",
        "FROM",
        NULL,
        NULL,
        "CONFIRM TRANSACTION",
        "Transaction details",
    },
    /*APPROVAL_EXCHANGE_CREATE*/
    {
        "TOKEN 1",
        "AMOUNT 1",
        "TOKEN 2",
        "AMOUNT 2",
        "FROM",
        "CONFIRM EXCHANGE",
        "Exchange Create Details",
    },
    /*APPROVAL_EXCHANGE_TRANSACTION*/
    {
        "EXCHANGE ID",
        "TOKEN PAIR",
        "AMOUNT",
        "EXPECTED",
        "FROM",
        "CONFIRM TRANSACTION",
        "Exchange Pair Details",
    },
    /*APPROVAL_EXCHANGE_WITHDRAW/INJECT*/
    {
        "ACTION",
        "EXCHANGE ID",
        "TOKEN NAME",
        "AMOUNT",
        "FROM",
        "CONFIRM TRANSACTION",
        "Exchange MX Details",
    },
    /*APPROVAL_WITNESSVOTE_TRANSACTION*/
    {
        "TOTAL VOTES",
        "DETAILS",
        "FROM",
        NULL,
        NULL,
        "CONFIRM TRANSACTION",
        "Witness Vote",
    },
    /*APPROVAL_FREEZE_TRANSACTION*/
    {
        "GAIN",
        "AMOUNT",
        "TO",
        "FROM",
        NULL,
        "CONFIRM TRANSACTION",
        "Freeze TRX",
    },
    /*APPROVAL_UNFREEZEASSET_TRANSACTION*/
    {
        "GAIN",
        "DELEGATED",
        "FROM",
        NULL,
        NULL,
        "CONFIRM TRANSACTION",
        "Unfreeze TRX",
    },
    /*APPROVAL_WITHDRAWBALANCE_TRANSACTION*/
    {
        "FROM",
        NULL,
        NULL,
        NULL,
        NULL,
        "CONFIRM TRANSACTION",
        "Claim Rewards",
    },
    /*APPROVAL_SIGN_PERSONAL_MESSAGE*/
    {
        "HASH",
        "Sign with",
        NULL,
        NULL,
        NULL,
        "SIGN MESSAGE",
        "Message signature",
    },
    /*APPROVAL_CUSTOM_CONTRACT*/
    {
        "SELECTOR",
        "CONTRACT",
        "TOKEN",
        "AMOUNT",
        "FROM",
        "CONFIRM TRANSACTION",
        "Custom Contract",
    },
};

const bagl_element_t *ui_approval_common_show_details(unsigned int detailidx) {
    if (ui_approval_blue_values[detailidx] != NULL &&
        strlen(ui_approval_blue_values[detailidx]) *
                BAGL_FONT_OPEN_SANS_LIGHT_16_22PX_AVG_WIDTH >=
            160) {
        // display details screen
        ui_details_init(
            ui_approval_blue_details_name[G_ui_approval_blue_state][detailidx],
            ui_approval_blue_values[detailidx], ui_approval_blue_init);
    }
    return NULL;
}

const bagl_element_t *ui_approval_blue_1_details(const bagl_element_t *e) {
    return ui_approval_common_show_details(0);
}

const bagl_element_t *ui_approval_blue_2_details(const bagl_element_t *e) {
    return ui_approval_common_show_details(1);
}

const bagl_element_t *ui_approval_blue_3_details(const bagl_element_t *e) {
    return ui_approval_common_show_details(2);
}

const bagl_element_t *ui_approval_blue_4_details(const bagl_element_t *e) {
    return ui_approval_common_show_details(3);
}

const bagl_element_t *ui_approval_blue_5_details(const bagl_element_t *e) {
    return ui_approval_common_show_details(4);
}

const bagl_element_t ui_approval_blue[] = {
    {{BAGL_RECTANGLE, 0x00, 0, 68, 320, 413, 0, 0, BAGL_FILL, COLOR_BG_1,
      0x000000, 0, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    // erase screen (only under the status bar)
    {{BAGL_RECTANGLE, 0x00, 0, 20, 320, 48, 0, 0, BAGL_FILL, COLOR_APP,
      COLOR_APP, 0, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    /// TOP STATUS BAR
    {{BAGL_LABELINE, 0x60, 0, 45, 320, 30, 0, 0, BAGL_FILL, 0xFFFFFF, COLOR_APP,
      BAGL_FONT_OPEN_SANS_SEMIBOLD_10_13PX | BAGL_FONT_ALIGNMENT_CENTER, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    // BADGE_TRANSACTION.GIF
    {{BAGL_ICON, 0x40, 30, 98, 50, 50, 0, 0, BAGL_FILL, 0, COLOR_BG_1, 0, 0},
     &C_badge_transaction,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x50, 100, 117, 320, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x00, 100, 138, 320, 30, 0, 0, BAGL_FILL, 0x999999,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_8_11PX, 0},
     "Check and confirm transaction",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x70, 30, 196, 100, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_SEMIBOLD_8_11PX, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    // x-18 when ...
    {{BAGL_LABELINE, 0x10, 130, 200, 160, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_LIGHT_16_22PX | BAGL_FONT_ALIGNMENT_RIGHT,
      0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x20, 284, 196, 6, 16, 0, 0, BAGL_FILL, 0x999999,
      COLOR_BG_1, BAGL_FONT_SYMBOLS_0 | BAGL_FONT_ALIGNMENT_RIGHT, 0},
     BAGL_FONT_SYMBOLS_0_MINIRIGHT,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_NONE | BAGL_FLAG_TOUCHABLE, 0x80, 0, 168, 320, 48, 0, 9, BAGL_FILL,
      0xFFFFFF, 0x000000, 0, 0},
     NULL,
     0,
     0xEEEEEE,
     0x000000,
     ui_approval_blue_1_details,
     ui_menu_item_out_over,
     ui_menu_item_out_over},
    {{BAGL_RECTANGLE, 0x20, 0, 168, 5, 48, 0, 0, BAGL_FILL, COLOR_BG_1,
      COLOR_BG_1, 0, 0},
     NULL,
     0,
     0x41CCB4,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_RECTANGLE, 0x31, 30, 216, 260, 1, 1, 0, 0, 0xEEEEEE, COLOR_BG_1, 0,
      0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x71, 30, 245, 100, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_SEMIBOLD_8_11PX, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    // x-18 when ...
    {{BAGL_LABELINE, 0x11, 130, 245, 160, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_REGULAR_10_13PX | BAGL_FONT_ALIGNMENT_RIGHT, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x21, 284, 245, 6, 16, 0, 0, BAGL_FILL, 0x999999,
      COLOR_BG_1, BAGL_FONT_SYMBOLS_0 | BAGL_FONT_ALIGNMENT_RIGHT, 0},
     BAGL_FONT_SYMBOLS_0_MINIRIGHT,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_NONE | BAGL_FLAG_TOUCHABLE, 0x80, 0, 217, 320, 48, 0, 9, BAGL_FILL,
      0xFFFFFF, 0x000000, 0, 0},
     NULL,
     0,
     0xEEEEEE,
     0x000000,
     ui_approval_blue_2_details,
     ui_menu_item_out_over,
     ui_menu_item_out_over},
    {{BAGL_RECTANGLE, 0x21, 0, 217, 5, 48, 0, 0, BAGL_FILL, COLOR_BG_1,
      COLOR_BG_1, 0, 0},
     NULL,
     0,
     0x41CCB4,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_RECTANGLE, 0x32, 30, 265, 260, 1, 1, 0, 0, 0xEEEEEE, COLOR_BG_1, 0,
      0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x72, 30, 294, 100, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_SEMIBOLD_8_11PX, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL}, // MAX FEES
    // x-18 when ...
    {{BAGL_LABELINE, 0x12, 130, 294, 160, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_REGULAR_10_13PX | BAGL_FONT_ALIGNMENT_RIGHT, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL}, // maxFee
    {{BAGL_LABELINE, 0x22, 284, 294, 6, 16, 0, 0, BAGL_FILL, 0x999999,
      COLOR_BG_1, BAGL_FONT_SYMBOLS_0 | BAGL_FONT_ALIGNMENT_RIGHT, 0},
     BAGL_FONT_SYMBOLS_0_MINIRIGHT,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_NONE | BAGL_FLAG_TOUCHABLE, 0x80, 0, 266, 320, 48, 0, 9, BAGL_FILL,
      0xFFFFFF, 0x000000, 0, 0},
     NULL,
     0,
     0xEEEEEE,
     0x000000,
     ui_approval_blue_3_details,
     ui_menu_item_out_over,
     ui_menu_item_out_over},
    {{BAGL_RECTANGLE, 0x22, 0, 266, 5, 48, 0, 0, BAGL_FILL, COLOR_BG_1,
      COLOR_BG_1, 0, 0},
     NULL,
     0,
     0x41CCB4,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_RECTANGLE, 0x33, 30, 314, 260, 1, 1, 0, 0, 0xEEEEEE, COLOR_BG_1, 0,
      0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x73, 30, 343, 100, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_SEMIBOLD_8_11PX, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL}, // MAX FEES
    // x-18 when ...
    {{BAGL_LABELINE, 0x13, 130, 343, 160, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_REGULAR_10_13PX | BAGL_FONT_ALIGNMENT_RIGHT, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL}, // maxFee
    {{BAGL_LABELINE, 0x23, 284, 343, 6, 16, 0, 0, BAGL_FILL, 0x999999,
      COLOR_BG_1, BAGL_FONT_SYMBOLS_0 | BAGL_FONT_ALIGNMENT_RIGHT, 0},
     BAGL_FONT_SYMBOLS_0_MINIRIGHT,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_NONE | BAGL_FLAG_TOUCHABLE, 0x80, 0, 315, 320, 48, 0, 9, BAGL_FILL,
      0xFFFFFF, 0x000000, 0, 0},
     NULL,
     0,
     0xEEEEEE,
     0x000000,
     ui_approval_blue_4_details,
     ui_menu_item_out_over,
     ui_menu_item_out_over},
    {{BAGL_RECTANGLE, 0x23, 0, 315, 5, 48, 0, 0, BAGL_FILL, COLOR_BG_1,
      COLOR_BG_1, 0, 0},
     NULL,
     0,
     0x41CCB4,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_RECTANGLE, 0x34, 30, 363, 260, 1, 1, 0, 0, 0xEEEEEE, COLOR_BG_1, 0,
      0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x74, 30, 392, 100, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1, BAGL_FONT_OPEN_SANS_SEMIBOLD_8_11PX, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL}, // MAX FEES
    // x-18 when ...
    {{BAGL_LABELINE, 0x14, 130, 392, 160, 30, 0, 0, BAGL_FILL, 0x000000,
      COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_REGULAR_10_13PX | BAGL_FONT_ALIGNMENT_RIGHT, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL}, // maxFee
    {{BAGL_LABELINE, 0x24, 284, 392, 6, 16, 0, 0, BAGL_FILL, 0x999999,
      COLOR_BG_1, BAGL_FONT_SYMBOLS_0 | BAGL_FONT_ALIGNMENT_RIGHT, 0},
     BAGL_FONT_SYMBOLS_0_MINIRIGHT,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_NONE | BAGL_FLAG_TOUCHABLE, 0x80, 0, 364, 320, 48, 0, 9, BAGL_FILL,
      0xFFFFFF, 0x000000, 0, 0},
     NULL,
     0,
     0xEEEEEE,
     0x000000,
     ui_approval_blue_5_details,
     ui_menu_item_out_over,
     ui_menu_item_out_over},
    {{BAGL_RECTANGLE, 0x24, 0, 364, 5, 48, 0, 0, BAGL_FILL, COLOR_BG_1,
      COLOR_BG_1, 0, 0},
     NULL,
     0,
     0x41CCB4,
     0,
     NULL,
     NULL,
     NULL},

    // EXTRA DATA field
    {{BAGL_RECTANGLE, 0x90, 30, 364, 260, 1, 1, 0, 0, 0xEEEEEE, COLOR_BG_1, 0, 0}, NULL, 0, 0, 0, NULL, NULL, NULL},
    {{BAGL_LABELINE, 0x90, 30, 392, 120, 30, 0, 0, BAGL_FILL, 0x000000, COLOR_BG_1, BAGL_FONT_OPEN_SANS_SEMIBOLD_8_11PX, 0}, "EXTRA DATA", 0, 0, 0, NULL, NULL, NULL},
    {{BAGL_LABELINE, 0x90, 133, 392, 140, 30, 0, 0, BAGL_FILL, 0x666666, COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX | BAGL_FONT_ALIGNMENT_RIGHT, 0}, "Present", 0, 0, 0, NULL, NULL, NULL},
    {{BAGL_ICON, 0x90, 278, 382, 12, 12, 0, 0, BAGL_FILL, 0, COLOR_BG_1, 0, 0}, &C_icon_warning, 0, 0, 0, NULL, NULL, NULL},

    // Custom Contract
    {{BAGL_LABELINE, 0xA0, 133, 172, 140, 30, 0, 0, BAGL_FILL, 0x666666, COLOR_BG_1, BAGL_FONT_OPEN_SANS_REGULAR_10_13PX | BAGL_FONT_ALIGNMENT_RIGHT, 0}, "Unverified", 0, 0, 0, NULL, NULL, NULL},
    {{BAGL_ICON, 0xA0, 278, 162, 12, 12, 0, 0, BAGL_FILL, 0, COLOR_BG_1, 0, 0}, &C_icon_warning, 0, 0, 0, NULL, NULL, NULL},

    {{BAGL_RECTANGLE | BAGL_FLAG_TOUCHABLE, 0x00, 40, 414, 115, 36, 0, 18,
      BAGL_FILL, 0xCCCCCC, COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_REGULAR_11_14PX | BAGL_FONT_ALIGNMENT_CENTER |
          BAGL_FONT_ALIGNMENT_MIDDLE,
      0},
     "REJECT",
     0,
     0xB7B7B7,
     COLOR_BG_1,
     ui_approval_blue_cancel_callback,
     NULL,
     NULL},
    {{BAGL_RECTANGLE | BAGL_FLAG_TOUCHABLE, 0x00, 165, 414, 115, 36, 0, 18,
      BAGL_FILL, 0x41ccb4, COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_REGULAR_11_14PX | BAGL_FONT_ALIGNMENT_CENTER |
          BAGL_FONT_ALIGNMENT_MIDDLE,
      0},
     "CONFIRM",
     0,
     0x3ab7a2,
     COLOR_BG_1,
     ui_approval_blue_ok_callback,
     NULL,
     NULL},

};

const bagl_element_t *ui_approval_blue_prepro(const bagl_element_t *element) {
    if (element->component.userid == 0) {
        return 1;
    }
    // none elements are skipped
    if ((element->component.type & (~BAGL_FLAG_TOUCHABLE)) == BAGL_NONE) {
        return 0;
    } else {
        switch (element->component.userid & 0xF0) {
        // touchable nonetype entries, skip them to avoid latencies (to be fixed
        // in the sdk later on)
        case 0x80:
            return 0;

        // icon
        case 0x40:
            return 1;

        // TITLE
        case 0x60:
            os_memmove(&tmp_element, element, sizeof(bagl_element_t));
            tmp_element.text =
                ui_approval_blue_details_name[G_ui_approval_blue_state][5];
            return &tmp_element;

        // SUBLINE
        case 0x50:
            os_memmove(&tmp_element, element, sizeof(bagl_element_t));
            tmp_element.text =
                ui_approval_blue_details_name[G_ui_approval_blue_state][6];
            return &tmp_element;

        // details label
        case 0x70:
            if (!ui_approval_blue_details_name[G_ui_approval_blue_state]
                                              [element->component.userid &
                                               0xF]) {
                return NULL;
            }
            os_memmove(&tmp_element, element, sizeof(bagl_element_t));
            tmp_element.text =
                ui_approval_blue_details_name[G_ui_approval_blue_state]
                                             [element->component.userid & 0xF];
            return &tmp_element;

        // detail value
        case 0x10:
            // won't display
            if (!ui_approval_blue_details_name[G_ui_approval_blue_state]
                                              [element->component.userid &
                                               0xF]) {
                return NULL;
            }
            // always display the value
            os_memmove(&tmp_element, element, sizeof(bagl_element_t));
            tmp_element.text =
                ui_approval_blue_values[(element->component.userid & 0xF)];

            // x -= 18 when overflow is detected
            if (strlen(ui_approval_blue_values[(element->component.userid &
                                                0xF)]) *
                    BAGL_FONT_OPEN_SANS_LIGHT_16_22PX_AVG_WIDTH >=
                160) {
                tmp_element.component.x -= 18;
            }
            return &tmp_element;

        // right arrow and left selection rectangle
        case 0x20:
            if (!ui_approval_blue_details_name[G_ui_approval_blue_state]
                                              [element->component.userid &
                                               0xF]) {
                return NULL;
            }
            if (strlen(ui_approval_blue_values[(element->component.userid &
                                                0xF)]) *
                    BAGL_FONT_OPEN_SANS_LIGHT_16_22PX_AVG_WIDTH <
                160) {
                return NULL;
            }

        // horizontal delimiter
        case 0x30:
            return ui_approval_blue_details_name[G_ui_approval_blue_state]
                                                [element->component.userid &
                                                 0xF] != NULL
                       ? element
                       : NULL;
        case 0x90:
            return (txContent.dataBytes>0);

        case 0xA0:
            return (customContractField&0x01);
        }
    }
    return element;
}

unsigned int ui_approval_blue_button(unsigned int button_mask,
                                     unsigned int button_mask_counter) {
    return 0;
}

void ui_approval_blue_init(void) {
    UX_DISPLAY(ui_approval_blue, ui_approval_blue_prepro);
}

void ui_approval_transaction_blue_init(void) {
    // wipe all cases
    os_memset(ui_approval_blue_values, 0, sizeof(ui_approval_blue_values));
    ui_approval_blue_ok = (bagl_element_callback_t)io_seproxyhal_touch_tx_ok;
    ui_approval_blue_cancel =
        (bagl_element_callback_t)io_seproxyhal_touch_cancel;
    ui_approval_blue_values[0] = (const char*)G_io_apdu_buffer;
    ui_approval_blue_values[1] = (const char*)fullContract;
    ui_approval_blue_values[2] = (const char*)toAddress;
    ui_approval_blue_values[3] = (const char*)fromAddress;

    ui_approval_blue_init();
}

void ui_approval_simple_transaction_blue_init(void) {
    // wipe all cases
    os_memset(ui_approval_blue_values, 0, sizeof(ui_approval_blue_values));
    ui_approval_blue_ok = (bagl_element_callback_t)io_seproxyhal_touch_tx_ok;
    ui_approval_blue_cancel =
        (bagl_element_callback_t)io_seproxyhal_touch_cancel;
    ui_approval_blue_values[0] = (const char*)fullContract;
    ui_approval_blue_values[1] = (const char*)fullHash;
    ui_approval_blue_values[2] = (const char*)fromAddress;

    ui_approval_blue_init();
}

// BANCOR EXCHANGE
void ui_approval_exchange_withdraw_inject_blue_init(void) {
    // wipe all cases
    os_memset(ui_approval_blue_values, 0, sizeof(ui_approval_blue_values));
    ui_approval_blue_ok = (bagl_element_callback_t)io_seproxyhal_touch_tx_ok;
    ui_approval_blue_cancel =
        (bagl_element_callback_t)io_seproxyhal_touch_cancel;
    ui_approval_blue_values[0] = (const char*)exchangeContractDetail;
    ui_approval_blue_values[1] = (const char*)toAddress;
    ui_approval_blue_values[2] = (const char*)fullContract;
    ui_approval_blue_values[3] = (const char*)G_io_apdu_buffer;
    ui_approval_blue_values[4] = (const char*)fromAddress;

    ui_approval_blue_init();
}

void ui_approval_exchange_transaction_blue_init(void) {
    // wipe all cases
    os_memset(ui_approval_blue_values, 0, sizeof(ui_approval_blue_values));
    ui_approval_blue_ok = (bagl_element_callback_t)io_seproxyhal_touch_tx_ok;
    ui_approval_blue_cancel =
        (bagl_element_callback_t)io_seproxyhal_touch_cancel;
    ui_approval_blue_values[0] = (const char*)toAddress;
    ui_approval_blue_values[1] = (const char*)fullContract;
    ui_approval_blue_values[2] = (const char*)G_io_apdu_buffer;
    ui_approval_blue_values[3] = (const char*)G_io_apdu_buffer+100;
    ui_approval_blue_values[4] = (const char*)fromAddress;

    ui_approval_blue_init();
}

void ui_approval_witnessvote_transaction_blue_init(void) {
    // wipe all cases
    os_memset(ui_approval_blue_values, 0, sizeof(ui_approval_blue_values));
    ui_approval_blue_ok = (bagl_element_callback_t)io_seproxyhal_touch_tx_ok;
    ui_approval_blue_cancel =
        (bagl_element_callback_t)io_seproxyhal_touch_cancel;
    ui_approval_blue_values[0] = (const char*)fullContract;
    ui_approval_blue_values[1] = (const char*)G_io_apdu_buffer;
    ui_approval_blue_values[2] = (const char*)fromAddress;
    ui_approval_blue_init();
}

void ui_approval_freeze_transaction_blue_init(void) {
    // wipe all cases
    os_memset(ui_approval_blue_values, 0, sizeof(ui_approval_blue_values));
    ui_approval_blue_ok = (bagl_element_callback_t)io_seproxyhal_touch_tx_ok;
    ui_approval_blue_cancel =
        (bagl_element_callback_t)io_seproxyhal_touch_cancel;
    ui_approval_blue_values[0] = (const char*)fullContract;
    ui_approval_blue_values[1] = (const char*)G_io_apdu_buffer;
    ui_approval_blue_values[2] = (const char*)toAddress;
    ui_approval_blue_values[3] = (const char*)fromAddress;
    ui_approval_blue_init();
}

void ui_approval_unfreeze_transaction_blue_init(void) {
    // wipe all cases
    os_memset(ui_approval_blue_values, 0, sizeof(ui_approval_blue_values));
    ui_approval_blue_ok = (bagl_element_callback_t)io_seproxyhal_touch_tx_ok;
    ui_approval_blue_cancel =
        (bagl_element_callback_t)io_seproxyhal_touch_cancel;
    ui_approval_blue_values[0] = (const char*)fullContract;
    ui_approval_blue_values[1] = (const char*)toAddress;
    ui_approval_blue_values[2] = (const char*)fromAddress;
    ui_approval_blue_init();
}

void ui_approval_withdraw_balance_transaction_blue_init(void) {
    // wipe all cases
    os_memset(ui_approval_blue_values, 0, sizeof(ui_approval_blue_values));
    ui_approval_blue_ok = (bagl_element_callback_t)io_seproxyhal_touch_tx_ok;
    ui_approval_blue_cancel =
        (bagl_element_callback_t)io_seproxyhal_touch_cancel;
    ui_approval_blue_values[0] = (const char*)fromAddress;
    ui_approval_blue_init();
}

void ui_approval_exchange_create_blue_init(void) {
    // wipe all cases
    os_memset(ui_approval_blue_values, 0, sizeof(ui_approval_blue_values));
    ui_approval_blue_ok = (bagl_element_callback_t)io_seproxyhal_touch_tx_ok;
    ui_approval_blue_cancel =
        (bagl_element_callback_t)io_seproxyhal_touch_cancel;
    ui_approval_blue_values[0] = (const char*)fullContract;
    ui_approval_blue_values[1] = (const char*)G_io_apdu_buffer;
    ui_approval_blue_values[2] = (const char*)toAddress;
    ui_approval_blue_values[3] = (const char*)G_io_apdu_buffer+100;
    ui_approval_blue_values[4] = (const char*)fromAddress;

    ui_approval_blue_init();
}

void ui_approval_message_sign_blue_init(void) {
    // wipe all cases
    os_memset(ui_approval_blue_values, 0, sizeof(ui_approval_blue_values));
    ui_approval_blue_ok = (bagl_element_callback_t)io_seproxyhal_touch_signMessage_ok;
    ui_approval_blue_cancel =
        (bagl_element_callback_t)io_seproxyhal_touch_cancel;
    ui_approval_blue_values[0] = (const char*)fullContract;
    ui_approval_blue_values[1] = (const char*)fromAddress;

    ui_approval_blue_init();
}

void ui_approval_custom_contract_blue_init(void) {
    // wipe all cases
    os_memset(ui_approval_blue_values, 0, sizeof(ui_approval_blue_values));
    ui_approval_blue_ok = (bagl_element_callback_t)io_seproxyhal_touch_tx_ok;
    ui_approval_blue_cancel =
        (bagl_element_callback_t)io_seproxyhal_touch_cancel;
    ui_approval_blue_values[0] = (const char*)TRC20Action;
    ui_approval_blue_values[1] = (const char*)fullContract;
    ui_approval_blue_values[2] = (const char*)toAddress;
    ui_approval_blue_values[3] = (const char*)G_io_apdu_buffer;
    ui_approval_blue_values[4] = (const char*)fromAddress;

    ui_approval_blue_init();
}

#endif // #if defined(TARGET_BLUE)

// PGP ECDH
unsigned int io_seproxyhal_touch_ecdh_ok(const bagl_element_t *e) {
    uint8_t privateKeyData[32];
    cx_ecfp_private_key_t privateKey;
    uint32_t tx = 0;

    // Get private key
    os_perso_derive_node_bip32(CX_CURVE_256K1, transactionContext.bip32_path.indices,
            transactionContext.bip32_path.length, privateKeyData, NULL);
    cx_ecfp_init_private_key(CX_CURVE_256K1, privateKeyData, 32, &privateKey);

    tx = cx_ecdh(&privateKey, CX_ECDH_POINT,
                    transactionContext.signature, 65,
                    G_io_apdu_buffer, 160);

    // Clear tmp buffer data
    explicit_bzero(&privateKey, sizeof(privateKey));
    explicit_bzero(privateKeyData, sizeof(privateKeyData));

    G_io_apdu_buffer[tx++] = 0x90;
    G_io_apdu_buffer[tx++] = 0x00;

    // Send back the response, do not restart the event loop
    io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, tx);
    // Display back the original UX
    ui_idle();
    return 0; // do not redraw the widget
}

#if defined(TARGET_BLUE)

unsigned int
ui_approval_pgp_ecdh_blue_button(unsigned int button_mask,
                                 unsigned int button_mask_counter) {
    return 0;
}

// UI to approve or deny the signature proposal
static const bagl_element_t const ui_approval_pgp_ecdh_blue[] = {
    {{BAGL_RECTANGLE, 0x00, 0, 68, 320, 413, 0, 0, BAGL_FILL, COLOR_BG_1,
      0x000000, 0, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    // erase screen (only under the status bar)
    {{BAGL_RECTANGLE, 0x00, 0, 20, 320, 48, 0, 0, BAGL_FILL, COLOR_APP,
      COLOR_APP, 0, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

     /// TOP STATUS BAR
    {{BAGL_LABELINE, 0x00, 0, 45, 320, 30, 0, 0, BAGL_FILL, 0xFFFFFF, COLOR_APP,
      BAGL_FONT_OPEN_SANS_SEMIBOLD_10_13PX | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "TRON SHARED SECRETE",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABEL, 0x00, 0, 87, 320, 32, 0, 0, 0, 0x000000, 0xF9F9F9,
      BAGL_FONT_OPEN_SANS_LIGHT_14px | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "Confirm ECDH Address:",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABEL, 0x00, 0, 136, 320, 33, 0, 0, 0, 0x000000, 0xF9F9F9,
      BAGL_FONT_OPEN_SANS_SEMIBOLD_11_16PX | BAGL_FONT_ALIGNMENT_CENTER, 0},
     (const char *)fromAddress,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

     {{BAGL_LABEL, 0x00, 0, 185, 320, 32, 0, 0, 0, 0x000000, 0xF9F9F9,
      BAGL_FONT_OPEN_SANS_LIGHT_14px | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "Shared with",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABEL, 0x00, 0, 234, 320, 33, 0, 0, 0, 0x000000, 0xF9F9F9,
      BAGL_FONT_OPEN_SANS_SEMIBOLD_11_16PX | BAGL_FONT_ALIGNMENT_CENTER, 0},
     (const char *)toAddress,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_BUTTON | BAGL_FLAG_TOUCHABLE, 0x00, 35, 385, 120, 40, 0, 6,
      BAGL_FILL, 0xcccccc, COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_LIGHT_14px | BAGL_FONT_ALIGNMENT_CENTER |
          BAGL_FONT_ALIGNMENT_MIDDLE,
      0},
     "CANCEL",
     0,
     0x37ae99,
     COLOR_BG_1,
     io_seproxyhal_touch_cancel,
     NULL,
     NULL},
    {{BAGL_BUTTON | BAGL_FLAG_TOUCHABLE, 0x00, 165, 385, 120, 40, 0, 6,
      BAGL_FILL, 0x41ccb4, COLOR_BG_1,
      BAGL_FONT_OPEN_SANS_LIGHT_14px | BAGL_FONT_ALIGNMENT_CENTER |
          BAGL_FONT_ALIGNMENT_MIDDLE,
      0},
     "CONFIRM",
     0,
     0x37ae99,
     COLOR_BG_1,
     io_seproxyhal_touch_ecdh_ok,
     NULL,
     NULL},

};

#endif // #if defined(TARGET_BLUE)

#if defined(HAVE_UX_FLOW)

void display_settings(void);
void switch_settings_contract_data();
void switch_settings_custom_contracts();
void switch_settings_truncate_address();

//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_idle_flow_1_step,
    pnn,
    {
      &C_icon,
      "Application",
      "is ready",
    });
UX_STEP_NOCB(
    ux_idle_flow_2_step,
    bn,
    {
      "Version",
      APPVERSION,
    });
UX_STEP_VALID(
    ux_idle_flow_3_step,
    pb,
    display_settings(),
    {
      &C_icon_coggle,
      "Settings",
    });

UX_STEP_VALID(
    ux_idle_flow_4_step,
    pb,
    os_sched_exit(-1),
    {
      &C_icon_dashboard_x,
      "Quit",
    });

UX_DEF(ux_idle_flow,
  &ux_idle_flow_1_step,
  &ux_idle_flow_2_step,
  &ux_idle_flow_3_step,
  &ux_idle_flow_4_step
);


#if defined(TARGET_NANOS)

UX_STEP_VALID(
    ux_settings_flow_1_step,
    bnnn_paging,
    switch_settings_contract_data(),
    {
      .title = "Transactions data",
      .text = addressSummary,
    });

UX_STEP_VALID(
    ux_settings_flow_2_step,
    bnnn_paging,
    switch_settings_custom_contracts(),
    {
      .title = "Custom contracts",
      .text = addressSummary + 20
    });

UX_STEP_VALID(
    ux_settings_flow_3_step,
    bnnn_paging,
    switch_settings_truncate_address(),
    {
      .title = "Truncate Address",
      .text = addressSummary + 40
    });

#else

UX_STEP_VALID(
    ux_settings_flow_1_step,
    bnnn,
    switch_settings_contract_data(),
    {
      "Transactions data",
      "Allow extra data",
      "in transactions",
      addressSummary,
    });

UX_STEP_VALID(
    ux_settings_flow_2_step,
    bnnn,
    switch_settings_custom_contracts(),
    {
      "Custom contracts",
      "Allow unverified",
      "contracts",
      addressSummary + 20
    });

UX_STEP_VALID(
    ux_settings_flow_3_step,
    bnnn,
    switch_settings_truncate_address(),
    {
      "Truncate address",
      "Truncate display",
      "address",
      addressSummary + 40
    });

#endif

UX_STEP_VALID(
    ux_settings_flow_4_step,
    pb,
    ui_idle(),
    {
      &C_icon_back,
      "Back",
    });

UX_DEF(ux_settings_flow,
  &ux_settings_flow_1_step,
  &ux_settings_flow_2_step,
  &ux_settings_flow_3_step,
  &ux_settings_flow_4_step
);

void display_settings() {
  strcpy(addressSummary, (N_storage.dataAllowed ? "Allowed" : "NOT Allowed"));
  strcpy(addressSummary + 20, (N_storage.customContract ? "Allowed" : "NOT Allowed"));
  strcpy(addressSummary + 40, (N_storage.truncateAddress ? "Yes" : "No"));
  ux_flow_init(0, ux_settings_flow, NULL);
}

void switch_settings_contract_data() {
  uint8_t value = (N_storage.dataAllowed ? 0 : 1);
  dataAllowed = value;
  nvm_write((void*)&N_storage.dataAllowed, (void*)&value, sizeof(uint8_t));
  display_settings();
}

void switch_settings_custom_contracts() {
  uint8_t value = (N_storage.customContract ? 0 : 1);
  customContract = value;
  nvm_write((void*)&N_storage.customContract, (void*)&value, sizeof(uint8_t));
  display_settings();
}

void switch_settings_truncate_address() {
  uint8_t value = (N_storage.truncateAddress ? 0 : 1);
  truncateAddress = value;
  nvm_write((void*)&N_storage.truncateAddress, (void*)&value, sizeof(uint8_t));
  display_settings();
}

//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(ux_approval_tx_data_warning_step,
    pnn,
    {
      &C_icon_warning,
      "Data",
      "Present",
    });

UX_STEP_NOCB(
    ux_approval_from_address_step,
    bnnn_paging,
    {
      .title = "From Address",
      .text = fromAddress
    });

UX_STEP_VALID(
    ux_approval_confirm_step,
    pbb,
    io_seproxyhal_touch_tx_ok(NULL),
    {
      &C_icon_validate_14,
      "Accept",
      "and send",
    });

UX_STEP_VALID(
    ux_approval_reject_step,
    pb,
    io_seproxyhal_touch_cancel(NULL),
    {
      &C_icon_crossmark,
      "Reject",
    });

//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_display_public_flow_1_step,
    pnn,
    {
      &C_icon_eye,
      "Verify",
      "address",
    });
UX_STEP_NOCB(
    ux_display_public_flow_2_step,
    bnnn_paging,
    {
      .title = "Address",
      .text = toAddress,
    });
UX_STEP_VALID(
    ux_display_public_flow_3_step,
    pb,
    io_seproxyhal_touch_address_ok(NULL),
    {
      &C_icon_validate_14,
      "Approve",
    });

UX_DEF(ux_display_public_flow,
  &ux_display_public_flow_1_step,
  &ux_display_public_flow_2_step,
  &ux_display_public_flow_3_step,
  &ux_approval_reject_step
);

// Simple Transaction:
//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_approval_st_flow_1_step,
    pnn,
    {
      &C_icon_eye,
      "Verify",
      fullContract
    });
UX_STEP_NOCB(
    ux_approval_st_flow_2_step,
    bnnn_paging,
    {
      .title = "Hash",
      .text = fullHash
    });

UX_DEF(ux_approval_st_flow,
  &ux_approval_st_flow_1_step,
  &ux_approval_st_flow_2_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

UX_DEF(ux_approval_st_data_warning_flow,
  &ux_approval_st_flow_1_step,
  &ux_approval_tx_data_warning_step,
  &ux_approval_st_flow_2_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

// TRANSFER
//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_approval_tx_1_step,
    pnn,
    {
      &C_icon_eye,
      "Review",
      "transfer",
    });
UX_STEP_NOCB(
    ux_approval_tx_2_step,
    bnnn_paging,
    {
      .title = "Amount",
      .text = G_io_apdu_buffer
    });
UX_STEP_NOCB(
    ux_approval_tx_3_step,
    bnnn_paging,
    {
      .title = "Token",
      .text = (const char *)fullContract,
    });
UX_STEP_NOCB(
    ux_approval_tx_4_step,
    bnnn_paging,
    {
      .title = TRC20ActionSendAllow,
      .text = toAddress,
    });

UX_DEF(ux_approval_tx_flow,
  &ux_approval_tx_1_step,
  &ux_approval_tx_2_step,
  &ux_approval_tx_3_step,
  &ux_approval_tx_4_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

UX_DEF(ux_approval_tx_data_warning_flow,
  &ux_approval_tx_1_step,
  &ux_approval_tx_data_warning_step,
  &ux_approval_tx_2_step,
  &ux_approval_tx_3_step,
  &ux_approval_tx_4_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

// EXCHANGE CREATE
//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_approval_exchange_create_1_step,
    pnn,
    {
      &C_icon_eye,
      "Review",
      "exchange",
    });
UX_STEP_NOCB(
    ux_approval_exchange_create_2_step,
    bnnn_paging,
    {
      .title = "Token 1",
      .text = (const char *)fullContract
    });
UX_STEP_NOCB(
    ux_approval_exchange_create_3_step,
    bnnn_paging,
    {
      .title = "Amount 1",
      .text = G_io_apdu_buffer,
    });
UX_STEP_NOCB(
    ux_approval_exchange_create_4_step,
    bnnn_paging,
    {
      .title = "Token 2",
      .text = toAddress,
    });
UX_STEP_NOCB(
    ux_approval_exchange_create_5_step,
    bnnn_paging,
    {
      .title = "Amount 2",
      .text = G_io_apdu_buffer+100,
    });
UX_STEP_VALID(
    ux_approval_exchange_create_confirm_step,
    pbb,
    io_seproxyhal_touch_tx_ok(NULL),
    {
      &C_icon_validate_14,
      "Accept",
      "and create",
    });

UX_DEF(ux_approval_exchange_create_flow,
  &ux_approval_exchange_create_1_step,
  &ux_approval_exchange_create_2_step,
  &ux_approval_exchange_create_3_step,
  &ux_approval_exchange_create_4_step,
  &ux_approval_exchange_create_5_step,
  &ux_approval_from_address_step,
  &ux_approval_exchange_create_confirm_step,
  &ux_approval_reject_step
);

UX_DEF(ux_approval_exchange_create_data_warning_flow,
  &ux_approval_exchange_create_1_step,
  &ux_approval_tx_data_warning_step,
  &ux_approval_exchange_create_2_step,
  &ux_approval_exchange_create_3_step,
  &ux_approval_exchange_create_4_step,
  &ux_approval_exchange_create_5_step,
  &ux_approval_from_address_step,
  &ux_approval_exchange_create_confirm_step,
  &ux_approval_reject_step
);

// WITNESS VOTE TRANSACTION
//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_approval_vote_flow_1_step,
    pnn,
    {
      &C_icon_eye,
      "Review",
      "votes",
    });
UX_STEP_NOCB(
    ux_approval_vote_flow_2_step,
    bnnn_paging,
    {
      .title = (char *)(G_io_apdu_buffer+voteSlot(0, VOTE_ADDRESS)),
      .text = (char *)(G_io_apdu_buffer+voteSlot(0, VOTE_AMOUNT)),
    });
UX_STEP_NOCB(
    ux_approval_vote_flow_3_step,
    bnnn_paging,
    {
      .title = (char *)(G_io_apdu_buffer+voteSlot(1, VOTE_ADDRESS)),
      .text = (char *)(G_io_apdu_buffer+voteSlot(1, VOTE_AMOUNT)),
    });
UX_STEP_NOCB(
    ux_approval_vote_flow_4_step,
    bnnn_paging,
    {
      .title = (char *)(G_io_apdu_buffer+voteSlot(2, VOTE_ADDRESS)),
      .text = (char *)(G_io_apdu_buffer+voteSlot(2, VOTE_AMOUNT)),
    });
UX_STEP_NOCB(
    ux_approval_vote_flow_5_step,
    bnnn_paging,
    {
      .title = (char *)(G_io_apdu_buffer+voteSlot(3, VOTE_ADDRESS)),
      .text = (char *)(G_io_apdu_buffer+voteSlot(3, VOTE_AMOUNT)),
    });
UX_STEP_NOCB(
    ux_approval_vote_flow_6_step,
    bnnn_paging,
    {
      .title = (char *)(G_io_apdu_buffer+voteSlot(4, VOTE_ADDRESS)),
      .text = (char *)(G_io_apdu_buffer+voteSlot(4, VOTE_AMOUNT)),
    });

// 11 slots for dynamic NanoS/NanoX UX voting steps
const ux_flow_step_t * ux_approval_vote_flow[11];

// FREEZE TRANSACTION
//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_approval_freeze_flow_1_step,
    pnn,
    {
      &C_icon_eye,
      "Review",
      "freeze",
    });
UX_STEP_NOCB(
    ux_approval_freeze_flow_2_step,
    bnnn_paging,
    {
      .title = "Gain",
      .text = (const char *)fullContract
    });
UX_STEP_NOCB(
    ux_approval_freeze_flow_3_step,
    bnnn_paging,
    {
      .title = "Amount",
      .text = G_io_apdu_buffer,
    });
UX_STEP_NOCB(
    ux_approval_freeze_flow_4_step,
    bnnn_paging,
    {
      .title = "Freeze To",
      .text = toAddress,
    });

UX_DEF(ux_approval_freeze_flow,
  &ux_approval_freeze_flow_1_step,
  &ux_approval_freeze_flow_2_step,
  &ux_approval_freeze_flow_3_step,
  &ux_approval_freeze_flow_4_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

UX_DEF(ux_approval_freeze_data_warning_flow,
  &ux_approval_freeze_flow_1_step,
  &ux_approval_tx_data_warning_step,
  &ux_approval_freeze_flow_2_step,
  &ux_approval_freeze_flow_3_step,
  &ux_approval_freeze_flow_4_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);


UX_STEP_NOCB(
    ux_approval_unfreeze_flow_1_step,
    pnn,
    {
      &C_icon_eye,
      "Review",
      "unfreeze",
    });
UX_STEP_NOCB(
    ux_approval_unfreeze_flow_2_step,
    bnnn_paging,
    {
      .title = "Resource",
      .text = (const char *)fullContract
    });
UX_STEP_NOCB(
    ux_approval_unfreeze_flow_3_step,
    bnnn_paging,
    {
      .title = "Delegated To",
      .text = toAddress,
    });

UX_DEF(ux_approval_unfreeze_flow,
  &ux_approval_unfreeze_flow_1_step,
  &ux_approval_unfreeze_flow_2_step,
  &ux_approval_unfreeze_flow_3_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

UX_DEF(ux_approval_unfreeze_data_warning_flow,
  &ux_approval_unfreeze_flow_1_step,
  &ux_approval_tx_data_warning_step,
  &ux_approval_unfreeze_flow_2_step,
  &ux_approval_unfreeze_flow_3_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);


// WITHDRAW BALANCE TRANSACTION
//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_approval_withdraw_balance_flow_1_step,
    pnn,
    {
      &C_icon_eye,
      "Claim",
      "rewards",
    });

UX_DEF(ux_approval_withdraw_balance_flow,
  &ux_approval_withdraw_balance_flow_1_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

UX_DEF(ux_approval_withdraw_balance_data_warning_flow,
  &ux_approval_withdraw_balance_flow_1_step,
  &ux_approval_tx_data_warning_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

// EXCHANGE TRANSACTION
//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_approval_exchange_transaction_1_step,
    pnn,
    {
      &C_icon_eye,
      "Review",
      "transaction",
    });
UX_STEP_NOCB(
    ux_approval_exchange_transaction_2_step,
    bnnn_paging,
    {
      .title = "Exchange ID",
      .text = toAddress
    });
UX_STEP_NOCB(
    ux_approval_exchange_transaction_3_step,
    bnnn_paging,
    {
      .title = "Token pair",
      .text = (const char *)fullContract,
    });
UX_STEP_NOCB(
    ux_approval_exchange_transaction_4_step,
    bnnn_paging,
    {
      .title = "Amount",
      .text = G_io_apdu_buffer,
    });
UX_STEP_NOCB(
    ux_approval_exchange_transaction_5_step,
    bnnn_paging,
    {
      .title = "Expected",
      .text = G_io_apdu_buffer+100,
    });

UX_DEF(ux_approval_exchange_transaction_flow,
  &ux_approval_exchange_transaction_1_step,
  &ux_approval_exchange_transaction_2_step,
  &ux_approval_exchange_transaction_3_step,
  &ux_approval_exchange_transaction_4_step,
  &ux_approval_exchange_transaction_5_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

UX_DEF(ux_approval_exchange_transaction_data_warning_flow,
  &ux_approval_exchange_transaction_1_step,
  &ux_approval_tx_data_warning_step,
  &ux_approval_exchange_transaction_2_step,
  &ux_approval_exchange_transaction_3_step,
  &ux_approval_exchange_transaction_4_step,
  &ux_approval_exchange_transaction_5_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);


// EXCHANGE WITHDRAW INJECT
//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_approval_exchange_wi_1_step,
    pnn,
    {
      &C_icon_eye,
      "Review",
      "transaction",
    });
UX_STEP_NOCB(
    ux_approval_exchange_wi_2_step,
    bnnn_paging,
    {
      .title = "Action",
      .text = exchangeContractDetail
    });
UX_STEP_NOCB(
    ux_approval_exchange_wi_3_step,
    bnnn_paging,
    {
      .title = "Exchange ID",
      .text = toAddress,
    });
UX_STEP_NOCB(
    ux_approval_exchange_wi_4_step,
    bnnn_paging,
    {
      .title = "Token name",
      .text = (const char *)fullContract,
    });
UX_STEP_NOCB(
    ux_approval_exchange_wi_5_step,
    bnnn_paging,
    {
      .title = "Amount",
      .text = G_io_apdu_buffer,
    });

UX_DEF(ux_approval_exchange_wi_flow,
  &ux_approval_exchange_wi_1_step,
  &ux_approval_exchange_wi_2_step,
  &ux_approval_exchange_wi_3_step,
  &ux_approval_exchange_wi_4_step,
  &ux_approval_exchange_wi_5_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

UX_DEF(ux_approval_exchange_wi_data_warning_flow,
  &ux_approval_exchange_wi_1_step,
  &ux_approval_tx_data_warning_step,
  &ux_approval_exchange_wi_2_step,
  &ux_approval_exchange_wi_3_step,
  &ux_approval_exchange_wi_4_step,
  &ux_approval_exchange_wi_5_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

// ECDH Shared Secret
//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_approval_pgp_ecdh_1_step,
    pnn,
    {
      &C_icon_eye,
      "Approve",
      "Shared Secret",
    });
UX_STEP_NOCB(
    ux_approval_pgp_ecdh_2_step,
    bnnn_paging,
    {
      .title = "ECDH Address",
      .text = fromAddress
    });
UX_STEP_NOCB(
    ux_approval_pgp_ecdh_3_step,
    bnnn_paging,
    {
      .title = "Shared With",
      .text = toAddress,
    });

UX_STEP_VALID(
    ux_approval_pgp_ecdh_4_step,
    pb,
    io_seproxyhal_touch_ecdh_ok(NULL),
    {
      &C_icon_validate_14,
      "Accept",
    });
UX_STEP_VALID(
    ux_approval_pgp_ecdh_5_step,
    pb,
    io_seproxyhal_touch_cancel(NULL),
    {
      &C_icon_crossmark,
      "Reject",
    });

UX_DEF(ux_approval_pgp_ecdh_flow,
  &ux_approval_pgp_ecdh_1_step,
  &ux_approval_pgp_ecdh_2_step,
  &ux_approval_pgp_ecdh_3_step,
  &ux_approval_pgp_ecdh_4_step,
  &ux_approval_pgp_ecdh_5_step
);

// Sign personal message
//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_sign_flow_1_step,
    pnn,
    {
      &C_icon_certificate,
      "Sign",
      "message",
    });
UX_STEP_NOCB(
    ux_sign_flow_2_step,
    bnnn_paging,
    {
      .title = "Message hash",
      .text = (const char *)fullContract,
    });
UX_STEP_NOCB(
    ux_sign_flow_3_step,
    bnnn_paging,
    {
      .title = "Sign with",
      .text = fromAddress,
    });
UX_STEP_VALID(
    ux_sign_flow_4_step,
    pbb,
    io_seproxyhal_touch_signMessage_ok(NULL),
    {
      &C_icon_validate_14,
      "Sign",
      "message",
    });
UX_STEP_VALID(
    ux_sign_flow_5_step,
    pbb,
    io_seproxyhal_touch_cancel(NULL),
    {
      &C_icon_crossmark,
      "Cancel",
      "signature",
    });

UX_DEF(ux_sign_flow,
  &ux_sign_flow_1_step,
  &ux_sign_flow_2_step,
  &ux_sign_flow_3_step,
  &ux_sign_flow_4_step,
  &ux_sign_flow_5_step
);


// CUSTOM CONTRACT
//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_approval_custom_contract_1_step,
    pnn,
    {
      &C_icon_eye,
      "Custom",
      "Contract",
    });
UX_STEP_NOCB(
    ux_approval_custom_contract_2_step,
    bnnn_paging,
    {
      .title = "Contract",
      .text = (const char *)fullContract
    });
UX_STEP_NOCB(
    ux_approval_custom_contract_3_step,
    bnnn_paging,
    {
      .title = "Selector",
      .text = TRC20Action,
    });
UX_STEP_NOCB(
    ux_approval_custom_contract_4_step,
    bnnn_paging,
    {
      .title = "Token",
      .text = toAddress,
    });
UX_STEP_NOCB(
    ux_approval_custom_contract_5_step,
    bnnn_paging,
    {
      .title = "Call Amount",
      .text = G_io_apdu_buffer,
    });

UX_STEP_NOCB(ux_approval_custom_contract_warning_step,
    pnn,
    {
      &C_icon_warning,
      "This contract",
      "is not verified",
    });

UX_DEF(ux_approval_custom_contract_flow,
  &ux_approval_custom_contract_1_step,
  &ux_approval_custom_contract_warning_step,
  &ux_approval_custom_contract_2_step,
  &ux_approval_custom_contract_3_step,
  &ux_approval_custom_contract_4_step,
  &ux_approval_custom_contract_5_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

UX_DEF(ux_approval_custom_contract_data_warning_flow,
  &ux_approval_custom_contract_1_step,
  &ux_approval_custom_contract_warning_step,
  &ux_approval_tx_data_warning_step,
  &ux_approval_custom_contract_2_step,
  &ux_approval_custom_contract_3_step,
  &ux_approval_custom_contract_4_step,
  &ux_approval_custom_contract_5_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

// Account Permission Update:
//////////////////////////////////////////////////////////////////////
UX_STEP_NOCB(
    ux_approval_account_permission_update_1_step,
    pnn,
    {
      &C_icon_eye,
      "Permission",
      "Update"
    });
UX_STEP_NOCB(
    ux_approval_account_permission_update_2_step,
    bnnn_paging,
    {
      .title = "Hash",
      .text = fullHash
    });

UX_DEF(ux_approval_account_permission_update_flow,
  &ux_approval_account_permission_update_1_step,
  &ux_approval_account_permission_update_2_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

UX_DEF(ux_approval_account_permission_update_data_warning_flow,
  &ux_approval_account_permission_update_1_step,
  &ux_approval_tx_data_warning_step,
  &ux_approval_account_permission_update_2_step,
  &ux_approval_from_address_step,
  &ux_approval_confirm_step,
  &ux_approval_reject_step
);

#endif // #if defined(HAVE_UX_FLOW)

void ui_idle(void) {
#if defined(TARGET_BLUE)
    UX_DISPLAY(ui_idle_blue, NULL);
#elif defined(HAVE_UX_FLOW)
    // reserve a display stack slot if none yet
    if(G_ux.stack_count == 0) {
        ux_stack_push();
    }
    ux_flow_init(0, ux_idle_flow, NULL);
#endif // #if TARGET_ID
}

#if defined(TARGET_BLUE)
unsigned int io_seproxyhal_touch_settings(const bagl_element_t *e) {
    UX_DISPLAY(ui_settings_blue, ui_settings_blue_prepro);
    return 0; // do not redraw button, screen has switched
}
#endif // #if defined(TARGET_BLUE)

unsigned int io_seproxyhal_touch_exit(const bagl_element_t *e) {
    // Go back to the dashboard
    os_sched_exit(0);
    return 0; // do not redraw the widget
}

unsigned int io_seproxyhal_touch_address_ok(const bagl_element_t *e) {
    uint32_t tx = set_result_get_publicKey();
    G_io_apdu_buffer[tx++] = 0x90;
    G_io_apdu_buffer[tx++] = 0x00;

    // Send back the response, do not restart the event loop
    io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, tx);
    // Display back the original UX
    ui_idle();
    return 0; // do not redraw the widget
}

unsigned int io_seproxyhal_touch_cancel(const bagl_element_t *e) {
    G_io_apdu_buffer[0] = 0x69;
    G_io_apdu_buffer[1] = 0x85;
    // Send back the response, do not restart the event loop
    io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, 2);
    // Display back the original UX
    ui_idle();
    return 0; // do not redraw the widget
}

unsigned int io_seproxyhal_touch_signMessage_ok(const bagl_element_t *e) {
    uint32_t tx = 0;

    signTransaction(&transactionContext);
    // send to output buffer
    os_memmove(G_io_apdu_buffer, transactionContext.signature, transactionContext.signatureLength);
    tx=transactionContext.signatureLength;
    G_io_apdu_buffer[tx++] = 0x90;
    G_io_apdu_buffer[tx++] = 0x00;

    // Send back the response, do not restart the event loop
    io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, tx);
    // Display back the original UX
    ui_idle();
    return 0; // do not redraw the widget
}


unsigned int io_seproxyhal_touch_tx_ok(const bagl_element_t *e) {
    uint32_t tx = 0;

    signTransaction(&transactionContext);
    // send to output buffer
    os_memmove(G_io_apdu_buffer, transactionContext.signature, transactionContext.signatureLength);
    tx=transactionContext.signatureLength;
    G_io_apdu_buffer[tx++] = 0x90;
    G_io_apdu_buffer[tx++] = 0x00;

    // Send back the response, do not restart the event loop
    io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, tx);
    // Display back the original UX
    ui_idle();
    return 0; // do not redraw the widget
}

unsigned short io_exchange_al(unsigned char channel, unsigned short tx_len) {
    switch (channel & ~(IO_FLAGS)) {
    case CHANNEL_KEYBOARD:
        break;

    // multiplexed io exchange over a SPI channel and TLV encapsulated protocol
    case CHANNEL_SPI:
        if (tx_len) {
            io_seproxyhal_spi_send(G_io_apdu_buffer, tx_len);

            if (channel & IO_RESET_AFTER_REPLIED) {
                reset();
            }
            return 0; // nothing received from the master so far (it's a tx
                      // transaction)
        } else {
            return io_seproxyhal_spi_recv(G_io_apdu_buffer,
                                          sizeof(G_io_apdu_buffer), 0);
        }

    default:
        THROW(INVALID_PARAMETER);
    }
    return 0;
}


uint32_t set_result_get_publicKey() {
    uint32_t tx = 0;
    uint32_t addressLength = BASE58CHECK_ADDRESS_SIZE;
    G_io_apdu_buffer[tx++] = 65;
    os_memmove(G_io_apdu_buffer + tx, publicKeyContext.publicKey.W, 65);
    tx += 65;
    G_io_apdu_buffer[tx++] = addressLength;
    os_memmove(G_io_apdu_buffer + tx, publicKeyContext.address58,
               addressLength);
    tx += addressLength;
    return tx;
}

off_t read_bip32_path(const uint8_t *buffer, size_t length,
                      bip32_path_t *path) {
  if (length < 1) {
    return -1;
  }
  unsigned int path_length = *buffer++;

  if (path_length < 1 || path_length > MAX_BIP32_PATH) {
    PRINTF("Invalid path\n");
    return -1;
  }

  if (length < 1 + 4 * path_length) {
    return -1;
  }
  path->length = path_length;
  for (unsigned int i = 0; i < path_length; i++) {
    path->indices[i] = U4BE(buffer, 0);
    buffer += 4;
  }
  return 1 + 4 * path_length;
}

// APDU public key
void handleGetPublicKey(uint8_t p1, uint8_t p2, uint8_t *dataBuffer,
                        uint16_t dataLength, volatile unsigned int *flags,
                        volatile unsigned int *tx) {
    // Get private key data
    uint8_t privateKeyData[33];
    bip32_path_t bip32_path;
    cx_ecfp_private_key_t privateKey;

    uint8_t p2Chain = p2 & 0x3F;

    if ((p1 != P1_CONFIRM) && (p1 != P1_NON_CONFIRM)) {
        THROW(0x6B00);
    }
    if ((p2Chain != P2_CHAINCODE) && (p2Chain != P2_NO_CHAINCODE)) {
        THROW(0x6B00);
    }

    // Add requested BIP path to tmp array
    if (read_bip32_path(dataBuffer, dataLength, &bip32_path) < 0) {
        PRINTF("read_bip32_path failed\n");
        THROW(0x6A80);
    }

    // Get private key
    os_perso_derive_node_bip32(CX_CURVE_256K1, bip32_path.indices,
                               bip32_path.length, privateKeyData, NULL);

    cx_ecfp_init_private_key(CX_CURVE_256K1, privateKeyData, 32, &privateKey);
    cx_ecfp_generate_pair(CX_CURVE_256K1, &publicKeyContext.publicKey,
                          &privateKey, 1);

    // Clear tmp buffer data
    os_memset(&privateKey, 0, sizeof(privateKey));
    os_memset(privateKeyData, 0, sizeof(privateKeyData));

    // Get address from PK
    getAddressFromKey(&publicKeyContext.publicKey, publicKeyContext.address);

    // Get Base58
    getBase58FromAddress(publicKeyContext.address,
                                publicKeyContext.address58, &sha2, false);

    os_memmove((void *)toAddress,publicKeyContext.address58,BASE58CHECK_ADDRESS_SIZE);
    toAddress[BASE58CHECK_ADDRESS_SIZE]='\0';

    if (p1 == P1_NON_CONFIRM) {
        *tx=set_result_get_publicKey();
        THROW(0x9000);
    } else {

    // prepare for a UI based reply
#if defined(TARGET_BLUE)
        UX_DISPLAY(ui_address_blue, ui_address_blue_prepro);
#elif defined(HAVE_UX_FLOW)
        ux_flow_init(0, ux_display_public_flow, NULL);
#endif // #if TARGET

        *flags |= IO_ASYNCH_REPLY;
    }

}

void convertUint256BE(uint8_t *data, uint32_t length, uint256_t *target) {
    uint8_t tmp[32];
    os_memset(tmp, 0, 32);
    os_memmove(tmp + 32 - length, data, length);
    readu256BE(tmp, target);
}

// APDU Sign
void handleSign(uint8_t p1, uint8_t p2, uint8_t *workBuffer,
                uint16_t dataLength, volatile unsigned int *flags,
                volatile unsigned int *tx) {

    UNUSED(tx);
    uint256_t uint256;

    if (p2 != 0x00) {
        THROW(0x6B00);
    }

    // initialize context
    if ((p1 == P1_FIRST) || (p1 == P1_SIGN)) {
        off_t ret = read_bip32_path(workBuffer, dataLength, &transactionContext.bip32_path);
        if (ret < 0) {
            THROW(0x6a80);
        }
        workBuffer += ret;
        dataLength -= ret;

        initTx(&txContext, &sha2, &txContent);
        customContractField = 0;
        txContent.publicKeyContext = &publicKeyContext;

    } else if ((p1&0xF0) == P1_TRC10_NAME)  {
        PRINTF("Setting token name\nContract type: %d\n",txContent.contractType);
        switch (txContent.contractType){
            case TRANSFERASSETCONTRACT:
            case EXCHANGECREATECONTRACT:
                // Max 2 Tokens Name
                if ((p1&0x07)>1)
                    THROW(0x6A80);
                // Decode Token name and validate signature
                if (!parseTokenName((p1&0x07),workBuffer, dataLength, &txContent)) {
                    PRINTF("Unexpected parser status\n");
                    THROW(0x6802);
                }
                // if not last token name, return
                if (!(p1&0x08)) THROW(0x9000);
                dataLength = 0;

                break;
            case EXCHANGEINJECTCONTRACT:
            case EXCHANGEWITHDRAWCONTRACT:
            case EXCHANGETRANSACTIONCONTRACT:
                // Max 1 pair set
                if ((p1&0x07)>0)
                    THROW(0x6A80);
                // error if not last
                if (!(p1&0x08)) THROW(0x6A80);
                PRINTF("Decoding Exchange\n");
                // Decode Token name and validate signature
                if (!parseExchange(workBuffer, dataLength, &txContent)) {
                    PRINTF("Unexpected parser status\n");
                    THROW(0x6802);
                }
                dataLength = 0;
                break;
            default:
                // Error if any other contract
                THROW(0x6A80);
        }
    }else if ((p1 != P1_MORE) && (p1 != P1_LAST)) {
        THROW(0x6B00);
    }

    // Context must be initialized first
    if (!txContext.initialized) {
        PRINTF("Context not initialized\n");
        THROW(0x6985);
    }
    // hash data
    cx_hash((cx_hash_t *)txContext.sha2, 0, workBuffer, dataLength, NULL, 32);
    txContent.bandwidth+=dataLength;

    // process buffer
    uint16_t txResult = processTx(workBuffer, dataLength, &txContent);
    PRINTF("txResult: %04x\n", txResult);
    switch (txResult) {
        case USTREAM_PROCESSING:
            // Last data should not return
            if (p1 == P1_LAST || p1 == P1_SIGN) break;
            THROW(0x9000);
        case USTREAM_FINISHED:
            break;
        case USTREAM_FAULT:
            THROW(0x6A80);
        default:
            PRINTF("Unexpected parser status\n");
            THROW(txResult);
    }

    // Last data hash
    cx_hash((cx_hash_t *)txContext.sha2, CX_LAST, workBuffer,
            0, transactionContext.hash, 32);

    if (txContent.permission_id>0){
        PRINTF("Set permission_id...\n");
        snprintf((char*)fromAddress, 5, "P%d - ",txContent.permission_id);
        getBase58FromAddress(txContent.account, (void *)(fromAddress+4), &sha2, truncateAddress);
    } else {
        PRINTF("Regular transaction...\n");
        getBase58FromAddress(txContent.account, (void *)fromAddress, &sha2, truncateAddress);
    }

    switch (txContent.contractType){
        case TRANSFERCONTRACT: // TRX Transfer
        case TRANSFERASSETCONTRACT: // TRC10 Transfer
        case TRIGGERSMARTCONTRACT: // TRC20 Transfer

            os_memmove((void *)TRC20ActionSendAllow, "Send To\0", 8);
            if (txContent.contractType==TRIGGERSMARTCONTRACT){
                if (txContent.TRC20Method==1)
                    os_memmove((void *)TRC20Action, "Asset\0", 6);
                else if (txContent.TRC20Method==2){
                    os_memmove((void *)TRC20ActionSendAllow, "Allow\0", 8);
                    os_memmove((void *)TRC20Action, "Approve\0", 8);
                }else {
                    if (!customContract) THROW(0x6B00);
                    customContractField = 1;

                    getBase58FromAddress(txContent.contractAddress, (uint8_t *)fullContract, &sha2, truncateAddress);
                    snprintf((char *)TRC20Action, sizeof(TRC20Action), "%08x", txContent.customSelector);
                    G_io_apdu_buffer[0]='\0';
                    G_io_apdu_buffer[100]='\0';
                    toAddress[0]='\0';
                    if (txContent.amount[0]>0 && txContent.amount[1]>0) THROW(0x6A80);
                    // call has value
                    if (txContent.amount[0]>0) {
                        os_memmove((void *)toAddress, "TRX\0", 4);
                        print_amount(txContent.amount[0],(void *)G_io_apdu_buffer,100, SUN_DIG);
                        customContractField |= (1<<0x05);
                        customContractField |= (1<<0x06);
                    }else if (txContent.amount[1]>0) {
                        os_memmove((void *)toAddress, txContent.tokenNames[0], txContent.tokenNamesLength[0]+1);
                        print_amount(txContent.amount[1],(void *)G_io_apdu_buffer,100, 0);
                        customContractField |= (1<<0x05);
                        customContractField |= (1<<0x06);
                    }else{
                        os_memmove((void *)toAddress, "-\0", 2);
                        os_memmove((void *)G_io_apdu_buffer, "0\0", 2);
                    }

                    // approve custom contract
                    #if defined(TARGET_BLUE)
                        G_ui_approval_blue_state = APPROVAL_CUSTOM_CONTRACT;
                        ui_approval_custom_contract_blue_init();
                    #elif defined(HAVE_UX_FLOW)
                        ux_flow_init(0,
                            ((txContent.dataBytes>0)? ux_approval_custom_contract_data_warning_flow : ux_approval_custom_contract_flow),
                            NULL);
                    #endif // #if TARGET_ID

                    break;
                }

                convertUint256BE(txContent.TRC20Amount, 32, &uint256);
                tostring256(&uint256, 10, (char *)G_io_apdu_buffer+100, 100);
                if (!adjustDecimals((char *)G_io_apdu_buffer+100, strlen((const char *)G_io_apdu_buffer+100), (char *)G_io_apdu_buffer, 100, txContent.decimals[0]))
                    THROW(0x6B00);
            }else
                print_amount(txContent.amount[0],(void *)G_io_apdu_buffer,100, (txContent.contractType==TRANSFERCONTRACT)?SUN_DIG:txContent.decimals[0]);

            getBase58FromAddress(txContent.destination, (uint8_t *)toAddress,
                                 &sha2, truncateAddress);

            // get token name if any
            os_memmove((void *)fullContract, txContent.tokenNames[0], txContent.tokenNamesLength[0]+1);

            #if defined(TARGET_BLUE)
                G_ui_approval_blue_state = APPROVAL_TRANSFER;
                ui_approval_transaction_blue_init();
            #elif defined(HAVE_UX_FLOW)
                ux_flow_init(0,
                    ((txContent.dataBytes>0)? ux_approval_tx_data_warning_flow : ux_approval_tx_flow),
                    NULL);
            #endif // #if TARGET_ID

        break;
        case EXCHANGECREATECONTRACT:

            os_memmove((void *)fullContract, txContent.tokenNames[0], txContent.tokenNamesLength[0]+1);
            os_memmove((void *)toAddress, txContent.tokenNames[1], txContent.tokenNamesLength[1]+1);
            print_amount(txContent.amount[0],(void *)G_io_apdu_buffer,100, (strncmp((const char *)txContent.tokenNames[0], "TRX", 3)==0)?SUN_DIG:txContent.decimals[0]);
            print_amount(txContent.amount[1],(void *)G_io_apdu_buffer+100,100, (strncmp((const char *)txContent.tokenNames[1], "TRX", 3)==0)?SUN_DIG:txContent.decimals[1]);
            // write exchange contract type
            if (!setExchangeContractDetail(txContent.contractType, (void*)exchangeContractDetail)) THROW(0x6A80);

            #if defined(TARGET_BLUE)
                G_ui_approval_blue_state = APPROVAL_EXCHANGE_CREATE;
                ui_approval_exchange_create_blue_init();
            #elif defined(HAVE_UX_FLOW)
                ux_flow_init(0,
                    ((txContent.dataBytes>0)? ux_approval_exchange_create_data_warning_flow : ux_approval_exchange_create_flow),
                    NULL);
            #endif // #if TARGET_ID
        break;
        case EXCHANGEINJECTCONTRACT:
        case EXCHANGEWITHDRAWCONTRACT:

            os_memmove((void *)fullContract, txContent.tokenNames[0], txContent.tokenNamesLength[0]+1);
            print_amount(txContent.exchangeID,(void *)toAddress,sizeof(toAddress), 0);
            print_amount(txContent.amount[0],(void *)G_io_apdu_buffer,100, (strncmp((const char *)txContent.tokenNames[0], "TRX", 3)==0)?SUN_DIG:txContent.decimals[0]);
            // write exchange contract type
            if (!setExchangeContractDetail(txContent.contractType, (void*)exchangeContractDetail)) THROW(0x6A80);

            #if defined(TARGET_BLUE)
                G_ui_approval_blue_state = APPROVAL_EXCHANGE_WITHDRAW_INJECT;
                ui_approval_exchange_withdraw_inject_blue_init();
            #elif defined(HAVE_UX_FLOW)
                ux_flow_init(0,
                    ((txContent.dataBytes>0)? ux_approval_exchange_wi_data_warning_flow : ux_approval_exchange_wi_flow),
                    NULL);
            #endif // #if TARGET_ID
        break;
        case EXCHANGETRANSACTIONCONTRACT:
            //os_memmove((void *)fullContract, txContent.tokenNames[0], txContent.tokenNamesLength[0]+1);
            snprintf((char *)fullContract, sizeof(fullContract), "%s -> %s", txContent.tokenNames[0], txContent.tokenNames[1]);

            print_amount(txContent.exchangeID,(void *)toAddress,sizeof(toAddress), 0);
            print_amount(txContent.amount[0],(void *)G_io_apdu_buffer,100, txContent.decimals[0]);
            print_amount(txContent.amount[1],(void *)G_io_apdu_buffer+100,100, txContent.decimals[1]);
            // write exchange contract type
            if (!setExchangeContractDetail(txContent.contractType, (void*)exchangeContractDetail)) THROW(0x6A80);

            #if defined(TARGET_BLUE)
                G_ui_approval_blue_state = APPROVAL_EXCHANGE_TRANSACTION;
                ui_approval_exchange_transaction_blue_init();
            #elif defined(HAVE_UX_FLOW)
                ux_flow_init(0,
                    ((txContent.dataBytes>0)? ux_approval_exchange_transaction_data_warning_flow : ux_approval_exchange_transaction_flow),
                    NULL);
            #endif // #if TARGET_ID
        break;
        case VOTEWITNESSCONTRACT: {
            // vote for SR
            protocol_VoteWitnessContract *contract = &msg.vote_witness_contract;

            PRINTF("Voting!!\n");
            PRINTF("Count: %d\n", contract->votes_count);
            memset(G_io_apdu_buffer, 0, 200);
            txContent.amount[0] = 0;

            uint32_t total_votes = 0;

            for (int i = 0; i < contract->votes_count; i++) {
              getBase58FromAddress(contract->votes[i].vote_address,
                                   (uint8_t *)fullContract, &sha2, truncateAddress);

            #if defined(TARGET_BLUE)
                total_votes += (unsigned int)contract->votes[i].vote_count;
                fillVoteAddressSlot((void *)toAddress, (const char *)fullContract, 0);
                snprintf(
                    (char *)(G_io_apdu_buffer+(i*MAX_CHAR_PER_LINE)), MAX_CHAR_PER_LINE,"%s: %u",
                    toAddress,
                    (unsigned int)contract->votes[i].vote_count
                );
                int lineLength = strlen((const char *)(G_io_apdu_buffer+(i*MAX_CHAR_PER_LINE)));
                os_memset(
                    (char *)(G_io_apdu_buffer+(i*MAX_CHAR_PER_LINE)+lineLength)
                    , 0x20, MAX_CHAR_PER_LINE - lineLength);

                txContent.amount[0] += contract->votes[i].vote_count;
            #else
                fillVoteAddressSlot((void *)G_io_apdu_buffer, (const char *)fullContract, i);
                fillVoteAmountSlot((void *)G_io_apdu_buffer, contract->votes[i].vote_count, i);
            #endif
            }

            #if defined(TARGET_BLUE)
                snprintf(
                    (char *)fullContract, sizeof(fullContract),"%d: %u",
                    contract->votes_count,
                    (unsigned int)total_votes
                );
                G_ui_approval_blue_state = APPROVAL_WITNESSVOTE_TRANSACTION;
                ui_approval_witnessvote_transaction_blue_init();
            #elif defined(HAVE_UX_FLOW)
                int step = 0;
                int votes_count = contract->votes_count;
                ux_approval_vote_flow[step++] = &ux_approval_vote_flow_1_step;
                if (txContent.dataBytes>0) ux_approval_vote_flow[step++] = &ux_approval_tx_data_warning_step;

                if (votes_count-- > 0)
                    ux_approval_vote_flow[step++] = &ux_approval_vote_flow_2_step;
                if (votes_count-- > 0)
                    ux_approval_vote_flow[step++] = &ux_approval_vote_flow_3_step;
                if (votes_count-- > 0)
                    ux_approval_vote_flow[step++] = &ux_approval_vote_flow_4_step;
                if (votes_count-- > 0)
                    ux_approval_vote_flow[step++] = &ux_approval_vote_flow_5_step;
                if (votes_count-- > 0)
                    ux_approval_vote_flow[step++] = &ux_approval_vote_flow_6_step;

                ux_approval_vote_flow[step++] = &ux_approval_from_address_step;
                ux_approval_vote_flow[step++] = &ux_approval_confirm_step;
                ux_approval_vote_flow[step++] = &ux_approval_reject_step;
                ux_approval_vote_flow[step++] = FLOW_END_STEP;
                ux_flow_init(0, ux_approval_vote_flow, NULL);
            #endif // #if TARGET_ID
        }
        break;
        case FREEZEBALANCECONTRACT: // Freeze TRX
            if (txContent.resource == 0)
                os_memmove((void *)fullContract, "Bandwidth\0", 10);
            else os_memmove((void *)fullContract, "Energy\0", 7);

            print_amount(txContent.amount[0],(void *)G_io_apdu_buffer,0, SUN_DIG);
            if (strlen((const char *)txContent.destination)>0) {
                getBase58FromAddress(txContent.destination,
                    (uint8_t *)toAddress, &sha2, truncateAddress);
            } else {
                getBase58FromAddress(txContent.account,
                    (uint8_t *)toAddress, &sha2, truncateAddress);
            }

            #if defined(TARGET_BLUE)
                G_ui_approval_blue_state = APPROVAL_FREEZEASSET_TRANSACTION;
                ui_approval_freeze_transaction_blue_init();
            #elif defined(HAVE_UX_FLOW)
                ux_flow_init(0,
                     ((txContent.dataBytes>0)? ux_approval_freeze_data_warning_flow : ux_approval_freeze_flow),
                     NULL);
            #endif // #if TARGET_ID
        break;
        case UNFREEZEBALANCECONTRACT: // unreeze TRX
            if (txContent.resource == 0)
                os_memmove((void *)fullContract, "Bandwidth\0", 10);
            else os_memmove((void *)fullContract, "Energy\0", 7);

            if (strlen((const char *)txContent.destination)>0) {
                getBase58FromAddress(txContent.destination,
                    (uint8_t *)toAddress, &sha2, truncateAddress);
            } else {
                getBase58FromAddress(txContent.account,
                    (uint8_t *)toAddress, &sha2, truncateAddress);
            }

            #if defined(TARGET_BLUE)
                G_ui_approval_blue_state = APPROVAL_UNFREEZEASSET_TRANSACTION;
                ui_approval_unfreeze_transaction_blue_init();
            #elif defined(HAVE_UX_FLOW)
                ux_flow_init(0,
                     ((txContent.dataBytes>0)? ux_approval_unfreeze_data_warning_flow : ux_approval_unfreeze_flow),
                     NULL);
            #endif // #if TARGET_ID
        break;
        case WITHDRAWBALANCECONTRACT: // Claim Rewards
            getBase58FromAddress(txContent.account,
                (uint8_t *)toAddress, &sha2, truncateAddress);

            #if defined(TARGET_BLUE)
                G_ui_approval_blue_state = APPROVAL_WITHDRAWBALANCE_TRANSACTION;
                ui_approval_withdraw_balance_transaction_blue_init();
            #elif defined(HAVE_UX_FLOW)
                ux_flow_init(0,
                     ((txContent.dataBytes>0)? ux_approval_withdraw_balance_data_warning_flow : ux_approval_withdraw_balance_flow),
                     NULL);
            #endif // #if TARGET_ID
        break;
        case ACCOUNTPERMISSIONUPDATECONTRACT:
            // Write fullHash
            array_hexstr((char *)fullHash, transactionContext.hash, 32);
            // write contract type
            if (!setContractType(txContent.contractType, (void*)fullContract)) THROW(0x6A80);
            #if defined(TARGET_BLUE)
                G_ui_approval_blue_state = APPROVAL_TRANSACTION;
                ui_approval_simple_transaction_blue_init();
            #elif defined(HAVE_UX_FLOW)
                ux_flow_init(0,
                    ((txContent.dataBytes>0)?
                      ux_approval_account_permission_update_data_warning_flow :
                      ux_approval_account_permission_update_flow),
                    NULL);
            #endif // #if TARGET_ID
        break;
        case INVALID_CONTRACT:
            THROW(0x6B00); // Contract not initialized
        break;
        default:
            // Write fullHash
            array_hexstr((char *)fullHash, transactionContext.hash, 32);
            // write contract type
            if (!setContractType(txContent.contractType, (void*)fullContract)) THROW(0x6A80);

            #if defined(TARGET_BLUE)
                G_ui_approval_blue_state = APPROVAL_TRANSACTION;
                ui_approval_simple_transaction_blue_init();
            #elif defined(HAVE_UX_FLOW)
                ux_flow_init(0,
                    ((txContent.dataBytes>0)? ux_approval_st_data_warning_flow : ux_approval_st_flow),
                    NULL);
            #endif // #if TARGET_ID
        break;
    }

    *flags |= IO_ASYNCH_REPLY;
}

// // APDU App Config and Version
void handleGetAppConfiguration(uint8_t p1, uint8_t p2, uint8_t *workBuffer,
                               uint16_t dataLength,
                               volatile unsigned int *flags,
                               volatile unsigned int *tx) {
    //Clear buffer
    UNUSED(p1);
    UNUSED(p2);
    UNUSED(workBuffer);
    UNUSED(dataLength);
    UNUSED(flags);
    //Add info to buffer
    G_io_apdu_buffer[0] = 0x00;
    G_io_apdu_buffer[0] |= (N_storage.dataAllowed<<0);
    G_io_apdu_buffer[0] |= (N_storage.customContract<<1);
    G_io_apdu_buffer[0] |= (N_storage.truncateAddress<<2);
    G_io_apdu_buffer[1] = LEDGER_MAJOR_VERSION;
    G_io_apdu_buffer[2] = LEDGER_MINOR_VERSION;
    G_io_apdu_buffer[3] = LEDGER_PATCH_VERSION;
    *tx = 4;        // Set return size
    THROW(0x9000);  //Return OK
}

// APDU Sign
void handleECDHSecret(uint8_t p1, uint8_t p2, uint8_t *workBuffer,
                uint16_t dataLength, volatile unsigned int *flags,
                volatile unsigned int *tx) {

    UNUSED(tx);
    uint8_t privateKeyData[32];
    cx_ecfp_private_key_t privateKey;

    if ((p1 != 0x00) || (p2 != 0x01) ) {
            THROW(0x6B00);
    }

    off_t ret = read_bip32_path(workBuffer, dataLength, &transactionContext.bip32_path);
    if (ret < 0) {
        THROW(0x6a80);
    }
    workBuffer += ret;
    dataLength -= ret;
    if (dataLength != 65) {
        PRINTF("Public key length error!");
        THROW(0x6700);
    }

    // Load raw Data
    os_memmove(transactionContext.signature, workBuffer, dataLength);

    // Get private key
    os_perso_derive_node_bip32(CX_CURVE_256K1, transactionContext.bip32_path.indices,
            transactionContext.bip32_path.length, privateKeyData, NULL);

    cx_ecfp_init_private_key(CX_CURVE_256K1, privateKeyData, 32, &privateKey);
    cx_ecfp_generate_pair(CX_CURVE_256K1, &publicKeyContext.publicKey,
                          &privateKey, 1);

    // Clear tmp buffer data
    os_memset(&privateKey, 0, sizeof(privateKey));
    os_memset(privateKeyData, 0, sizeof(privateKeyData));

    // Get address from PK
    getAddressFromKey(&publicKeyContext.publicKey, publicKeyContext.address);
    // Get Base58
    getBase58FromAddress(publicKeyContext.address,
                                (uint8_t *)fromAddress, &sha2, false);

    // Get address from PK
    getAddressFromPublicKey(transactionContext.signature, publicKeyContext.address);
    // Get Base58
    getBase58FromAddress(publicKeyContext.address, (uint8_t *)toAddress,
                         &sha2, false);

    #if defined(TARGET_BLUE)
        UX_DISPLAY(ui_approval_pgp_ecdh_blue, NULL);
    #elif defined(HAVE_UX_FLOW)
        // reserve a display stack slot if none yet
        if(G_ux.stack_count == 0) {
            ux_stack_push();
        }
        ux_flow_init(0, ux_approval_pgp_ecdh_flow, NULL);
    #endif
    *flags |= IO_ASYNCH_REPLY;

}

void handleSignPersonalMessage(uint8_t p1, uint8_t p2, uint8_t *workBuffer, uint16_t dataLength, volatile unsigned int *flags, volatile unsigned int *tx) {
  UNUSED(tx);
  uint8_t privateKeyData[32];
  cx_ecfp_private_key_t privateKey;
  cx_sha3_t sha3;

    if ((p1 == P1_FIRST) || (p1 == P1_SIGN)) {
        off_t ret = read_bip32_path(workBuffer, dataLength, &transactionContext.bip32_path);
        if (ret < 0) {
          THROW(0x6a80);
        }
        workBuffer += ret;
        dataLength -= ret;

        // Message Length
        txContent.dataBytes = U4BE(workBuffer, 0);
        workBuffer += 4;
        dataLength -= 4;

        // Initialize message header + length
        cx_keccak_init(&sha3, 256);
        cx_hash((cx_hash_t *)&sha3, 0, (const uint8_t *)SIGN_MAGIC,
                sizeof(SIGN_MAGIC) - 1, NULL, 32);

        char tmp[11];
        snprintf((char *)tmp, 11,"%d",(uint32_t)txContent.dataBytes);
        cx_hash((cx_hash_t *)&sha3, 0, (const uint8_t *)tmp, strlen(tmp), NULL,32);

    } else if (p1 != P1_MORE) {
        THROW(0x6B00);
    }

    if (p2 != 0) {
        THROW(0x6B00);
    }
    if (dataLength > txContent.dataBytes) {
        THROW(0x6A80);
    }

    cx_hash((cx_hash_t *)&sha3, 0, workBuffer, dataLength, NULL,32);
    txContent.dataBytes -= dataLength;
    if (txContent.dataBytes == 0) {
        cx_hash((cx_hash_t *)&sha3, CX_LAST, workBuffer, 0, transactionContext.hash,32);

        #define HASH_LENGTH 4
        array_hexstr((char *)fullContract, transactionContext.hash, HASH_LENGTH / 2);
        fullContract[HASH_LENGTH / 2 * 2] = '.';
        fullContract[HASH_LENGTH / 2 * 2 + 1] = '.';
        fullContract[HASH_LENGTH / 2 * 2 + 2] = '.';
        array_hexstr((char *)fullContract + HASH_LENGTH / 2 * 2 + 3, transactionContext.hash + 32 - HASH_LENGTH / 2, HASH_LENGTH / 2);

        // Get private key
        os_perso_derive_node_bip32(CX_CURVE_256K1, transactionContext.bip32_path.indices,
                transactionContext.bip32_path.length, privateKeyData, NULL);

        cx_ecfp_init_private_key(CX_CURVE_256K1, privateKeyData, 32, &privateKey);
        cx_ecfp_generate_pair(CX_CURVE_256K1, &publicKeyContext.publicKey,
                            &privateKey, 1);

        // Clear tmp buffer data
        os_memset(&privateKey, 0, sizeof(privateKey));
        os_memset(privateKeyData, 0, sizeof(privateKeyData));

        // Get address from PK
        getAddressFromKey(&publicKeyContext.publicKey,
                          publicKeyContext.address);
        // Get Base58
        getBase58FromAddress(publicKeyContext.address,
                                    (uint8_t *)fromAddress, &sha2, false);

        fromAddress[BASE58CHECK_ADDRESS_SIZE]='\0';

        #if defined(TARGET_BLUE)
            G_ui_approval_blue_state = APPROVAL_SIGN_PERSONAL_MESSAGE;
            ui_approval_message_sign_blue_init();
        #elif defined(HAVE_UX_FLOW)
            ux_flow_init(0, ux_sign_flow, NULL);
        #endif

        *flags |= IO_ASYNCH_REPLY;

    } else {
        THROW(0x9000);
    }
}

// Check ADPU and process the assigned task
void handleApdu(volatile unsigned int *flags, volatile unsigned int *tx) {
    unsigned short sw = 0;

    BEGIN_TRY {
        TRY {
            if (G_io_apdu_buffer[OFFSET_CLA] != CLA) {
                THROW(0x6E00);
            }

            switch (G_io_apdu_buffer[OFFSET_INS]) {
            case INS_GET_PUBLIC_KEY:
                // Request Publick Key
                handleGetPublicKey(G_io_apdu_buffer[OFFSET_P1],
                    G_io_apdu_buffer[OFFSET_P2],
                    G_io_apdu_buffer + OFFSET_CDATA,
                    G_io_apdu_buffer[OFFSET_LC],
                    flags, tx);
                break;

            case INS_SIGN:
                // Request Signature
                handleSign(G_io_apdu_buffer[OFFSET_P1],
                    G_io_apdu_buffer[OFFSET_P2],
                    G_io_apdu_buffer + OFFSET_CDATA,
                    G_io_apdu_buffer[OFFSET_LC],
                    flags, tx);
                break;

            case INS_GET_APP_CONFIGURATION:
                // Request App configuration
                handleGetAppConfiguration(
                    G_io_apdu_buffer[OFFSET_P1], G_io_apdu_buffer[OFFSET_P2],
                    G_io_apdu_buffer + OFFSET_CDATA,
                    G_io_apdu_buffer[OFFSET_LC],
                    flags, tx);
                break;

            case INS_GET_ECDH_SECRET:
                // Request Signature
                handleECDHSecret(G_io_apdu_buffer[OFFSET_P1],
                    G_io_apdu_buffer[OFFSET_P2],
                    G_io_apdu_buffer + OFFSET_CDATA,
                    G_io_apdu_buffer[OFFSET_LC],
                    flags, tx);
                break;

            case INS_SIGN_PERSONAL_MESSAGE:
                handleSignPersonalMessage(
                    G_io_apdu_buffer[OFFSET_P1],
                    G_io_apdu_buffer[OFFSET_P2],
                    G_io_apdu_buffer + OFFSET_CDATA,
                    G_io_apdu_buffer[OFFSET_LC],
                    flags, tx);
                break;

            default:
                THROW(0x6D00);
                break;
            }
        }
        CATCH(EXCEPTION_IO_RESET) {
                THROW(EXCEPTION_IO_RESET);
        }
        CATCH_OTHER(e) {
            switch (e & 0xF000) {
            case 0x6000:
                // Wipe the transaction context and report the exception
                sw = e;
                os_memset(&txContent, 0, sizeof(txContent));
                break;
            case 0x9000:
                // All is well
                sw = e;
                break;
            default:
                // Internal error
                sw = 0x6800 | (e & 0x7FF);
                break;
            }
            // Unexpected exception => report
            G_io_apdu_buffer[*tx] = sw >> 8;
            G_io_apdu_buffer[*tx + 1] = sw;
            *tx += 2;
        }
        FINALLY {
        }
    }
    END_TRY;
}

#include "usbd_core.h"

// App main loop
void tron_main(void) {
    volatile unsigned int rx = 0;
    volatile unsigned int tx = 0;
    volatile unsigned int flags = 0;

    USBD_Device.dev_state = USBD_STATE_CONFIGURED;

    // DESIGN NOTE: the bootloader ignores the way APDU are fetched. The only
    // goal is to retrieve APDU.
    // When APDU are to be fetched from multiple IOs, like NFC+USB+BLE, make
    // sure the io_event is called with a
    // switch event, before the apdu is replied to the bootloader. This avoid
    // APDU injection faults.
    for (;;) {
        volatile unsigned short sw = 0;

        BEGIN_TRY {
            TRY {
                rx = tx;
                tx = 0; // ensure no race in catch_other if io_exchange throws
                        // an error
                rx = io_exchange(CHANNEL_APDU | flags, rx);
                flags = 0;

                // no apdu received, well, reset the session, and reset the
                // bootloader configuration
                if (rx == 0) {
                    THROW(0x6982);
                }

                handleApdu(&flags, &tx);
            }
            CATCH(EXCEPTION_IO_RESET) {
                THROW(EXCEPTION_IO_RESET);
            }
            CATCH_OTHER(e) {
                switch (e & 0xF000) {
                case 0x6000:
                    // Wipe the transaction context and report the exception
                    sw = e;
                    os_memset(&txContent, 0, sizeof(txContent));
                    break;
                case 0x9000:
                    // All is well
                    sw = e;
                    break;
                default:
                    // Internal error
                    sw = 0x6800 | (e & 0x7FF);
                    break;
                }
                // Unexpected exception => report
                G_io_apdu_buffer[tx] = sw >> 8;
                G_io_apdu_buffer[tx + 1] = sw;
                tx += 2;
            }
            FINALLY {
            }
        }
        END_TRY;
    }

    // return_to_dashboard:
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
}

unsigned char io_event(unsigned char channel) {
    // nothing done with the event, throw an error on the transport layer if
    // needed

    // can't have more than one tag in the reply, not supported yet.
    switch (G_io_seproxyhal_spi_buffer[0]) {
    case SEPROXYHAL_TAG_FINGER_EVENT:
        UX_FINGER_EVENT(G_io_seproxyhal_spi_buffer);
        break;

    case SEPROXYHAL_TAG_BUTTON_PUSH_EVENT:
        UX_BUTTON_PUSH_EVENT(G_io_seproxyhal_spi_buffer);
        break;

    case SEPROXYHAL_TAG_STATUS_EVENT:
        if (G_io_apdu_media == IO_APDU_MEDIA_USB_HID &&
            !(U4BE(G_io_seproxyhal_spi_buffer, 3) &
              SEPROXYHAL_TAG_STATUS_EVENT_FLAG_USB_POWERED)) {
            THROW(EXCEPTION_IO_RESET);
        }
    // no break is intentional
    default:
        UX_DEFAULT_EVENT();
        break;

    case SEPROXYHAL_TAG_DISPLAY_PROCESSED_EVENT:
        UX_DISPLAYED_EVENT({});
        break;

    case SEPROXYHAL_TAG_TICKER_EVENT:
        UX_TICKER_EVENT(G_io_seproxyhal_spi_buffer,{});
        break;
    }

    // close the event if not done previously (by a display or whatever)
    if (!io_seproxyhal_spi_is_status_sent()) {
        io_seproxyhal_general_status();
    }

    // command has been processed, DO NOT reset the current APDU transport
    return 1;
}


// Exit application
void app_exit(void) {
    BEGIN_TRY_L(exit) {
        TRY_L(exit) {
            os_sched_exit(-1);
        }
        FINALLY_L(exit) {
        }
    }
    END_TRY_L(exit);
}

// App boot loop
__attribute__((section(".boot"))) int main(void) {
    // exit critical section
    __asm volatile("cpsie i");

    // ensure exception will work as planned
    os_boot();

    for (;;) {
        os_memset(&txContent, 0, sizeof(txContent));

        UX_INIT();
        BEGIN_TRY {
            TRY {
                io_seproxyhal_init();
                #ifdef TARGET_NANOX
                // grab the current plane mode setting
                G_io_app.plane_mode = os_setting_get(OS_SETTING_PLANEMODE, NULL, 0);
                #endif // TARGET_NANOX

                if (N_storage.initialized != 0x01) {
                  internalStorage_t storage;
                  storage.dataAllowed = 0x00;
                  storage.customContract = 0x00;
                  storage.truncateAddress = 0x00;
                  storage.initialized = 0x01;
                  nvm_write((void*)&N_storage, (void*)&storage, sizeof(internalStorage_t));
                }
                dataAllowed = N_storage.dataAllowed;
                customContract = N_storage.customContract;
                truncateAddress = N_storage.truncateAddress;

                USB_power(1);
                ui_idle();

                //Call Tron main Loop
                tron_main();
            }
            CATCH(EXCEPTION_IO_RESET) {
                // reset IO and UX
                continue;
            }
            CATCH_ALL {
                break;
            }
            FINALLY {
            }
        }
        END_TRY;
    }
    app_exit();

    return 0;
}
