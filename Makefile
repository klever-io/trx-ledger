#*******************************************************************************
#   Ledger App
#   (c) 2018 Ledger
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#*******************************************************************************

ifeq ($(BOLOS_SDK),)
$(error Environment variable BOLOS_SDK is not set)
endif

##############
#  Compiler  #
##############
ifneq ($(BOLOS_ENV),)
$(info BOLOS_ENV=$(BOLOS_ENV))
CLANGPATH := $(BOLOS_ENV)/clang-arm-fropi/bin/
GCCPATH := $(BOLOS_ENV)/gcc-arm-none-eabi-5_3-2016q1/bin/
else
$(info BOLOS_ENV is not set: falling back to CLANGPATH and GCCPATH)
endif
ifeq ($(CLANGPATH),)
$(info CLANGPATH is not set: clang will be used from PATH)
endif
ifeq ($(GCCPATH),)
$(info GCCPATH is not set: arm-none-eabi-* will be used from PATH)
endif

CC       := $(CLANGPATH)clang

CFLAGS   += -O3 -Os -Isrc/include -Iextra/nanopb -Iproto

AS     := $(GCCPATH)arm-none-eabi-gcc

LD       := $(GCCPATH)arm-none-eabi-gcc
LDFLAGS  += -O3 -Os
LDLIBS   += -lm -lgcc -lc

include $(BOLOS_SDK)/Makefile.defines

APPNAME = Tron
APP_LOAD_PARAMS=--appFlags 0x240 --path "44'/195'" --curve secp256k1 $(COMMON_LOAD_PARAMS) 
# Samsung temporary implementation for wallet ID on 0xda7aba5e/0xc1a551c5
APP_LOAD_PARAMS += --path "1517992542'/1101353413'"

splitVersion=$(word $2, $(subst ., , $1))

APPVERSION = $(file < VERSION)

APPVERSION_M=$(call splitVersion, $(APPVERSION), 1)
APPVERSION_N=$(call splitVersion, $(APPVERSION), 2)
APPVERSION_P=$(call splitVersion, $(APPVERSION), 3)

#prepare hsm generation
ifeq ($(TARGET_NAME),TARGET_BLUE)
ICONNAME=icons/icon_blue.gif            # Name compatible w/ Blue SDK v2.1.1
else
ifeq ($(TARGET_NAME), TARGET_NANOX)
ICONNAME=icons/nanox_app_tron.gif
else
ICONNAME=icons/nanos_app_tron.gif
endif
endif


################
# Default rule #
################
all: default

############
# Platform #
############

DEFINES   += OS_IO_SEPROXYHAL
DEFINES   += HAVE_BAGL HAVE_SPRINTF
DEFINES   += HAVE_IO_USB HAVE_L4_USBLIB IO_USB_MAX_ENDPOINTS=6 IO_HID_EP_LENGTH=64 HAVE_USB_APDU
DEFINES   +=  LEDGER_MAJOR_VERSION=$(APPVERSION_M) LEDGER_MINOR_VERSION=$(APPVERSION_N) LEDGER_PATCH_VERSION=$(APPVERSION_P)

DEFINES   += USB_SEGMENT_SIZE=64
DEFINES   += BLE_SEGMENT_SIZE=32 #max MTU, min 20
DEFINES   += UNUSED\(x\)=\(void\)x
DEFINES   += APPVERSION=\"$(APPVERSION)\"

ifeq ($(TARGET_NAME),TARGET_NANOX)
DEFINES   += IO_SEPROXYHAL_BUFFER_SIZE_B=300
# BLE
DEFINES   += HAVE_BLE BLE_COMMAND_TIMEOUT_MS=2000
DEFINES   += HAVE_BLE_APDU # basic ledger apdu transport over BLE

DEFINES   += HAVE_GLO096 HAVE_UX_FLOW
DEFINES   += HAVE_BAGL BAGL_WIDTH=128 BAGL_HEIGHT=64
DEFINES   += HAVE_BAGL_ELLIPSIS # long label truncation feature
DEFINES   += HAVE_BAGL_FONT_OPEN_SANS_REGULAR_11PX
DEFINES   += HAVE_BAGL_FONT_OPEN_SANS_EXTRABOLD_11PX
DEFINES   += HAVE_BAGL_FONT_OPEN_SANS_LIGHT_16PX
else
DEFINES   += IO_SEPROXYHAL_BUFFER_SIZE_B=128
endif

# nanopb
DEFINES   += PB_NO_ERRMSG=1

# Enabling debug PRINTF
DEBUG = 0
ifneq ($(DEBUG),0)

        ifeq ($(TARGET_NAME),TARGET_NANOX)
                DEFINES   += HAVE_PRINTF PRINTF=mcu_usb_printf
        else
                DEFINES   += HAVE_PRINTF PRINTF=screen_printf
        endif
else
        DEFINES   += PRINTF\(...\)=
endif

# import rules to compile glyphs(/pone)
include $(BOLOS_SDK)/Makefile.glyphs

### computed variables
APP_SOURCE_PATH  += src proto extra/nanopb
SDK_SOURCE_PATH  += lib_u2f lib_stusb_impl lib_stusb
ifeq ($(TARGET_NAME),TARGET_NANOX)
SDK_SOURCE_PATH  += lib_blewbxx lib_blewbxx_impl
SDK_SOURCE_PATH  += lib_ux
endif

# If the SDK supports Flow for Nano S, build for it

ifeq ($(TARGET_NAME),TARGET_NANOS)

	ifneq "$(wildcard $(BOLOS_SDK)/lib_ux/src/ux_flow_engine.c)" ""
		SDK_SOURCE_PATH  += lib_ux
		DEFINES		       += HAVE_UX_FLOW
		DEFINES += HAVE_WALLET_ID_SDK
	endif

endif

# U2F
DEFINES   += U2F_PROXY_MAGIC=\"TRX\"
DEFINES   += HAVE_IO_U2F HAVE_U2F
DEFINES   += U2F_REQUEST_TIMEOUT=28000 # 28 seconds

load: all
	python -m ledgerblue.loadApp $(APP_LOAD_PARAMS)

delete:
	python -m ledgerblue.deleteApp $(COMMON_DELETE_PARAMS)

# import generic rules from the sdk
include $(BOLOS_SDK)/Makefile.rules

#add dependency on custom makefile filename
dep/%.d: %.c Makefile.genericwallet

listvariants:
	@echo VARIANTS COIN tron
