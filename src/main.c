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
#include "helpers.h"

#include "os_io_seproxyhal.h"
#include "string.h"

#include "glyphs.h"
#define TARGET_NANOS 1
#define HAVE_U2F 1

#ifdef HAVE_U2F

#include "u2f_service.h"
#include "u2f_transport.h"

#include "parse.h"

volatile unsigned char u2fMessageBuffer[U2F_MAX_MESSAGE_SIZE];

extern void USB_power_U2F(unsigned char enabled, unsigned char fido);
extern bool fidoActivated;

#endif

bagl_element_t tmp_element;
unsigned char G_io_seproxyhal_spi_buffer[IO_SEPROXYHAL_BUFFER_SIZE_B];

uint32_t set_result_get_publicKey(void);


// Define command events
#define CLA 0x27                        // Start byte for any communications    
#define INS_GET_PUBLIC_KEY 0x02
#define INS_SIGN 0x04
#define INS_GET_APP_CONFIGURATION 0x06  // Get Configuration
#define P1_CONFIRM 0x01
#define P1_NON_CONFIRM 0x00
#define P2_NO_CHAINCODE 0x00
#define P2_CHAINCODE 0x01
#define P1_FIRST 0x00
#define P1_MORE 0x80

#define OFFSET_CLA 0
#define OFFSET_INS 1
#define OFFSET_P1 2
#define OFFSET_P2 3
#define OFFSET_LC 4
#define OFFSET_CDATA 5


static const uint8_t const SIGN_PREFIX[] = {0x53, 0x54, 0x58, 0x00};



union {
    publicKeyContext_t publicKeyContext;
    transactionContext_t transactionContext;
} tmpCtx;
txContent_t txContent;

cx_sha3_t sha3;
cx_sha256_t sha2;
volatile char addressSummary[ADDRESS_SIZE+1];
volatile char fullAddress[BASE58CHECK_ADDRESS_SIZE+1]; 
volatile char fullAmount[50]; 
volatile char maxBandwidth[50];   
volatile bool dataPresent;

bagl_element_t tmp_element;

#ifdef HAVE_U2F

volatile u2f_service_t u2fService;

#endif

unsigned int io_seproxyhal_touch_settings(const bagl_element_t *e);
unsigned int io_seproxyhal_touch_exit(const bagl_element_t *e);
unsigned int io_seproxyhal_touch_tx_ok(const bagl_element_t *e);
unsigned int io_seproxyhal_touch_tx_cancel(const bagl_element_t *e);
unsigned int io_seproxyhal_touch_address_ok(const bagl_element_t *e);
unsigned int io_seproxyhal_touch_address_cancel(const bagl_element_t *e);
void ui_idle(void);
ux_state_t ux;
// display stepped screens
unsigned int ux_step;
unsigned int ux_step_count;

typedef struct internalStorage_t {
    uint8_t fidoTransport;
    uint8_t initialized;
} internalStorage_t;

WIDE internalStorage_t N_storage_real;
#define N_storage (*(WIDE internalStorage_t *)PIC(&N_storage_real))

#ifdef HAVE_U2F

void u2f_proxy_response(u2f_service_t *service, unsigned int tx) {
    os_memset(service->messageBuffer, 0, 5);
    os_memmove(service->messageBuffer + 5, G_io_apdu_buffer, tx);
    service->messageBuffer[tx + 5] = 0x90;
    service->messageBuffer[tx + 6] = 0x00;
    u2f_send_fragmented_response(service, U2F_CMD_MSG, service->messageBuffer,
                                 tx + 7, true);
}

#endif

const bagl_element_t *ui_menu_item_out_over(const bagl_element_t *e) {
    // the selection rectangle is after the none|touchable
    e = (const bagl_element_t *)(((unsigned int)e) + sizeof(bagl_element_t));
    return e;
}

#define BAGL_FONT_OPEN_SANS_LIGHT_16_22PX_AVG_WIDTH 10
#define BAGL_FONT_OPEN_SANS_REGULAR_10_13PX_AVG_WIDTH 8
#define MAX_CHAR_PER_LINE 25


#if defined(TARGET_NANOS)

const ux_menu_entry_t menu_main[];
const ux_menu_entry_t menu_settings[];
const ux_menu_entry_t menu_settings_browser[];

// change the setting
void menu_settings_browser_change(unsigned int enabled) {
    uint8_t fidoTransport = enabled;
    nvm_write(&N_storage.fidoTransport, (void *)&fidoTransport,
              sizeof(uint8_t));
    USB_power_U2F(0, 0);
    USB_power_U2F(1, N_storage.fidoTransport);
    // go back to the menu entry
    UX_MENU_DISPLAY(1, menu_settings, NULL);
}

// show the currently activated entry
void menu_settings_browser_init(unsigned int ignored) {
    UNUSED(ignored);
    UX_MENU_DISPLAY(N_storage.fidoTransport ? 1 : 0, menu_settings_browser,
                    NULL);
}

// Menu Entry Yes/No
const ux_menu_entry_t menu_settings_browser[] = {
    {NULL, menu_settings_browser_change, 0, NULL, "No", NULL, 0, 0},
    {NULL, menu_settings_browser_change, 1, NULL, "Yes", NULL, 0, 0},
    UX_MENU_END};

// Menu Settings
const ux_menu_entry_t menu_settings[] = {
    {NULL, menu_settings_browser_init, 0, NULL, "Browser support", NULL, 0, 0},
    {menu_main, NULL, 1, &C_icon_back, "Back", NULL, 61, 40},
    UX_MENU_END};

// Menu About
const ux_menu_entry_t menu_about[] = {
    {NULL, NULL, 0, NULL, "Version", APPVERSION, 0, 0},
    {menu_main, NULL, 2, &C_icon_back, "Back", NULL, 61, 40},
    UX_MENU_END};

// Main menu
const ux_menu_entry_t menu_main[] = {
    {NULL, NULL, 0, &C_icon, "Use wallet to", "view accounts", 33, 12},
    {menu_settings, NULL, 0, NULL, "Settings", NULL, 0, 0},
    {menu_about, NULL, 0, NULL, "About", NULL, 0, 0},
    {NULL, os_sched_exit, 0, &C_icon_dashboard, "Quit app", NULL, 50, 29},
    UX_MENU_END};

#endif // #if TARGET_NANOS



#if defined(TARGET_NANOS)
const bagl_element_t ui_address_nanos[] = {
    // type                               userid    x    y   w    h  str rad
    // fill      fg        bg      fid iid  txt   touchparams...       ]
    {{BAGL_RECTANGLE, 0x00, 0, 0, 128, 32, 0, 0, BAGL_FILL, 0x000000, 0xFFFFFF,
      0, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_ICON, 0x00, 3, 12, 7, 7, 0, 0, 0, 0xFFFFFF, 0x000000, 0,
      BAGL_GLYPH_ICON_CROSS},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_ICON, 0x00, 117, 13, 8, 6, 0, 0, 0, 0xFFFFFF, 0x000000, 0,
      BAGL_GLYPH_ICON_CHECK},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    //{{BAGL_ICON                           , 0x01,  31,   9,  14,  14, 0, 0, 0
    //, 0xFFFFFF, 0x000000, 0, BAGL_GLYPH_ICON_EYE_BADGE  }, NULL, 0, 0, 0,
    // NULL, NULL, NULL },
    {{BAGL_LABELINE, 0x01, 0, 12, 128, 32, 0, 0, 0, 0xFFFFFF, 0x000000,
      BAGL_FONT_OPEN_SANS_EXTRABOLD_11px | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "Confirm",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x01, 0, 26, 128, 32, 0, 0, 0, 0xFFFFFF, 0x000000,
      BAGL_FONT_OPEN_SANS_EXTRABOLD_11px | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "address",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x02, 0, 12, 128, 32, 0, 0, 0, 0xFFFFFF, 0x000000,
      BAGL_FONT_OPEN_SANS_REGULAR_11px | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "Address",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x02, 23, 26, 82, 12, 0x80 | 10, 0, 0, 0xFFFFFF, 0x000000,
      BAGL_FONT_OPEN_SANS_EXTRABOLD_11px | BAGL_FONT_ALIGNMENT_CENTER, 26},
     (char *)fullAddress,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
};

unsigned int ui_address_prepro(const bagl_element_t *element) {
    if (element->component.userid > 0) {
        unsigned int display = (ux_step == element->component.userid - 1);
        if (display) {
            switch (element->component.userid) {
            case 1:
                UX_CALLBACK_SET_INTERVAL(2000);
                break;
            case 2:
                UX_CALLBACK_SET_INTERVAL(MAX(
                    3000, 1000 + bagl_label_roundtrip_duration_ms(element, 7)));
                break;
            }
        }
        return display;
    }
    return 1;
}

unsigned int ui_address_nanos_button(unsigned int button_mask,
                                     unsigned int button_mask_counter);
#endif // #if defined(TARGET_NANOS)


#if defined(TARGET_NANOS)
// Show transactions details for approval
const char *const ui_approval_details[][2] = {
    {"Amount", fullAmount}, {"Address", addressSummary},
    {"Bandwidth", maxBandwidth},
};
const bagl_element_t ui_approval_nanos[] = {
    // type                               userid    x    y   w    h  str rad
    // fill      fg        bg      fid iid  txt   touchparams...       ]
    {{BAGL_RECTANGLE, 0x00, 0, 0, 128, 32, 0, 0, BAGL_FILL, 0x000000, 0xFFFFFF,
      0, 0},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_ICON, 0x00, 3, 12, 7, 7, 0, 0, 0, 0xFFFFFF, 0x000000, 0,
      BAGL_GLYPH_ICON_CROSS},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_ICON, 0x00, 117, 13, 8, 6, 0, 0, 0, 0xFFFFFF, 0x000000, 0,
      BAGL_GLYPH_ICON_CHECK},
     NULL,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    //{{BAGL_ICON                           , 0x01,  21,   9,  14,  14, 0, 0, 0
    //, 0xFFFFFF, 0x000000, 0, BAGL_GLYPH_ICON_TRANSACTION_BADGE  }, NULL, 0, 0,
    // 0, NULL, NULL, NULL },
    {{BAGL_LABELINE, 0x01, 0, 12, 128, 32, 0, 0, 0, 0xFFFFFF, 0x000000,
      BAGL_FONT_OPEN_SANS_EXTRABOLD_11px | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "Confirm",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x01, 0, 26, 128, 32, 0, 0, 0, 0xFFFFFF, 0x000000,
      BAGL_FONT_OPEN_SANS_EXTRABOLD_11px | BAGL_FONT_ALIGNMENT_CENTER, 0},
     "transaction",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

    {{BAGL_LABELINE, 0x02, 0, 12, 128, 32, 0, 0, 0, 0xFFFFFF, 0x000000,
      BAGL_FONT_OPEN_SANS_REGULAR_11px | BAGL_FONT_ALIGNMENT_CENTER, 0},
     NULL, //"Amount",
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},
    {{BAGL_LABELINE, 0x12, 23, 26, 82, 12, 0x80 | 10, 0, 0, 0xFFFFFF, 0x000000,
      BAGL_FONT_OPEN_SANS_EXTRABOLD_11px | BAGL_FONT_ALIGNMENT_CENTER, 26},
     NULL, //(char *)fullAmount,
     0,
     0,
     0,
     NULL,
     NULL,
     NULL},

};

/*
 ux_step 0: confirm
         1: amount
         2: address
         3: [sourcetag]
         4: [destinationtag]
         5: fees
*/
unsigned int ui_approval_prepro(const bagl_element_t *element) {
    unsigned int display = 1;
    if (element->component.userid > 0) {
        // display the meta element when at least bigger
        display = (ux_step == element->component.userid - 1) ||
                  (element->component.userid >= 0x02 && ux_step >= 1);
        if (display) {
            switch (element->component.userid) {
            case 0x01:
                UX_CALLBACK_SET_INTERVAL(2000);
                break;
            case 0x02:
            case 0x12:
                os_memmove(&tmp_element, element, sizeof(bagl_element_t));
                display = ux_step - 1;
                switch (display) {
                case 0: // amount
                case 1: // address
                display_detail:
                    tmp_element.text =
                        ui_approval_details[display]
                                           [(element->component.userid) >> 4];
                    break;
                case 2: // fees
                    display = 3;
                    goto display_detail;
                }

                UX_CALLBACK_SET_INTERVAL(MAX(
                    3000,
                    1000 + bagl_label_roundtrip_duration_ms(&tmp_element, 7)));
                return &tmp_element;
            }
        }
    }
    return display;
}

unsigned int ui_approval_nanos_button(unsigned int button_mask,
                                      unsigned int button_mask_counter);

#endif // #if defined(TARGET_NANOS)

void ui_idle(void) {
#if defined(TARGET_NANOS)
    UX_MENU_DISPLAY(0, menu_main, NULL);
#endif // #if TARGET_ID
}

unsigned int io_seproxyhal_touch_exit(const bagl_element_t *e) {
    // Go back to the dashboard
    os_sched_exit(0);
    return 0; // do not redraw the widget
}

unsigned int io_seproxyhal_touch_address_ok(const bagl_element_t *e) {
    uint32_t tx = set_result_get_publicKey();
    G_io_apdu_buffer[tx++] = 0x90;
    G_io_apdu_buffer[tx++] = 0x00;
#ifdef HAVE_U2F
    if (fidoActivated) {
        u2f_proxy_response((u2f_service_t *)&u2fService, tx);
    } else {
        // Send back the response, do not restart the event loop
        io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, tx);
    }
#else  // HAVE_U2F
    // Send back the response, do not restart the event loop
    io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, tx);
#endif // HAVE_U2F
    // Display back the original UX
    ui_idle();
    return 0; // do not redraw the widget
}

unsigned int io_seproxyhal_touch_address_cancel(const bagl_element_t *e) {
    G_io_apdu_buffer[0] = 0x69;
    G_io_apdu_buffer[1] = 0x85;
#ifdef HAVE_U2F
    if (fidoActivated) {
        u2f_proxy_response((u2f_service_t *)&u2fService, 2);
    } else {
        // Send back the response, do not restart the event loop
        io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, 2);
    }
#else  // HAVE_U2F
    // Send back the response, do not restart the event loop
    io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, 2);
#endif // HAVE_U2F
    // Display back the original UX
    ui_idle();
    return 0; // do not redraw the widget
}

#if defined(TARGET_NANOS)
unsigned int ui_address_nanos_button(unsigned int button_mask,
                                     unsigned int button_mask_counter) {
    switch (button_mask) {
    case BUTTON_EVT_RELEASED | BUTTON_LEFT: // CANCEL
        io_seproxyhal_touch_address_cancel(NULL);
        break;

    case BUTTON_EVT_RELEASED | BUTTON_RIGHT: { // OK
        io_seproxyhal_touch_address_ok(NULL);
        break;
    }
    }
    return 0;
}
#endif // #if defined(TARGET_NANOS)

unsigned int io_seproxyhal_touch_tx_ok(const bagl_element_t *e) {
    
    // Todo send transaction

    return 0; // do not redraw the widget
}

unsigned int io_seproxyhal_touch_tx_cancel(const bagl_element_t *e) {
    G_io_apdu_buffer[0] = 0x69;
    G_io_apdu_buffer[1] = 0x85;
#ifdef HAVE_U2F
    if (fidoActivated) {
        u2f_proxy_response((u2f_service_t *)&u2fService, 2);
    } else {
        // Send back the response, do not restart the event loop
        io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, 2);
    }
#else  // HAVE_U2F
    // Send back the response, do not restart the event loop
    io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, 2);
#endif // HAVE_U2F
    // Display back the original UX
    ui_idle();
    return 0; // do not redraw the widget
}

#if defined(TARGET_NANOS)

unsigned int ui_approval_nanos_button(unsigned int button_mask,
                                      unsigned int button_mask_counter) {
    switch (button_mask) {
    case BUTTON_EVT_RELEASED | BUTTON_LEFT:
        io_seproxyhal_touch_tx_cancel(NULL);
        break;

    case BUTTON_EVT_RELEASED | BUTTON_RIGHT: {
        io_seproxyhal_touch_tx_ok(NULL);
        break;
    }
    }
    return 0;
}

#endif // #if defined(TARGET_NANOS)

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
    os_memmove(G_io_apdu_buffer + tx, tmpCtx.publicKeyContext.publicKey.W, 65);
    tx += 65;
    G_io_apdu_buffer[tx++] = addressLength;
    os_memmove(G_io_apdu_buffer + tx, tmpCtx.publicKeyContext.address58,
               addressLength);
    tx += addressLength;
    return tx;
}

// APDU public key
void handleGetPublicKey(uint8_t p1, uint8_t p2, uint8_t *dataBuffer,
                        uint16_t dataLength, volatile unsigned int *flags,
                        volatile unsigned int *tx) {
    //Clear Buffer                        
    UNUSED(dataLength);
    // Get private key data
    uint8_t privateKeyData[33];
    uint32_t bip32Path[MAX_BIP32_PATH];  
    uint32_t i;
    uint8_t bip32PathLength = *(dataBuffer++);
    cx_ecfp_private_key_t privateKey;
    
    uint8_t p2Chain = p2 & 0x3F;   
    uint8_t addressLength;

    uint8_t address58[BASE58CHECK_ADDRESS_SIZE];


    if ((bip32PathLength < 0x01) || (bip32PathLength > MAX_BIP32_PATH)) {
        PRINTF("Invalid path\n");
        THROW(0x6a80);
    }
    if ((p1 != P1_CONFIRM) && (p1 != P1_NON_CONFIRM)) {
        THROW(0x6B00);
    }
    if ((p2Chain != P2_CHAINCODE) && (p2Chain != P2_NO_CHAINCODE)) {
        THROW(0x6B00);
    }

    // Add requested BIP path to tmp array
    for (i = 0; i < bip32PathLength; i++) {
        bip32Path[i] = (dataBuffer[0] << 24) | (dataBuffer[1] << 16) |
                       (dataBuffer[2] << 8) | (dataBuffer[3]);
        dataBuffer += 4;
    }
    
    // Get private key
    os_perso_derive_node_bip32(CX_CURVE_256K1, bip32Path, bip32PathLength,
                               privateKeyData, NULL);

    cx_ecfp_init_private_key(CX_CURVE_256K1, privateKeyData, 32, &privateKey);
    cx_ecfp_generate_pair(CX_CURVE_256K1, &tmpCtx.publicKeyContext.publicKey,
                          &privateKey, 1);

    // Clear tmp buffer data
    os_memset(&privateKey, 0, sizeof(privateKey));
    os_memset(privateKeyData, 0, sizeof(privateKeyData));

    // Get address from PK
    getAddressFromKey(&tmpCtx.publicKeyContext.publicKey,
                                tmpCtx.publicKeyContext.address,&sha3);
                                
    // Get Base58
    getBase58FromAddres(tmpCtx.publicKeyContext.address,
                                tmpCtx.publicKeyContext.address58, &sha2);
    
    os_memmove(fullAddress,tmpCtx.publicKeyContext.address58,BASE58CHECK_ADDRESS_SIZE);    
  
    if (p1 == P1_NON_CONFIRM) {
        //os_memmove(G_io_apdu_buffer, fullAddress,sizeof(fullAddress));
        *tx=set_result_get_publicKey();
        THROW(0x9000);
    } else {
         
    // prepare for a UI based reply
#if defined(TARGET_NANOS)
        ux_step = 0;
        ux_step_count = 2;
        UX_DISPLAY(ui_address_nanos, ui_address_prepro);
#endif // #if TARGET

        *flags |= IO_ASYNCH_REPLY;
    }
    
}

// APDU Sign
void handleSign(uint8_t p1, uint8_t p2, uint8_t *workBuffer,
                uint16_t dataLength, volatile unsigned int *flags,
                volatile unsigned int *tx) {

    UNUSED(tx);
    uint32_t i;
    
    parserStatus_e txResult;
    
    if (p1 == P1_FIRST) {
        tmpCtx.transactionContext.pathLength = workBuffer[0];
        if ((tmpCtx.transactionContext.pathLength < 0x01) ||
            (tmpCtx.transactionContext.pathLength > MAX_BIP32_PATH)) {
            PRINTF("Invalid path\n");
            THROW(0x6a80);
        }
        workBuffer++;
        dataLength--;
        for (i = 0; i < tmpCtx.transactionContext.pathLength; i++) {
            tmpCtx.transactionContext.bip32Path[i] =
                (workBuffer[0] << 24) | (workBuffer[1] << 16) |
                (workBuffer[2] << 8) | (workBuffer[3]);
            workBuffer += 4;
            dataLength -= 4;
        }
        
    } else if (p1 != P1_MORE) {
        THROW(0x6B00);
    }
    if (p2 != 0) {
        THROW(0x6B00);
    }

    /*
    Parse will not be available for the first version
    //Parse Raw transaction dada
    if (parseTx(workBuffer, dataLength, &txContent) != USTREAM_FINISHED) {
        PRINTF("Unexpected parser status\n");
        THROW(0x6A80);
    }*/
    
    cx_sha256_init(&sha2);
    cx_hash(&sha2, CX_LAST, workBuffer, 133, tmpCtx.transactionContext.hash);
    os_memmove(G_io_apdu_buffer, tmpCtx.transactionContext.hash, 32);
    *tx=32;
    THROW(0x9000);  //Return OK


    // Store the hash
    //cx_hash((cx_hash_t *)&sha3, CX_LAST, tmpCtx.transactionContext.hash, 0,
    //        tmpCtx.transactionContext.hash);
  
#if defined(TARGET_BLUE)
    ui_approval_transaction_blue_init();
#elif defined(TARGET_NANOS)
    ux_step = 0;
    ux_step_count = 5;
    UX_DISPLAY(ui_approval_nanos, ui_approval_prepro);
#endif // #if TARGET_ID

    *flags |= IO_ASYNCH_REPLY;

}


// // APDU App Config and Versionp
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
    G_io_apdu_buffer[1] = LEDGER_MAJOR_VERSION;
    G_io_apdu_buffer[2] = LEDGER_MINOR_VERSION;
    G_io_apdu_buffer[3] = LEDGER_PATCH_VERSION;
    *tx = 4;        // Set return size
    THROW(0x9000);  //Return OK
}

// Check ADPU and process the assigned task
void handleApdu(volatile unsigned int *flags, volatile unsigned int *tx) {
    unsigned short sw = 0;
    uint8_t privateKeyData[65];
                cx_sha3_t *sha3Context = &sha3;
                uint8_t hashAddress[32];

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
                                   G_io_apdu_buffer[OFFSET_LC], flags, tx);
                break;

            case INS_SIGN:
                // Request Signature
                handleSign(G_io_apdu_buffer[OFFSET_P1],
                           G_io_apdu_buffer[OFFSET_P2],
                           G_io_apdu_buffer + OFFSET_CDATA,
                           G_io_apdu_buffer[OFFSET_LC], flags, tx);
                break;

            case INS_GET_APP_CONFIGURATION:
                // Request App configuration
                handleGetAppConfiguration(
                    G_io_apdu_buffer[OFFSET_P1], G_io_apdu_buffer[OFFSET_P2],
                    G_io_apdu_buffer + OFFSET_CDATA,
                    G_io_apdu_buffer[OFFSET_LC], flags, tx);
                break;

            default:
                THROW(0x6D00);
                break;
            }
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


// App main loop
void tron_main(void) {
    volatile unsigned int rx = 0;
    volatile unsigned int tx = 0;
    volatile unsigned int flags = 0;

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
        UX_TICKER_EVENT(G_io_seproxyhal_spi_buffer, {
            if (UX_ALLOWED) {
#if 0
                if (skipWarning && (ux_step == 0)) {
                    ux_step++;
                }
#endif
                if (ux_step_count) {
                    // prepare next screen
                    ux_step = (ux_step + 1) % ux_step_count;
                    // redisplay screen
                    UX_REDISPLAY();
                }
            }
        });
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

                if (N_storage.initialized != 0x01) {
                    internalStorage_t storage;
                    storage.fidoTransport = 0x00;
                    storage.initialized = 0x01;
                    nvm_write(&N_storage, (void *)&storage,
                              sizeof(internalStorage_t));
                }

#ifdef HAVE_U2F
                os_memset((unsigned char *)&u2fService, 0, sizeof(u2fService));
                u2fService.inputBuffer = G_io_apdu_buffer;
                u2fService.outputBuffer = G_io_apdu_buffer;
                u2fService.messageBuffer = (uint8_t *)u2fMessageBuffer;
                u2fService.messageBufferSize = U2F_MAX_MESSAGE_SIZE;
                u2f_initialize_service((u2f_service_t *)&u2fService);

                USB_power_U2F(1, N_storage.fidoTransport);
#else  // HAVE_U2F
                USB_power_U2F(1, 0);
#endif // HAVE_U2F

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
