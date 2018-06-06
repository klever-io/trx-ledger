
bin/app.elf:     file format elf32-littlearm


Disassembly of section .text:

c0d00000 <main>:
    }
    END_TRY_L(exit);
}

// App boot loop
__attribute__((section(".boot"))) int main(void) {
c0d00000:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00002:	b08d      	sub	sp, #52	; 0x34
    // exit critical section
    __asm volatile("cpsie i");
c0d00004:	b662      	cpsie	i

    // ensure exception will work as planned
    os_boot();
c0d00006:	f000 fe0d 	bl	c0d00c24 <os_boot>
c0d0000a:	4d27      	ldr	r5, [pc, #156]	; (c0d000a8 <_nvram_data_size+0x68>)
c0d0000c:	4e27      	ldr	r6, [pc, #156]	; (c0d000ac <_nvram_data_size+0x6c>)
c0d0000e:	2400      	movs	r4, #0

    for (;;) {
        os_memset(&txContent, 0, sizeof(txContent));
c0d00010:	2240      	movs	r2, #64	; 0x40
c0d00012:	4628      	mov	r0, r5
c0d00014:	4621      	mov	r1, r4
c0d00016:	f000 feb5 	bl	c0d00d84 <os_memset>

        UX_INIT();
c0d0001a:	22b0      	movs	r2, #176	; 0xb0
c0d0001c:	4630      	mov	r0, r6
c0d0001e:	4621      	mov	r1, r4
c0d00020:	f000 feb0 	bl	c0d00d84 <os_memset>
c0d00024:	af02      	add	r7, sp, #8
        BEGIN_TRY {
            TRY {
c0d00026:	4638      	mov	r0, r7
c0d00028:	f003 fa86 	bl	c0d03538 <setjmp>
c0d0002c:	8538      	strh	r0, [r7, #40]	; 0x28
c0d0002e:	b280      	uxth	r0, r0
c0d00030:	2800      	cmp	r0, #0
c0d00032:	d006      	beq.n	c0d00042 <_nvram_data_size+0x2>
c0d00034:	2810      	cmp	r0, #16
c0d00036:	d0ea      	beq.n	c0d0000e <main+0xe>
            FINALLY {
            }
        }
        END_TRY;
    }
    app_exit();
c0d00038:	f000 fdd0 	bl	c0d00bdc <app_exit>

    return 0;
c0d0003c:	2000      	movs	r0, #0
c0d0003e:	b00d      	add	sp, #52	; 0x34

c0d00040 <_nvram_data_size>:
c0d00040:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00042:	a802      	add	r0, sp, #8
    for (;;) {
        os_memset(&txContent, 0, sizeof(txContent));

        UX_INIT();
        BEGIN_TRY {
            TRY {
c0d00044:	f000 fdf1 	bl	c0d00c2a <try_context_set>
                io_seproxyhal_init();
c0d00048:	f001 f88e 	bl	c0d01168 <io_seproxyhal_init>

                if (N_storage.initialized != 0x01) {
c0d0004c:	4818      	ldr	r0, [pc, #96]	; (c0d000b0 <_nvram_data_size+0x70>)
c0d0004e:	f001 fd45 	bl	c0d01adc <pic>
c0d00052:	7840      	ldrb	r0, [r0, #1]
c0d00054:	2801      	cmp	r0, #1
c0d00056:	d00a      	beq.n	c0d0006e <_nvram_data_size+0x2e>
c0d00058:	ad01      	add	r5, sp, #4
                    internalStorage_t storage;
                    storage.fidoTransport = 0x00;
c0d0005a:	702c      	strb	r4, [r5, #0]
c0d0005c:	2001      	movs	r0, #1
                    storage.initialized = 0x01;
c0d0005e:	7068      	strb	r0, [r5, #1]
                    nvm_write(&N_storage, (void *)&storage,
c0d00060:	4813      	ldr	r0, [pc, #76]	; (c0d000b0 <_nvram_data_size+0x70>)
c0d00062:	f001 fd3b 	bl	c0d01adc <pic>
c0d00066:	2202      	movs	r2, #2
c0d00068:	4629      	mov	r1, r5
c0d0006a:	f001 fd79 	bl	c0d01b60 <nvm_write>
                              sizeof(internalStorage_t));
                }

#ifdef HAVE_U2F
                os_memset((unsigned char *)&u2fService, 0, sizeof(u2fService));
c0d0006e:	4c11      	ldr	r4, [pc, #68]	; (c0d000b4 <_nvram_data_size+0x74>)
c0d00070:	2100      	movs	r1, #0
c0d00072:	2260      	movs	r2, #96	; 0x60
c0d00074:	4620      	mov	r0, r4
c0d00076:	f000 fe85 	bl	c0d00d84 <os_memset>
                u2fService.inputBuffer = G_io_apdu_buffer;
c0d0007a:	480f      	ldr	r0, [pc, #60]	; (c0d000b8 <_nvram_data_size+0x78>)
c0d0007c:	64a0      	str	r0, [r4, #72]	; 0x48
                u2fService.outputBuffer = G_io_apdu_buffer;
c0d0007e:	64e0      	str	r0, [r4, #76]	; 0x4c
                u2fService.messageBuffer = (uint8_t *)u2fMessageBuffer;
c0d00080:	480e      	ldr	r0, [pc, #56]	; (c0d000bc <_nvram_data_size+0x7c>)
c0d00082:	6520      	str	r0, [r4, #80]	; 0x50
                u2fService.messageBufferSize = U2F_MAX_MESSAGE_SIZE;
c0d00084:	2021      	movs	r0, #33	; 0x21
c0d00086:	00c0      	lsls	r0, r0, #3
c0d00088:	2154      	movs	r1, #84	; 0x54
c0d0008a:	5260      	strh	r0, [r4, r1]
                u2f_initialize_service((u2f_service_t *)&u2fService);
c0d0008c:	4620      	mov	r0, r4
c0d0008e:	f002 f833 	bl	c0d020f8 <u2f_initialize_service>

                USB_power_U2F(1, N_storage.fidoTransport);
c0d00092:	4807      	ldr	r0, [pc, #28]	; (c0d000b0 <_nvram_data_size+0x70>)
c0d00094:	f001 fd22 	bl	c0d01adc <pic>
c0d00098:	7801      	ldrb	r1, [r0, #0]
c0d0009a:	2001      	movs	r0, #1
c0d0009c:	f003 f8de 	bl	c0d0325c <USB_power_U2F>
#else  // HAVE_U2F
                USB_power_U2F(1, 0);
#endif // HAVE_U2F

                ui_idle();
c0d000a0:	f000 f8a0 	bl	c0d001e4 <ui_idle>

                //Call Tron main Loop
                tron_main();
c0d000a4:	f000 fa64 	bl	c0d00570 <tron_main>
c0d000a8:	20001be8 	.word	0x20001be8
c0d000ac:	20001830 	.word	0x20001830
c0d000b0:	c0d03d80 	.word	0xc0d03d80
c0d000b4:	200018e0 	.word	0x200018e0
c0d000b8:	20001dbc 	.word	0x20001dbc
c0d000bc:	20001ca8 	.word	0x20001ca8

c0d000c0 <getAddressStringFromKey>:
                                cx_sha3_t *sha3Context) {
    
    // Todo: From prublickey to address

    
}
c0d000c0:	4770      	bx	lr
	...

c0d000c4 <u2f_proxy_response>:
WIDE internalStorage_t N_storage_real;
#define N_storage (*(WIDE internalStorage_t *)PIC(&N_storage_real))

#ifdef HAVE_U2F

void u2f_proxy_response(u2f_service_t *service, unsigned int tx) {
c0d000c4:	b570      	push	{r4, r5, r6, lr}
c0d000c6:	b082      	sub	sp, #8
c0d000c8:	460d      	mov	r5, r1
c0d000ca:	4604      	mov	r4, r0
    os_memset(service->messageBuffer, 0, 5);
c0d000cc:	6d20      	ldr	r0, [r4, #80]	; 0x50
c0d000ce:	2600      	movs	r6, #0
c0d000d0:	2205      	movs	r2, #5
c0d000d2:	4631      	mov	r1, r6
c0d000d4:	f000 fe56 	bl	c0d00d84 <os_memset>
    os_memmove(service->messageBuffer + 5, G_io_apdu_buffer, tx);
c0d000d8:	6d20      	ldr	r0, [r4, #80]	; 0x50
c0d000da:	1d40      	adds	r0, r0, #5
c0d000dc:	490c      	ldr	r1, [pc, #48]	; (c0d00110 <u2f_proxy_response+0x4c>)
c0d000de:	462a      	mov	r2, r5
c0d000e0:	f000 fe59 	bl	c0d00d96 <os_memmove>
    service->messageBuffer[tx + 5] = 0x90;
c0d000e4:	6d20      	ldr	r0, [r4, #80]	; 0x50
c0d000e6:	1940      	adds	r0, r0, r5
c0d000e8:	217c      	movs	r1, #124	; 0x7c
c0d000ea:	43c9      	mvns	r1, r1
c0d000ec:	310d      	adds	r1, #13
c0d000ee:	7141      	strb	r1, [r0, #5]
    service->messageBuffer[tx + 6] = 0x00;
c0d000f0:	6d20      	ldr	r0, [r4, #80]	; 0x50
c0d000f2:	1940      	adds	r0, r0, r5
c0d000f4:	7186      	strb	r6, [r0, #6]
    u2f_send_fragmented_response(service, U2F_CMD_MSG, service->messageBuffer,
c0d000f6:	6d22      	ldr	r2, [r4, #80]	; 0x50
c0d000f8:	2001      	movs	r0, #1
c0d000fa:	4669      	mov	r1, sp
c0d000fc:	6008      	str	r0, [r1, #0]
                                 tx + 7, true);
c0d000fe:	1de8      	adds	r0, r5, #7
void u2f_proxy_response(u2f_service_t *service, unsigned int tx) {
    os_memset(service->messageBuffer, 0, 5);
    os_memmove(service->messageBuffer + 5, G_io_apdu_buffer, tx);
    service->messageBuffer[tx + 5] = 0x90;
    service->messageBuffer[tx + 6] = 0x00;
    u2f_send_fragmented_response(service, U2F_CMD_MSG, service->messageBuffer,
c0d00100:	b283      	uxth	r3, r0
c0d00102:	2183      	movs	r1, #131	; 0x83
c0d00104:	4620      	mov	r0, r4
c0d00106:	f002 f81e 	bl	c0d02146 <u2f_send_fragmented_response>
                                 tx + 7, true);
}
c0d0010a:	b002      	add	sp, #8
c0d0010c:	bd70      	pop	{r4, r5, r6, pc}
c0d0010e:	46c0      	nop			; (mov r8, r8)
c0d00110:	20001dbc 	.word	0x20001dbc

c0d00114 <menu_settings_browser_change>:
const ux_menu_entry_t menu_main[];
const ux_menu_entry_t menu_settings[];
const ux_menu_entry_t menu_settings_browser[];

// change the setting
void menu_settings_browser_change(unsigned int enabled) {
c0d00114:	b570      	push	{r4, r5, r6, lr}
c0d00116:	b082      	sub	sp, #8
c0d00118:	ad01      	add	r5, sp, #4
    uint8_t fidoTransport = enabled;
c0d0011a:	7028      	strb	r0, [r5, #0]
    nvm_write(&N_storage.fidoTransport, (void *)&fidoTransport,
c0d0011c:	4e0e      	ldr	r6, [pc, #56]	; (c0d00158 <menu_settings_browser_change+0x44>)
c0d0011e:	4630      	mov	r0, r6
c0d00120:	f001 fcdc 	bl	c0d01adc <pic>
c0d00124:	2401      	movs	r4, #1
c0d00126:	4629      	mov	r1, r5
c0d00128:	4622      	mov	r2, r4
c0d0012a:	f001 fd19 	bl	c0d01b60 <nvm_write>
c0d0012e:	2500      	movs	r5, #0
              sizeof(uint8_t));
    USB_power_U2F(0, 0);
c0d00130:	4628      	mov	r0, r5
c0d00132:	4629      	mov	r1, r5
c0d00134:	f003 f892 	bl	c0d0325c <USB_power_U2F>
    USB_power_U2F(1, N_storage.fidoTransport);
c0d00138:	4630      	mov	r0, r6
c0d0013a:	f001 fccf 	bl	c0d01adc <pic>
c0d0013e:	7801      	ldrb	r1, [r0, #0]
c0d00140:	4620      	mov	r0, r4
c0d00142:	f003 f88b 	bl	c0d0325c <USB_power_U2F>
    // go back to the menu entry
    UX_MENU_DISPLAY(1, menu_settings, NULL);
c0d00146:	4905      	ldr	r1, [pc, #20]	; (c0d0015c <menu_settings_browser_change+0x48>)
c0d00148:	4479      	add	r1, pc
c0d0014a:	4620      	mov	r0, r4
c0d0014c:	462a      	mov	r2, r5
c0d0014e:	f001 fc3d 	bl	c0d019cc <ux_menu_display>
}
c0d00152:	b002      	add	sp, #8
c0d00154:	bd70      	pop	{r4, r5, r6, pc}
c0d00156:	46c0      	nop			; (mov r8, r8)
c0d00158:	c0d03d80 	.word	0xc0d03d80
c0d0015c:	0000361c 	.word	0x0000361c

c0d00160 <menu_settings_browser_init>:

// show the currently activated entry
void menu_settings_browser_init(unsigned int ignored) {
c0d00160:	b580      	push	{r7, lr}
    UNUSED(ignored);
    UX_MENU_DISPLAY(N_storage.fidoTransport ? 1 : 0, menu_settings_browser,
c0d00162:	4807      	ldr	r0, [pc, #28]	; (c0d00180 <menu_settings_browser_init+0x20>)
c0d00164:	f001 fcba 	bl	c0d01adc <pic>
c0d00168:	7801      	ldrb	r1, [r0, #0]
c0d0016a:	2001      	movs	r0, #1
c0d0016c:	2900      	cmp	r1, #0
c0d0016e:	d100      	bne.n	c0d00172 <menu_settings_browser_init+0x12>
c0d00170:	4608      	mov	r0, r1
c0d00172:	4904      	ldr	r1, [pc, #16]	; (c0d00184 <menu_settings_browser_init+0x24>)
c0d00174:	4479      	add	r1, pc
c0d00176:	2200      	movs	r2, #0
c0d00178:	f001 fc28 	bl	c0d019cc <ux_menu_display>
                    NULL);
}
c0d0017c:	bd80      	pop	{r7, pc}
c0d0017e:	46c0      	nop			; (mov r8, r8)
c0d00180:	c0d03d80 	.word	0xc0d03d80
c0d00184:	0000359c 	.word	0x0000359c

c0d00188 <ui_address_prepro>:
     NULL,
     NULL,
     NULL},
};

unsigned int ui_address_prepro(const bagl_element_t *element) {
c0d00188:	b570      	push	{r4, r5, r6, lr}
c0d0018a:	4605      	mov	r5, r0
    if (element->component.userid > 0) {
c0d0018c:	7868      	ldrb	r0, [r5, #1]
c0d0018e:	2401      	movs	r4, #1
c0d00190:	2800      	cmp	r0, #0
c0d00192:	d01f      	beq.n	c0d001d4 <ui_address_prepro+0x4c>
        unsigned int display = (ux_step == element->component.userid - 1);
c0d00194:	1e41      	subs	r1, r0, #1
c0d00196:	4a10      	ldr	r2, [pc, #64]	; (c0d001d8 <ui_address_prepro+0x50>)
c0d00198:	6812      	ldr	r2, [r2, #0]
c0d0019a:	2401      	movs	r4, #1
c0d0019c:	2300      	movs	r3, #0
c0d0019e:	428a      	cmp	r2, r1
c0d001a0:	d000      	beq.n	c0d001a4 <ui_address_prepro+0x1c>
c0d001a2:	461c      	mov	r4, r3
        if (display) {
c0d001a4:	428a      	cmp	r2, r1
c0d001a6:	d115      	bne.n	c0d001d4 <ui_address_prepro+0x4c>
c0d001a8:	267d      	movs	r6, #125	; 0x7d
c0d001aa:	0131      	lsls	r1, r6, #4
            switch (element->component.userid) {
c0d001ac:	2801      	cmp	r0, #1
c0d001ae:	d00f      	beq.n	c0d001d0 <ui_address_prepro+0x48>
c0d001b0:	2802      	cmp	r0, #2
c0d001b2:	d10f      	bne.n	c0d001d4 <ui_address_prepro+0x4c>
            case 1:
                UX_CALLBACK_SET_INTERVAL(2000);
                break;
            case 2:
                UX_CALLBACK_SET_INTERVAL(MAX(
c0d001b4:	2107      	movs	r1, #7
c0d001b6:	4628      	mov	r0, r5
c0d001b8:	f001 f98a 	bl	c0d014d0 <bagl_label_roundtrip_duration_ms>
c0d001bc:	00f6      	lsls	r6, r6, #3
c0d001be:	1980      	adds	r0, r0, r6
c0d001c0:	4906      	ldr	r1, [pc, #24]	; (c0d001dc <ui_address_prepro+0x54>)
c0d001c2:	4288      	cmp	r0, r1
c0d001c4:	d304      	bcc.n	c0d001d0 <ui_address_prepro+0x48>
c0d001c6:	2107      	movs	r1, #7
c0d001c8:	4628      	mov	r0, r5
c0d001ca:	f001 f981 	bl	c0d014d0 <bagl_label_roundtrip_duration_ms>
c0d001ce:	1981      	adds	r1, r0, r6
c0d001d0:	4803      	ldr	r0, [pc, #12]	; (c0d001e0 <ui_address_prepro+0x58>)
c0d001d2:	6141      	str	r1, [r0, #20]
            }
        }
        return display;
    }
    return 1;
}
c0d001d4:	4620      	mov	r0, r4
c0d001d6:	bd70      	pop	{r4, r5, r6, pc}
c0d001d8:	2000182c 	.word	0x2000182c
c0d001dc:	00000bb8 	.word	0x00000bb8
c0d001e0:	20001830 	.word	0x20001830

c0d001e4 <ui_idle>:
unsigned int ui_approval_nanos_button(unsigned int button_mask,
                                      unsigned int button_mask_counter);

#endif // #if defined(TARGET_NANOS)

void ui_idle(void) {
c0d001e4:	b580      	push	{r7, lr}
#if defined(TARGET_NANOS)
    UX_MENU_DISPLAY(0, menu_main, NULL);
c0d001e6:	4903      	ldr	r1, [pc, #12]	; (c0d001f4 <ui_idle+0x10>)
c0d001e8:	4479      	add	r1, pc
c0d001ea:	2000      	movs	r0, #0
c0d001ec:	4602      	mov	r2, r0
c0d001ee:	f001 fbed 	bl	c0d019cc <ux_menu_display>
#endif // #if TARGET_ID
}
c0d001f2:	bd80      	pop	{r7, pc}
c0d001f4:	00003624 	.word	0x00003624

c0d001f8 <io_seproxyhal_touch_address_ok>:
    // Go back to the dashboard
    os_sched_exit(0);
    return 0; // do not redraw the widget
}

unsigned int io_seproxyhal_touch_address_ok(const bagl_element_t *e) {
c0d001f8:	b510      	push	{r4, lr}
    uint32_t tx = set_result_get_publicKey();
    G_io_apdu_buffer[tx++] = 0x90;
c0d001fa:	480d      	ldr	r0, [pc, #52]	; (c0d00230 <io_seproxyhal_touch_address_ok+0x38>)
c0d001fc:	2190      	movs	r1, #144	; 0x90
c0d001fe:	7001      	strb	r1, [r0, #0]
c0d00200:	2100      	movs	r1, #0
    G_io_apdu_buffer[tx++] = 0x00;
c0d00202:	7041      	strb	r1, [r0, #1]
#ifdef HAVE_U2F
    if (fidoActivated) {
c0d00204:	480b      	ldr	r0, [pc, #44]	; (c0d00234 <io_seproxyhal_touch_address_ok+0x3c>)
c0d00206:	7800      	ldrb	r0, [r0, #0]
c0d00208:	2800      	cmp	r0, #0
c0d0020a:	d004      	beq.n	c0d00216 <io_seproxyhal_touch_address_ok+0x1e>
        u2f_proxy_response((u2f_service_t *)&u2fService, tx);
c0d0020c:	480a      	ldr	r0, [pc, #40]	; (c0d00238 <io_seproxyhal_touch_address_ok+0x40>)
c0d0020e:	2102      	movs	r1, #2
c0d00210:	f7ff ff58 	bl	c0d000c4 <u2f_proxy_response>
c0d00214:	e003      	b.n	c0d0021e <io_seproxyhal_touch_address_ok+0x26>
    } else {
        // Send back the response, do not restart the event loop
        io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, tx);
c0d00216:	2020      	movs	r0, #32
c0d00218:	2102      	movs	r1, #2
c0d0021a:	f001 f9bf 	bl	c0d0159c <io_exchange>

#endif // #if defined(TARGET_NANOS)

void ui_idle(void) {
#if defined(TARGET_NANOS)
    UX_MENU_DISPLAY(0, menu_main, NULL);
c0d0021e:	4907      	ldr	r1, [pc, #28]	; (c0d0023c <io_seproxyhal_touch_address_ok+0x44>)
c0d00220:	4479      	add	r1, pc
c0d00222:	2400      	movs	r4, #0
c0d00224:	4620      	mov	r0, r4
c0d00226:	4622      	mov	r2, r4
c0d00228:	f001 fbd0 	bl	c0d019cc <ux_menu_display>
    // Send back the response, do not restart the event loop
    io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, tx);
#endif // HAVE_U2F
    // Display back the original UX
    ui_idle();
    return 0; // do not redraw the widget
c0d0022c:	4620      	mov	r0, r4
c0d0022e:	bd10      	pop	{r4, pc}
c0d00230:	20001dbc 	.word	0x20001dbc
c0d00234:	200020fa 	.word	0x200020fa
c0d00238:	200018e0 	.word	0x200018e0
c0d0023c:	000035ec 	.word	0x000035ec

c0d00240 <io_seproxyhal_touch_address_cancel>:
}

unsigned int io_seproxyhal_touch_address_cancel(const bagl_element_t *e) {
c0d00240:	b510      	push	{r4, lr}
    G_io_apdu_buffer[0] = 0x69;
c0d00242:	480d      	ldr	r0, [pc, #52]	; (c0d00278 <io_seproxyhal_touch_address_cancel+0x38>)
c0d00244:	2169      	movs	r1, #105	; 0x69
c0d00246:	7001      	strb	r1, [r0, #0]
    G_io_apdu_buffer[1] = 0x85;
c0d00248:	2185      	movs	r1, #133	; 0x85
c0d0024a:	7041      	strb	r1, [r0, #1]
#ifdef HAVE_U2F
    if (fidoActivated) {
c0d0024c:	480b      	ldr	r0, [pc, #44]	; (c0d0027c <io_seproxyhal_touch_address_cancel+0x3c>)
c0d0024e:	7800      	ldrb	r0, [r0, #0]
c0d00250:	2800      	cmp	r0, #0
c0d00252:	d004      	beq.n	c0d0025e <io_seproxyhal_touch_address_cancel+0x1e>
        u2f_proxy_response((u2f_service_t *)&u2fService, 2);
c0d00254:	480a      	ldr	r0, [pc, #40]	; (c0d00280 <io_seproxyhal_touch_address_cancel+0x40>)
c0d00256:	2102      	movs	r1, #2
c0d00258:	f7ff ff34 	bl	c0d000c4 <u2f_proxy_response>
c0d0025c:	e003      	b.n	c0d00266 <io_seproxyhal_touch_address_cancel+0x26>
    } else {
        // Send back the response, do not restart the event loop
        io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, 2);
c0d0025e:	2020      	movs	r0, #32
c0d00260:	2102      	movs	r1, #2
c0d00262:	f001 f99b 	bl	c0d0159c <io_exchange>

#endif // #if defined(TARGET_NANOS)

void ui_idle(void) {
#if defined(TARGET_NANOS)
    UX_MENU_DISPLAY(0, menu_main, NULL);
c0d00266:	4907      	ldr	r1, [pc, #28]	; (c0d00284 <io_seproxyhal_touch_address_cancel+0x44>)
c0d00268:	4479      	add	r1, pc
c0d0026a:	2400      	movs	r4, #0
c0d0026c:	4620      	mov	r0, r4
c0d0026e:	4622      	mov	r2, r4
c0d00270:	f001 fbac 	bl	c0d019cc <ux_menu_display>
    // Send back the response, do not restart the event loop
    io_exchange(CHANNEL_APDU | IO_RETURN_AFTER_TX, 2);
#endif // HAVE_U2F
    // Display back the original UX
    ui_idle();
    return 0; // do not redraw the widget
c0d00274:	4620      	mov	r0, r4
c0d00276:	bd10      	pop	{r4, pc}
c0d00278:	20001dbc 	.word	0x20001dbc
c0d0027c:	200020fa 	.word	0x200020fa
c0d00280:	200018e0 	.word	0x200018e0
c0d00284:	000035a4 	.word	0x000035a4

c0d00288 <ui_address_nanos_button>:
}

#if defined(TARGET_NANOS)
unsigned int ui_address_nanos_button(unsigned int button_mask,
                                     unsigned int button_mask_counter) {
c0d00288:	b580      	push	{r7, lr}
    switch (button_mask) {
c0d0028a:	4906      	ldr	r1, [pc, #24]	; (c0d002a4 <ui_address_nanos_button+0x1c>)
c0d0028c:	4288      	cmp	r0, r1
c0d0028e:	d005      	beq.n	c0d0029c <ui_address_nanos_button+0x14>
c0d00290:	4905      	ldr	r1, [pc, #20]	; (c0d002a8 <ui_address_nanos_button+0x20>)
c0d00292:	4288      	cmp	r0, r1
c0d00294:	d104      	bne.n	c0d002a0 <ui_address_nanos_button+0x18>
    case BUTTON_EVT_RELEASED | BUTTON_LEFT: // CANCEL
        io_seproxyhal_touch_address_cancel(NULL);
c0d00296:	f7ff ffd3 	bl	c0d00240 <io_seproxyhal_touch_address_cancel>
c0d0029a:	e001      	b.n	c0d002a0 <ui_address_nanos_button+0x18>
        break;

    case BUTTON_EVT_RELEASED | BUTTON_RIGHT: { // OK
        io_seproxyhal_touch_address_ok(NULL);
c0d0029c:	f7ff ffac 	bl	c0d001f8 <io_seproxyhal_touch_address_ok>
        break;
    }
    }
    return 0;
c0d002a0:	2000      	movs	r0, #0
c0d002a2:	bd80      	pop	{r7, pc}
c0d002a4:	80000002 	.word	0x80000002
c0d002a8:	80000001 	.word	0x80000001

c0d002ac <io_exchange_al>:
    return 0;
}

#endif // #if defined(TARGET_NANOS)

unsigned short io_exchange_al(unsigned char channel, unsigned short tx_len) {
c0d002ac:	b5b0      	push	{r4, r5, r7, lr}
c0d002ae:	4605      	mov	r5, r0
c0d002b0:	200f      	movs	r0, #15
    switch (channel & ~(IO_FLAGS)) {
c0d002b2:	4028      	ands	r0, r5
c0d002b4:	2400      	movs	r4, #0
c0d002b6:	2801      	cmp	r0, #1
c0d002b8:	d013      	beq.n	c0d002e2 <io_exchange_al+0x36>
c0d002ba:	2802      	cmp	r0, #2
c0d002bc:	d113      	bne.n	c0d002e6 <io_exchange_al+0x3a>
    case CHANNEL_KEYBOARD:
        break;

    // multiplexed io exchange over a SPI channel and TLV encapsulated protocol
    case CHANNEL_SPI:
        if (tx_len) {
c0d002be:	2900      	cmp	r1, #0
c0d002c0:	d008      	beq.n	c0d002d4 <io_exchange_al+0x28>
            io_seproxyhal_spi_send(G_io_apdu_buffer, tx_len);
c0d002c2:	480a      	ldr	r0, [pc, #40]	; (c0d002ec <io_exchange_al+0x40>)
c0d002c4:	f001 fcee 	bl	c0d01ca4 <io_seproxyhal_spi_send>

            if (channel & IO_RESET_AFTER_REPLIED) {
c0d002c8:	b268      	sxtb	r0, r5
c0d002ca:	2800      	cmp	r0, #0
c0d002cc:	da09      	bge.n	c0d002e2 <io_exchange_al+0x36>
                reset();
c0d002ce:	f001 fc33 	bl	c0d01b38 <reset>
c0d002d2:	e006      	b.n	c0d002e2 <io_exchange_al+0x36>
            }
            return 0; // nothing received from the master so far (it's a tx
                      // transaction)
        } else {
            return io_seproxyhal_spi_recv(G_io_apdu_buffer,
c0d002d4:	2041      	movs	r0, #65	; 0x41
c0d002d6:	0081      	lsls	r1, r0, #2
c0d002d8:	4804      	ldr	r0, [pc, #16]	; (c0d002ec <io_exchange_al+0x40>)
c0d002da:	2200      	movs	r2, #0
c0d002dc:	f001 fd0e 	bl	c0d01cfc <io_seproxyhal_spi_recv>
c0d002e0:	4604      	mov	r4, r0

    default:
        THROW(INVALID_PARAMETER);
    }
    return 0;
}
c0d002e2:	4620      	mov	r0, r4
c0d002e4:	bdb0      	pop	{r4, r5, r7, pc}
            return io_seproxyhal_spi_recv(G_io_apdu_buffer,
                                          sizeof(G_io_apdu_buffer), 0);
        }

    default:
        THROW(INVALID_PARAMETER);
c0d002e6:	2002      	movs	r0, #2
c0d002e8:	f000 fe09 	bl	c0d00efe <os_longjmp>
c0d002ec:	20001dbc 	.word	0x20001dbc

c0d002f0 <handleGetPublicKey>:
}

// APDU public key
void handleGetPublicKey(uint8_t p1, uint8_t p2, uint8_t *dataBuffer,
                        uint16_t dataLength, volatile unsigned int *flags,
                        volatile unsigned int *tx) {
c0d002f0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d002f2:	b09f      	sub	sp, #124	; 0x7c
c0d002f4:	4613      	mov	r3, r2
c0d002f6:	4604      	mov	r4, r0
    uint32_t bip32Path[MAX_BIP32_PATH];  
    uint32_t i;
    uint8_t bip32PathLength = *(dataBuffer++);
    cx_ecfp_private_key_t privateKey;
    
    uint8_t p2Chain = p2 & 0x3F;   //TODO: check chain
c0d002f8:	253f      	movs	r5, #63	; 0x3f
c0d002fa:	400d      	ands	r5, r1
    UNUSED(dataLength);
    // Get private key data
    uint8_t privateKeyData[33];   //TODO: check size
    uint32_t bip32Path[MAX_BIP32_PATH];  
    uint32_t i;
    uint8_t bip32PathLength = *(dataBuffer++);
c0d002fc:	781a      	ldrb	r2, [r3, #0]
c0d002fe:	1c59      	adds	r1, r3, #1
c0d00300:	20d5      	movs	r0, #213	; 0xd5
c0d00302:	01c0      	lsls	r0, r0, #7
    cx_ecfp_private_key_t privateKey;
    
    uint8_t p2Chain = p2 & 0x3F;   //TODO: check chain
    uint8_t addressLength;

    if ((bip32PathLength < 0x01) || (bip32PathLength > MAX_BIP32_PATH)) {
c0d00304:	1e53      	subs	r3, r2, #1
c0d00306:	b2db      	uxtb	r3, r3
c0d00308:	2b0a      	cmp	r3, #10
c0d0030a:	d300      	bcc.n	c0d0030e <handleGetPublicKey+0x1e>
c0d0030c:	e09d      	b.n	c0d0044a <handleGetPublicKey+0x15a>
        PRINTF("Invalid path\n");
        THROW(0x6a80);
    }
    if ((p1 != P1_CONFIRM) && (p1 != P1_NON_CONFIRM)) {
c0d0030e:	2c02      	cmp	r4, #2
c0d00310:	d300      	bcc.n	c0d00314 <handleGetPublicKey+0x24>
c0d00312:	e097      	b.n	c0d00444 <handleGetPublicKey+0x154>
        THROW(0x6B00);
    }
    if ((p2Chain != P2_CHAINCODE) && (p2Chain != P2_NO_CHAINCODE)) {
c0d00314:	b2eb      	uxtb	r3, r5
c0d00316:	2b01      	cmp	r3, #1
c0d00318:	d900      	bls.n	c0d0031c <handleGetPublicKey+0x2c>
c0d0031a:	e093      	b.n	c0d00444 <handleGetPublicKey+0x154>
c0d0031c:	9824      	ldr	r0, [sp, #144]	; 0x90
c0d0031e:	9001      	str	r0, [sp, #4]
c0d00320:	a80c      	add	r0, sp, #48	; 0x30
c0d00322:	4613      	mov	r3, r2
        THROW(0x6B00);
    }
    
    // Add requested BIP path to tmp array
    for (i = 0; i < bip32PathLength; i++) {
        bip32Path[i] = (dataBuffer[0] << 24) | (dataBuffer[1] << 16) |
c0d00324:	780c      	ldrb	r4, [r1, #0]
c0d00326:	0624      	lsls	r4, r4, #24
c0d00328:	784e      	ldrb	r6, [r1, #1]
c0d0032a:	0436      	lsls	r6, r6, #16
c0d0032c:	4326      	orrs	r6, r4
                       (dataBuffer[2] << 8) | (dataBuffer[3]);
c0d0032e:	788c      	ldrb	r4, [r1, #2]
c0d00330:	0224      	lsls	r4, r4, #8
        THROW(0x6B00);
    }
    
    // Add requested BIP path to tmp array
    for (i = 0; i < bip32PathLength; i++) {
        bip32Path[i] = (dataBuffer[0] << 24) | (dataBuffer[1] << 16) |
c0d00332:	4334      	orrs	r4, r6
                       (dataBuffer[2] << 8) | (dataBuffer[3]);
c0d00334:	78ce      	ldrb	r6, [r1, #3]
c0d00336:	4326      	orrs	r6, r4
        THROW(0x6B00);
    }
    
    // Add requested BIP path to tmp array
    for (i = 0; i < bip32PathLength; i++) {
        bip32Path[i] = (dataBuffer[0] << 24) | (dataBuffer[1] << 16) |
c0d00338:	c040      	stmia	r0!, {r6}
    if ((p2Chain != P2_CHAINCODE) && (p2Chain != P2_NO_CHAINCODE)) {
        THROW(0x6B00);
    }
    
    // Add requested BIP path to tmp array
    for (i = 0; i < bip32PathLength; i++) {
c0d0033a:	1d09      	adds	r1, r1, #4
c0d0033c:	1e5b      	subs	r3, r3, #1
c0d0033e:	d1f1      	bne.n	c0d00324 <handleGetPublicKey+0x34>
c0d00340:	2400      	movs	r4, #0
        dataBuffer += 4;
    }
    
    
    // Get private key
    tmpCtx.publicKeyContext.getChaincode = (p2Chain == P2_CHAINCODE);
c0d00342:	2d01      	cmp	r5, #1
c0d00344:	4620      	mov	r0, r4
c0d00346:	d100      	bne.n	c0d0034a <handleGetPublicKey+0x5a>
c0d00348:	4628      	mov	r0, r5
c0d0034a:	2181      	movs	r1, #129	; 0x81
c0d0034c:	4b40      	ldr	r3, [pc, #256]	; (c0d00450 <handleGetPublicKey+0x160>)
c0d0034e:	5458      	strb	r0, [r3, r1]
    os_perso_derive_node_bip32(CX_CURVE_256K1, bip32Path, bip32PathLength,
                               privateKeyData,
                               (tmpCtx.publicKeyContext.getChaincode
c0d00350:	4618      	mov	r0, r3
c0d00352:	3061      	adds	r0, #97	; 0x61
c0d00354:	2d01      	cmp	r5, #1
c0d00356:	d000      	beq.n	c0d0035a <handleGetPublicKey+0x6a>
c0d00358:	4620      	mov	r0, r4
    }
    
    
    // Get private key
    tmpCtx.publicKeyContext.getChaincode = (p2Chain == P2_CHAINCODE);
    os_perso_derive_node_bip32(CX_CURVE_256K1, bip32Path, bip32PathLength,
c0d0035a:	4669      	mov	r1, sp
c0d0035c:	6008      	str	r0, [r1, #0]
c0d0035e:	2621      	movs	r6, #33	; 0x21
c0d00360:	a90c      	add	r1, sp, #48	; 0x30
c0d00362:	af16      	add	r7, sp, #88	; 0x58
c0d00364:	4630      	mov	r0, r6
c0d00366:	463b      	mov	r3, r7
c0d00368:	f001 fc58 	bl	c0d01c1c <os_perso_derive_node_bip32>
                               privateKeyData,
                               (tmpCtx.publicKeyContext.getChaincode
                                    ? tmpCtx.publicKeyContext.chainCode
                                    : NULL));

    cx_ecfp_init_private_key(CX_CURVE_256K1, privateKeyData, 65, &privateKey);
c0d0036c:	2241      	movs	r2, #65	; 0x41
c0d0036e:	ad02      	add	r5, sp, #8
c0d00370:	4630      	mov	r0, r6
c0d00372:	4639      	mov	r1, r7
c0d00374:	462b      	mov	r3, r5
c0d00376:	f001 fc21 	bl	c0d01bbc <cx_ecfp_init_private_key>
c0d0037a:	2301      	movs	r3, #1
    cx_ecfp_generate_pair(CX_CURVE_256K1, &tmpCtx.publicKeyContext.publicKey,
c0d0037c:	4630      	mov	r0, r6
c0d0037e:	4934      	ldr	r1, [pc, #208]	; (c0d00450 <handleGetPublicKey+0x160>)
c0d00380:	462a      	mov	r2, r5
c0d00382:	f001 fc33 	bl	c0d01bec <cx_ecfp_generate_pair>
                          &privateKey, 1);

    // Clear tmp buffer data
    os_memset(&privateKey, 0, sizeof(privateKey));
c0d00386:	2228      	movs	r2, #40	; 0x28
c0d00388:	4628      	mov	r0, r5
c0d0038a:	4621      	mov	r1, r4
c0d0038c:	f000 fcfa 	bl	c0d00d84 <os_memset>
    os_memset(privateKeyData, 0, sizeof(privateKeyData));
c0d00390:	4638      	mov	r0, r7
c0d00392:	4621      	mov	r1, r4
c0d00394:	4632      	mov	r2, r6
c0d00396:	f000 fcf5 	bl	c0d00d84 <os_memset>
c0d0039a:	482d      	ldr	r0, [pc, #180]	; (c0d00450 <handleGetPublicKey+0x160>)
  
    // Get public key
    // Compute Addres Here
    getAddressStringFromKey(&tmpCtx.publicKeyContext.publicKey,
c0d0039c:	4601      	mov	r1, r0
c0d0039e:	314c      	adds	r1, #76	; 0x4c
c0d003a0:	4a2c      	ldr	r2, [pc, #176]	; (c0d00454 <handleGetPublicKey+0x164>)
c0d003a2:	f7ff fe8d 	bl	c0d000c0 <getAddressStringFromKey>
#if defined(TARGET_NANOS)
#if 0        
        snprintf(fullAddress, sizeof(fullAddress), " 0x%.*s ", 40,
                 tmpCtx.publicKeyContext.address);
#endif
        ux_step = 0;
c0d003a6:	482c      	ldr	r0, [pc, #176]	; (c0d00458 <handleGetPublicKey+0x168>)
c0d003a8:	6004      	str	r4, [r0, #0]
        ux_step_count = 2;
c0d003aa:	482c      	ldr	r0, [pc, #176]	; (c0d0045c <handleGetPublicKey+0x16c>)
c0d003ac:	2102      	movs	r1, #2
c0d003ae:	6001      	str	r1, [r0, #0]
        UX_DISPLAY(ui_address_nanos, ui_address_prepro);
c0d003b0:	4d2b      	ldr	r5, [pc, #172]	; (c0d00460 <handleGetPublicKey+0x170>)
c0d003b2:	482d      	ldr	r0, [pc, #180]	; (c0d00468 <handleGetPublicKey+0x178>)
c0d003b4:	4478      	add	r0, pc
c0d003b6:	6028      	str	r0, [r5, #0]
c0d003b8:	2007      	movs	r0, #7
c0d003ba:	6068      	str	r0, [r5, #4]
c0d003bc:	482b      	ldr	r0, [pc, #172]	; (c0d0046c <handleGetPublicKey+0x17c>)
c0d003be:	4478      	add	r0, pc
c0d003c0:	6128      	str	r0, [r5, #16]
c0d003c2:	482b      	ldr	r0, [pc, #172]	; (c0d00470 <handleGetPublicKey+0x180>)
c0d003c4:	4478      	add	r0, pc
c0d003c6:	60e8      	str	r0, [r5, #12]
c0d003c8:	2003      	movs	r0, #3
c0d003ca:	7628      	strb	r0, [r5, #24]
c0d003cc:	61ec      	str	r4, [r5, #28]
c0d003ce:	4628      	mov	r0, r5
c0d003d0:	3018      	adds	r0, #24
c0d003d2:	f001 fc51 	bl	c0d01c78 <os_ux>
c0d003d6:	61e8      	str	r0, [r5, #28]
c0d003d8:	f001 fb7e 	bl	c0d01ad8 <ux_check_status_default>
c0d003dc:	f000 fef0 	bl	c0d011c0 <io_seproxyhal_init_ux>
c0d003e0:	60ac      	str	r4, [r5, #8]
c0d003e2:	6828      	ldr	r0, [r5, #0]
c0d003e4:	2800      	cmp	r0, #0
c0d003e6:	d026      	beq.n	c0d00436 <handleGetPublicKey+0x146>
c0d003e8:	69e8      	ldr	r0, [r5, #28]
c0d003ea:	491e      	ldr	r1, [pc, #120]	; (c0d00464 <handleGetPublicKey+0x174>)
c0d003ec:	4288      	cmp	r0, r1
c0d003ee:	d022      	beq.n	c0d00436 <handleGetPublicKey+0x146>
c0d003f0:	2800      	cmp	r0, #0
c0d003f2:	d020      	beq.n	c0d00436 <handleGetPublicKey+0x146>
c0d003f4:	2000      	movs	r0, #0
c0d003f6:	6869      	ldr	r1, [r5, #4]
c0d003f8:	4288      	cmp	r0, r1
c0d003fa:	d21c      	bcs.n	c0d00436 <handleGetPublicKey+0x146>
c0d003fc:	f001 fc68 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d00400:	2800      	cmp	r0, #0
c0d00402:	d118      	bne.n	c0d00436 <handleGetPublicKey+0x146>
c0d00404:	68a8      	ldr	r0, [r5, #8]
c0d00406:	68e9      	ldr	r1, [r5, #12]
c0d00408:	2438      	movs	r4, #56	; 0x38
c0d0040a:	4360      	muls	r0, r4
c0d0040c:	682a      	ldr	r2, [r5, #0]
c0d0040e:	1810      	adds	r0, r2, r0
c0d00410:	2900      	cmp	r1, #0
c0d00412:	d002      	beq.n	c0d0041a <handleGetPublicKey+0x12a>
c0d00414:	4788      	blx	r1
c0d00416:	2800      	cmp	r0, #0
c0d00418:	d007      	beq.n	c0d0042a <handleGetPublicKey+0x13a>
c0d0041a:	2801      	cmp	r0, #1
c0d0041c:	d103      	bne.n	c0d00426 <handleGetPublicKey+0x136>
c0d0041e:	68a8      	ldr	r0, [r5, #8]
c0d00420:	4344      	muls	r4, r0
c0d00422:	6828      	ldr	r0, [r5, #0]
c0d00424:	1900      	adds	r0, r0, r4
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
c0d00426:	f001 f811 	bl	c0d0144c <io_seproxyhal_display_default>
        snprintf(fullAddress, sizeof(fullAddress), " 0x%.*s ", 40,
                 tmpCtx.publicKeyContext.address);
#endif
        ux_step = 0;
        ux_step_count = 2;
        UX_DISPLAY(ui_address_nanos, ui_address_prepro);
c0d0042a:	68a8      	ldr	r0, [r5, #8]
c0d0042c:	1c40      	adds	r0, r0, #1
c0d0042e:	60a8      	str	r0, [r5, #8]
c0d00430:	6829      	ldr	r1, [r5, #0]
c0d00432:	2900      	cmp	r1, #0
c0d00434:	d1df      	bne.n	c0d003f6 <handleGetPublicKey+0x106>
c0d00436:	9a01      	ldr	r2, [sp, #4]
#endif // #if TARGET

        *flags |= IO_ASYNCH_REPLY;
c0d00438:	6810      	ldr	r0, [r2, #0]
c0d0043a:	2110      	movs	r1, #16
c0d0043c:	4301      	orrs	r1, r0
c0d0043e:	6011      	str	r1, [r2, #0]
    
}
c0d00440:	b01f      	add	sp, #124	; 0x7c
c0d00442:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00444:	3080      	adds	r0, #128	; 0x80
c0d00446:	f000 fd5a 	bl	c0d00efe <os_longjmp>
    uint8_t p2Chain = p2 & 0x3F;   //TODO: check chain
    uint8_t addressLength;

    if ((bip32PathLength < 0x01) || (bip32PathLength > MAX_BIP32_PATH)) {
        PRINTF("Invalid path\n");
        THROW(0x6a80);
c0d0044a:	f000 fd58 	bl	c0d00efe <os_longjmp>
c0d0044e:	46c0      	nop			; (mov r8, r8)
c0d00450:	20001940 	.word	0x20001940
c0d00454:	20001a38 	.word	0x20001a38
c0d00458:	2000182c 	.word	0x2000182c
c0d0045c:	20001be0 	.word	0x20001be0
c0d00460:	20001830 	.word	0x20001830
c0d00464:	b0105044 	.word	0xb0105044
c0d00468:	000034e4 	.word	0x000034e4
c0d0046c:	fffffec7 	.word	0xfffffec7
c0d00470:	fffffdc1 	.word	0xfffffdc1

c0d00474 <io_seproxyhal_display>:
    // return_to_dashboard:
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
c0d00474:	b580      	push	{r7, lr}
    io_seproxyhal_display_default((bagl_element_t *)element);
c0d00476:	f000 ffe9 	bl	c0d0144c <io_seproxyhal_display_default>
}
c0d0047a:	bd80      	pop	{r7, pc}

c0d0047c <handleApdu>:
    *tx = 4;        // Set return size
    THROW(0x9000);  //Return OK
}

// Check ADPU and process the assigned task
void handleApdu(volatile unsigned int *flags, volatile unsigned int *tx) {
c0d0047c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0047e:	b08d      	sub	sp, #52	; 0x34
c0d00480:	460c      	mov	r4, r1
c0d00482:	4606      	mov	r6, r0
c0d00484:	af02      	add	r7, sp, #8
    unsigned short sw = 0;

    BEGIN_TRY {
        TRY {
c0d00486:	4638      	mov	r0, r7
c0d00488:	f003 f856 	bl	c0d03538 <setjmp>
c0d0048c:	4605      	mov	r5, r0
c0d0048e:	853d      	strh	r5, [r7, #40]	; 0x28
c0d00490:	4832      	ldr	r0, [pc, #200]	; (c0d0055c <handleApdu+0xe0>)
c0d00492:	4205      	tst	r5, r0
c0d00494:	d015      	beq.n	c0d004c2 <handleApdu+0x46>
c0d00496:	a802      	add	r0, sp, #8
c0d00498:	2100      	movs	r1, #0
            default:
                THROW(0x6D00);
                break;
            }
        }
        CATCH_OTHER(e) {
c0d0049a:	8501      	strh	r1, [r0, #40]	; 0x28
c0d0049c:	200f      	movs	r0, #15
c0d0049e:	0300      	lsls	r0, r0, #12
            switch (e & 0xF000) {
c0d004a0:	4028      	ands	r0, r5
c0d004a2:	0a29      	lsrs	r1, r5, #8
c0d004a4:	b2ce      	uxtb	r6, r1
c0d004a6:	2109      	movs	r1, #9
c0d004a8:	0309      	lsls	r1, r1, #12
c0d004aa:	4288      	cmp	r0, r1
c0d004ac:	d022      	beq.n	c0d004f4 <handleApdu+0x78>
c0d004ae:	2103      	movs	r1, #3
c0d004b0:	0349      	lsls	r1, r1, #13
c0d004b2:	4288      	cmp	r0, r1
c0d004b4:	d118      	bne.n	c0d004e8 <handleApdu+0x6c>
            case 0x6000:
                // Wipe the transaction context and report the exception
                sw = e;
                os_memset(&txContent, 0, sizeof(txContent));
c0d004b6:	482a      	ldr	r0, [pc, #168]	; (c0d00560 <handleApdu+0xe4>)
c0d004b8:	2100      	movs	r1, #0
c0d004ba:	2240      	movs	r2, #64	; 0x40
c0d004bc:	f000 fc62 	bl	c0d00d84 <os_memset>
c0d004c0:	e018      	b.n	c0d004f4 <handleApdu+0x78>
c0d004c2:	a802      	add	r0, sp, #8
// Check ADPU and process the assigned task
void handleApdu(volatile unsigned int *flags, volatile unsigned int *tx) {
    unsigned short sw = 0;

    BEGIN_TRY {
        TRY {
c0d004c4:	f000 fbb1 	bl	c0d00c2a <try_context_set>
            if (G_io_apdu_buffer[OFFSET_CLA] != CLA) {
c0d004c8:	4a27      	ldr	r2, [pc, #156]	; (c0d00568 <handleApdu+0xec>)
c0d004ca:	7810      	ldrb	r0, [r2, #0]
c0d004cc:	2827      	cmp	r0, #39	; 0x27
c0d004ce:	d129      	bne.n	c0d00524 <handleApdu+0xa8>
                THROW(0x6E00);
            }

            switch (G_io_apdu_buffer[OFFSET_INS]) {
c0d004d0:	7850      	ldrb	r0, [r2, #1]
c0d004d2:	2802      	cmp	r0, #2
c0d004d4:	d12a      	bne.n	c0d0052c <handleApdu+0xb0>
            case INS_GET_PUBLIC_KEY:
                // Request Publick Key
                handleGetPublicKey(G_io_apdu_buffer[OFFSET_P1],
c0d004d6:	78d1      	ldrb	r1, [r2, #3]
c0d004d8:	7890      	ldrb	r0, [r2, #2]
c0d004da:	466b      	mov	r3, sp
c0d004dc:	601e      	str	r6, [r3, #0]
c0d004de:	1d52      	adds	r2, r2, #5
c0d004e0:	2300      	movs	r3, #0
c0d004e2:	f7ff ff05 	bl	c0d002f0 <handleGetPublicKey>
c0d004e6:	e00e      	b.n	c0d00506 <handleApdu+0x8a>
                // All is well
                sw = e;
                break;
            default:
                // Internal error
                sw = 0x6800 | (e & 0x7FF);
c0d004e8:	481e      	ldr	r0, [pc, #120]	; (c0d00564 <handleApdu+0xe8>)
c0d004ea:	4005      	ands	r5, r0
c0d004ec:	200d      	movs	r0, #13
c0d004ee:	02c0      	lsls	r0, r0, #11
c0d004f0:	4305      	orrs	r5, r0
                break;
c0d004f2:	0a2e      	lsrs	r6, r5, #8
            }
            // Unexpected exception => report
            G_io_apdu_buffer[*tx] = sw >> 8;
c0d004f4:	6820      	ldr	r0, [r4, #0]
c0d004f6:	491c      	ldr	r1, [pc, #112]	; (c0d00568 <handleApdu+0xec>)
c0d004f8:	540e      	strb	r6, [r1, r0]
            G_io_apdu_buffer[*tx + 1] = sw;
c0d004fa:	6820      	ldr	r0, [r4, #0]
                // Internal error
                sw = 0x6800 | (e & 0x7FF);
                break;
            }
            // Unexpected exception => report
            G_io_apdu_buffer[*tx] = sw >> 8;
c0d004fc:	1808      	adds	r0, r1, r0
            G_io_apdu_buffer[*tx + 1] = sw;
c0d004fe:	7045      	strb	r5, [r0, #1]
            *tx += 2;
c0d00500:	6820      	ldr	r0, [r4, #0]
c0d00502:	1c80      	adds	r0, r0, #2
c0d00504:	6020      	str	r0, [r4, #0]
        }
        FINALLY {
c0d00506:	f000 fcff 	bl	c0d00f08 <try_context_get>
c0d0050a:	a902      	add	r1, sp, #8
c0d0050c:	4288      	cmp	r0, r1
c0d0050e:	d103      	bne.n	c0d00518 <handleApdu+0x9c>
c0d00510:	f000 fcfc 	bl	c0d00f0c <try_context_get_previous>
c0d00514:	f000 fb89 	bl	c0d00c2a <try_context_set>
c0d00518:	a802      	add	r0, sp, #8
        }
    }
    END_TRY;
c0d0051a:	8d00      	ldrh	r0, [r0, #40]	; 0x28
c0d0051c:	2800      	cmp	r0, #0
c0d0051e:	d103      	bne.n	c0d00528 <handleApdu+0xac>
}
c0d00520:	b00d      	add	sp, #52	; 0x34
c0d00522:	bdf0      	pop	{r4, r5, r6, r7, pc}
    unsigned short sw = 0;

    BEGIN_TRY {
        TRY {
            if (G_io_apdu_buffer[OFFSET_CLA] != CLA) {
                THROW(0x6E00);
c0d00524:	2037      	movs	r0, #55	; 0x37
c0d00526:	0240      	lsls	r0, r0, #9
c0d00528:	f000 fce9 	bl	c0d00efe <os_longjmp>
c0d0052c:	2804      	cmp	r0, #4
c0d0052e:	d00d      	beq.n	c0d0054c <handleApdu+0xd0>
c0d00530:	2806      	cmp	r0, #6
c0d00532:	d10e      	bne.n	c0d00552 <handleApdu+0xd6>
    UNUSED(p2);
    UNUSED(workBuffer);
    UNUSED(dataLength);
    UNUSED(flags);
    //Add info to buffer
    G_io_apdu_buffer[0] = 0x00;
c0d00534:	2000      	movs	r0, #0
c0d00536:	7010      	strb	r0, [r2, #0]
    G_io_apdu_buffer[1] = LEDGER_MAJOR_VERSION;
c0d00538:	7050      	strb	r0, [r2, #1]
    G_io_apdu_buffer[2] = LEDGER_MINOR_VERSION;
c0d0053a:	7090      	strb	r0, [r2, #2]
c0d0053c:	2001      	movs	r0, #1
    G_io_apdu_buffer[3] = LEDGER_PATCH_VERSION;
c0d0053e:	70d0      	strb	r0, [r2, #3]
    *tx = 4;        // Set return size
c0d00540:	2004      	movs	r0, #4
c0d00542:	6020      	str	r0, [r4, #0]
    THROW(0x9000);  //Return OK
c0d00544:	2009      	movs	r0, #9
c0d00546:	0300      	lsls	r0, r0, #12
c0d00548:	f000 fcd9 	bl	c0d00efe <os_longjmp>
void handleSign(uint8_t p1, uint8_t p2, uint8_t *workBuffer,
                uint16_t dataLength, volatile unsigned int *flags,
                volatile unsigned int *tx) {

    PRINTF("To be implemented\n");
    THROW(0x6a81);
c0d0054c:	4807      	ldr	r0, [pc, #28]	; (c0d0056c <handleApdu+0xf0>)
c0d0054e:	f000 fcd6 	bl	c0d00efe <os_longjmp>
                    G_io_apdu_buffer + OFFSET_CDATA,
                    G_io_apdu_buffer[OFFSET_LC], flags, tx);
                break;

            default:
                THROW(0x6D00);
c0d00552:	206d      	movs	r0, #109	; 0x6d
c0d00554:	0200      	lsls	r0, r0, #8
c0d00556:	f000 fcd2 	bl	c0d00efe <os_longjmp>
c0d0055a:	46c0      	nop			; (mov r8, r8)
c0d0055c:	0000ffff 	.word	0x0000ffff
c0d00560:	20001be8 	.word	0x20001be8
c0d00564:	000007ff 	.word	0x000007ff
c0d00568:	20001dbc 	.word	0x20001dbc
c0d0056c:	00006a81 	.word	0x00006a81

c0d00570 <tron_main>:
    END_TRY;
}


// App main loop
void tron_main(void) {
c0d00570:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00572:	b08f      	sub	sp, #60	; 0x3c
c0d00574:	2600      	movs	r6, #0
    volatile unsigned int rx = 0;
c0d00576:	960e      	str	r6, [sp, #56]	; 0x38
    volatile unsigned int tx = 0;
c0d00578:	960d      	str	r6, [sp, #52]	; 0x34
    volatile unsigned int flags = 0;
c0d0057a:	960c      	str	r6, [sp, #48]	; 0x30
c0d0057c:	4f32      	ldr	r7, [pc, #200]	; (c0d00648 <tron_main+0xd8>)
c0d0057e:	4c30      	ldr	r4, [pc, #192]	; (c0d00640 <tron_main+0xd0>)
c0d00580:	a80b      	add	r0, sp, #44	; 0x2c
    // When APDU are to be fetched from multiple IOs, like NFC+USB+BLE, make
    // sure the io_event is called with a
    // switch event, before the apdu is replied to the bootloader. This avoid
    // APDU injection faults.
    for (;;) {
        volatile unsigned short sw = 0;
c0d00582:	8006      	strh	r6, [r0, #0]
c0d00584:	466d      	mov	r5, sp

        BEGIN_TRY {
            TRY {
c0d00586:	4628      	mov	r0, r5
c0d00588:	f002 ffd6 	bl	c0d03538 <setjmp>
c0d0058c:	8528      	strh	r0, [r5, #40]	; 0x28
c0d0058e:	492b      	ldr	r1, [pc, #172]	; (c0d0063c <tron_main+0xcc>)
c0d00590:	4208      	tst	r0, r1
c0d00592:	d014      	beq.n	c0d005be <tron_main+0x4e>
c0d00594:	4669      	mov	r1, sp
                    THROW(0x6982);
                }

                handleApdu(&flags, &tx);
            }
            CATCH_OTHER(e) {
c0d00596:	850e      	strh	r6, [r1, #40]	; 0x28
c0d00598:	210f      	movs	r1, #15
c0d0059a:	0309      	lsls	r1, r1, #12
                switch (e & 0xF000) {
c0d0059c:	4001      	ands	r1, r0
c0d0059e:	2209      	movs	r2, #9
c0d005a0:	0312      	lsls	r2, r2, #12
c0d005a2:	4291      	cmp	r1, r2
c0d005a4:	d022      	beq.n	c0d005ec <tron_main+0x7c>
c0d005a6:	2203      	movs	r2, #3
c0d005a8:	0352      	lsls	r2, r2, #13
c0d005aa:	4291      	cmp	r1, r2
c0d005ac:	d121      	bne.n	c0d005f2 <tron_main+0x82>
c0d005ae:	a90b      	add	r1, sp, #44	; 0x2c
                case 0x6000:
                    // Wipe the transaction context and report the exception
                    sw = e;
c0d005b0:	8008      	strh	r0, [r1, #0]
c0d005b2:	2100      	movs	r1, #0
                    os_memset(&txContent, 0, sizeof(txContent));
c0d005b4:	2240      	movs	r2, #64	; 0x40
c0d005b6:	4620      	mov	r0, r4
c0d005b8:	f000 fbe4 	bl	c0d00d84 <os_memset>
c0d005bc:	e020      	b.n	c0d00600 <tron_main+0x90>
c0d005be:	4668      	mov	r0, sp
    // APDU injection faults.
    for (;;) {
        volatile unsigned short sw = 0;

        BEGIN_TRY {
            TRY {
c0d005c0:	f000 fb33 	bl	c0d00c2a <try_context_set>
                rx = tx;
c0d005c4:	980d      	ldr	r0, [sp, #52]	; 0x34
c0d005c6:	900e      	str	r0, [sp, #56]	; 0x38
c0d005c8:	2500      	movs	r5, #0
                tx = 0; // ensure no race in catch_other if io_exchange throws
c0d005ca:	950d      	str	r5, [sp, #52]	; 0x34
                        // an error
                rx = io_exchange(CHANNEL_APDU | flags, rx);
c0d005cc:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d005ce:	990e      	ldr	r1, [sp, #56]	; 0x38
c0d005d0:	b2c0      	uxtb	r0, r0
c0d005d2:	b289      	uxth	r1, r1
c0d005d4:	f000 ffe2 	bl	c0d0159c <io_exchange>
c0d005d8:	900e      	str	r0, [sp, #56]	; 0x38
                flags = 0;
c0d005da:	950c      	str	r5, [sp, #48]	; 0x30

                // no apdu received, well, reset the session, and reset the
                // bootloader configuration
                if (rx == 0) {
c0d005dc:	980e      	ldr	r0, [sp, #56]	; 0x38
c0d005de:	2800      	cmp	r0, #0
c0d005e0:	d028      	beq.n	c0d00634 <tron_main+0xc4>
c0d005e2:	a80c      	add	r0, sp, #48	; 0x30
c0d005e4:	a90d      	add	r1, sp, #52	; 0x34
                    THROW(0x6982);
                }

                handleApdu(&flags, &tx);
c0d005e6:	f7ff ff49 	bl	c0d0047c <handleApdu>
c0d005ea:	e014      	b.n	c0d00616 <tron_main+0xa6>
c0d005ec:	a90b      	add	r1, sp, #44	; 0x2c
                    sw = e;
                    os_memset(&txContent, 0, sizeof(txContent));
                    break;
                case 0x9000:
                    // All is well
                    sw = e;
c0d005ee:	8008      	strh	r0, [r1, #0]
c0d005f0:	e006      	b.n	c0d00600 <tron_main+0x90>
                    break;
                default:
                    // Internal error
                    sw = 0x6800 | (e & 0x7FF);
c0d005f2:	4914      	ldr	r1, [pc, #80]	; (c0d00644 <tron_main+0xd4>)
c0d005f4:	4008      	ands	r0, r1
c0d005f6:	210d      	movs	r1, #13
c0d005f8:	02c9      	lsls	r1, r1, #11
c0d005fa:	4301      	orrs	r1, r0
c0d005fc:	a80b      	add	r0, sp, #44	; 0x2c
c0d005fe:	8001      	strh	r1, [r0, #0]
                    break;
                }
                // Unexpected exception => report
                G_io_apdu_buffer[tx] = sw >> 8;
c0d00600:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d00602:	0a00      	lsrs	r0, r0, #8
c0d00604:	990d      	ldr	r1, [sp, #52]	; 0x34
c0d00606:	5478      	strb	r0, [r7, r1]
                G_io_apdu_buffer[tx + 1] = sw;
c0d00608:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d0060a:	990d      	ldr	r1, [sp, #52]	; 0x34
                    // Internal error
                    sw = 0x6800 | (e & 0x7FF);
                    break;
                }
                // Unexpected exception => report
                G_io_apdu_buffer[tx] = sw >> 8;
c0d0060c:	1879      	adds	r1, r7, r1
                G_io_apdu_buffer[tx + 1] = sw;
c0d0060e:	7048      	strb	r0, [r1, #1]
                tx += 2;
c0d00610:	980d      	ldr	r0, [sp, #52]	; 0x34
c0d00612:	1c80      	adds	r0, r0, #2
c0d00614:	900d      	str	r0, [sp, #52]	; 0x34
            }
            FINALLY {
c0d00616:	f000 fc77 	bl	c0d00f08 <try_context_get>
c0d0061a:	4669      	mov	r1, sp
c0d0061c:	4288      	cmp	r0, r1
c0d0061e:	d103      	bne.n	c0d00628 <tron_main+0xb8>
c0d00620:	f000 fc74 	bl	c0d00f0c <try_context_get_previous>
c0d00624:	f000 fb01 	bl	c0d00c2a <try_context_set>
c0d00628:	4668      	mov	r0, sp
            }
        }
        END_TRY;
c0d0062a:	8d00      	ldrh	r0, [r0, #40]	; 0x28
c0d0062c:	2800      	cmp	r0, #0
c0d0062e:	d0a7      	beq.n	c0d00580 <tron_main+0x10>
c0d00630:	f000 fc65 	bl	c0d00efe <os_longjmp>
                flags = 0;

                // no apdu received, well, reset the session, and reset the
                // bootloader configuration
                if (rx == 0) {
                    THROW(0x6982);
c0d00634:	4805      	ldr	r0, [pc, #20]	; (c0d0064c <tron_main+0xdc>)
c0d00636:	f000 fc62 	bl	c0d00efe <os_longjmp>
c0d0063a:	46c0      	nop			; (mov r8, r8)
c0d0063c:	0000ffff 	.word	0x0000ffff
c0d00640:	20001be8 	.word	0x20001be8
c0d00644:	000007ff 	.word	0x000007ff
c0d00648:	20001dbc 	.word	0x20001dbc
c0d0064c:	00006982 	.word	0x00006982

c0d00650 <io_event>:
// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
}

unsigned char io_event(unsigned char channel) {
c0d00650:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00652:	b085      	sub	sp, #20
    // nothing done with the event, throw an error on the transport layer if
    // needed

    // can't have more than one tag in the reply, not supported yet.
    switch (G_io_seproxyhal_spi_buffer[0]) {
c0d00654:	4ddb      	ldr	r5, [pc, #876]	; (c0d009c4 <io_event+0x374>)
c0d00656:	7828      	ldrb	r0, [r5, #0]
c0d00658:	4edb      	ldr	r6, [pc, #876]	; (c0d009c8 <io_event+0x378>)
c0d0065a:	280c      	cmp	r0, #12
c0d0065c:	dd10      	ble.n	c0d00680 <io_event+0x30>
c0d0065e:	280d      	cmp	r0, #13
c0d00660:	d077      	beq.n	c0d00752 <io_event+0x102>
c0d00662:	280e      	cmp	r0, #14
c0d00664:	d100      	bne.n	c0d00668 <io_event+0x18>
c0d00666:	e0b4      	b.n	c0d007d2 <io_event+0x182>
c0d00668:	2815      	cmp	r0, #21
c0d0066a:	d133      	bne.n	c0d006d4 <io_event+0x84>
    case SEPROXYHAL_TAG_BUTTON_PUSH_EVENT:
        UX_BUTTON_PUSH_EVENT(G_io_seproxyhal_spi_buffer);
        break;

    case SEPROXYHAL_TAG_STATUS_EVENT:
        if (G_io_apdu_media == IO_APDU_MEDIA_USB_HID &&
c0d0066c:	48d7      	ldr	r0, [pc, #860]	; (c0d009cc <io_event+0x37c>)
c0d0066e:	7800      	ldrb	r0, [r0, #0]
c0d00670:	2801      	cmp	r0, #1
c0d00672:	d12f      	bne.n	c0d006d4 <io_event+0x84>
            !(U4BE(G_io_seproxyhal_spi_buffer, 3) &
c0d00674:	79a8      	ldrb	r0, [r5, #6]
    case SEPROXYHAL_TAG_BUTTON_PUSH_EVENT:
        UX_BUTTON_PUSH_EVENT(G_io_seproxyhal_spi_buffer);
        break;

    case SEPROXYHAL_TAG_STATUS_EVENT:
        if (G_io_apdu_media == IO_APDU_MEDIA_USB_HID &&
c0d00676:	0700      	lsls	r0, r0, #28
c0d00678:	d42c      	bmi.n	c0d006d4 <io_event+0x84>
            !(U4BE(G_io_seproxyhal_spi_buffer, 3) &
              SEPROXYHAL_TAG_STATUS_EVENT_FLAG_USB_POWERED)) {
            THROW(EXCEPTION_IO_RESET);
c0d0067a:	2010      	movs	r0, #16
c0d0067c:	f000 fc3f 	bl	c0d00efe <os_longjmp>
c0d00680:	2805      	cmp	r0, #5
c0d00682:	d100      	bne.n	c0d00686 <io_event+0x36>
c0d00684:	e0e5      	b.n	c0d00852 <io_event+0x202>
c0d00686:	280c      	cmp	r0, #12
c0d00688:	d124      	bne.n	c0d006d4 <io_event+0x84>
    // needed

    // can't have more than one tag in the reply, not supported yet.
    switch (G_io_seproxyhal_spi_buffer[0]) {
    case SEPROXYHAL_TAG_FINGER_EVENT:
        UX_FINGER_EVENT(G_io_seproxyhal_spi_buffer);
c0d0068a:	4cd1      	ldr	r4, [pc, #836]	; (c0d009d0 <io_event+0x380>)
c0d0068c:	2001      	movs	r0, #1
c0d0068e:	7620      	strb	r0, [r4, #24]
c0d00690:	2600      	movs	r6, #0
c0d00692:	61e6      	str	r6, [r4, #28]
c0d00694:	4620      	mov	r0, r4
c0d00696:	3018      	adds	r0, #24
c0d00698:	f001 faee 	bl	c0d01c78 <os_ux>
c0d0069c:	61e0      	str	r0, [r4, #28]
c0d0069e:	f001 fa1b 	bl	c0d01ad8 <ux_check_status_default>
c0d006a2:	69e0      	ldr	r0, [r4, #28]
c0d006a4:	49fb      	ldr	r1, [pc, #1004]	; (c0d00a94 <io_event+0x444>)
c0d006a6:	4288      	cmp	r0, r1
c0d006a8:	d100      	bne.n	c0d006ac <io_event+0x5c>
c0d006aa:	e283      	b.n	c0d00bb4 <io_event+0x564>
c0d006ac:	2800      	cmp	r0, #0
c0d006ae:	d100      	bne.n	c0d006b2 <io_event+0x62>
c0d006b0:	e280      	b.n	c0d00bb4 <io_event+0x564>
c0d006b2:	49f6      	ldr	r1, [pc, #984]	; (c0d00a8c <io_event+0x43c>)
c0d006b4:	4288      	cmp	r0, r1
c0d006b6:	d000      	beq.n	c0d006ba <io_event+0x6a>
c0d006b8:	e211      	b.n	c0d00ade <io_event+0x48e>
c0d006ba:	f000 fd81 	bl	c0d011c0 <io_seproxyhal_init_ux>
c0d006be:	60a6      	str	r6, [r4, #8]
c0d006c0:	6820      	ldr	r0, [r4, #0]
c0d006c2:	2800      	cmp	r0, #0
c0d006c4:	d100      	bne.n	c0d006c8 <io_event+0x78>
c0d006c6:	e275      	b.n	c0d00bb4 <io_event+0x564>
c0d006c8:	69e0      	ldr	r0, [r4, #28]
c0d006ca:	49f2      	ldr	r1, [pc, #968]	; (c0d00a94 <io_event+0x444>)
c0d006cc:	4288      	cmp	r0, r1
c0d006ce:	d000      	beq.n	c0d006d2 <io_event+0x82>
c0d006d0:	e12b      	b.n	c0d0092a <io_event+0x2da>
c0d006d2:	e26f      	b.n	c0d00bb4 <io_event+0x564>
              SEPROXYHAL_TAG_STATUS_EVENT_FLAG_USB_POWERED)) {
            THROW(EXCEPTION_IO_RESET);
        }
    // no break is intentional
    default:
        UX_DEFAULT_EVENT();
c0d006d4:	4cee      	ldr	r4, [pc, #952]	; (c0d00a90 <io_event+0x440>)
c0d006d6:	2001      	movs	r0, #1
c0d006d8:	7620      	strb	r0, [r4, #24]
c0d006da:	2500      	movs	r5, #0
c0d006dc:	61e5      	str	r5, [r4, #28]
c0d006de:	4620      	mov	r0, r4
c0d006e0:	3018      	adds	r0, #24
c0d006e2:	f001 fac9 	bl	c0d01c78 <os_ux>
c0d006e6:	61e0      	str	r0, [r4, #28]
c0d006e8:	f001 f9f6 	bl	c0d01ad8 <ux_check_status_default>
c0d006ec:	69e0      	ldr	r0, [r4, #28]
c0d006ee:	42b0      	cmp	r0, r6
c0d006f0:	d000      	beq.n	c0d006f4 <io_event+0xa4>
c0d006f2:	e0d2      	b.n	c0d0089a <io_event+0x24a>
c0d006f4:	f000 fd64 	bl	c0d011c0 <io_seproxyhal_init_ux>
c0d006f8:	60a5      	str	r5, [r4, #8]
c0d006fa:	6820      	ldr	r0, [r4, #0]
c0d006fc:	2800      	cmp	r0, #0
c0d006fe:	d100      	bne.n	c0d00702 <io_event+0xb2>
c0d00700:	e258      	b.n	c0d00bb4 <io_event+0x564>
c0d00702:	69e0      	ldr	r0, [r4, #28]
c0d00704:	49e3      	ldr	r1, [pc, #908]	; (c0d00a94 <io_event+0x444>)
c0d00706:	4288      	cmp	r0, r1
c0d00708:	d120      	bne.n	c0d0074c <io_event+0xfc>
c0d0070a:	e253      	b.n	c0d00bb4 <io_event+0x564>
c0d0070c:	6860      	ldr	r0, [r4, #4]
c0d0070e:	4285      	cmp	r5, r0
c0d00710:	d300      	bcc.n	c0d00714 <io_event+0xc4>
c0d00712:	e24f      	b.n	c0d00bb4 <io_event+0x564>
c0d00714:	f001 fadc 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d00718:	2800      	cmp	r0, #0
c0d0071a:	d000      	beq.n	c0d0071e <io_event+0xce>
c0d0071c:	e24a      	b.n	c0d00bb4 <io_event+0x564>
c0d0071e:	68a0      	ldr	r0, [r4, #8]
c0d00720:	68e1      	ldr	r1, [r4, #12]
c0d00722:	2538      	movs	r5, #56	; 0x38
c0d00724:	4368      	muls	r0, r5
c0d00726:	6822      	ldr	r2, [r4, #0]
c0d00728:	1810      	adds	r0, r2, r0
c0d0072a:	2900      	cmp	r1, #0
c0d0072c:	d002      	beq.n	c0d00734 <io_event+0xe4>
c0d0072e:	4788      	blx	r1
c0d00730:	2800      	cmp	r0, #0
c0d00732:	d007      	beq.n	c0d00744 <io_event+0xf4>
c0d00734:	2801      	cmp	r0, #1
c0d00736:	d103      	bne.n	c0d00740 <io_event+0xf0>
c0d00738:	68a0      	ldr	r0, [r4, #8]
c0d0073a:	4345      	muls	r5, r0
c0d0073c:	6820      	ldr	r0, [r4, #0]
c0d0073e:	1940      	adds	r0, r0, r5
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
c0d00740:	f000 fe84 	bl	c0d0144c <io_seproxyhal_display_default>
              SEPROXYHAL_TAG_STATUS_EVENT_FLAG_USB_POWERED)) {
            THROW(EXCEPTION_IO_RESET);
        }
    // no break is intentional
    default:
        UX_DEFAULT_EVENT();
c0d00744:	68a0      	ldr	r0, [r4, #8]
c0d00746:	1c45      	adds	r5, r0, #1
c0d00748:	60a5      	str	r5, [r4, #8]
c0d0074a:	6820      	ldr	r0, [r4, #0]
c0d0074c:	2800      	cmp	r0, #0
c0d0074e:	d1dd      	bne.n	c0d0070c <io_event+0xbc>
c0d00750:	e230      	b.n	c0d00bb4 <io_event+0x564>
        break;

    case SEPROXYHAL_TAG_DISPLAY_PROCESSED_EVENT:
        UX_DISPLAYED_EVENT({});
c0d00752:	4ccf      	ldr	r4, [pc, #828]	; (c0d00a90 <io_event+0x440>)
c0d00754:	2001      	movs	r0, #1
c0d00756:	7620      	strb	r0, [r4, #24]
c0d00758:	2500      	movs	r5, #0
c0d0075a:	61e5      	str	r5, [r4, #28]
c0d0075c:	4620      	mov	r0, r4
c0d0075e:	3018      	adds	r0, #24
c0d00760:	f001 fa8a 	bl	c0d01c78 <os_ux>
c0d00764:	61e0      	str	r0, [r4, #28]
c0d00766:	f001 f9b7 	bl	c0d01ad8 <ux_check_status_default>
c0d0076a:	69e0      	ldr	r0, [r4, #28]
c0d0076c:	49c9      	ldr	r1, [pc, #804]	; (c0d00a94 <io_event+0x444>)
c0d0076e:	4288      	cmp	r0, r1
c0d00770:	d100      	bne.n	c0d00774 <io_event+0x124>
c0d00772:	e21f      	b.n	c0d00bb4 <io_event+0x564>
c0d00774:	49c5      	ldr	r1, [pc, #788]	; (c0d00a8c <io_event+0x43c>)
c0d00776:	4288      	cmp	r0, r1
c0d00778:	d100      	bne.n	c0d0077c <io_event+0x12c>
c0d0077a:	e17a      	b.n	c0d00a72 <io_event+0x422>
c0d0077c:	2800      	cmp	r0, #0
c0d0077e:	d100      	bne.n	c0d00782 <io_event+0x132>
c0d00780:	e218      	b.n	c0d00bb4 <io_event+0x564>
c0d00782:	6820      	ldr	r0, [r4, #0]
c0d00784:	2800      	cmp	r0, #0
c0d00786:	d100      	bne.n	c0d0078a <io_event+0x13a>
c0d00788:	e20e      	b.n	c0d00ba8 <io_event+0x558>
c0d0078a:	68a0      	ldr	r0, [r4, #8]
c0d0078c:	6861      	ldr	r1, [r4, #4]
c0d0078e:	4288      	cmp	r0, r1
c0d00790:	d300      	bcc.n	c0d00794 <io_event+0x144>
c0d00792:	e209      	b.n	c0d00ba8 <io_event+0x558>
c0d00794:	f001 fa9c 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d00798:	2800      	cmp	r0, #0
c0d0079a:	d000      	beq.n	c0d0079e <io_event+0x14e>
c0d0079c:	e204      	b.n	c0d00ba8 <io_event+0x558>
c0d0079e:	68a0      	ldr	r0, [r4, #8]
c0d007a0:	68e1      	ldr	r1, [r4, #12]
c0d007a2:	2538      	movs	r5, #56	; 0x38
c0d007a4:	4368      	muls	r0, r5
c0d007a6:	6822      	ldr	r2, [r4, #0]
c0d007a8:	1810      	adds	r0, r2, r0
c0d007aa:	2900      	cmp	r1, #0
c0d007ac:	d002      	beq.n	c0d007b4 <io_event+0x164>
c0d007ae:	4788      	blx	r1
c0d007b0:	2800      	cmp	r0, #0
c0d007b2:	d007      	beq.n	c0d007c4 <io_event+0x174>
c0d007b4:	2801      	cmp	r0, #1
c0d007b6:	d103      	bne.n	c0d007c0 <io_event+0x170>
c0d007b8:	68a0      	ldr	r0, [r4, #8]
c0d007ba:	4345      	muls	r5, r0
c0d007bc:	6820      	ldr	r0, [r4, #0]
c0d007be:	1940      	adds	r0, r0, r5
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
c0d007c0:	f000 fe44 	bl	c0d0144c <io_seproxyhal_display_default>
    default:
        UX_DEFAULT_EVENT();
        break;

    case SEPROXYHAL_TAG_DISPLAY_PROCESSED_EVENT:
        UX_DISPLAYED_EVENT({});
c0d007c4:	68a0      	ldr	r0, [r4, #8]
c0d007c6:	1c40      	adds	r0, r0, #1
c0d007c8:	60a0      	str	r0, [r4, #8]
c0d007ca:	6821      	ldr	r1, [r4, #0]
c0d007cc:	2900      	cmp	r1, #0
c0d007ce:	d1dd      	bne.n	c0d0078c <io_event+0x13c>
c0d007d0:	e1ea      	b.n	c0d00ba8 <io_event+0x558>
        break;

    case SEPROXYHAL_TAG_TICKER_EVENT:
        UX_TICKER_EVENT(G_io_seproxyhal_spi_buffer, {
c0d007d2:	4cfe      	ldr	r4, [pc, #1016]	; (c0d00bcc <io_event+0x57c>)
c0d007d4:	2001      	movs	r0, #1
c0d007d6:	7620      	strb	r0, [r4, #24]
c0d007d8:	2700      	movs	r7, #0
c0d007da:	61e7      	str	r7, [r4, #28]
c0d007dc:	4620      	mov	r0, r4
c0d007de:	3018      	adds	r0, #24
c0d007e0:	f001 fa4a 	bl	c0d01c78 <os_ux>
c0d007e4:	61e0      	str	r0, [r4, #28]
c0d007e6:	f001 f977 	bl	c0d01ad8 <ux_check_status_default>
c0d007ea:	69e5      	ldr	r5, [r4, #28]
c0d007ec:	42b5      	cmp	r5, r6
c0d007ee:	d000      	beq.n	c0d007f2 <io_event+0x1a2>
c0d007f0:	e0c1      	b.n	c0d00976 <io_event+0x326>
c0d007f2:	f000 fce5 	bl	c0d011c0 <io_seproxyhal_init_ux>
c0d007f6:	2000      	movs	r0, #0
c0d007f8:	60a0      	str	r0, [r4, #8]
c0d007fa:	6821      	ldr	r1, [r4, #0]
c0d007fc:	2900      	cmp	r1, #0
c0d007fe:	d100      	bne.n	c0d00802 <io_event+0x1b2>
c0d00800:	e1d8      	b.n	c0d00bb4 <io_event+0x564>
c0d00802:	69e1      	ldr	r1, [r4, #28]
c0d00804:	4af4      	ldr	r2, [pc, #976]	; (c0d00bd8 <io_event+0x588>)
c0d00806:	4291      	cmp	r1, r2
c0d00808:	d120      	bne.n	c0d0084c <io_event+0x1fc>
c0d0080a:	e1d3      	b.n	c0d00bb4 <io_event+0x564>
c0d0080c:	6861      	ldr	r1, [r4, #4]
c0d0080e:	4288      	cmp	r0, r1
c0d00810:	d300      	bcc.n	c0d00814 <io_event+0x1c4>
c0d00812:	e1cf      	b.n	c0d00bb4 <io_event+0x564>
c0d00814:	f001 fa5c 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d00818:	2800      	cmp	r0, #0
c0d0081a:	d000      	beq.n	c0d0081e <io_event+0x1ce>
c0d0081c:	e1ca      	b.n	c0d00bb4 <io_event+0x564>
c0d0081e:	68a0      	ldr	r0, [r4, #8]
c0d00820:	68e1      	ldr	r1, [r4, #12]
c0d00822:	2538      	movs	r5, #56	; 0x38
c0d00824:	4368      	muls	r0, r5
c0d00826:	6822      	ldr	r2, [r4, #0]
c0d00828:	1810      	adds	r0, r2, r0
c0d0082a:	2900      	cmp	r1, #0
c0d0082c:	d002      	beq.n	c0d00834 <io_event+0x1e4>
c0d0082e:	4788      	blx	r1
c0d00830:	2800      	cmp	r0, #0
c0d00832:	d007      	beq.n	c0d00844 <io_event+0x1f4>
c0d00834:	2801      	cmp	r0, #1
c0d00836:	d103      	bne.n	c0d00840 <io_event+0x1f0>
c0d00838:	68a0      	ldr	r0, [r4, #8]
c0d0083a:	4345      	muls	r5, r0
c0d0083c:	6820      	ldr	r0, [r4, #0]
c0d0083e:	1940      	adds	r0, r0, r5
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
c0d00840:	f000 fe04 	bl	c0d0144c <io_seproxyhal_display_default>
    case SEPROXYHAL_TAG_DISPLAY_PROCESSED_EVENT:
        UX_DISPLAYED_EVENT({});
        break;

    case SEPROXYHAL_TAG_TICKER_EVENT:
        UX_TICKER_EVENT(G_io_seproxyhal_spi_buffer, {
c0d00844:	68a0      	ldr	r0, [r4, #8]
c0d00846:	1c40      	adds	r0, r0, #1
c0d00848:	60a0      	str	r0, [r4, #8]
c0d0084a:	6821      	ldr	r1, [r4, #0]
c0d0084c:	2900      	cmp	r1, #0
c0d0084e:	d1dd      	bne.n	c0d0080c <io_event+0x1bc>
c0d00850:	e1b0      	b.n	c0d00bb4 <io_event+0x564>
    case SEPROXYHAL_TAG_FINGER_EVENT:
        UX_FINGER_EVENT(G_io_seproxyhal_spi_buffer);
        break;

    case SEPROXYHAL_TAG_BUTTON_PUSH_EVENT:
        UX_BUTTON_PUSH_EVENT(G_io_seproxyhal_spi_buffer);
c0d00852:	4cde      	ldr	r4, [pc, #888]	; (c0d00bcc <io_event+0x57c>)
c0d00854:	2001      	movs	r0, #1
c0d00856:	7620      	strb	r0, [r4, #24]
c0d00858:	2600      	movs	r6, #0
c0d0085a:	61e6      	str	r6, [r4, #28]
c0d0085c:	4620      	mov	r0, r4
c0d0085e:	3018      	adds	r0, #24
c0d00860:	f001 fa0a 	bl	c0d01c78 <os_ux>
c0d00864:	61e0      	str	r0, [r4, #28]
c0d00866:	f001 f937 	bl	c0d01ad8 <ux_check_status_default>
c0d0086a:	69e0      	ldr	r0, [r4, #28]
c0d0086c:	49da      	ldr	r1, [pc, #872]	; (c0d00bd8 <io_event+0x588>)
c0d0086e:	4288      	cmp	r0, r1
c0d00870:	d100      	bne.n	c0d00874 <io_event+0x224>
c0d00872:	e19f      	b.n	c0d00bb4 <io_event+0x564>
c0d00874:	2800      	cmp	r0, #0
c0d00876:	d100      	bne.n	c0d0087a <io_event+0x22a>
c0d00878:	e19c      	b.n	c0d00bb4 <io_event+0x564>
c0d0087a:	49d3      	ldr	r1, [pc, #844]	; (c0d00bc8 <io_event+0x578>)
c0d0087c:	4288      	cmp	r0, r1
c0d0087e:	d000      	beq.n	c0d00882 <io_event+0x232>
c0d00880:	e167      	b.n	c0d00b52 <io_event+0x502>
c0d00882:	f000 fc9d 	bl	c0d011c0 <io_seproxyhal_init_ux>
c0d00886:	60a6      	str	r6, [r4, #8]
c0d00888:	6820      	ldr	r0, [r4, #0]
c0d0088a:	2800      	cmp	r0, #0
c0d0088c:	d100      	bne.n	c0d00890 <io_event+0x240>
c0d0088e:	e191      	b.n	c0d00bb4 <io_event+0x564>
c0d00890:	69e0      	ldr	r0, [r4, #28]
c0d00892:	49d1      	ldr	r1, [pc, #836]	; (c0d00bd8 <io_event+0x588>)
c0d00894:	4288      	cmp	r0, r1
c0d00896:	d16b      	bne.n	c0d00970 <io_event+0x320>
c0d00898:	e18c      	b.n	c0d00bb4 <io_event+0x564>
              SEPROXYHAL_TAG_STATUS_EVENT_FLAG_USB_POWERED)) {
            THROW(EXCEPTION_IO_RESET);
        }
    // no break is intentional
    default:
        UX_DEFAULT_EVENT();
c0d0089a:	6820      	ldr	r0, [r4, #0]
c0d0089c:	2800      	cmp	r0, #0
c0d0089e:	d100      	bne.n	c0d008a2 <io_event+0x252>
c0d008a0:	e182      	b.n	c0d00ba8 <io_event+0x558>
c0d008a2:	68a0      	ldr	r0, [r4, #8]
c0d008a4:	6861      	ldr	r1, [r4, #4]
c0d008a6:	4288      	cmp	r0, r1
c0d008a8:	d300      	bcc.n	c0d008ac <io_event+0x25c>
c0d008aa:	e17d      	b.n	c0d00ba8 <io_event+0x558>
c0d008ac:	f001 fa10 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d008b0:	2800      	cmp	r0, #0
c0d008b2:	d000      	beq.n	c0d008b6 <io_event+0x266>
c0d008b4:	e178      	b.n	c0d00ba8 <io_event+0x558>
c0d008b6:	68a0      	ldr	r0, [r4, #8]
c0d008b8:	68e1      	ldr	r1, [r4, #12]
c0d008ba:	2538      	movs	r5, #56	; 0x38
c0d008bc:	4368      	muls	r0, r5
c0d008be:	6822      	ldr	r2, [r4, #0]
c0d008c0:	1810      	adds	r0, r2, r0
c0d008c2:	2900      	cmp	r1, #0
c0d008c4:	d002      	beq.n	c0d008cc <io_event+0x27c>
c0d008c6:	4788      	blx	r1
c0d008c8:	2800      	cmp	r0, #0
c0d008ca:	d007      	beq.n	c0d008dc <io_event+0x28c>
c0d008cc:	2801      	cmp	r0, #1
c0d008ce:	d103      	bne.n	c0d008d8 <io_event+0x288>
c0d008d0:	68a0      	ldr	r0, [r4, #8]
c0d008d2:	4345      	muls	r5, r0
c0d008d4:	6820      	ldr	r0, [r4, #0]
c0d008d6:	1940      	adds	r0, r0, r5
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
c0d008d8:	f000 fdb8 	bl	c0d0144c <io_seproxyhal_display_default>
              SEPROXYHAL_TAG_STATUS_EVENT_FLAG_USB_POWERED)) {
            THROW(EXCEPTION_IO_RESET);
        }
    // no break is intentional
    default:
        UX_DEFAULT_EVENT();
c0d008dc:	68a0      	ldr	r0, [r4, #8]
c0d008de:	1c40      	adds	r0, r0, #1
c0d008e0:	60a0      	str	r0, [r4, #8]
c0d008e2:	6821      	ldr	r1, [r4, #0]
c0d008e4:	2900      	cmp	r1, #0
c0d008e6:	d1dd      	bne.n	c0d008a4 <io_event+0x254>
c0d008e8:	e15e      	b.n	c0d00ba8 <io_event+0x558>
    // needed

    // can't have more than one tag in the reply, not supported yet.
    switch (G_io_seproxyhal_spi_buffer[0]) {
    case SEPROXYHAL_TAG_FINGER_EVENT:
        UX_FINGER_EVENT(G_io_seproxyhal_spi_buffer);
c0d008ea:	6860      	ldr	r0, [r4, #4]
c0d008ec:	4286      	cmp	r6, r0
c0d008ee:	d300      	bcc.n	c0d008f2 <io_event+0x2a2>
c0d008f0:	e160      	b.n	c0d00bb4 <io_event+0x564>
c0d008f2:	f001 f9ed 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d008f6:	2800      	cmp	r0, #0
c0d008f8:	d000      	beq.n	c0d008fc <io_event+0x2ac>
c0d008fa:	e15b      	b.n	c0d00bb4 <io_event+0x564>
c0d008fc:	68a0      	ldr	r0, [r4, #8]
c0d008fe:	68e1      	ldr	r1, [r4, #12]
c0d00900:	2538      	movs	r5, #56	; 0x38
c0d00902:	4368      	muls	r0, r5
c0d00904:	6822      	ldr	r2, [r4, #0]
c0d00906:	1810      	adds	r0, r2, r0
c0d00908:	2900      	cmp	r1, #0
c0d0090a:	d002      	beq.n	c0d00912 <io_event+0x2c2>
c0d0090c:	4788      	blx	r1
c0d0090e:	2800      	cmp	r0, #0
c0d00910:	d007      	beq.n	c0d00922 <io_event+0x2d2>
c0d00912:	2801      	cmp	r0, #1
c0d00914:	d103      	bne.n	c0d0091e <io_event+0x2ce>
c0d00916:	68a0      	ldr	r0, [r4, #8]
c0d00918:	4345      	muls	r5, r0
c0d0091a:	6820      	ldr	r0, [r4, #0]
c0d0091c:	1940      	adds	r0, r0, r5
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
c0d0091e:	f000 fd95 	bl	c0d0144c <io_seproxyhal_display_default>
    // needed

    // can't have more than one tag in the reply, not supported yet.
    switch (G_io_seproxyhal_spi_buffer[0]) {
    case SEPROXYHAL_TAG_FINGER_EVENT:
        UX_FINGER_EVENT(G_io_seproxyhal_spi_buffer);
c0d00922:	68a0      	ldr	r0, [r4, #8]
c0d00924:	1c46      	adds	r6, r0, #1
c0d00926:	60a6      	str	r6, [r4, #8]
c0d00928:	6820      	ldr	r0, [r4, #0]
c0d0092a:	2800      	cmp	r0, #0
c0d0092c:	d1dd      	bne.n	c0d008ea <io_event+0x29a>
c0d0092e:	e141      	b.n	c0d00bb4 <io_event+0x564>
        break;

    case SEPROXYHAL_TAG_BUTTON_PUSH_EVENT:
        UX_BUTTON_PUSH_EVENT(G_io_seproxyhal_spi_buffer);
c0d00930:	6860      	ldr	r0, [r4, #4]
c0d00932:	4286      	cmp	r6, r0
c0d00934:	d300      	bcc.n	c0d00938 <io_event+0x2e8>
c0d00936:	e13d      	b.n	c0d00bb4 <io_event+0x564>
c0d00938:	f001 f9ca 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d0093c:	2800      	cmp	r0, #0
c0d0093e:	d000      	beq.n	c0d00942 <io_event+0x2f2>
c0d00940:	e138      	b.n	c0d00bb4 <io_event+0x564>
c0d00942:	68a0      	ldr	r0, [r4, #8]
c0d00944:	68e1      	ldr	r1, [r4, #12]
c0d00946:	2538      	movs	r5, #56	; 0x38
c0d00948:	4368      	muls	r0, r5
c0d0094a:	6822      	ldr	r2, [r4, #0]
c0d0094c:	1810      	adds	r0, r2, r0
c0d0094e:	2900      	cmp	r1, #0
c0d00950:	d002      	beq.n	c0d00958 <io_event+0x308>
c0d00952:	4788      	blx	r1
c0d00954:	2800      	cmp	r0, #0
c0d00956:	d007      	beq.n	c0d00968 <io_event+0x318>
c0d00958:	2801      	cmp	r0, #1
c0d0095a:	d103      	bne.n	c0d00964 <io_event+0x314>
c0d0095c:	68a0      	ldr	r0, [r4, #8]
c0d0095e:	4345      	muls	r5, r0
c0d00960:	6820      	ldr	r0, [r4, #0]
c0d00962:	1940      	adds	r0, r0, r5
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
c0d00964:	f000 fd72 	bl	c0d0144c <io_seproxyhal_display_default>
    case SEPROXYHAL_TAG_FINGER_EVENT:
        UX_FINGER_EVENT(G_io_seproxyhal_spi_buffer);
        break;

    case SEPROXYHAL_TAG_BUTTON_PUSH_EVENT:
        UX_BUTTON_PUSH_EVENT(G_io_seproxyhal_spi_buffer);
c0d00968:	68a0      	ldr	r0, [r4, #8]
c0d0096a:	1c46      	adds	r6, r0, #1
c0d0096c:	60a6      	str	r6, [r4, #8]
c0d0096e:	6820      	ldr	r0, [r4, #0]
c0d00970:	2800      	cmp	r0, #0
c0d00972:	d1dd      	bne.n	c0d00930 <io_event+0x2e0>
c0d00974:	e11e      	b.n	c0d00bb4 <io_event+0x564>
    case SEPROXYHAL_TAG_DISPLAY_PROCESSED_EVENT:
        UX_DISPLAYED_EVENT({});
        break;

    case SEPROXYHAL_TAG_TICKER_EVENT:
        UX_TICKER_EVENT(G_io_seproxyhal_spi_buffer, {
c0d00976:	6960      	ldr	r0, [r4, #20]
c0d00978:	2800      	cmp	r0, #0
c0d0097a:	d04b      	beq.n	c0d00a14 <io_event+0x3c4>
c0d0097c:	2164      	movs	r1, #100	; 0x64
c0d0097e:	2864      	cmp	r0, #100	; 0x64
c0d00980:	4602      	mov	r2, r0
c0d00982:	d300      	bcc.n	c0d00986 <io_event+0x336>
c0d00984:	460a      	mov	r2, r1
c0d00986:	1a80      	subs	r0, r0, r2
c0d00988:	6160      	str	r0, [r4, #20]
c0d0098a:	3e11      	subs	r6, #17
c0d0098c:	42b5      	cmp	r5, r6
c0d0098e:	d041      	beq.n	c0d00a14 <io_event+0x3c4>
c0d00990:	2d00      	cmp	r5, #0
c0d00992:	d03f      	beq.n	c0d00a14 <io_event+0x3c4>
c0d00994:	2800      	cmp	r0, #0
c0d00996:	d13d      	bne.n	c0d00a14 <io_event+0x3c4>
c0d00998:	488d      	ldr	r0, [pc, #564]	; (c0d00bd0 <io_event+0x580>)
c0d0099a:	6801      	ldr	r1, [r0, #0]
c0d0099c:	2900      	cmp	r1, #0
c0d0099e:	d039      	beq.n	c0d00a14 <io_event+0x3c4>
c0d009a0:	4e8c      	ldr	r6, [pc, #560]	; (c0d00bd4 <io_event+0x584>)
c0d009a2:	6830      	ldr	r0, [r6, #0]
c0d009a4:	1c40      	adds	r0, r0, #1
c0d009a6:	f002 fd6d 	bl	c0d03484 <__aeabi_uidivmod>
c0d009aa:	6031      	str	r1, [r6, #0]
c0d009ac:	f000 fc08 	bl	c0d011c0 <io_seproxyhal_init_ux>
c0d009b0:	60a7      	str	r7, [r4, #8]
c0d009b2:	6820      	ldr	r0, [r4, #0]
c0d009b4:	2800      	cmp	r0, #0
c0d009b6:	d02d      	beq.n	c0d00a14 <io_event+0x3c4>
c0d009b8:	69e0      	ldr	r0, [r4, #28]
c0d009ba:	4987      	ldr	r1, [pc, #540]	; (c0d00bd8 <io_event+0x588>)
c0d009bc:	4288      	cmp	r0, r1
c0d009be:	d127      	bne.n	c0d00a10 <io_event+0x3c0>
c0d009c0:	e028      	b.n	c0d00a14 <io_event+0x3c4>
c0d009c2:	46c0      	nop			; (mov r8, r8)
c0d009c4:	20001c28 	.word	0x20001c28
c0d009c8:	b0105055 	.word	0xb0105055
c0d009cc:	20001ed0 	.word	0x20001ed0
c0d009d0:	20001830 	.word	0x20001830
c0d009d4:	6860      	ldr	r0, [r4, #4]
c0d009d6:	4287      	cmp	r7, r0
c0d009d8:	d21c      	bcs.n	c0d00a14 <io_event+0x3c4>
c0d009da:	f001 f979 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d009de:	2800      	cmp	r0, #0
c0d009e0:	d118      	bne.n	c0d00a14 <io_event+0x3c4>
c0d009e2:	68a0      	ldr	r0, [r4, #8]
c0d009e4:	68e1      	ldr	r1, [r4, #12]
c0d009e6:	2638      	movs	r6, #56	; 0x38
c0d009e8:	4370      	muls	r0, r6
c0d009ea:	6822      	ldr	r2, [r4, #0]
c0d009ec:	1810      	adds	r0, r2, r0
c0d009ee:	2900      	cmp	r1, #0
c0d009f0:	d002      	beq.n	c0d009f8 <io_event+0x3a8>
c0d009f2:	4788      	blx	r1
c0d009f4:	2800      	cmp	r0, #0
c0d009f6:	d007      	beq.n	c0d00a08 <io_event+0x3b8>
c0d009f8:	2801      	cmp	r0, #1
c0d009fa:	d103      	bne.n	c0d00a04 <io_event+0x3b4>
c0d009fc:	68a0      	ldr	r0, [r4, #8]
c0d009fe:	4346      	muls	r6, r0
c0d00a00:	6820      	ldr	r0, [r4, #0]
c0d00a02:	1980      	adds	r0, r0, r6
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
c0d00a04:	f000 fd22 	bl	c0d0144c <io_seproxyhal_display_default>
    case SEPROXYHAL_TAG_DISPLAY_PROCESSED_EVENT:
        UX_DISPLAYED_EVENT({});
        break;

    case SEPROXYHAL_TAG_TICKER_EVENT:
        UX_TICKER_EVENT(G_io_seproxyhal_spi_buffer, {
c0d00a08:	68a0      	ldr	r0, [r4, #8]
c0d00a0a:	1c47      	adds	r7, r0, #1
c0d00a0c:	60a7      	str	r7, [r4, #8]
c0d00a0e:	6820      	ldr	r0, [r4, #0]
c0d00a10:	2800      	cmp	r0, #0
c0d00a12:	d1df      	bne.n	c0d009d4 <io_event+0x384>
c0d00a14:	4870      	ldr	r0, [pc, #448]	; (c0d00bd8 <io_event+0x588>)
c0d00a16:	4285      	cmp	r5, r0
c0d00a18:	d100      	bne.n	c0d00a1c <io_event+0x3cc>
c0d00a1a:	e0cb      	b.n	c0d00bb4 <io_event+0x564>
c0d00a1c:	2d00      	cmp	r5, #0
c0d00a1e:	d100      	bne.n	c0d00a22 <io_event+0x3d2>
c0d00a20:	e0c8      	b.n	c0d00bb4 <io_event+0x564>
c0d00a22:	6820      	ldr	r0, [r4, #0]
c0d00a24:	2800      	cmp	r0, #0
c0d00a26:	d100      	bne.n	c0d00a2a <io_event+0x3da>
c0d00a28:	e0be      	b.n	c0d00ba8 <io_event+0x558>
c0d00a2a:	68a0      	ldr	r0, [r4, #8]
c0d00a2c:	6861      	ldr	r1, [r4, #4]
c0d00a2e:	4288      	cmp	r0, r1
c0d00a30:	d300      	bcc.n	c0d00a34 <io_event+0x3e4>
c0d00a32:	e0b9      	b.n	c0d00ba8 <io_event+0x558>
c0d00a34:	f001 f94c 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d00a38:	2800      	cmp	r0, #0
c0d00a3a:	d000      	beq.n	c0d00a3e <io_event+0x3ee>
c0d00a3c:	e0b4      	b.n	c0d00ba8 <io_event+0x558>
c0d00a3e:	68a0      	ldr	r0, [r4, #8]
c0d00a40:	68e1      	ldr	r1, [r4, #12]
c0d00a42:	2538      	movs	r5, #56	; 0x38
c0d00a44:	4368      	muls	r0, r5
c0d00a46:	6822      	ldr	r2, [r4, #0]
c0d00a48:	1810      	adds	r0, r2, r0
c0d00a4a:	2900      	cmp	r1, #0
c0d00a4c:	d002      	beq.n	c0d00a54 <io_event+0x404>
c0d00a4e:	4788      	blx	r1
c0d00a50:	2800      	cmp	r0, #0
c0d00a52:	d007      	beq.n	c0d00a64 <io_event+0x414>
c0d00a54:	2801      	cmp	r0, #1
c0d00a56:	d103      	bne.n	c0d00a60 <io_event+0x410>
c0d00a58:	68a0      	ldr	r0, [r4, #8]
c0d00a5a:	4345      	muls	r5, r0
c0d00a5c:	6820      	ldr	r0, [r4, #0]
c0d00a5e:	1940      	adds	r0, r0, r5
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
c0d00a60:	f000 fcf4 	bl	c0d0144c <io_seproxyhal_display_default>
    case SEPROXYHAL_TAG_DISPLAY_PROCESSED_EVENT:
        UX_DISPLAYED_EVENT({});
        break;

    case SEPROXYHAL_TAG_TICKER_EVENT:
        UX_TICKER_EVENT(G_io_seproxyhal_spi_buffer, {
c0d00a64:	68a0      	ldr	r0, [r4, #8]
c0d00a66:	1c40      	adds	r0, r0, #1
c0d00a68:	60a0      	str	r0, [r4, #8]
c0d00a6a:	6821      	ldr	r1, [r4, #0]
c0d00a6c:	2900      	cmp	r1, #0
c0d00a6e:	d1dd      	bne.n	c0d00a2c <io_event+0x3dc>
c0d00a70:	e09a      	b.n	c0d00ba8 <io_event+0x558>
    default:
        UX_DEFAULT_EVENT();
        break;

    case SEPROXYHAL_TAG_DISPLAY_PROCESSED_EVENT:
        UX_DISPLAYED_EVENT({});
c0d00a72:	f000 fba5 	bl	c0d011c0 <io_seproxyhal_init_ux>
c0d00a76:	60a5      	str	r5, [r4, #8]
c0d00a78:	6820      	ldr	r0, [r4, #0]
c0d00a7a:	2800      	cmp	r0, #0
c0d00a7c:	d100      	bne.n	c0d00a80 <io_event+0x430>
c0d00a7e:	e099      	b.n	c0d00bb4 <io_event+0x564>
c0d00a80:	69e0      	ldr	r0, [r4, #28]
c0d00a82:	4955      	ldr	r1, [pc, #340]	; (c0d00bd8 <io_event+0x588>)
c0d00a84:	4288      	cmp	r0, r1
c0d00a86:	d127      	bne.n	c0d00ad8 <io_event+0x488>
c0d00a88:	e094      	b.n	c0d00bb4 <io_event+0x564>
c0d00a8a:	46c0      	nop			; (mov r8, r8)
c0d00a8c:	b0105055 	.word	0xb0105055
c0d00a90:	20001830 	.word	0x20001830
c0d00a94:	b0105044 	.word	0xb0105044
c0d00a98:	6860      	ldr	r0, [r4, #4]
c0d00a9a:	4285      	cmp	r5, r0
c0d00a9c:	d300      	bcc.n	c0d00aa0 <io_event+0x450>
c0d00a9e:	e089      	b.n	c0d00bb4 <io_event+0x564>
c0d00aa0:	f001 f916 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d00aa4:	2800      	cmp	r0, #0
c0d00aa6:	d000      	beq.n	c0d00aaa <io_event+0x45a>
c0d00aa8:	e084      	b.n	c0d00bb4 <io_event+0x564>
c0d00aaa:	68a0      	ldr	r0, [r4, #8]
c0d00aac:	68e1      	ldr	r1, [r4, #12]
c0d00aae:	2538      	movs	r5, #56	; 0x38
c0d00ab0:	4368      	muls	r0, r5
c0d00ab2:	6822      	ldr	r2, [r4, #0]
c0d00ab4:	1810      	adds	r0, r2, r0
c0d00ab6:	2900      	cmp	r1, #0
c0d00ab8:	d002      	beq.n	c0d00ac0 <io_event+0x470>
c0d00aba:	4788      	blx	r1
c0d00abc:	2800      	cmp	r0, #0
c0d00abe:	d007      	beq.n	c0d00ad0 <io_event+0x480>
c0d00ac0:	2801      	cmp	r0, #1
c0d00ac2:	d103      	bne.n	c0d00acc <io_event+0x47c>
c0d00ac4:	68a0      	ldr	r0, [r4, #8]
c0d00ac6:	4345      	muls	r5, r0
c0d00ac8:	6820      	ldr	r0, [r4, #0]
c0d00aca:	1940      	adds	r0, r0, r5
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
c0d00acc:	f000 fcbe 	bl	c0d0144c <io_seproxyhal_display_default>
    default:
        UX_DEFAULT_EVENT();
        break;

    case SEPROXYHAL_TAG_DISPLAY_PROCESSED_EVENT:
        UX_DISPLAYED_EVENT({});
c0d00ad0:	68a0      	ldr	r0, [r4, #8]
c0d00ad2:	1c45      	adds	r5, r0, #1
c0d00ad4:	60a5      	str	r5, [r4, #8]
c0d00ad6:	6820      	ldr	r0, [r4, #0]
c0d00ad8:	2800      	cmp	r0, #0
c0d00ada:	d1dd      	bne.n	c0d00a98 <io_event+0x448>
c0d00adc:	e06a      	b.n	c0d00bb4 <io_event+0x564>
    // needed

    // can't have more than one tag in the reply, not supported yet.
    switch (G_io_seproxyhal_spi_buffer[0]) {
    case SEPROXYHAL_TAG_FINGER_EVENT:
        UX_FINGER_EVENT(G_io_seproxyhal_spi_buffer);
c0d00ade:	88a0      	ldrh	r0, [r4, #4]
c0d00ae0:	9004      	str	r0, [sp, #16]
c0d00ae2:	6820      	ldr	r0, [r4, #0]
c0d00ae4:	9003      	str	r0, [sp, #12]
c0d00ae6:	79ee      	ldrb	r6, [r5, #7]
c0d00ae8:	79ab      	ldrb	r3, [r5, #6]
c0d00aea:	796f      	ldrb	r7, [r5, #5]
c0d00aec:	792a      	ldrb	r2, [r5, #4]
c0d00aee:	78ed      	ldrb	r5, [r5, #3]
c0d00af0:	68e1      	ldr	r1, [r4, #12]
c0d00af2:	4668      	mov	r0, sp
c0d00af4:	6005      	str	r5, [r0, #0]
c0d00af6:	6041      	str	r1, [r0, #4]
c0d00af8:	0212      	lsls	r2, r2, #8
c0d00afa:	433a      	orrs	r2, r7
c0d00afc:	021b      	lsls	r3, r3, #8
c0d00afe:	4333      	orrs	r3, r6
c0d00b00:	9803      	ldr	r0, [sp, #12]
c0d00b02:	9904      	ldr	r1, [sp, #16]
c0d00b04:	f000 fbd4 	bl	c0d012b0 <io_seproxyhal_touch_element_callback>
c0d00b08:	6820      	ldr	r0, [r4, #0]
c0d00b0a:	2800      	cmp	r0, #0
c0d00b0c:	d04c      	beq.n	c0d00ba8 <io_event+0x558>
c0d00b0e:	68a0      	ldr	r0, [r4, #8]
c0d00b10:	6861      	ldr	r1, [r4, #4]
c0d00b12:	4288      	cmp	r0, r1
c0d00b14:	d248      	bcs.n	c0d00ba8 <io_event+0x558>
c0d00b16:	f001 f8db 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d00b1a:	2800      	cmp	r0, #0
c0d00b1c:	d144      	bne.n	c0d00ba8 <io_event+0x558>
c0d00b1e:	68a0      	ldr	r0, [r4, #8]
c0d00b20:	68e1      	ldr	r1, [r4, #12]
c0d00b22:	2538      	movs	r5, #56	; 0x38
c0d00b24:	4368      	muls	r0, r5
c0d00b26:	6822      	ldr	r2, [r4, #0]
c0d00b28:	1810      	adds	r0, r2, r0
c0d00b2a:	2900      	cmp	r1, #0
c0d00b2c:	d002      	beq.n	c0d00b34 <io_event+0x4e4>
c0d00b2e:	4788      	blx	r1
c0d00b30:	2800      	cmp	r0, #0
c0d00b32:	d007      	beq.n	c0d00b44 <io_event+0x4f4>
c0d00b34:	2801      	cmp	r0, #1
c0d00b36:	d103      	bne.n	c0d00b40 <io_event+0x4f0>
c0d00b38:	68a0      	ldr	r0, [r4, #8]
c0d00b3a:	4345      	muls	r5, r0
c0d00b3c:	6820      	ldr	r0, [r4, #0]
c0d00b3e:	1940      	adds	r0, r0, r5
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
c0d00b40:	f000 fc84 	bl	c0d0144c <io_seproxyhal_display_default>
    // needed

    // can't have more than one tag in the reply, not supported yet.
    switch (G_io_seproxyhal_spi_buffer[0]) {
    case SEPROXYHAL_TAG_FINGER_EVENT:
        UX_FINGER_EVENT(G_io_seproxyhal_spi_buffer);
c0d00b44:	68a0      	ldr	r0, [r4, #8]
c0d00b46:	1c40      	adds	r0, r0, #1
c0d00b48:	60a0      	str	r0, [r4, #8]
c0d00b4a:	6821      	ldr	r1, [r4, #0]
c0d00b4c:	2900      	cmp	r1, #0
c0d00b4e:	d1df      	bne.n	c0d00b10 <io_event+0x4c0>
c0d00b50:	e02a      	b.n	c0d00ba8 <io_event+0x558>
        break;

    case SEPROXYHAL_TAG_BUTTON_PUSH_EVENT:
        UX_BUTTON_PUSH_EVENT(G_io_seproxyhal_spi_buffer);
c0d00b52:	6920      	ldr	r0, [r4, #16]
c0d00b54:	2800      	cmp	r0, #0
c0d00b56:	d003      	beq.n	c0d00b60 <io_event+0x510>
c0d00b58:	78e9      	ldrb	r1, [r5, #3]
c0d00b5a:	0849      	lsrs	r1, r1, #1
c0d00b5c:	f000 fce4 	bl	c0d01528 <io_seproxyhal_button_push>
c0d00b60:	6820      	ldr	r0, [r4, #0]
c0d00b62:	2800      	cmp	r0, #0
c0d00b64:	d020      	beq.n	c0d00ba8 <io_event+0x558>
c0d00b66:	68a0      	ldr	r0, [r4, #8]
c0d00b68:	6861      	ldr	r1, [r4, #4]
c0d00b6a:	4288      	cmp	r0, r1
c0d00b6c:	d21c      	bcs.n	c0d00ba8 <io_event+0x558>
c0d00b6e:	f001 f8af 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d00b72:	2800      	cmp	r0, #0
c0d00b74:	d118      	bne.n	c0d00ba8 <io_event+0x558>
c0d00b76:	68a0      	ldr	r0, [r4, #8]
c0d00b78:	68e1      	ldr	r1, [r4, #12]
c0d00b7a:	2538      	movs	r5, #56	; 0x38
c0d00b7c:	4368      	muls	r0, r5
c0d00b7e:	6822      	ldr	r2, [r4, #0]
c0d00b80:	1810      	adds	r0, r2, r0
c0d00b82:	2900      	cmp	r1, #0
c0d00b84:	d002      	beq.n	c0d00b8c <io_event+0x53c>
c0d00b86:	4788      	blx	r1
c0d00b88:	2800      	cmp	r0, #0
c0d00b8a:	d007      	beq.n	c0d00b9c <io_event+0x54c>
c0d00b8c:	2801      	cmp	r0, #1
c0d00b8e:	d103      	bne.n	c0d00b98 <io_event+0x548>
c0d00b90:	68a0      	ldr	r0, [r4, #8]
c0d00b92:	4345      	muls	r5, r0
c0d00b94:	6820      	ldr	r0, [r4, #0]
c0d00b96:	1940      	adds	r0, r0, r5
    return;
}

// override point, but nothing more to do
void io_seproxyhal_display(const bagl_element_t *element) {
    io_seproxyhal_display_default((bagl_element_t *)element);
c0d00b98:	f000 fc58 	bl	c0d0144c <io_seproxyhal_display_default>
    case SEPROXYHAL_TAG_FINGER_EVENT:
        UX_FINGER_EVENT(G_io_seproxyhal_spi_buffer);
        break;

    case SEPROXYHAL_TAG_BUTTON_PUSH_EVENT:
        UX_BUTTON_PUSH_EVENT(G_io_seproxyhal_spi_buffer);
c0d00b9c:	68a0      	ldr	r0, [r4, #8]
c0d00b9e:	1c40      	adds	r0, r0, #1
c0d00ba0:	60a0      	str	r0, [r4, #8]
c0d00ba2:	6821      	ldr	r1, [r4, #0]
c0d00ba4:	2900      	cmp	r1, #0
c0d00ba6:	d1df      	bne.n	c0d00b68 <io_event+0x518>
c0d00ba8:	6860      	ldr	r0, [r4, #4]
c0d00baa:	68a1      	ldr	r1, [r4, #8]
c0d00bac:	4281      	cmp	r1, r0
c0d00bae:	d301      	bcc.n	c0d00bb4 <io_event+0x564>
c0d00bb0:	f001 f88e 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
        });
        break;
    }

    // close the event if not done previously (by a display or whatever)
    if (!io_seproxyhal_spi_is_status_sent()) {
c0d00bb4:	f001 f88c 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d00bb8:	2800      	cmp	r0, #0
c0d00bba:	d101      	bne.n	c0d00bc0 <io_event+0x570>
        io_seproxyhal_general_status();
c0d00bbc:	f000 f9ac 	bl	c0d00f18 <io_seproxyhal_general_status>
    }

    // command has been processed, DO NOT reset the current APDU transport
    return 1;
c0d00bc0:	2001      	movs	r0, #1
c0d00bc2:	b005      	add	sp, #20
c0d00bc4:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00bc6:	46c0      	nop			; (mov r8, r8)
c0d00bc8:	b0105055 	.word	0xb0105055
c0d00bcc:	20001830 	.word	0x20001830
c0d00bd0:	20001be0 	.word	0x20001be0
c0d00bd4:	2000182c 	.word	0x2000182c
c0d00bd8:	b0105044 	.word	0xb0105044

c0d00bdc <app_exit>:
}


// Exit application
void app_exit(void) {
c0d00bdc:	b510      	push	{r4, lr}
c0d00bde:	b08c      	sub	sp, #48	; 0x30
c0d00be0:	ac01      	add	r4, sp, #4
    BEGIN_TRY_L(exit) {
        TRY_L(exit) {
c0d00be2:	4620      	mov	r0, r4
c0d00be4:	f002 fca8 	bl	c0d03538 <setjmp>
c0d00be8:	8520      	strh	r0, [r4, #40]	; 0x28
c0d00bea:	490d      	ldr	r1, [pc, #52]	; (c0d00c20 <app_exit+0x44>)
c0d00bec:	4208      	tst	r0, r1
c0d00bee:	d106      	bne.n	c0d00bfe <app_exit+0x22>
c0d00bf0:	a801      	add	r0, sp, #4
c0d00bf2:	f000 f81a 	bl	c0d00c2a <try_context_set>
            os_sched_exit(-1);
c0d00bf6:	2000      	movs	r0, #0
c0d00bf8:	43c0      	mvns	r0, r0
c0d00bfa:	f001 f827 	bl	c0d01c4c <os_sched_exit>
        }
        FINALLY_L(exit) {
c0d00bfe:	f000 f983 	bl	c0d00f08 <try_context_get>
c0d00c02:	a901      	add	r1, sp, #4
c0d00c04:	4288      	cmp	r0, r1
c0d00c06:	d103      	bne.n	c0d00c10 <app_exit+0x34>
c0d00c08:	f000 f980 	bl	c0d00f0c <try_context_get_previous>
c0d00c0c:	f000 f80d 	bl	c0d00c2a <try_context_set>
c0d00c10:	a801      	add	r0, sp, #4
        }
    }
    END_TRY_L(exit);
c0d00c12:	8d00      	ldrh	r0, [r0, #40]	; 0x28
c0d00c14:	2800      	cmp	r0, #0
c0d00c16:	d101      	bne.n	c0d00c1c <app_exit+0x40>
}
c0d00c18:	b00c      	add	sp, #48	; 0x30
c0d00c1a:	bd10      	pop	{r4, pc}
            os_sched_exit(-1);
        }
        FINALLY_L(exit) {
        }
    }
    END_TRY_L(exit);
c0d00c1c:	f000 f96f 	bl	c0d00efe <os_longjmp>
c0d00c20:	0000ffff 	.word	0x0000ffff

c0d00c24 <os_boot>:
  //                ^ platform register
  return (try_context_t*) current_ctx->jmp_buf[5];
}

void try_context_set(try_context_t* ctx) {
  __asm volatile ("mov r9, %0"::"r"(ctx));
c0d00c24:	2000      	movs	r0, #0
c0d00c26:	4681      	mov	r9, r0
void os_boot(void) {
  // TODO patch entry point when romming (f)

  // set the default try context to nothing
  try_context_set(NULL);
}
c0d00c28:	4770      	bx	lr

c0d00c2a <try_context_set>:
  //                ^ platform register
  return (try_context_t*) current_ctx->jmp_buf[5];
}

void try_context_set(try_context_t* ctx) {
  __asm volatile ("mov r9, %0"::"r"(ctx));
c0d00c2a:	4681      	mov	r9, r0
}
c0d00c2c:	4770      	bx	lr
	...

c0d00c30 <io_usb_hid_receive>:
volatile unsigned int   G_io_usb_hid_channel;
volatile unsigned int   G_io_usb_hid_remaining_length;
volatile unsigned int   G_io_usb_hid_sequence_number;
volatile unsigned char* G_io_usb_hid_current_buffer;

io_usb_hid_receive_status_t io_usb_hid_receive (io_send_t sndfct, unsigned char* buffer, unsigned short l) {
c0d00c30:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00c32:	b081      	sub	sp, #4
c0d00c34:	9200      	str	r2, [sp, #0]
c0d00c36:	460f      	mov	r7, r1
c0d00c38:	4605      	mov	r5, r0
  // avoid over/under flows
  if (buffer != G_io_usb_ep_buffer) {
c0d00c3a:	4b49      	ldr	r3, [pc, #292]	; (c0d00d60 <io_usb_hid_receive+0x130>)
c0d00c3c:	429f      	cmp	r7, r3
c0d00c3e:	d00f      	beq.n	c0d00c60 <io_usb_hid_receive+0x30>
}

void os_memset(void * dst, unsigned char c, unsigned int length) {
#define DSTCHAR ((unsigned char *)dst)
  while(length--) {
    DSTCHAR[length] = c;
c0d00c40:	4c47      	ldr	r4, [pc, #284]	; (c0d00d60 <io_usb_hid_receive+0x130>)
c0d00c42:	2640      	movs	r6, #64	; 0x40
c0d00c44:	4620      	mov	r0, r4
c0d00c46:	4631      	mov	r1, r6
c0d00c48:	f002 fc22 	bl	c0d03490 <__aeabi_memclr>
c0d00c4c:	9800      	ldr	r0, [sp, #0]

io_usb_hid_receive_status_t io_usb_hid_receive (io_send_t sndfct, unsigned char* buffer, unsigned short l) {
  // avoid over/under flows
  if (buffer != G_io_usb_ep_buffer) {
    os_memset(G_io_usb_ep_buffer, 0, sizeof(G_io_usb_ep_buffer));
    os_memmove(G_io_usb_ep_buffer, buffer, MIN(l, sizeof(G_io_usb_ep_buffer)));
c0d00c4e:	2840      	cmp	r0, #64	; 0x40
c0d00c50:	4602      	mov	r2, r0
c0d00c52:	d300      	bcc.n	c0d00c56 <io_usb_hid_receive+0x26>
c0d00c54:	4632      	mov	r2, r6
c0d00c56:	4620      	mov	r0, r4
c0d00c58:	4639      	mov	r1, r7
c0d00c5a:	f000 f89c 	bl	c0d00d96 <os_memmove>
c0d00c5e:	4b40      	ldr	r3, [pc, #256]	; (c0d00d60 <io_usb_hid_receive+0x130>)
c0d00c60:	7898      	ldrb	r0, [r3, #2]
  }

  // process the chunk content
  switch(G_io_usb_ep_buffer[2]) {
c0d00c62:	2801      	cmp	r0, #1
c0d00c64:	dc0b      	bgt.n	c0d00c7e <io_usb_hid_receive+0x4e>
c0d00c66:	2800      	cmp	r0, #0
c0d00c68:	d02a      	beq.n	c0d00cc0 <io_usb_hid_receive+0x90>
c0d00c6a:	2801      	cmp	r0, #1
c0d00c6c:	d16a      	bne.n	c0d00d44 <io_usb_hid_receive+0x114>
    // await for the next chunk
    goto apdu_reset;

  case 0x01: // ALLOCATE CHANNEL
    // do not reset the current apdu reception if any
    cx_rng(G_io_usb_ep_buffer+3, 4);
c0d00c6e:	1cd8      	adds	r0, r3, #3
c0d00c70:	2104      	movs	r1, #4
c0d00c72:	461c      	mov	r4, r3
c0d00c74:	f000 ff8a 	bl	c0d01b8c <cx_rng>
    // send the response
    sndfct(G_io_usb_ep_buffer, IO_HID_EP_LENGTH);
c0d00c78:	2140      	movs	r1, #64	; 0x40
c0d00c7a:	4620      	mov	r0, r4
c0d00c7c:	e02b      	b.n	c0d00cd6 <io_usb_hid_receive+0xa6>
c0d00c7e:	2802      	cmp	r0, #2
c0d00c80:	d027      	beq.n	c0d00cd2 <io_usb_hid_receive+0xa2>
c0d00c82:	2805      	cmp	r0, #5
c0d00c84:	d15e      	bne.n	c0d00d44 <io_usb_hid_receive+0x114>

  // process the chunk content
  switch(G_io_usb_ep_buffer[2]) {
  case 0x05:
    // ensure sequence idx is 0 for the first chunk ! 
    if (U2BE(G_io_usb_ep_buffer, 3) != G_io_usb_hid_sequence_number) {
c0d00c86:	7918      	ldrb	r0, [r3, #4]
c0d00c88:	78d9      	ldrb	r1, [r3, #3]
c0d00c8a:	0209      	lsls	r1, r1, #8
c0d00c8c:	4301      	orrs	r1, r0
c0d00c8e:	4a35      	ldr	r2, [pc, #212]	; (c0d00d64 <io_usb_hid_receive+0x134>)
c0d00c90:	6810      	ldr	r0, [r2, #0]
c0d00c92:	2400      	movs	r4, #0
c0d00c94:	4281      	cmp	r1, r0
c0d00c96:	d15b      	bne.n	c0d00d50 <io_usb_hid_receive+0x120>
c0d00c98:	4e33      	ldr	r6, [pc, #204]	; (c0d00d68 <io_usb_hid_receive+0x138>)
      // ignore packet
      goto apdu_reset;
    }
    // cid, tag, seq
    l -= 2+1+2;
c0d00c9a:	9800      	ldr	r0, [sp, #0]
c0d00c9c:	1980      	adds	r0, r0, r6
c0d00c9e:	1f07      	subs	r7, r0, #4
    
    // append the received chunk to the current command apdu
    if (G_io_usb_hid_sequence_number == 0) {
c0d00ca0:	6810      	ldr	r0, [r2, #0]
c0d00ca2:	2800      	cmp	r0, #0
c0d00ca4:	d01a      	beq.n	c0d00cdc <io_usb_hid_receive+0xac>
      // copy data
      os_memmove((void*)G_io_usb_hid_current_buffer, G_io_usb_ep_buffer+7, l);
    }
    else {
      // check for invalid length encoding (more data in chunk that announced in the total apdu)
      if (l > G_io_usb_hid_remaining_length) {
c0d00ca6:	4639      	mov	r1, r7
c0d00ca8:	4031      	ands	r1, r6
c0d00caa:	4830      	ldr	r0, [pc, #192]	; (c0d00d6c <io_usb_hid_receive+0x13c>)
c0d00cac:	6802      	ldr	r2, [r0, #0]
c0d00cae:	4291      	cmp	r1, r2
c0d00cb0:	d900      	bls.n	c0d00cb4 <io_usb_hid_receive+0x84>
        l = G_io_usb_hid_remaining_length;
c0d00cb2:	6807      	ldr	r7, [r0, #0]
      }

      /// This is a following chunk
      // append content
      os_memmove((void*)G_io_usb_hid_current_buffer, G_io_usb_ep_buffer+5, l);
c0d00cb4:	463a      	mov	r2, r7
c0d00cb6:	4032      	ands	r2, r6
c0d00cb8:	482d      	ldr	r0, [pc, #180]	; (c0d00d70 <io_usb_hid_receive+0x140>)
c0d00cba:	6800      	ldr	r0, [r0, #0]
c0d00cbc:	1d59      	adds	r1, r3, #5
c0d00cbe:	e031      	b.n	c0d00d24 <io_usb_hid_receive+0xf4>
c0d00cc0:	2400      	movs	r4, #0
}

void os_memset(void * dst, unsigned char c, unsigned int length) {
#define DSTCHAR ((unsigned char *)dst)
  while(length--) {
    DSTCHAR[length] = c;
c0d00cc2:	719c      	strb	r4, [r3, #6]
c0d00cc4:	715c      	strb	r4, [r3, #5]
c0d00cc6:	711c      	strb	r4, [r3, #4]
c0d00cc8:	70dc      	strb	r4, [r3, #3]

  case 0x00: // get version ID
    // do not reset the current apdu reception if any
    os_memset(G_io_usb_ep_buffer+3, 0, 4); // PROTOCOL VERSION is 0
    // send the response
    sndfct(G_io_usb_ep_buffer, IO_HID_EP_LENGTH);
c0d00cca:	2140      	movs	r1, #64	; 0x40
c0d00ccc:	4618      	mov	r0, r3
c0d00cce:	47a8      	blx	r5
c0d00cd0:	e03e      	b.n	c0d00d50 <io_usb_hid_receive+0x120>
    goto apdu_reset;

  case 0x02: // ECHO|PING
    // do not reset the current apdu reception if any
    // send the response
    sndfct(G_io_usb_ep_buffer, IO_HID_EP_LENGTH);
c0d00cd2:	4823      	ldr	r0, [pc, #140]	; (c0d00d60 <io_usb_hid_receive+0x130>)
c0d00cd4:	2140      	movs	r1, #64	; 0x40
c0d00cd6:	47a8      	blx	r5
c0d00cd8:	2400      	movs	r4, #0
c0d00cda:	e039      	b.n	c0d00d50 <io_usb_hid_receive+0x120>
    
    // append the received chunk to the current command apdu
    if (G_io_usb_hid_sequence_number == 0) {
      /// This is the apdu first chunk
      // total apdu size to receive
      G_io_usb_hid_total_length = U2BE(G_io_usb_ep_buffer, 5); //(G_io_usb_ep_buffer[5]<<8)+(G_io_usb_ep_buffer[6]&0xFF);
c0d00cdc:	7998      	ldrb	r0, [r3, #6]
c0d00cde:	7959      	ldrb	r1, [r3, #5]
c0d00ce0:	0209      	lsls	r1, r1, #8
c0d00ce2:	4301      	orrs	r1, r0
c0d00ce4:	4823      	ldr	r0, [pc, #140]	; (c0d00d74 <io_usb_hid_receive+0x144>)
c0d00ce6:	6001      	str	r1, [r0, #0]
      // check for invalid length encoding (more data in chunk that announced in the total apdu)
      if (G_io_usb_hid_total_length > sizeof(G_io_apdu_buffer)) {
c0d00ce8:	6801      	ldr	r1, [r0, #0]
c0d00cea:	2241      	movs	r2, #65	; 0x41
c0d00cec:	0092      	lsls	r2, r2, #2
c0d00cee:	4291      	cmp	r1, r2
c0d00cf0:	d82e      	bhi.n	c0d00d50 <io_usb_hid_receive+0x120>
        goto apdu_reset;
      }
      // seq and total length
      l -= 2;
      // compute remaining size to receive
      G_io_usb_hid_remaining_length = G_io_usb_hid_total_length;
c0d00cf2:	6801      	ldr	r1, [r0, #0]
c0d00cf4:	481d      	ldr	r0, [pc, #116]	; (c0d00d6c <io_usb_hid_receive+0x13c>)
c0d00cf6:	6001      	str	r1, [r0, #0]
      G_io_usb_hid_current_buffer = G_io_apdu_buffer;
c0d00cf8:	491d      	ldr	r1, [pc, #116]	; (c0d00d70 <io_usb_hid_receive+0x140>)
c0d00cfa:	4a1f      	ldr	r2, [pc, #124]	; (c0d00d78 <io_usb_hid_receive+0x148>)
c0d00cfc:	600a      	str	r2, [r1, #0]

      // retain the channel id to use for the reply
      G_io_usb_hid_channel = U2BE(G_io_usb_ep_buffer, 0);
c0d00cfe:	7859      	ldrb	r1, [r3, #1]
c0d00d00:	781a      	ldrb	r2, [r3, #0]
c0d00d02:	0212      	lsls	r2, r2, #8
c0d00d04:	430a      	orrs	r2, r1
c0d00d06:	491d      	ldr	r1, [pc, #116]	; (c0d00d7c <io_usb_hid_receive+0x14c>)
c0d00d08:	600a      	str	r2, [r1, #0]
      // check for invalid length encoding (more data in chunk that announced in the total apdu)
      if (G_io_usb_hid_total_length > sizeof(G_io_apdu_buffer)) {
        goto apdu_reset;
      }
      // seq and total length
      l -= 2;
c0d00d0a:	491d      	ldr	r1, [pc, #116]	; (c0d00d80 <io_usb_hid_receive+0x150>)
c0d00d0c:	9a00      	ldr	r2, [sp, #0]
c0d00d0e:	1857      	adds	r7, r2, r1
      G_io_usb_hid_current_buffer = G_io_apdu_buffer;

      // retain the channel id to use for the reply
      G_io_usb_hid_channel = U2BE(G_io_usb_ep_buffer, 0);

      if (l > G_io_usb_hid_remaining_length) {
c0d00d10:	4639      	mov	r1, r7
c0d00d12:	4031      	ands	r1, r6
c0d00d14:	6802      	ldr	r2, [r0, #0]
c0d00d16:	4291      	cmp	r1, r2
c0d00d18:	d900      	bls.n	c0d00d1c <io_usb_hid_receive+0xec>
        l = G_io_usb_hid_remaining_length;
c0d00d1a:	6807      	ldr	r7, [r0, #0]
      }
      // copy data
      os_memmove((void*)G_io_usb_hid_current_buffer, G_io_usb_ep_buffer+7, l);
c0d00d1c:	463a      	mov	r2, r7
c0d00d1e:	4032      	ands	r2, r6
c0d00d20:	1dd9      	adds	r1, r3, #7
c0d00d22:	4815      	ldr	r0, [pc, #84]	; (c0d00d78 <io_usb_hid_receive+0x148>)
c0d00d24:	f000 f837 	bl	c0d00d96 <os_memmove>
      /// This is a following chunk
      // append content
      os_memmove((void*)G_io_usb_hid_current_buffer, G_io_usb_ep_buffer+5, l);
    }
    // factorize (f)
    G_io_usb_hid_current_buffer += l;
c0d00d28:	4037      	ands	r7, r6
c0d00d2a:	4811      	ldr	r0, [pc, #68]	; (c0d00d70 <io_usb_hid_receive+0x140>)
c0d00d2c:	6801      	ldr	r1, [r0, #0]
c0d00d2e:	19c9      	adds	r1, r1, r7
c0d00d30:	6001      	str	r1, [r0, #0]
    G_io_usb_hid_remaining_length -= l;
c0d00d32:	480e      	ldr	r0, [pc, #56]	; (c0d00d6c <io_usb_hid_receive+0x13c>)
c0d00d34:	6801      	ldr	r1, [r0, #0]
c0d00d36:	1bc9      	subs	r1, r1, r7
c0d00d38:	6001      	str	r1, [r0, #0]
c0d00d3a:	480a      	ldr	r0, [pc, #40]	; (c0d00d64 <io_usb_hid_receive+0x134>)
c0d00d3c:	4601      	mov	r1, r0
    G_io_usb_hid_sequence_number++;
c0d00d3e:	6808      	ldr	r0, [r1, #0]
c0d00d40:	1c40      	adds	r0, r0, #1
c0d00d42:	6008      	str	r0, [r1, #0]
    // await for the next chunk
    goto apdu_reset;
  }

  // if more data to be received, notify it
  if (G_io_usb_hid_remaining_length) {
c0d00d44:	4809      	ldr	r0, [pc, #36]	; (c0d00d6c <io_usb_hid_receive+0x13c>)
c0d00d46:	6801      	ldr	r1, [r0, #0]
c0d00d48:	2001      	movs	r0, #1
c0d00d4a:	2402      	movs	r4, #2
c0d00d4c:	2900      	cmp	r1, #0
c0d00d4e:	d103      	bne.n	c0d00d58 <io_usb_hid_receive+0x128>
  io_usb_hid_init();
  return IO_USB_APDU_RESET;
}

void io_usb_hid_init(void) {
  G_io_usb_hid_sequence_number = 0; 
c0d00d50:	4804      	ldr	r0, [pc, #16]	; (c0d00d64 <io_usb_hid_receive+0x134>)
c0d00d52:	2100      	movs	r1, #0
c0d00d54:	6001      	str	r1, [r0, #0]
c0d00d56:	4620      	mov	r0, r4
  return IO_USB_APDU_RECEIVED;

apdu_reset:
  io_usb_hid_init();
  return IO_USB_APDU_RESET;
}
c0d00d58:	b2c0      	uxtb	r0, r0
c0d00d5a:	b001      	add	sp, #4
c0d00d5c:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00d5e:	46c0      	nop			; (mov r8, r8)
c0d00d60:	20001f38 	.word	0x20001f38
c0d00d64:	20001db0 	.word	0x20001db0
c0d00d68:	0000ffff 	.word	0x0000ffff
c0d00d6c:	20001db8 	.word	0x20001db8
c0d00d70:	20001ec0 	.word	0x20001ec0
c0d00d74:	20001db4 	.word	0x20001db4
c0d00d78:	20001dbc 	.word	0x20001dbc
c0d00d7c:	20001ec4 	.word	0x20001ec4
c0d00d80:	0001fff9 	.word	0x0001fff9

c0d00d84 <os_memset>:
    }
  }
#undef DSTCHAR
}

void os_memset(void * dst, unsigned char c, unsigned int length) {
c0d00d84:	b580      	push	{r7, lr}
c0d00d86:	460b      	mov	r3, r1
#define DSTCHAR ((unsigned char *)dst)
  while(length--) {
c0d00d88:	2a00      	cmp	r2, #0
c0d00d8a:	d003      	beq.n	c0d00d94 <os_memset+0x10>
    DSTCHAR[length] = c;
c0d00d8c:	4611      	mov	r1, r2
c0d00d8e:	461a      	mov	r2, r3
c0d00d90:	f002 fb84 	bl	c0d0349c <__aeabi_memset>
  }
#undef DSTCHAR
}
c0d00d94:	bd80      	pop	{r7, pc}

c0d00d96 <os_memmove>:
    }
  }
}
#endif // HAVE_USB_APDU

REENTRANT(void os_memmove(void * dst, const void WIDE * src, unsigned int length)) {
c0d00d96:	b5b0      	push	{r4, r5, r7, lr}
#define DSTCHAR ((unsigned char *)dst)
#define SRCCHAR ((unsigned char WIDE *)src)
  if (dst > src) {
c0d00d98:	4288      	cmp	r0, r1
c0d00d9a:	d90d      	bls.n	c0d00db8 <os_memmove+0x22>
    while(length--) {
c0d00d9c:	2a00      	cmp	r2, #0
c0d00d9e:	d014      	beq.n	c0d00dca <os_memmove+0x34>
c0d00da0:	1e49      	subs	r1, r1, #1
c0d00da2:	4252      	negs	r2, r2
c0d00da4:	1e40      	subs	r0, r0, #1
c0d00da6:	2300      	movs	r3, #0
c0d00da8:	43db      	mvns	r3, r3
      DSTCHAR[length] = SRCCHAR[length];
c0d00daa:	461c      	mov	r4, r3
c0d00dac:	4354      	muls	r4, r2
c0d00dae:	5d0d      	ldrb	r5, [r1, r4]
c0d00db0:	5505      	strb	r5, [r0, r4]

REENTRANT(void os_memmove(void * dst, const void WIDE * src, unsigned int length)) {
#define DSTCHAR ((unsigned char *)dst)
#define SRCCHAR ((unsigned char WIDE *)src)
  if (dst > src) {
    while(length--) {
c0d00db2:	1c52      	adds	r2, r2, #1
c0d00db4:	d1f9      	bne.n	c0d00daa <os_memmove+0x14>
c0d00db6:	e008      	b.n	c0d00dca <os_memmove+0x34>
      DSTCHAR[length] = SRCCHAR[length];
    }
  }
  else {
    unsigned short l = 0;
    while (length--) {
c0d00db8:	2a00      	cmp	r2, #0
c0d00dba:	d006      	beq.n	c0d00dca <os_memmove+0x34>
c0d00dbc:	2300      	movs	r3, #0
      DSTCHAR[l] = SRCCHAR[l];
c0d00dbe:	b29c      	uxth	r4, r3
c0d00dc0:	5d0d      	ldrb	r5, [r1, r4]
c0d00dc2:	5505      	strb	r5, [r0, r4]
      l++;
c0d00dc4:	1c5b      	adds	r3, r3, #1
      DSTCHAR[length] = SRCCHAR[length];
    }
  }
  else {
    unsigned short l = 0;
    while (length--) {
c0d00dc6:	1e52      	subs	r2, r2, #1
c0d00dc8:	d1f9      	bne.n	c0d00dbe <os_memmove+0x28>
      DSTCHAR[l] = SRCCHAR[l];
      l++;
    }
  }
#undef DSTCHAR
}
c0d00dca:	bdb0      	pop	{r4, r5, r7, pc}

c0d00dcc <io_usb_hid_init>:
  io_usb_hid_init();
  return IO_USB_APDU_RESET;
}

void io_usb_hid_init(void) {
  G_io_usb_hid_sequence_number = 0; 
c0d00dcc:	4801      	ldr	r0, [pc, #4]	; (c0d00dd4 <io_usb_hid_init+0x8>)
c0d00dce:	2100      	movs	r1, #0
c0d00dd0:	6001      	str	r1, [r0, #0]
  //G_io_usb_hid_remaining_length = 0; // not really needed
  //G_io_usb_hid_total_length = 0; // not really needed
  //G_io_usb_hid_current_buffer = G_io_apdu_buffer; // not really needed
}
c0d00dd2:	4770      	bx	lr
c0d00dd4:	20001db0 	.word	0x20001db0

c0d00dd8 <io_usb_hid_exchange>:

unsigned short io_usb_hid_exchange(io_send_t sndfct, unsigned short sndlength,
                                   io_recv_t rcvfct,
                                   unsigned char flags) {
c0d00dd8:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00dda:	b085      	sub	sp, #20
c0d00ddc:	9301      	str	r3, [sp, #4]
c0d00dde:	9200      	str	r2, [sp, #0]
c0d00de0:	460e      	mov	r6, r1
c0d00de2:	9003      	str	r0, [sp, #12]
  unsigned char l;

  // perform send
  if (sndlength) {
c0d00de4:	2e00      	cmp	r6, #0
c0d00de6:	d047      	beq.n	c0d00e78 <io_usb_hid_exchange+0xa0>
    G_io_usb_hid_sequence_number = 0; 
c0d00de8:	4c32      	ldr	r4, [pc, #200]	; (c0d00eb4 <io_usb_hid_exchange+0xdc>)
c0d00dea:	2000      	movs	r0, #0
c0d00dec:	6020      	str	r0, [r4, #0]
    G_io_usb_hid_current_buffer = G_io_apdu_buffer;
c0d00dee:	4932      	ldr	r1, [pc, #200]	; (c0d00eb8 <io_usb_hid_exchange+0xe0>)
c0d00df0:	4832      	ldr	r0, [pc, #200]	; (c0d00ebc <io_usb_hid_exchange+0xe4>)
c0d00df2:	6008      	str	r0, [r1, #0]
c0d00df4:	4f32      	ldr	r7, [pc, #200]	; (c0d00ec0 <io_usb_hid_exchange+0xe8>)
}

void os_memset(void * dst, unsigned char c, unsigned int length) {
#define DSTCHAR ((unsigned char *)dst)
  while(length--) {
    DSTCHAR[length] = c;
c0d00df6:	1d78      	adds	r0, r7, #5
c0d00df8:	2539      	movs	r5, #57	; 0x39
c0d00dfa:	9002      	str	r0, [sp, #8]
c0d00dfc:	4629      	mov	r1, r5
c0d00dfe:	f002 fb47 	bl	c0d03490 <__aeabi_memclr>
c0d00e02:	4830      	ldr	r0, [pc, #192]	; (c0d00ec4 <io_usb_hid_exchange+0xec>)
c0d00e04:	4601      	mov	r1, r0

    // fill the chunk
    os_memset(G_io_usb_ep_buffer, 0, IO_HID_EP_LENGTH-2);

    // keep the channel identifier
    G_io_usb_ep_buffer[0] = (G_io_usb_hid_channel>>8)&0xFF;
c0d00e06:	6808      	ldr	r0, [r1, #0]
c0d00e08:	0a00      	lsrs	r0, r0, #8
c0d00e0a:	7038      	strb	r0, [r7, #0]
    G_io_usb_ep_buffer[1] = G_io_usb_hid_channel&0xFF;
c0d00e0c:	6808      	ldr	r0, [r1, #0]
c0d00e0e:	7078      	strb	r0, [r7, #1]
c0d00e10:	2005      	movs	r0, #5
    G_io_usb_ep_buffer[2] = 0x05;
c0d00e12:	70b8      	strb	r0, [r7, #2]
    G_io_usb_ep_buffer[3] = G_io_usb_hid_sequence_number>>8;
c0d00e14:	6820      	ldr	r0, [r4, #0]
c0d00e16:	0a00      	lsrs	r0, r0, #8
c0d00e18:	70f8      	strb	r0, [r7, #3]
    G_io_usb_ep_buffer[4] = G_io_usb_hid_sequence_number;
c0d00e1a:	6820      	ldr	r0, [r4, #0]
c0d00e1c:	7138      	strb	r0, [r7, #4]
c0d00e1e:	b2b1      	uxth	r1, r6

    if (G_io_usb_hid_sequence_number == 0) {
c0d00e20:	6820      	ldr	r0, [r4, #0]
c0d00e22:	2800      	cmp	r0, #0
c0d00e24:	9104      	str	r1, [sp, #16]
c0d00e26:	d00a      	beq.n	c0d00e3e <io_usb_hid_exchange+0x66>
      G_io_usb_hid_current_buffer += l;
      sndlength -= l;
      l += 7;
    }
    else {
      l = ((sndlength>IO_HID_EP_LENGTH-5) ? IO_HID_EP_LENGTH-5 : sndlength);
c0d00e28:	203b      	movs	r0, #59	; 0x3b
c0d00e2a:	293b      	cmp	r1, #59	; 0x3b
c0d00e2c:	460e      	mov	r6, r1
c0d00e2e:	d300      	bcc.n	c0d00e32 <io_usb_hid_exchange+0x5a>
c0d00e30:	4606      	mov	r6, r0
c0d00e32:	4821      	ldr	r0, [pc, #132]	; (c0d00eb8 <io_usb_hid_exchange+0xe0>)
c0d00e34:	4602      	mov	r2, r0
      os_memmove(G_io_usb_ep_buffer+5, (const void*)G_io_usb_hid_current_buffer, l);
c0d00e36:	6811      	ldr	r1, [r2, #0]
c0d00e38:	9802      	ldr	r0, [sp, #8]
c0d00e3a:	4615      	mov	r5, r2
c0d00e3c:	e009      	b.n	c0d00e52 <io_usb_hid_exchange+0x7a>
    G_io_usb_ep_buffer[3] = G_io_usb_hid_sequence_number>>8;
    G_io_usb_ep_buffer[4] = G_io_usb_hid_sequence_number;

    if (G_io_usb_hid_sequence_number == 0) {
      l = ((sndlength>IO_HID_EP_LENGTH-7) ? IO_HID_EP_LENGTH-7 : sndlength);
      G_io_usb_ep_buffer[5] = sndlength>>8;
c0d00e3e:	0a30      	lsrs	r0, r6, #8
c0d00e40:	7178      	strb	r0, [r7, #5]
      G_io_usb_ep_buffer[6] = sndlength;
c0d00e42:	71be      	strb	r6, [r7, #6]
    G_io_usb_ep_buffer[2] = 0x05;
    G_io_usb_ep_buffer[3] = G_io_usb_hid_sequence_number>>8;
    G_io_usb_ep_buffer[4] = G_io_usb_hid_sequence_number;

    if (G_io_usb_hid_sequence_number == 0) {
      l = ((sndlength>IO_HID_EP_LENGTH-7) ? IO_HID_EP_LENGTH-7 : sndlength);
c0d00e44:	2939      	cmp	r1, #57	; 0x39
c0d00e46:	460e      	mov	r6, r1
c0d00e48:	d300      	bcc.n	c0d00e4c <io_usb_hid_exchange+0x74>
c0d00e4a:	462e      	mov	r6, r5
c0d00e4c:	4d1a      	ldr	r5, [pc, #104]	; (c0d00eb8 <io_usb_hid_exchange+0xe0>)
      G_io_usb_ep_buffer[5] = sndlength>>8;
      G_io_usb_ep_buffer[6] = sndlength;
      os_memmove(G_io_usb_ep_buffer+7, (const void*)G_io_usb_hid_current_buffer, l);
c0d00e4e:	6829      	ldr	r1, [r5, #0]
c0d00e50:	1df8      	adds	r0, r7, #7
c0d00e52:	4632      	mov	r2, r6
c0d00e54:	f7ff ff9f 	bl	c0d00d96 <os_memmove>
c0d00e58:	4c16      	ldr	r4, [pc, #88]	; (c0d00eb4 <io_usb_hid_exchange+0xdc>)
c0d00e5a:	6828      	ldr	r0, [r5, #0]
c0d00e5c:	1980      	adds	r0, r0, r6
      G_io_usb_hid_current_buffer += l;
c0d00e5e:	6028      	str	r0, [r5, #0]
      G_io_usb_hid_current_buffer += l;
      sndlength -= l;
      l += 5;
    }
    // prepare next chunk numbering
    G_io_usb_hid_sequence_number++;
c0d00e60:	6820      	ldr	r0, [r4, #0]
c0d00e62:	1c40      	adds	r0, r0, #1
c0d00e64:	6020      	str	r0, [r4, #0]
    // send the chunk
    // always pad :)
    sndfct(G_io_usb_ep_buffer, sizeof(G_io_usb_ep_buffer));
c0d00e66:	2140      	movs	r1, #64	; 0x40
c0d00e68:	4638      	mov	r0, r7
c0d00e6a:	9a03      	ldr	r2, [sp, #12]
c0d00e6c:	4790      	blx	r2
c0d00e6e:	9804      	ldr	r0, [sp, #16]
c0d00e70:	1b86      	subs	r6, r0, r6
c0d00e72:	4815      	ldr	r0, [pc, #84]	; (c0d00ec8 <io_usb_hid_exchange+0xf0>)
  // perform send
  if (sndlength) {
    G_io_usb_hid_sequence_number = 0; 
    G_io_usb_hid_current_buffer = G_io_apdu_buffer;
  }
  while(sndlength) {
c0d00e74:	4206      	tst	r6, r0
c0d00e76:	d1be      	bne.n	c0d00df6 <io_usb_hid_exchange+0x1e>
  io_usb_hid_init();
  return IO_USB_APDU_RESET;
}

void io_usb_hid_init(void) {
  G_io_usb_hid_sequence_number = 0; 
c0d00e78:	480e      	ldr	r0, [pc, #56]	; (c0d00eb4 <io_usb_hid_exchange+0xdc>)
c0d00e7a:	2400      	movs	r4, #0
c0d00e7c:	6004      	str	r4, [r0, #0]
  }

  // prepare for next apdu
  io_usb_hid_init();

  if (flags & IO_RESET_AFTER_REPLIED) {
c0d00e7e:	2080      	movs	r0, #128	; 0x80
c0d00e80:	9d01      	ldr	r5, [sp, #4]
c0d00e82:	4205      	tst	r5, r0
c0d00e84:	d001      	beq.n	c0d00e8a <io_usb_hid_exchange+0xb2>
    reset();
c0d00e86:	f000 fe57 	bl	c0d01b38 <reset>
  }

  if (flags & IO_RETURN_AFTER_TX ) {
c0d00e8a:	06a8      	lsls	r0, r5, #26
c0d00e8c:	d40f      	bmi.n	c0d00eae <io_usb_hid_exchange+0xd6>
c0d00e8e:	4c0c      	ldr	r4, [pc, #48]	; (c0d00ec0 <io_usb_hid_exchange+0xe8>)
c0d00e90:	9d00      	ldr	r5, [sp, #0]
  }

  // receive the next command
  for(;;) {
    // receive a hid chunk
    l = rcvfct(G_io_usb_ep_buffer, sizeof(G_io_usb_ep_buffer));
c0d00e92:	2140      	movs	r1, #64	; 0x40
c0d00e94:	4620      	mov	r0, r4
c0d00e96:	47a8      	blx	r5
    // check for wrongly sized tlvs
    if (l > sizeof(G_io_usb_ep_buffer)) {
c0d00e98:	b2c2      	uxtb	r2, r0
c0d00e9a:	2a40      	cmp	r2, #64	; 0x40
c0d00e9c:	d8f9      	bhi.n	c0d00e92 <io_usb_hid_exchange+0xba>
      continue;
    }

    // call the chunk reception
    switch(io_usb_hid_receive(sndfct, G_io_usb_ep_buffer, l)) {
c0d00e9e:	9803      	ldr	r0, [sp, #12]
c0d00ea0:	4621      	mov	r1, r4
c0d00ea2:	f7ff fec5 	bl	c0d00c30 <io_usb_hid_receive>
c0d00ea6:	2802      	cmp	r0, #2
c0d00ea8:	d1f3      	bne.n	c0d00e92 <io_usb_hid_exchange+0xba>
      default:
        continue;

      case IO_USB_APDU_RECEIVED:

        return G_io_usb_hid_total_length;
c0d00eaa:	4808      	ldr	r0, [pc, #32]	; (c0d00ecc <io_usb_hid_exchange+0xf4>)
c0d00eac:	6804      	ldr	r4, [r0, #0]
    }
  }
}
c0d00eae:	b2a0      	uxth	r0, r4
c0d00eb0:	b005      	add	sp, #20
c0d00eb2:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00eb4:	20001db0 	.word	0x20001db0
c0d00eb8:	20001ec0 	.word	0x20001ec0
c0d00ebc:	20001dbc 	.word	0x20001dbc
c0d00ec0:	20001f38 	.word	0x20001f38
c0d00ec4:	20001ec4 	.word	0x20001ec4
c0d00ec8:	0000ffff 	.word	0x0000ffff
c0d00ecc:	20001db4 	.word	0x20001db4

c0d00ed0 <os_memcmp>:
    DSTCHAR[length] = c;
  }
#undef DSTCHAR
}

char os_memcmp(const void WIDE * buf1, const void WIDE * buf2, unsigned int length) {
c0d00ed0:	b570      	push	{r4, r5, r6, lr}
#define BUF1 ((unsigned char const WIDE *)buf1)
#define BUF2 ((unsigned char const WIDE *)buf2)
  while(length--) {
c0d00ed2:	1e43      	subs	r3, r0, #1
c0d00ed4:	1e49      	subs	r1, r1, #1
c0d00ed6:	4252      	negs	r2, r2
c0d00ed8:	2000      	movs	r0, #0
c0d00eda:	43c4      	mvns	r4, r0
c0d00edc:	2a00      	cmp	r2, #0
c0d00ede:	d00c      	beq.n	c0d00efa <os_memcmp+0x2a>
    if (BUF1[length] != BUF2[length]) {
c0d00ee0:	4626      	mov	r6, r4
c0d00ee2:	4356      	muls	r6, r2
c0d00ee4:	5d8d      	ldrb	r5, [r1, r6]
c0d00ee6:	5d9e      	ldrb	r6, [r3, r6]
c0d00ee8:	1c52      	adds	r2, r2, #1
c0d00eea:	42ae      	cmp	r6, r5
c0d00eec:	d0f6      	beq.n	c0d00edc <os_memcmp+0xc>
      return (BUF1[length] > BUF2[length])? 1:-1;
c0d00eee:	2000      	movs	r0, #0
c0d00ef0:	43c1      	mvns	r1, r0
c0d00ef2:	2001      	movs	r0, #1
c0d00ef4:	42ae      	cmp	r6, r5
c0d00ef6:	d800      	bhi.n	c0d00efa <os_memcmp+0x2a>
c0d00ef8:	4608      	mov	r0, r1
  }
  return 0;
#undef BUF1
#undef BUF2

}
c0d00efa:	b2c0      	uxtb	r0, r0
c0d00efc:	bd70      	pop	{r4, r5, r6, pc}

c0d00efe <os_longjmp>:
void try_context_set(try_context_t* ctx) {
  __asm volatile ("mov r9, %0"::"r"(ctx));
}

#ifndef HAVE_BOLOS
void os_longjmp(unsigned int exception) {
c0d00efe:	b580      	push	{r7, lr}
c0d00f00:	4601      	mov	r1, r0
  return xoracc;
}

try_context_t* try_context_get(void) {
  try_context_t* current_ctx;
  __asm volatile ("mov %0, r9":"=r"(current_ctx));
c0d00f02:	4648      	mov	r0, r9
  __asm volatile ("mov r9, %0"::"r"(ctx));
}

#ifndef HAVE_BOLOS
void os_longjmp(unsigned int exception) {
  longjmp(try_context_get()->jmp_buf, exception);
c0d00f04:	f002 fb24 	bl	c0d03550 <longjmp>

c0d00f08 <try_context_get>:
  return xoracc;
}

try_context_t* try_context_get(void) {
  try_context_t* current_ctx;
  __asm volatile ("mov %0, r9":"=r"(current_ctx));
c0d00f08:	4648      	mov	r0, r9
  return current_ctx;
c0d00f0a:	4770      	bx	lr

c0d00f0c <try_context_get_previous>:
}

try_context_t* try_context_get_previous(void) {
c0d00f0c:	2000      	movs	r0, #0
  try_context_t* current_ctx;
  __asm volatile ("mov %0, r9":"=r"(current_ctx));
c0d00f0e:	4649      	mov	r1, r9

  // first context reached ?
  if (current_ctx == NULL) {
c0d00f10:	2900      	cmp	r1, #0
c0d00f12:	d000      	beq.n	c0d00f16 <try_context_get_previous+0xa>
  }

  // return r9 content saved on the current context. It links to the previous context.
  // r4 r5 r6 r7 r8 r9 r10 r11 sp lr
  //                ^ platform register
  return (try_context_t*) current_ctx->jmp_buf[5];
c0d00f14:	6948      	ldr	r0, [r1, #20]
}
c0d00f16:	4770      	bx	lr

c0d00f18 <io_seproxyhal_general_status>:
  if (G_io_timeout) {
    G_io_timeout = timeout_ms;
  }
}

void io_seproxyhal_general_status(void) {
c0d00f18:	b580      	push	{r7, lr}
  // avoid troubles
  if (io_seproxyhal_spi_is_status_sent()) {
c0d00f1a:	f000 fed9 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d00f1e:	2800      	cmp	r0, #0
c0d00f20:	d10b      	bne.n	c0d00f3a <io_seproxyhal_general_status+0x22>
    return;
  }
  // send the general status
  G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_GENERAL_STATUS;
c0d00f22:	4806      	ldr	r0, [pc, #24]	; (c0d00f3c <io_seproxyhal_general_status+0x24>)
c0d00f24:	2160      	movs	r1, #96	; 0x60
c0d00f26:	7001      	strb	r1, [r0, #0]
  G_io_seproxyhal_spi_buffer[1] = 0;
c0d00f28:	2100      	movs	r1, #0
c0d00f2a:	7041      	strb	r1, [r0, #1]
  G_io_seproxyhal_spi_buffer[2] = 2;
c0d00f2c:	2202      	movs	r2, #2
c0d00f2e:	7082      	strb	r2, [r0, #2]
  G_io_seproxyhal_spi_buffer[3] = SEPROXYHAL_TAG_GENERAL_STATUS_LAST_COMMAND>>8;
c0d00f30:	70c1      	strb	r1, [r0, #3]
  G_io_seproxyhal_spi_buffer[4] = SEPROXYHAL_TAG_GENERAL_STATUS_LAST_COMMAND;
c0d00f32:	7101      	strb	r1, [r0, #4]
  io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 5);
c0d00f34:	2105      	movs	r1, #5
c0d00f36:	f000 feb5 	bl	c0d01ca4 <io_seproxyhal_spi_send>
}
c0d00f3a:	bd80      	pop	{r7, pc}
c0d00f3c:	20001c28 	.word	0x20001c28

c0d00f40 <io_seproxyhal_handle_usb_event>:
static volatile unsigned char G_io_usb_ep_xfer_len[IO_USB_MAX_ENDPOINTS];
#include "usbd_def.h"
#include "usbd_core.h"
extern USBD_HandleTypeDef USBD_Device;

void io_seproxyhal_handle_usb_event(void) {
c0d00f40:	b510      	push	{r4, lr}
  switch(G_io_seproxyhal_spi_buffer[3]) {
c0d00f42:	4813      	ldr	r0, [pc, #76]	; (c0d00f90 <io_seproxyhal_handle_usb_event+0x50>)
c0d00f44:	78c0      	ldrb	r0, [r0, #3]
c0d00f46:	2803      	cmp	r0, #3
c0d00f48:	dc07      	bgt.n	c0d00f5a <io_seproxyhal_handle_usb_event+0x1a>
c0d00f4a:	2801      	cmp	r0, #1
c0d00f4c:	d00d      	beq.n	c0d00f6a <io_seproxyhal_handle_usb_event+0x2a>
c0d00f4e:	2802      	cmp	r0, #2
c0d00f50:	d11d      	bne.n	c0d00f8e <io_seproxyhal_handle_usb_event+0x4e>
      if (G_io_apdu_media != IO_APDU_MEDIA_NONE) {
        THROW(EXCEPTION_IO_RESET);
      }
      break;
    case SEPROXYHAL_TAG_USB_EVENT_SOF:
      USBD_LL_SOF(&USBD_Device);
c0d00f52:	4810      	ldr	r0, [pc, #64]	; (c0d00f94 <io_seproxyhal_handle_usb_event+0x54>)
c0d00f54:	f001 fe06 	bl	c0d02b64 <USBD_LL_SOF>
      break;
    case SEPROXYHAL_TAG_USB_EVENT_RESUMED:
      USBD_LL_Resume(&USBD_Device);
      break;
  }
}
c0d00f58:	bd10      	pop	{r4, pc}
c0d00f5a:	2804      	cmp	r0, #4
c0d00f5c:	d014      	beq.n	c0d00f88 <io_seproxyhal_handle_usb_event+0x48>
c0d00f5e:	2808      	cmp	r0, #8
c0d00f60:	d115      	bne.n	c0d00f8e <io_seproxyhal_handle_usb_event+0x4e>
      break;
    case SEPROXYHAL_TAG_USB_EVENT_SUSPENDED:
      USBD_LL_Suspend(&USBD_Device);
      break;
    case SEPROXYHAL_TAG_USB_EVENT_RESUMED:
      USBD_LL_Resume(&USBD_Device);
c0d00f62:	480c      	ldr	r0, [pc, #48]	; (c0d00f94 <io_seproxyhal_handle_usb_event+0x54>)
c0d00f64:	f001 fdfc 	bl	c0d02b60 <USBD_LL_Resume>
      break;
  }
}
c0d00f68:	bd10      	pop	{r4, pc}
extern USBD_HandleTypeDef USBD_Device;

void io_seproxyhal_handle_usb_event(void) {
  switch(G_io_seproxyhal_spi_buffer[3]) {
    case SEPROXYHAL_TAG_USB_EVENT_RESET:
      USBD_LL_SetSpeed(&USBD_Device, USBD_SPEED_FULL);  
c0d00f6a:	4c0a      	ldr	r4, [pc, #40]	; (c0d00f94 <io_seproxyhal_handle_usb_event+0x54>)
c0d00f6c:	2101      	movs	r1, #1
c0d00f6e:	4620      	mov	r0, r4
c0d00f70:	f001 fdf1 	bl	c0d02b56 <USBD_LL_SetSpeed>
      USBD_LL_Reset(&USBD_Device);
c0d00f74:	4620      	mov	r0, r4
c0d00f76:	f001 fdce 	bl	c0d02b16 <USBD_LL_Reset>
      // ongoing APDU detected, throw a reset, even if not the media. to avoid potential troubles.
      if (G_io_apdu_media != IO_APDU_MEDIA_NONE) {
c0d00f7a:	4807      	ldr	r0, [pc, #28]	; (c0d00f98 <io_seproxyhal_handle_usb_event+0x58>)
c0d00f7c:	7800      	ldrb	r0, [r0, #0]
c0d00f7e:	2800      	cmp	r0, #0
c0d00f80:	d005      	beq.n	c0d00f8e <io_seproxyhal_handle_usb_event+0x4e>
        THROW(EXCEPTION_IO_RESET);
c0d00f82:	2010      	movs	r0, #16
c0d00f84:	f7ff ffbb 	bl	c0d00efe <os_longjmp>
      break;
    case SEPROXYHAL_TAG_USB_EVENT_SOF:
      USBD_LL_SOF(&USBD_Device);
      break;
    case SEPROXYHAL_TAG_USB_EVENT_SUSPENDED:
      USBD_LL_Suspend(&USBD_Device);
c0d00f88:	4802      	ldr	r0, [pc, #8]	; (c0d00f94 <io_seproxyhal_handle_usb_event+0x54>)
c0d00f8a:	f001 fde7 	bl	c0d02b5c <USBD_LL_Suspend>
      break;
    case SEPROXYHAL_TAG_USB_EVENT_RESUMED:
      USBD_LL_Resume(&USBD_Device);
      break;
  }
}
c0d00f8e:	bd10      	pop	{r4, pc}
c0d00f90:	20001c28 	.word	0x20001c28
c0d00f94:	20001fc4 	.word	0x20001fc4
c0d00f98:	20001ed0 	.word	0x20001ed0

c0d00f9c <io_seproxyhal_get_ep_rx_size>:

uint16_t io_seproxyhal_get_ep_rx_size(uint8_t epnum) {
  return G_io_usb_ep_xfer_len[epnum&0x7F];
c0d00f9c:	217f      	movs	r1, #127	; 0x7f
c0d00f9e:	4001      	ands	r1, r0
c0d00fa0:	4801      	ldr	r0, [pc, #4]	; (c0d00fa8 <io_seproxyhal_get_ep_rx_size+0xc>)
c0d00fa2:	5c40      	ldrb	r0, [r0, r1]
c0d00fa4:	4770      	bx	lr
c0d00fa6:	46c0      	nop			; (mov r8, r8)
c0d00fa8:	20001ed1 	.word	0x20001ed1

c0d00fac <io_seproxyhal_handle_usb_ep_xfer_event>:
}

void io_seproxyhal_handle_usb_ep_xfer_event(void) {
c0d00fac:	b580      	push	{r7, lr}
  switch(G_io_seproxyhal_spi_buffer[4]) {
c0d00fae:	4810      	ldr	r0, [pc, #64]	; (c0d00ff0 <io_seproxyhal_handle_usb_ep_xfer_event+0x44>)
c0d00fb0:	7901      	ldrb	r1, [r0, #4]
c0d00fb2:	2904      	cmp	r1, #4
c0d00fb4:	d008      	beq.n	c0d00fc8 <io_seproxyhal_handle_usb_ep_xfer_event+0x1c>
c0d00fb6:	2902      	cmp	r1, #2
c0d00fb8:	d011      	beq.n	c0d00fde <io_seproxyhal_handle_usb_ep_xfer_event+0x32>
c0d00fba:	2901      	cmp	r1, #1
c0d00fbc:	d10e      	bne.n	c0d00fdc <io_seproxyhal_handle_usb_ep_xfer_event+0x30>
    /* This event is received when a new SETUP token had been received on a control endpoint */
    case SEPROXYHAL_TAG_USB_EP_XFER_SETUP:
      // assume length of setup packet, and that it is on endpoint 0
      USBD_LL_SetupStage(&USBD_Device, &G_io_seproxyhal_spi_buffer[6]);
c0d00fbe:	1d81      	adds	r1, r0, #6
c0d00fc0:	480d      	ldr	r0, [pc, #52]	; (c0d00ff8 <io_seproxyhal_handle_usb_ep_xfer_event+0x4c>)
c0d00fc2:	f001 fcaa 	bl	c0d0291a <USBD_LL_SetupStage>
      // saved just in case it is needed ...
      G_io_usb_ep_xfer_len[G_io_seproxyhal_spi_buffer[3]&0x7F] = G_io_seproxyhal_spi_buffer[5];
      USBD_LL_DataOutStage(&USBD_Device, G_io_seproxyhal_spi_buffer[3]&0x7F, &G_io_seproxyhal_spi_buffer[6]);
      break;
  }
}
c0d00fc6:	bd80      	pop	{r7, pc}
      break;

    /* This event is received when a new DATA token is received on an endpoint */
    case SEPROXYHAL_TAG_USB_EP_XFER_OUT:
      // saved just in case it is needed ...
      G_io_usb_ep_xfer_len[G_io_seproxyhal_spi_buffer[3]&0x7F] = G_io_seproxyhal_spi_buffer[5];
c0d00fc8:	78c2      	ldrb	r2, [r0, #3]
c0d00fca:	217f      	movs	r1, #127	; 0x7f
c0d00fcc:	4011      	ands	r1, r2
c0d00fce:	7942      	ldrb	r2, [r0, #5]
c0d00fd0:	4b08      	ldr	r3, [pc, #32]	; (c0d00ff4 <io_seproxyhal_handle_usb_ep_xfer_event+0x48>)
c0d00fd2:	545a      	strb	r2, [r3, r1]
      USBD_LL_DataOutStage(&USBD_Device, G_io_seproxyhal_spi_buffer[3]&0x7F, &G_io_seproxyhal_spi_buffer[6]);
c0d00fd4:	1d82      	adds	r2, r0, #6
c0d00fd6:	4808      	ldr	r0, [pc, #32]	; (c0d00ff8 <io_seproxyhal_handle_usb_ep_xfer_event+0x4c>)
c0d00fd8:	f001 fccd 	bl	c0d02976 <USBD_LL_DataOutStage>
      break;
  }
}
c0d00fdc:	bd80      	pop	{r7, pc}
      USBD_LL_SetupStage(&USBD_Device, &G_io_seproxyhal_spi_buffer[6]);
      break;

    /* This event is received after the prepare data packet has been flushed to the usb host */
    case SEPROXYHAL_TAG_USB_EP_XFER_IN:
      USBD_LL_DataInStage(&USBD_Device, G_io_seproxyhal_spi_buffer[3]&0x7F, &G_io_seproxyhal_spi_buffer[6]);
c0d00fde:	78c2      	ldrb	r2, [r0, #3]
c0d00fe0:	217f      	movs	r1, #127	; 0x7f
c0d00fe2:	4011      	ands	r1, r2
c0d00fe4:	1d82      	adds	r2, r0, #6
c0d00fe6:	4804      	ldr	r0, [pc, #16]	; (c0d00ff8 <io_seproxyhal_handle_usb_ep_xfer_event+0x4c>)
c0d00fe8:	f001 fd1f 	bl	c0d02a2a <USBD_LL_DataInStage>
      // saved just in case it is needed ...
      G_io_usb_ep_xfer_len[G_io_seproxyhal_spi_buffer[3]&0x7F] = G_io_seproxyhal_spi_buffer[5];
      USBD_LL_DataOutStage(&USBD_Device, G_io_seproxyhal_spi_buffer[3]&0x7F, &G_io_seproxyhal_spi_buffer[6]);
      break;
  }
}
c0d00fec:	bd80      	pop	{r7, pc}
c0d00fee:	46c0      	nop			; (mov r8, r8)
c0d00ff0:	20001c28 	.word	0x20001c28
c0d00ff4:	20001ed1 	.word	0x20001ed1
c0d00ff8:	20001fc4 	.word	0x20001fc4

c0d00ffc <io_usb_send_ep>:
}

#endif // HAVE_L4_USBLIB

// TODO, refactor this using the USB DataIn event like for the U2F tunnel
void io_usb_send_ep(unsigned int ep, unsigned char* buffer, unsigned short length, unsigned int timeout) {
c0d00ffc:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00ffe:	b081      	sub	sp, #4
c0d01000:	4614      	mov	r4, r2
c0d01002:	4605      	mov	r5, r0
  if (timeout) {
    timeout++;
  }

  // won't send if overflowing seproxyhal buffer format
  if (length > 255) {
c0d01004:	2cff      	cmp	r4, #255	; 0xff
c0d01006:	d83a      	bhi.n	c0d0107e <io_usb_send_ep+0x82>
    return;
  }
  
  G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
c0d01008:	4e1f      	ldr	r6, [pc, #124]	; (c0d01088 <io_usb_send_ep+0x8c>)
c0d0100a:	2050      	movs	r0, #80	; 0x50
c0d0100c:	7030      	strb	r0, [r6, #0]
  G_io_seproxyhal_spi_buffer[1] = (3+length)>>8;
c0d0100e:	1ce0      	adds	r0, r4, #3
c0d01010:	9100      	str	r1, [sp, #0]
c0d01012:	0a01      	lsrs	r1, r0, #8
c0d01014:	7071      	strb	r1, [r6, #1]
  G_io_seproxyhal_spi_buffer[2] = (3+length);
c0d01016:	70b0      	strb	r0, [r6, #2]
  G_io_seproxyhal_spi_buffer[3] = ep|0x80;
c0d01018:	2080      	movs	r0, #128	; 0x80
c0d0101a:	4305      	orrs	r5, r0
c0d0101c:	70f5      	strb	r5, [r6, #3]
  G_io_seproxyhal_spi_buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_IN;
c0d0101e:	2020      	movs	r0, #32
c0d01020:	7130      	strb	r0, [r6, #4]
  G_io_seproxyhal_spi_buffer[5] = length;
c0d01022:	7174      	strb	r4, [r6, #5]
  io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 6);
c0d01024:	2106      	movs	r1, #6
c0d01026:	4630      	mov	r0, r6
c0d01028:	461f      	mov	r7, r3
c0d0102a:	f000 fe3b 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  io_seproxyhal_spi_send(buffer, length);
c0d0102e:	9800      	ldr	r0, [sp, #0]
c0d01030:	4621      	mov	r1, r4
c0d01032:	f000 fe37 	bl	c0d01ca4 <io_seproxyhal_spi_send>

  // if timeout is requested
  if(timeout) {
c0d01036:	1c78      	adds	r0, r7, #1
c0d01038:	2802      	cmp	r0, #2
c0d0103a:	d320      	bcc.n	c0d0107e <io_usb_send_ep+0x82>
c0d0103c:	e006      	b.n	c0d0104c <io_usb_send_ep+0x50>
          THROW(EXCEPTION_IO_RESET);
        }
        */

        // link disconnected ?
        if(G_io_seproxyhal_spi_buffer[0] == SEPROXYHAL_TAG_STATUS_EVENT) {
c0d0103e:	2915      	cmp	r1, #21
c0d01040:	d102      	bne.n	c0d01048 <io_usb_send_ep+0x4c>
          if (!(U4BE(G_io_seproxyhal_spi_buffer, 3) & SEPROXYHAL_TAG_STATUS_EVENT_FLAG_USB_POWERED)) {
c0d01042:	79b0      	ldrb	r0, [r6, #6]
c0d01044:	0700      	lsls	r0, r0, #28
c0d01046:	d51c      	bpl.n	c0d01082 <io_usb_send_ep+0x86>
        
        // usb reset ?
        //io_seproxyhal_handle_usb_event();
        // also process other transfer requests if any (useful for HID keyboard while playing with CAPS lock key, side effect on LED status)
        // also handle IO timeout in a centralized and configurable way
        io_seproxyhal_handle_event();
c0d01048:	f000 f820 	bl	c0d0108c <io_seproxyhal_handle_event>
  io_seproxyhal_spi_send(buffer, length);

  // if timeout is requested
  if(timeout) {
    for (;;) {
      if (!io_seproxyhal_spi_is_status_sent()) {
c0d0104c:	f000 fe40 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d01050:	2800      	cmp	r0, #0
c0d01052:	d101      	bne.n	c0d01058 <io_usb_send_ep+0x5c>
        io_seproxyhal_general_status();
c0d01054:	f7ff ff60 	bl	c0d00f18 <io_seproxyhal_general_status>
      }

      rx_len = io_seproxyhal_spi_recv(G_io_seproxyhal_spi_buffer, sizeof(G_io_seproxyhal_spi_buffer), 0);
c0d01058:	2180      	movs	r1, #128	; 0x80
c0d0105a:	2200      	movs	r2, #0
c0d0105c:	4630      	mov	r0, r6
c0d0105e:	f000 fe4d 	bl	c0d01cfc <io_seproxyhal_spi_recv>

      // wait for ack of the seproxyhal
      // discard if not an acknowledgment
      if (G_io_seproxyhal_spi_buffer[0] != SEPROXYHAL_TAG_USB_EP_XFER_EVENT
c0d01062:	7831      	ldrb	r1, [r6, #0]
        || rx_len != 6 
c0d01064:	2806      	cmp	r0, #6
c0d01066:	d1ea      	bne.n	c0d0103e <io_usb_send_ep+0x42>
c0d01068:	2910      	cmp	r1, #16
c0d0106a:	d1e8      	bne.n	c0d0103e <io_usb_send_ep+0x42>
        || G_io_seproxyhal_spi_buffer[3] != (ep|0x80)
c0d0106c:	78f0      	ldrb	r0, [r6, #3]
        || G_io_seproxyhal_spi_buffer[4] != SEPROXYHAL_TAG_USB_EP_XFER_IN
c0d0106e:	42a8      	cmp	r0, r5
c0d01070:	d1e5      	bne.n	c0d0103e <io_usb_send_ep+0x42>
c0d01072:	7930      	ldrb	r0, [r6, #4]
c0d01074:	2802      	cmp	r0, #2
c0d01076:	d1e2      	bne.n	c0d0103e <io_usb_send_ep+0x42>
        || G_io_seproxyhal_spi_buffer[5] != length) {
c0d01078:	7970      	ldrb	r0, [r6, #5]

      rx_len = io_seproxyhal_spi_recv(G_io_seproxyhal_spi_buffer, sizeof(G_io_seproxyhal_spi_buffer), 0);

      // wait for ack of the seproxyhal
      // discard if not an acknowledgment
      if (G_io_seproxyhal_spi_buffer[0] != SEPROXYHAL_TAG_USB_EP_XFER_EVENT
c0d0107a:	42a0      	cmp	r0, r4
c0d0107c:	d1df      	bne.n	c0d0103e <io_usb_send_ep+0x42>

      // chunk sending succeeded
      break;
    }
  }
}
c0d0107e:	b001      	add	sp, #4
c0d01080:	bdf0      	pop	{r4, r5, r6, r7, pc}
        */

        // link disconnected ?
        if(G_io_seproxyhal_spi_buffer[0] == SEPROXYHAL_TAG_STATUS_EVENT) {
          if (!(U4BE(G_io_seproxyhal_spi_buffer, 3) & SEPROXYHAL_TAG_STATUS_EVENT_FLAG_USB_POWERED)) {
           THROW(EXCEPTION_IO_RESET);
c0d01082:	2010      	movs	r0, #16
c0d01084:	f7ff ff3b 	bl	c0d00efe <os_longjmp>
c0d01088:	20001c28 	.word	0x20001c28

c0d0108c <io_seproxyhal_handle_event>:
    // copy apdu to apdu buffer
    os_memmove(G_io_apdu_buffer, G_io_seproxyhal_spi_buffer+3, G_io_apdu_length);
  }
}

unsigned int io_seproxyhal_handle_event(void) {
c0d0108c:	b580      	push	{r7, lr}
  unsigned int rx_len = U2BE(G_io_seproxyhal_spi_buffer, 1);
c0d0108e:	481e      	ldr	r0, [pc, #120]	; (c0d01108 <io_seproxyhal_handle_event+0x7c>)
c0d01090:	7882      	ldrb	r2, [r0, #2]
c0d01092:	7841      	ldrb	r1, [r0, #1]
c0d01094:	0209      	lsls	r1, r1, #8
c0d01096:	4311      	orrs	r1, r2
c0d01098:	7800      	ldrb	r0, [r0, #0]

  switch(G_io_seproxyhal_spi_buffer[0]) {
c0d0109a:	280f      	cmp	r0, #15
c0d0109c:	dc0a      	bgt.n	c0d010b4 <io_seproxyhal_handle_event+0x28>
c0d0109e:	280e      	cmp	r0, #14
c0d010a0:	d010      	beq.n	c0d010c4 <io_seproxyhal_handle_event+0x38>
c0d010a2:	280f      	cmp	r0, #15
c0d010a4:	d11d      	bne.n	c0d010e2 <io_seproxyhal_handle_event+0x56>
c0d010a6:	2000      	movs	r0, #0
  #ifdef HAVE_IO_USB
    case SEPROXYHAL_TAG_USB_EVENT:
      if (rx_len != 3+1) {
c0d010a8:	2904      	cmp	r1, #4
c0d010aa:	d121      	bne.n	c0d010f0 <io_seproxyhal_handle_event+0x64>
        return 0;
      }
      io_seproxyhal_handle_usb_event();
c0d010ac:	f7ff ff48 	bl	c0d00f40 <io_seproxyhal_handle_usb_event>
c0d010b0:	2001      	movs	r0, #1
    default:
      return io_event(CHANNEL_SPI);
  }
  // defaulty return as not processed
  return 0;
}
c0d010b2:	bd80      	pop	{r7, pc}
c0d010b4:	2810      	cmp	r0, #16
c0d010b6:	d018      	beq.n	c0d010ea <io_seproxyhal_handle_event+0x5e>
c0d010b8:	2816      	cmp	r0, #22
c0d010ba:	d112      	bne.n	c0d010e2 <io_seproxyhal_handle_event+0x56>
      io_seproxyhal_handle_bluenrg_event();
      return 1;
  #endif // HAVE_BLE

    case SEPROXYHAL_TAG_CAPDU_EVENT:
      io_seproxyhal_handle_capdu_event();
c0d010bc:	f000 f832 	bl	c0d01124 <io_seproxyhal_handle_capdu_event>
c0d010c0:	2001      	movs	r0, #1
    default:
      return io_event(CHANNEL_SPI);
  }
  // defaulty return as not processed
  return 0;
}
c0d010c2:	bd80      	pop	{r7, pc}
      return 1;

      // ask the user if not processed here
    case SEPROXYHAL_TAG_TICKER_EVENT:
      // process ticker events to timeout the IO transfers, and forward to the user io_event function too
      if(G_io_timeout) {
c0d010c4:	4811      	ldr	r0, [pc, #68]	; (c0d0110c <io_seproxyhal_handle_event+0x80>)
c0d010c6:	6801      	ldr	r1, [r0, #0]
c0d010c8:	2900      	cmp	r1, #0
c0d010ca:	d00a      	beq.n	c0d010e2 <io_seproxyhal_handle_event+0x56>
        G_io_timeout-=MIN(G_io_timeout, 100);
c0d010cc:	6802      	ldr	r2, [r0, #0]
c0d010ce:	2164      	movs	r1, #100	; 0x64
c0d010d0:	2a63      	cmp	r2, #99	; 0x63
c0d010d2:	d800      	bhi.n	c0d010d6 <io_seproxyhal_handle_event+0x4a>
c0d010d4:	6801      	ldr	r1, [r0, #0]
c0d010d6:	6802      	ldr	r2, [r0, #0]
c0d010d8:	1a51      	subs	r1, r2, r1
c0d010da:	6001      	str	r1, [r0, #0]
        #warning TODO use real ticker event interval here instead of the x100ms multiplier
        if (!G_io_timeout) {
c0d010dc:	6800      	ldr	r0, [r0, #0]
c0d010de:	2800      	cmp	r0, #0
c0d010e0:	d00b      	beq.n	c0d010fa <io_seproxyhal_handle_event+0x6e>
          G_io_apdu_state = APDU_IDLE;
          THROW(EXCEPTION_IO_RESET);
        }
      }
    default:
      return io_event(CHANNEL_SPI);
c0d010e2:	2002      	movs	r0, #2
c0d010e4:	f7ff fab4 	bl	c0d00650 <io_event>
  }
  // defaulty return as not processed
  return 0;
}
c0d010e8:	bd80      	pop	{r7, pc}
c0d010ea:	2000      	movs	r0, #0
      }
      io_seproxyhal_handle_usb_event();
      return 1;

    case SEPROXYHAL_TAG_USB_EP_XFER_EVENT:
      if (rx_len < 3+3) {
c0d010ec:	2906      	cmp	r1, #6
c0d010ee:	d200      	bcs.n	c0d010f2 <io_seproxyhal_handle_event+0x66>
    default:
      return io_event(CHANNEL_SPI);
  }
  // defaulty return as not processed
  return 0;
}
c0d010f0:	bd80      	pop	{r7, pc}
    case SEPROXYHAL_TAG_USB_EP_XFER_EVENT:
      if (rx_len < 3+3) {
        // error !
        return 0;
      }
      io_seproxyhal_handle_usb_ep_xfer_event();
c0d010f2:	f7ff ff5b 	bl	c0d00fac <io_seproxyhal_handle_usb_ep_xfer_event>
c0d010f6:	2001      	movs	r0, #1
    default:
      return io_event(CHANNEL_SPI);
  }
  // defaulty return as not processed
  return 0;
}
c0d010f8:	bd80      	pop	{r7, pc}
      if(G_io_timeout) {
        G_io_timeout-=MIN(G_io_timeout, 100);
        #warning TODO use real ticker event interval here instead of the x100ms multiplier
        if (!G_io_timeout) {
          // timeout !
          G_io_apdu_state = APDU_IDLE;
c0d010fa:	4805      	ldr	r0, [pc, #20]	; (c0d01110 <io_seproxyhal_handle_event+0x84>)
c0d010fc:	2100      	movs	r1, #0
c0d010fe:	7001      	strb	r1, [r0, #0]
          THROW(EXCEPTION_IO_RESET);
c0d01100:	2010      	movs	r0, #16
c0d01102:	f7ff fefc 	bl	c0d00efe <os_longjmp>
c0d01106:	46c0      	nop			; (mov r8, r8)
c0d01108:	20001c28 	.word	0x20001c28
c0d0110c:	20001ecc 	.word	0x20001ecc
c0d01110:	20001ed7 	.word	0x20001ed7

c0d01114 <io_usb_send_apdu_data>:
      break;
    }
  }
}

void io_usb_send_apdu_data(unsigned char* buffer, unsigned short length) {
c0d01114:	b580      	push	{r7, lr}
c0d01116:	460a      	mov	r2, r1
c0d01118:	4601      	mov	r1, r0
  // wait for 20 events before hanging up and timeout (~2 seconds of timeout)
  io_usb_send_ep(0x82, buffer, length, 20);
c0d0111a:	2082      	movs	r0, #130	; 0x82
c0d0111c:	2314      	movs	r3, #20
c0d0111e:	f7ff ff6d 	bl	c0d00ffc <io_usb_send_ep>
}
c0d01122:	bd80      	pop	{r7, pc}

c0d01124 <io_seproxyhal_handle_capdu_event>:

}
#endif


void io_seproxyhal_handle_capdu_event(void) {
c0d01124:	b580      	push	{r7, lr}
  if(G_io_apdu_state == APDU_IDLE) 
c0d01126:	480b      	ldr	r0, [pc, #44]	; (c0d01154 <io_seproxyhal_handle_capdu_event+0x30>)
c0d01128:	7801      	ldrb	r1, [r0, #0]
c0d0112a:	2900      	cmp	r1, #0
c0d0112c:	d110      	bne.n	c0d01150 <io_seproxyhal_handle_capdu_event+0x2c>
  {
    G_io_apdu_media = IO_APDU_MEDIA_RAW; // for application code
c0d0112e:	490a      	ldr	r1, [pc, #40]	; (c0d01158 <io_seproxyhal_handle_capdu_event+0x34>)
c0d01130:	2205      	movs	r2, #5
c0d01132:	700a      	strb	r2, [r1, #0]
    G_io_apdu_state = APDU_RAW; // for next call to io_exchange
c0d01134:	210a      	movs	r1, #10
c0d01136:	7001      	strb	r1, [r0, #0]
    G_io_apdu_length = U2BE(G_io_seproxyhal_spi_buffer, 1);
c0d01138:	4808      	ldr	r0, [pc, #32]	; (c0d0115c <io_seproxyhal_handle_capdu_event+0x38>)
c0d0113a:	7881      	ldrb	r1, [r0, #2]
c0d0113c:	7842      	ldrb	r2, [r0, #1]
c0d0113e:	0212      	lsls	r2, r2, #8
c0d01140:	430a      	orrs	r2, r1
c0d01142:	4907      	ldr	r1, [pc, #28]	; (c0d01160 <io_seproxyhal_handle_capdu_event+0x3c>)
c0d01144:	800a      	strh	r2, [r1, #0]
    // copy apdu to apdu buffer
    os_memmove(G_io_apdu_buffer, G_io_seproxyhal_spi_buffer+3, G_io_apdu_length);
c0d01146:	880a      	ldrh	r2, [r1, #0]
c0d01148:	1cc1      	adds	r1, r0, #3
c0d0114a:	4806      	ldr	r0, [pc, #24]	; (c0d01164 <io_seproxyhal_handle_capdu_event+0x40>)
c0d0114c:	f7ff fe23 	bl	c0d00d96 <os_memmove>
  }
}
c0d01150:	bd80      	pop	{r7, pc}
c0d01152:	46c0      	nop			; (mov r8, r8)
c0d01154:	20001ed7 	.word	0x20001ed7
c0d01158:	20001ed0 	.word	0x20001ed0
c0d0115c:	20001c28 	.word	0x20001c28
c0d01160:	20001ed8 	.word	0x20001ed8
c0d01164:	20001dbc 	.word	0x20001dbc

c0d01168 <io_seproxyhal_init>:
#ifdef HAVE_BOLOS_APP_STACK_CANARY
#define APP_STACK_CANARY_MAGIC 0xDEAD0031
extern unsigned int app_stack_canary;
#endif // HAVE_BOLOS_APP_STACK_CANARY

void io_seproxyhal_init(void) {
c0d01168:	b510      	push	{r4, lr}
  // Enforce OS compatibility
  check_api_level(CX_COMPAT_APILEVEL);
c0d0116a:	2008      	movs	r0, #8
c0d0116c:	f000 fcce 	bl	c0d01b0c <check_api_level>

#ifdef HAVE_BOLOS_APP_STACK_CANARY
  app_stack_canary = APP_STACK_CANARY_MAGIC;
#endif // HAVE_BOLOS_APP_STACK_CANARY  

  G_io_apdu_state = APDU_IDLE;
c0d01170:	480a      	ldr	r0, [pc, #40]	; (c0d0119c <io_seproxyhal_init+0x34>)
c0d01172:	2400      	movs	r4, #0
c0d01174:	7004      	strb	r4, [r0, #0]
  G_io_apdu_offset = 0;
c0d01176:	480a      	ldr	r0, [pc, #40]	; (c0d011a0 <io_seproxyhal_init+0x38>)
c0d01178:	8004      	strh	r4, [r0, #0]
  G_io_apdu_length = 0;
c0d0117a:	480a      	ldr	r0, [pc, #40]	; (c0d011a4 <io_seproxyhal_init+0x3c>)
c0d0117c:	8004      	strh	r4, [r0, #0]
  G_io_apdu_seq = 0;
c0d0117e:	480a      	ldr	r0, [pc, #40]	; (c0d011a8 <io_seproxyhal_init+0x40>)
c0d01180:	8004      	strh	r4, [r0, #0]
  G_io_apdu_media = IO_APDU_MEDIA_NONE;
c0d01182:	480a      	ldr	r0, [pc, #40]	; (c0d011ac <io_seproxyhal_init+0x44>)
c0d01184:	7004      	strb	r4, [r0, #0]
  G_io_timeout_limit = NO_TIMEOUT;
c0d01186:	480a      	ldr	r0, [pc, #40]	; (c0d011b0 <io_seproxyhal_init+0x48>)
c0d01188:	6004      	str	r4, [r0, #0]
  debug_apdus_offset = 0;
  #endif // DEBUG_APDU


  #ifdef HAVE_USB_APDU
  io_usb_hid_init();
c0d0118a:	f7ff fe1f 	bl	c0d00dcc <io_usb_hid_init>
  io_seproxyhal_init_button();
}

void io_seproxyhal_init_ux(void) {
  // initialize the touch part
  G_bagl_last_touched_not_released_component = NULL;
c0d0118e:	4809      	ldr	r0, [pc, #36]	; (c0d011b4 <io_seproxyhal_init+0x4c>)
c0d01190:	6004      	str	r4, [r0, #0]

}

void io_seproxyhal_init_button(void) {
  // no button push so far
  G_button_mask = 0;
c0d01192:	4809      	ldr	r0, [pc, #36]	; (c0d011b8 <io_seproxyhal_init+0x50>)
c0d01194:	6004      	str	r4, [r0, #0]
  G_button_same_mask_counter = 0;
c0d01196:	4809      	ldr	r0, [pc, #36]	; (c0d011bc <io_seproxyhal_init+0x54>)
c0d01198:	6004      	str	r4, [r0, #0]
  io_usb_hid_init();
  #endif // HAVE_USB_APDU

  io_seproxyhal_init_ux();
  io_seproxyhal_init_button();
}
c0d0119a:	bd10      	pop	{r4, pc}
c0d0119c:	20001ed7 	.word	0x20001ed7
c0d011a0:	20001eda 	.word	0x20001eda
c0d011a4:	20001ed8 	.word	0x20001ed8
c0d011a8:	20001edc 	.word	0x20001edc
c0d011ac:	20001ed0 	.word	0x20001ed0
c0d011b0:	20001ec8 	.word	0x20001ec8
c0d011b4:	20001ee0 	.word	0x20001ee0
c0d011b8:	20001ee4 	.word	0x20001ee4
c0d011bc:	20001ee8 	.word	0x20001ee8

c0d011c0 <io_seproxyhal_init_ux>:

void io_seproxyhal_init_ux(void) {
  // initialize the touch part
  G_bagl_last_touched_not_released_component = NULL;
c0d011c0:	4801      	ldr	r0, [pc, #4]	; (c0d011c8 <io_seproxyhal_init_ux+0x8>)
c0d011c2:	2100      	movs	r1, #0
c0d011c4:	6001      	str	r1, [r0, #0]

}
c0d011c6:	4770      	bx	lr
c0d011c8:	20001ee0 	.word	0x20001ee0

c0d011cc <io_seproxyhal_touch_out>:
  G_button_same_mask_counter = 0;
}

#ifdef HAVE_BAGL

unsigned int io_seproxyhal_touch_out(const bagl_element_t* element, bagl_element_callback_t before_display) {
c0d011cc:	b5b0      	push	{r4, r5, r7, lr}
c0d011ce:	460d      	mov	r5, r1
c0d011d0:	4604      	mov	r4, r0
  const bagl_element_t* el;
  if (element->out != NULL) {
c0d011d2:	6b20      	ldr	r0, [r4, #48]	; 0x30
c0d011d4:	2800      	cmp	r0, #0
c0d011d6:	d00c      	beq.n	c0d011f2 <io_seproxyhal_touch_out+0x26>
    el = (const bagl_element_t*)PIC(((bagl_element_callback_t)PIC(element->out))(element));
c0d011d8:	f000 fc80 	bl	c0d01adc <pic>
c0d011dc:	4601      	mov	r1, r0
c0d011de:	4620      	mov	r0, r4
c0d011e0:	4788      	blx	r1
c0d011e2:	f000 fc7b 	bl	c0d01adc <pic>
c0d011e6:	2100      	movs	r1, #0
    // backward compatible with samples and such
    if (! el) {
c0d011e8:	2800      	cmp	r0, #0
c0d011ea:	d010      	beq.n	c0d0120e <io_seproxyhal_touch_out+0x42>
c0d011ec:	2801      	cmp	r0, #1
c0d011ee:	d000      	beq.n	c0d011f2 <io_seproxyhal_touch_out+0x26>
c0d011f0:	4604      	mov	r4, r0
      element = el;
    }
  }

  // out function might have triggered a draw of its own during a display callback
  if (before_display) {
c0d011f2:	2d00      	cmp	r5, #0
c0d011f4:	d007      	beq.n	c0d01206 <io_seproxyhal_touch_out+0x3a>
    el = before_display(element);
c0d011f6:	4620      	mov	r0, r4
c0d011f8:	47a8      	blx	r5
c0d011fa:	2100      	movs	r1, #0
    if (!el) {
c0d011fc:	2800      	cmp	r0, #0
c0d011fe:	d006      	beq.n	c0d0120e <io_seproxyhal_touch_out+0x42>
c0d01200:	2801      	cmp	r0, #1
c0d01202:	d000      	beq.n	c0d01206 <io_seproxyhal_touch_out+0x3a>
c0d01204:	4604      	mov	r4, r0
    if ((unsigned int)el != 1) {
      element = el;
    }
  }

  io_seproxyhal_display(element);
c0d01206:	4620      	mov	r0, r4
c0d01208:	f7ff f934 	bl	c0d00474 <io_seproxyhal_display>
c0d0120c:	2101      	movs	r1, #1
  return 1;
}
c0d0120e:	4608      	mov	r0, r1
c0d01210:	bdb0      	pop	{r4, r5, r7, pc}

c0d01212 <io_seproxyhal_touch_over>:

unsigned int io_seproxyhal_touch_over(const bagl_element_t* element, bagl_element_callback_t before_display) {
c0d01212:	b5b0      	push	{r4, r5, r7, lr}
c0d01214:	b08e      	sub	sp, #56	; 0x38
c0d01216:	460c      	mov	r4, r1
c0d01218:	4605      	mov	r5, r0
  bagl_element_t e;
  const bagl_element_t* el;
  if (element->over != NULL) {
c0d0121a:	6b68      	ldr	r0, [r5, #52]	; 0x34
c0d0121c:	2800      	cmp	r0, #0
c0d0121e:	d00c      	beq.n	c0d0123a <io_seproxyhal_touch_over+0x28>
    el = (const bagl_element_t*)PIC(((bagl_element_callback_t)PIC(element->over))(element));
c0d01220:	f000 fc5c 	bl	c0d01adc <pic>
c0d01224:	4601      	mov	r1, r0
c0d01226:	4628      	mov	r0, r5
c0d01228:	4788      	blx	r1
c0d0122a:	f000 fc57 	bl	c0d01adc <pic>
c0d0122e:	2100      	movs	r1, #0
    // backward compatible with samples and such
    if (!el) {
c0d01230:	2800      	cmp	r0, #0
c0d01232:	d016      	beq.n	c0d01262 <io_seproxyhal_touch_over+0x50>
c0d01234:	2801      	cmp	r0, #1
c0d01236:	d000      	beq.n	c0d0123a <io_seproxyhal_touch_over+0x28>
c0d01238:	4605      	mov	r5, r0
c0d0123a:	4668      	mov	r0, sp
      element = el;
    }
  }

  // over function might have triggered a draw of its own during a display callback
  os_memmove(&e, (void*)element, sizeof(bagl_element_t));
c0d0123c:	2238      	movs	r2, #56	; 0x38
c0d0123e:	4629      	mov	r1, r5
c0d01240:	f7ff fda9 	bl	c0d00d96 <os_memmove>
  e.component.fgcolor = element->overfgcolor;
c0d01244:	6a68      	ldr	r0, [r5, #36]	; 0x24
c0d01246:	9004      	str	r0, [sp, #16]
  e.component.bgcolor = element->overbgcolor;
c0d01248:	6aa8      	ldr	r0, [r5, #40]	; 0x28
c0d0124a:	9005      	str	r0, [sp, #20]

  //element = &e; // for INARRAY checks, it disturbs a bit. avoid it

  if (before_display) {
c0d0124c:	2c00      	cmp	r4, #0
c0d0124e:	d004      	beq.n	c0d0125a <io_seproxyhal_touch_over+0x48>
    el = before_display(element);
c0d01250:	4628      	mov	r0, r5
c0d01252:	47a0      	blx	r4
c0d01254:	2100      	movs	r1, #0
    element = &e;
    if (!el) {
c0d01256:	2800      	cmp	r0, #0
c0d01258:	d003      	beq.n	c0d01262 <io_seproxyhal_touch_over+0x50>
c0d0125a:	4668      	mov	r0, sp
  //else 
  {
    element = &e;
  }

  io_seproxyhal_display(element);
c0d0125c:	f7ff f90a 	bl	c0d00474 <io_seproxyhal_display>
c0d01260:	2101      	movs	r1, #1
  return 1;
}
c0d01262:	4608      	mov	r0, r1
c0d01264:	b00e      	add	sp, #56	; 0x38
c0d01266:	bdb0      	pop	{r4, r5, r7, pc}

c0d01268 <io_seproxyhal_touch_tap>:

unsigned int io_seproxyhal_touch_tap(const bagl_element_t* element, bagl_element_callback_t before_display) {
c0d01268:	b5b0      	push	{r4, r5, r7, lr}
c0d0126a:	460d      	mov	r5, r1
c0d0126c:	4604      	mov	r4, r0
  const bagl_element_t* el;
  if (element->tap != NULL) {
c0d0126e:	6ae0      	ldr	r0, [r4, #44]	; 0x2c
c0d01270:	2800      	cmp	r0, #0
c0d01272:	d00c      	beq.n	c0d0128e <io_seproxyhal_touch_tap+0x26>
    el = (const bagl_element_t*)PIC(((bagl_element_callback_t)PIC(element->tap))(element));
c0d01274:	f000 fc32 	bl	c0d01adc <pic>
c0d01278:	4601      	mov	r1, r0
c0d0127a:	4620      	mov	r0, r4
c0d0127c:	4788      	blx	r1
c0d0127e:	f000 fc2d 	bl	c0d01adc <pic>
c0d01282:	2100      	movs	r1, #0
    // backward compatible with samples and such
    if (!el) {
c0d01284:	2800      	cmp	r0, #0
c0d01286:	d010      	beq.n	c0d012aa <io_seproxyhal_touch_tap+0x42>
c0d01288:	2801      	cmp	r0, #1
c0d0128a:	d000      	beq.n	c0d0128e <io_seproxyhal_touch_tap+0x26>
c0d0128c:	4604      	mov	r4, r0
      element = el;
    }
  }

  // tap function might have triggered a draw of its own during a display callback
  if (before_display) {
c0d0128e:	2d00      	cmp	r5, #0
c0d01290:	d007      	beq.n	c0d012a2 <io_seproxyhal_touch_tap+0x3a>
    el = before_display(element);
c0d01292:	4620      	mov	r0, r4
c0d01294:	47a8      	blx	r5
c0d01296:	2100      	movs	r1, #0
    if (!el) {
c0d01298:	2800      	cmp	r0, #0
c0d0129a:	d006      	beq.n	c0d012aa <io_seproxyhal_touch_tap+0x42>
c0d0129c:	2801      	cmp	r0, #1
c0d0129e:	d000      	beq.n	c0d012a2 <io_seproxyhal_touch_tap+0x3a>
c0d012a0:	4604      	mov	r4, r0
    }
    if ((unsigned int)el != 1) {
      element = el;
    }
  }
  io_seproxyhal_display(element);
c0d012a2:	4620      	mov	r0, r4
c0d012a4:	f7ff f8e6 	bl	c0d00474 <io_seproxyhal_display>
c0d012a8:	2101      	movs	r1, #1
  return 1;
}
c0d012aa:	4608      	mov	r0, r1
c0d012ac:	bdb0      	pop	{r4, r5, r7, pc}
	...

c0d012b0 <io_seproxyhal_touch_element_callback>:
  io_seproxyhal_touch_element_callback(elements, element_count, x, y, event_kind, NULL);  
}

// browse all elements and until an element has changed state, continue browsing
// return if processed or not
void io_seproxyhal_touch_element_callback(const bagl_element_t* elements, unsigned short element_count, unsigned short x, unsigned short y, unsigned char event_kind, bagl_element_callback_t before_display) {
c0d012b0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d012b2:	b087      	sub	sp, #28
c0d012b4:	9302      	str	r3, [sp, #8]
c0d012b6:	9203      	str	r2, [sp, #12]
c0d012b8:	9105      	str	r1, [sp, #20]
  unsigned char comp_idx;
  unsigned char last_touched_not_released_component_was_in_current_array = 0;

  // find the first empty entry
  for (comp_idx=0; comp_idx < element_count; comp_idx++) {
c0d012ba:	2900      	cmp	r1, #0
c0d012bc:	d077      	beq.n	c0d013ae <io_seproxyhal_touch_element_callback+0xfe>
c0d012be:	9004      	str	r0, [sp, #16]
c0d012c0:	980d      	ldr	r0, [sp, #52]	; 0x34
c0d012c2:	9001      	str	r0, [sp, #4]
c0d012c4:	980c      	ldr	r0, [sp, #48]	; 0x30
c0d012c6:	9000      	str	r0, [sp, #0]
c0d012c8:	2500      	movs	r5, #0
c0d012ca:	4b3c      	ldr	r3, [pc, #240]	; (c0d013bc <io_seproxyhal_touch_element_callback+0x10c>)
c0d012cc:	9506      	str	r5, [sp, #24]
c0d012ce:	462f      	mov	r7, r5
c0d012d0:	461e      	mov	r6, r3
    // process all components matching the x/y/w/h (no break) => fishy for the released out of zone
    // continue processing only if a status has not been sent
    if (io_seproxyhal_spi_is_status_sent()) {
c0d012d2:	f000 fcfd 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d012d6:	2800      	cmp	r0, #0
c0d012d8:	d155      	bne.n	c0d01386 <io_seproxyhal_touch_element_callback+0xd6>
      // continue instead of return to process all elemnts and therefore discard last touched element
      break;
    }

    // only perform out callback when element was in the current array, else, leave it be
    if (&elements[comp_idx] == G_bagl_last_touched_not_released_component) {
c0d012da:	2038      	movs	r0, #56	; 0x38
c0d012dc:	4368      	muls	r0, r5
c0d012de:	9c04      	ldr	r4, [sp, #16]
c0d012e0:	1825      	adds	r5, r4, r0
c0d012e2:	4633      	mov	r3, r6
c0d012e4:	681a      	ldr	r2, [r3, #0]
c0d012e6:	2101      	movs	r1, #1
c0d012e8:	4295      	cmp	r5, r2
c0d012ea:	d000      	beq.n	c0d012ee <io_seproxyhal_touch_element_callback+0x3e>
c0d012ec:	9906      	ldr	r1, [sp, #24]
c0d012ee:	9106      	str	r1, [sp, #24]
      last_touched_not_released_component_was_in_current_array = 1;
    }

    // the first component drawn with a 
    if ((elements[comp_idx].component.type & BAGL_FLAG_TOUCHABLE) 
c0d012f0:	5620      	ldrsb	r0, [r4, r0]
        && elements[comp_idx].component.x-elements[comp_idx].touch_area_brim <= x && x<elements[comp_idx].component.x+elements[comp_idx].component.width+elements[comp_idx].touch_area_brim
c0d012f2:	2800      	cmp	r0, #0
c0d012f4:	da41      	bge.n	c0d0137a <io_seproxyhal_touch_element_callback+0xca>
c0d012f6:	2020      	movs	r0, #32
c0d012f8:	5c28      	ldrb	r0, [r5, r0]
c0d012fa:	2102      	movs	r1, #2
c0d012fc:	5e69      	ldrsh	r1, [r5, r1]
c0d012fe:	1a0a      	subs	r2, r1, r0
c0d01300:	9c03      	ldr	r4, [sp, #12]
c0d01302:	42a2      	cmp	r2, r4
c0d01304:	dc39      	bgt.n	c0d0137a <io_seproxyhal_touch_element_callback+0xca>
c0d01306:	1841      	adds	r1, r0, r1
c0d01308:	88ea      	ldrh	r2, [r5, #6]
c0d0130a:	1889      	adds	r1, r1, r2
        && elements[comp_idx].component.y-elements[comp_idx].touch_area_brim <= y && y<elements[comp_idx].component.y+elements[comp_idx].component.height+elements[comp_idx].touch_area_brim) {
c0d0130c:	9a03      	ldr	r2, [sp, #12]
c0d0130e:	428a      	cmp	r2, r1
c0d01310:	da33      	bge.n	c0d0137a <io_seproxyhal_touch_element_callback+0xca>
c0d01312:	2104      	movs	r1, #4
c0d01314:	5e6c      	ldrsh	r4, [r5, r1]
c0d01316:	1a22      	subs	r2, r4, r0
c0d01318:	9902      	ldr	r1, [sp, #8]
c0d0131a:	428a      	cmp	r2, r1
c0d0131c:	dc2d      	bgt.n	c0d0137a <io_seproxyhal_touch_element_callback+0xca>
c0d0131e:	1820      	adds	r0, r4, r0
c0d01320:	8929      	ldrh	r1, [r5, #8]
c0d01322:	1840      	adds	r0, r0, r1
    if (&elements[comp_idx] == G_bagl_last_touched_not_released_component) {
      last_touched_not_released_component_was_in_current_array = 1;
    }

    // the first component drawn with a 
    if ((elements[comp_idx].component.type & BAGL_FLAG_TOUCHABLE) 
c0d01324:	9902      	ldr	r1, [sp, #8]
c0d01326:	4281      	cmp	r1, r0
c0d01328:	da27      	bge.n	c0d0137a <io_seproxyhal_touch_element_callback+0xca>
        && elements[comp_idx].component.x-elements[comp_idx].touch_area_brim <= x && x<elements[comp_idx].component.x+elements[comp_idx].component.width+elements[comp_idx].touch_area_brim
        && elements[comp_idx].component.y-elements[comp_idx].touch_area_brim <= y && y<elements[comp_idx].component.y+elements[comp_idx].component.height+elements[comp_idx].touch_area_brim) {

      // outing the previous over'ed component
      if (&elements[comp_idx] != G_bagl_last_touched_not_released_component 
c0d0132a:	6818      	ldr	r0, [r3, #0]
              && G_bagl_last_touched_not_released_component != NULL) {
c0d0132c:	4285      	cmp	r5, r0
c0d0132e:	d010      	beq.n	c0d01352 <io_seproxyhal_touch_element_callback+0xa2>
c0d01330:	6818      	ldr	r0, [r3, #0]
    if ((elements[comp_idx].component.type & BAGL_FLAG_TOUCHABLE) 
        && elements[comp_idx].component.x-elements[comp_idx].touch_area_brim <= x && x<elements[comp_idx].component.x+elements[comp_idx].component.width+elements[comp_idx].touch_area_brim
        && elements[comp_idx].component.y-elements[comp_idx].touch_area_brim <= y && y<elements[comp_idx].component.y+elements[comp_idx].component.height+elements[comp_idx].touch_area_brim) {

      // outing the previous over'ed component
      if (&elements[comp_idx] != G_bagl_last_touched_not_released_component 
c0d01332:	2800      	cmp	r0, #0
c0d01334:	d00d      	beq.n	c0d01352 <io_seproxyhal_touch_element_callback+0xa2>
              && G_bagl_last_touched_not_released_component != NULL) {
        // only out the previous element if the newly matching will be displayed 
        if (!before_display || before_display(&elements[comp_idx])) {
c0d01336:	9801      	ldr	r0, [sp, #4]
c0d01338:	2800      	cmp	r0, #0
c0d0133a:	d005      	beq.n	c0d01348 <io_seproxyhal_touch_element_callback+0x98>
c0d0133c:	4628      	mov	r0, r5
c0d0133e:	9901      	ldr	r1, [sp, #4]
c0d01340:	4788      	blx	r1
c0d01342:	4633      	mov	r3, r6
c0d01344:	2800      	cmp	r0, #0
c0d01346:	d018      	beq.n	c0d0137a <io_seproxyhal_touch_element_callback+0xca>
          if (io_seproxyhal_touch_out(G_bagl_last_touched_not_released_component, before_display)) {
c0d01348:	6818      	ldr	r0, [r3, #0]
c0d0134a:	9901      	ldr	r1, [sp, #4]
c0d0134c:	f7ff ff3e 	bl	c0d011cc <io_seproxyhal_touch_out>
c0d01350:	e008      	b.n	c0d01364 <io_seproxyhal_touch_element_callback+0xb4>
c0d01352:	9800      	ldr	r0, [sp, #0]
        continue;
      }
      */
      
      // callback the hal to notify the component impacted by the user input
      else if (event_kind == SEPROXYHAL_TAG_FINGER_EVENT_RELEASE) {
c0d01354:	2801      	cmp	r0, #1
c0d01356:	d009      	beq.n	c0d0136c <io_seproxyhal_touch_element_callback+0xbc>
c0d01358:	2802      	cmp	r0, #2
c0d0135a:	d10e      	bne.n	c0d0137a <io_seproxyhal_touch_element_callback+0xca>
        if (io_seproxyhal_touch_tap(&elements[comp_idx], before_display)) {
c0d0135c:	4628      	mov	r0, r5
c0d0135e:	9901      	ldr	r1, [sp, #4]
c0d01360:	f7ff ff82 	bl	c0d01268 <io_seproxyhal_touch_tap>
c0d01364:	4633      	mov	r3, r6
c0d01366:	2800      	cmp	r0, #0
c0d01368:	d007      	beq.n	c0d0137a <io_seproxyhal_touch_element_callback+0xca>
c0d0136a:	e022      	b.n	c0d013b2 <io_seproxyhal_touch_element_callback+0x102>
          return;
        }
      }
      else if (event_kind == SEPROXYHAL_TAG_FINGER_EVENT_TOUCH) {
        // ask for overing
        if (io_seproxyhal_touch_over(&elements[comp_idx], before_display)) {
c0d0136c:	4628      	mov	r0, r5
c0d0136e:	9901      	ldr	r1, [sp, #4]
c0d01370:	f7ff ff4f 	bl	c0d01212 <io_seproxyhal_touch_over>
c0d01374:	4633      	mov	r3, r6
c0d01376:	2800      	cmp	r0, #0
c0d01378:	d11e      	bne.n	c0d013b8 <io_seproxyhal_touch_element_callback+0x108>
void io_seproxyhal_touch_element_callback(const bagl_element_t* elements, unsigned short element_count, unsigned short x, unsigned short y, unsigned char event_kind, bagl_element_callback_t before_display) {
  unsigned char comp_idx;
  unsigned char last_touched_not_released_component_was_in_current_array = 0;

  // find the first empty entry
  for (comp_idx=0; comp_idx < element_count; comp_idx++) {
c0d0137a:	1c7f      	adds	r7, r7, #1
c0d0137c:	b2fd      	uxtb	r5, r7
c0d0137e:	9805      	ldr	r0, [sp, #20]
c0d01380:	4285      	cmp	r5, r0
c0d01382:	d3a5      	bcc.n	c0d012d0 <io_seproxyhal_touch_element_callback+0x20>
c0d01384:	e000      	b.n	c0d01388 <io_seproxyhal_touch_element_callback+0xd8>
c0d01386:	4633      	mov	r3, r6
    }
  }

  // if overing out of component or over another component, the out event is sent after the over event of the previous component
  if(last_touched_not_released_component_was_in_current_array 
    && G_bagl_last_touched_not_released_component != NULL) {
c0d01388:	9806      	ldr	r0, [sp, #24]
c0d0138a:	0600      	lsls	r0, r0, #24
c0d0138c:	d00f      	beq.n	c0d013ae <io_seproxyhal_touch_element_callback+0xfe>
c0d0138e:	6818      	ldr	r0, [r3, #0]
      }
    }
  }

  // if overing out of component or over another component, the out event is sent after the over event of the previous component
  if(last_touched_not_released_component_was_in_current_array 
c0d01390:	2800      	cmp	r0, #0
c0d01392:	d00c      	beq.n	c0d013ae <io_seproxyhal_touch_element_callback+0xfe>
    && G_bagl_last_touched_not_released_component != NULL) {

    // we won't be able to notify the out, don't do it, in case a diplay refused the dra of the relased element and the position matched another element of the array (in autocomplete for example)
    if (io_seproxyhal_spi_is_status_sent()) {
c0d01394:	f000 fc9c 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d01398:	4631      	mov	r1, r6
c0d0139a:	2800      	cmp	r0, #0
c0d0139c:	d107      	bne.n	c0d013ae <io_seproxyhal_touch_element_callback+0xfe>
      return;
    }
    
    if (io_seproxyhal_touch_out(G_bagl_last_touched_not_released_component, before_display)) {
c0d0139e:	6808      	ldr	r0, [r1, #0]
c0d013a0:	9901      	ldr	r1, [sp, #4]
c0d013a2:	f7ff ff13 	bl	c0d011cc <io_seproxyhal_touch_out>
c0d013a6:	2800      	cmp	r0, #0
c0d013a8:	d001      	beq.n	c0d013ae <io_seproxyhal_touch_element_callback+0xfe>
      // ok component out has been emitted
      G_bagl_last_touched_not_released_component = NULL;
c0d013aa:	2000      	movs	r0, #0
c0d013ac:	6030      	str	r0, [r6, #0]
    }
  }

  // not processed
}
c0d013ae:	b007      	add	sp, #28
c0d013b0:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d013b2:	2000      	movs	r0, #0
c0d013b4:	6018      	str	r0, [r3, #0]
c0d013b6:	e7fa      	b.n	c0d013ae <io_seproxyhal_touch_element_callback+0xfe>
      }
      else if (event_kind == SEPROXYHAL_TAG_FINGER_EVENT_TOUCH) {
        // ask for overing
        if (io_seproxyhal_touch_over(&elements[comp_idx], before_display)) {
          // remember the last touched component
          G_bagl_last_touched_not_released_component = (bagl_element_t*)&elements[comp_idx];
c0d013b8:	601d      	str	r5, [r3, #0]
c0d013ba:	e7f8      	b.n	c0d013ae <io_seproxyhal_touch_element_callback+0xfe>
c0d013bc:	20001ee0 	.word	0x20001ee0

c0d013c0 <io_seproxyhal_display_icon>:
  // remaining length of bitmap bits to be displayed
  return len;
}
#endif // SEPROXYHAL_TAG_SCREEN_DISPLAY_RAW_STATUS

void io_seproxyhal_display_icon(bagl_component_t* icon_component, bagl_icon_details_t* icon_details) {
c0d013c0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d013c2:	b089      	sub	sp, #36	; 0x24
c0d013c4:	460c      	mov	r4, r1
c0d013c6:	4601      	mov	r1, r0
c0d013c8:	ad02      	add	r5, sp, #8
c0d013ca:	221c      	movs	r2, #28
  bagl_component_t icon_component_mod;
  // ensure not being out of bounds in the icon component agianst the declared icon real size
  os_memmove(&icon_component_mod, icon_component, sizeof(bagl_component_t));
c0d013cc:	4628      	mov	r0, r5
c0d013ce:	9201      	str	r2, [sp, #4]
c0d013d0:	f7ff fce1 	bl	c0d00d96 <os_memmove>
  icon_component_mod.width = icon_details->width;
c0d013d4:	6821      	ldr	r1, [r4, #0]
c0d013d6:	80e9      	strh	r1, [r5, #6]
  icon_component_mod.height = icon_details->height;
c0d013d8:	6862      	ldr	r2, [r4, #4]
c0d013da:	812a      	strh	r2, [r5, #8]
  // component type = ICON, provided bitmap
  // => bitmap transmitted


  // color index size
  unsigned int h = (1<<(icon_details->bpp))*sizeof(unsigned int); 
c0d013dc:	68a0      	ldr	r0, [r4, #8]
  unsigned int w = ((icon_component->width*icon_component->height*icon_details->bpp)/8)+((icon_component->width*icon_component->height*icon_details->bpp)%8?1:0);
  unsigned short length = sizeof(bagl_component_t)
                          +1 /* bpp */
                          +h /* color index */
                          +w; /* image bitmap size */
  G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_SCREEN_DISPLAY_STATUS;
c0d013de:	4f1a      	ldr	r7, [pc, #104]	; (c0d01448 <io_seproxyhal_display_icon+0x88>)
c0d013e0:	2365      	movs	r3, #101	; 0x65
c0d013e2:	703b      	strb	r3, [r7, #0]


  // color index size
  unsigned int h = (1<<(icon_details->bpp))*sizeof(unsigned int); 
  // bitmap size
  unsigned int w = ((icon_component->width*icon_component->height*icon_details->bpp)/8)+((icon_component->width*icon_component->height*icon_details->bpp)%8?1:0);
c0d013e4:	b292      	uxth	r2, r2
c0d013e6:	4342      	muls	r2, r0
c0d013e8:	b28b      	uxth	r3, r1
c0d013ea:	4353      	muls	r3, r2
c0d013ec:	08d9      	lsrs	r1, r3, #3
c0d013ee:	1c4e      	adds	r6, r1, #1
c0d013f0:	2207      	movs	r2, #7
c0d013f2:	4213      	tst	r3, r2
c0d013f4:	d100      	bne.n	c0d013f8 <io_seproxyhal_display_icon+0x38>
c0d013f6:	460e      	mov	r6, r1
c0d013f8:	4631      	mov	r1, r6
c0d013fa:	9100      	str	r1, [sp, #0]
c0d013fc:	2604      	movs	r6, #4
  // component type = ICON, provided bitmap
  // => bitmap transmitted


  // color index size
  unsigned int h = (1<<(icon_details->bpp))*sizeof(unsigned int); 
c0d013fe:	4086      	lsls	r6, r0
  // bitmap size
  unsigned int w = ((icon_component->width*icon_component->height*icon_details->bpp)/8)+((icon_component->width*icon_component->height*icon_details->bpp)%8?1:0);
  unsigned short length = sizeof(bagl_component_t)
                          +1 /* bpp */
                          +h /* color index */
c0d01400:	1870      	adds	r0, r6, r1
                          +w; /* image bitmap size */
c0d01402:	301d      	adds	r0, #29
  G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_SCREEN_DISPLAY_STATUS;
  G_io_seproxyhal_spi_buffer[1] = length>>8;
c0d01404:	0a01      	lsrs	r1, r0, #8
c0d01406:	7079      	strb	r1, [r7, #1]
  G_io_seproxyhal_spi_buffer[2] = length;
c0d01408:	70b8      	strb	r0, [r7, #2]
c0d0140a:	2103      	movs	r1, #3
  io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 3);
c0d0140c:	4638      	mov	r0, r7
c0d0140e:	f000 fc49 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  io_seproxyhal_spi_send((unsigned char*)icon_component, sizeof(bagl_component_t));
c0d01412:	4628      	mov	r0, r5
c0d01414:	9901      	ldr	r1, [sp, #4]
c0d01416:	f000 fc45 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  G_io_seproxyhal_spi_buffer[0] = icon_details->bpp;
c0d0141a:	68a0      	ldr	r0, [r4, #8]
c0d0141c:	7038      	strb	r0, [r7, #0]
c0d0141e:	2101      	movs	r1, #1
  io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 1);
c0d01420:	4638      	mov	r0, r7
c0d01422:	f000 fc3f 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  io_seproxyhal_spi_send((unsigned char*)PIC(icon_details->colors), h);
c0d01426:	68e0      	ldr	r0, [r4, #12]
c0d01428:	f000 fb58 	bl	c0d01adc <pic>
c0d0142c:	b2b1      	uxth	r1, r6
c0d0142e:	f000 fc39 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  io_seproxyhal_spi_send((unsigned char*)PIC(icon_details->bitmap), w);
c0d01432:	9800      	ldr	r0, [sp, #0]
c0d01434:	b285      	uxth	r5, r0
c0d01436:	6920      	ldr	r0, [r4, #16]
c0d01438:	f000 fb50 	bl	c0d01adc <pic>
c0d0143c:	4629      	mov	r1, r5
c0d0143e:	f000 fc31 	bl	c0d01ca4 <io_seproxyhal_spi_send>
#endif // !SEPROXYHAL_TAG_SCREEN_DISPLAY_RAW_STATUS
}
c0d01442:	b009      	add	sp, #36	; 0x24
c0d01444:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d01446:	46c0      	nop			; (mov r8, r8)
c0d01448:	20001c28 	.word	0x20001c28

c0d0144c <io_seproxyhal_display_default>:

void io_seproxyhal_display_default(const bagl_element_t * element) {
c0d0144c:	b570      	push	{r4, r5, r6, lr}
c0d0144e:	4604      	mov	r4, r0
  // process automagically address from rom and from ram
  unsigned int type = (element->component.type & ~(BAGL_FLAG_TOUCHABLE));
c0d01450:	7820      	ldrb	r0, [r4, #0]
c0d01452:	267f      	movs	r6, #127	; 0x7f
c0d01454:	4006      	ands	r6, r0

  // avoid sending another status :), fixes a lot of bugs in the end
  if (io_seproxyhal_spi_is_status_sent()) {
c0d01456:	f000 fc3b 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d0145a:	2800      	cmp	r0, #0
c0d0145c:	d130      	bne.n	c0d014c0 <io_seproxyhal_display_default+0x74>
c0d0145e:	2e00      	cmp	r6, #0
c0d01460:	d02e      	beq.n	c0d014c0 <io_seproxyhal_display_default+0x74>
    return;
  }

  if (type != BAGL_NONE) {
    if (element->text != NULL) {
c0d01462:	69e0      	ldr	r0, [r4, #28]
c0d01464:	2800      	cmp	r0, #0
c0d01466:	d01d      	beq.n	c0d014a4 <io_seproxyhal_display_default+0x58>
      unsigned int text_adr = PIC((unsigned int)element->text);
c0d01468:	f000 fb38 	bl	c0d01adc <pic>
c0d0146c:	4605      	mov	r5, r0
      // consider an icon details descriptor is pointed by the context
      if (type == BAGL_ICON && element->component.icon_id == 0) {
c0d0146e:	2e05      	cmp	r6, #5
c0d01470:	d102      	bne.n	c0d01478 <io_seproxyhal_display_default+0x2c>
c0d01472:	7ea0      	ldrb	r0, [r4, #26]
c0d01474:	2800      	cmp	r0, #0
c0d01476:	d024      	beq.n	c0d014c2 <io_seproxyhal_display_default+0x76>
        io_seproxyhal_display_icon(&element->component, (bagl_icon_details_t*)text_adr);
      }
      else {
        unsigned short length = sizeof(bagl_component_t)+strlen((const char*)text_adr);
c0d01478:	4628      	mov	r0, r5
c0d0147a:	f002 f877 	bl	c0d0356c <strlen>
c0d0147e:	4606      	mov	r6, r0
        G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_SCREEN_DISPLAY_STATUS;
c0d01480:	4812      	ldr	r0, [pc, #72]	; (c0d014cc <io_seproxyhal_display_default+0x80>)
c0d01482:	2165      	movs	r1, #101	; 0x65
c0d01484:	7001      	strb	r1, [r0, #0]
      // consider an icon details descriptor is pointed by the context
      if (type == BAGL_ICON && element->component.icon_id == 0) {
        io_seproxyhal_display_icon(&element->component, (bagl_icon_details_t*)text_adr);
      }
      else {
        unsigned short length = sizeof(bagl_component_t)+strlen((const char*)text_adr);
c0d01486:	4631      	mov	r1, r6
c0d01488:	311c      	adds	r1, #28
        G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_SCREEN_DISPLAY_STATUS;
        G_io_seproxyhal_spi_buffer[1] = length>>8;
c0d0148a:	0a0a      	lsrs	r2, r1, #8
c0d0148c:	7042      	strb	r2, [r0, #1]
        G_io_seproxyhal_spi_buffer[2] = length;
c0d0148e:	7081      	strb	r1, [r0, #2]
        io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 3);
c0d01490:	2103      	movs	r1, #3
c0d01492:	f000 fc07 	bl	c0d01ca4 <io_seproxyhal_spi_send>
c0d01496:	211c      	movs	r1, #28
        io_seproxyhal_spi_send((unsigned char*)&element->component, sizeof(bagl_component_t));
c0d01498:	4620      	mov	r0, r4
c0d0149a:	f000 fc03 	bl	c0d01ca4 <io_seproxyhal_spi_send>
        io_seproxyhal_spi_send((unsigned char*)text_adr, length-sizeof(bagl_component_t));
c0d0149e:	b2b1      	uxth	r1, r6
c0d014a0:	4628      	mov	r0, r5
c0d014a2:	e00b      	b.n	c0d014bc <io_seproxyhal_display_default+0x70>
      }
    }
    else {
      unsigned short length = sizeof(bagl_component_t);
      G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_SCREEN_DISPLAY_STATUS;
c0d014a4:	4809      	ldr	r0, [pc, #36]	; (c0d014cc <io_seproxyhal_display_default+0x80>)
c0d014a6:	2165      	movs	r1, #101	; 0x65
c0d014a8:	7001      	strb	r1, [r0, #0]
      G_io_seproxyhal_spi_buffer[1] = length>>8;
c0d014aa:	2100      	movs	r1, #0
c0d014ac:	7041      	strb	r1, [r0, #1]
c0d014ae:	251c      	movs	r5, #28
      G_io_seproxyhal_spi_buffer[2] = length;
c0d014b0:	7085      	strb	r5, [r0, #2]
      io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 3);
c0d014b2:	2103      	movs	r1, #3
c0d014b4:	f000 fbf6 	bl	c0d01ca4 <io_seproxyhal_spi_send>
      io_seproxyhal_spi_send((unsigned char*)&element->component, sizeof(bagl_component_t));
c0d014b8:	4620      	mov	r0, r4
c0d014ba:	4629      	mov	r1, r5
c0d014bc:	f000 fbf2 	bl	c0d01ca4 <io_seproxyhal_spi_send>
    }
  }
}
c0d014c0:	bd70      	pop	{r4, r5, r6, pc}
  if (type != BAGL_NONE) {
    if (element->text != NULL) {
      unsigned int text_adr = PIC((unsigned int)element->text);
      // consider an icon details descriptor is pointed by the context
      if (type == BAGL_ICON && element->component.icon_id == 0) {
        io_seproxyhal_display_icon(&element->component, (bagl_icon_details_t*)text_adr);
c0d014c2:	4620      	mov	r0, r4
c0d014c4:	4629      	mov	r1, r5
c0d014c6:	f7ff ff7b 	bl	c0d013c0 <io_seproxyhal_display_icon>
      G_io_seproxyhal_spi_buffer[2] = length;
      io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 3);
      io_seproxyhal_spi_send((unsigned char*)&element->component, sizeof(bagl_component_t));
    }
  }
}
c0d014ca:	bd70      	pop	{r4, r5, r6, pc}
c0d014cc:	20001c28 	.word	0x20001c28

c0d014d0 <bagl_label_roundtrip_duration_ms>:

unsigned int bagl_label_roundtrip_duration_ms(const bagl_element_t* e, unsigned int average_char_width) {
c0d014d0:	b580      	push	{r7, lr}
c0d014d2:	460a      	mov	r2, r1
  return bagl_label_roundtrip_duration_ms_buf(e, e->text, average_char_width);
c0d014d4:	69c1      	ldr	r1, [r0, #28]
c0d014d6:	f000 f801 	bl	c0d014dc <bagl_label_roundtrip_duration_ms_buf>
c0d014da:	bd80      	pop	{r7, pc}

c0d014dc <bagl_label_roundtrip_duration_ms_buf>:
}

unsigned int bagl_label_roundtrip_duration_ms_buf(const bagl_element_t* e, const char* str, unsigned int average_char_width) {
c0d014dc:	b570      	push	{r4, r5, r6, lr}
c0d014de:	4616      	mov	r6, r2
c0d014e0:	4604      	mov	r4, r0
c0d014e2:	2500      	movs	r5, #0
  // not a scrollable label
  if (e == NULL || (e->component.type != BAGL_LABEL && e->component.type != BAGL_LABELINE)) {
c0d014e4:	2c00      	cmp	r4, #0
c0d014e6:	d01c      	beq.n	c0d01522 <bagl_label_roundtrip_duration_ms_buf+0x46>
c0d014e8:	7820      	ldrb	r0, [r4, #0]
c0d014ea:	2807      	cmp	r0, #7
c0d014ec:	d001      	beq.n	c0d014f2 <bagl_label_roundtrip_duration_ms_buf+0x16>
c0d014ee:	2802      	cmp	r0, #2
c0d014f0:	d117      	bne.n	c0d01522 <bagl_label_roundtrip_duration_ms_buf+0x46>
    return 0;
  }
  
  unsigned int text_adr = PIC((unsigned int)str);
c0d014f2:	4608      	mov	r0, r1
c0d014f4:	f000 faf2 	bl	c0d01adc <pic>
  unsigned int textlen = 0;
  
  // no delay, no text to display
  if (!text_adr) {
c0d014f8:	2800      	cmp	r0, #0
c0d014fa:	d012      	beq.n	c0d01522 <bagl_label_roundtrip_duration_ms_buf+0x46>
    return 0;
  }
  textlen = strlen((const char*)text_adr);
c0d014fc:	f002 f836 	bl	c0d0356c <strlen>
  
  // no delay, all text fits
  textlen = textlen * average_char_width;
c0d01500:	4346      	muls	r6, r0
  if (textlen <= e->component.width) {
c0d01502:	88e0      	ldrh	r0, [r4, #6]
c0d01504:	4286      	cmp	r6, r0
c0d01506:	d90c      	bls.n	c0d01522 <bagl_label_roundtrip_duration_ms_buf+0x46>
    return 0; 
  }
  
  // compute scrolled text length
  return 2*(textlen - e->component.width)*1000/e->component.icon_id + 2*(e->component.stroke & ~(0x80))*100;
c0d01508:	1a31      	subs	r1, r6, r0
c0d0150a:	207d      	movs	r0, #125	; 0x7d
c0d0150c:	0100      	lsls	r0, r0, #4
c0d0150e:	4348      	muls	r0, r1
c0d01510:	7ea1      	ldrb	r1, [r4, #26]
c0d01512:	f001 ff31 	bl	c0d03378 <__aeabi_uidiv>
c0d01516:	7aa1      	ldrb	r1, [r4, #10]
c0d01518:	0049      	lsls	r1, r1, #1
c0d0151a:	b2c9      	uxtb	r1, r1
c0d0151c:	2264      	movs	r2, #100	; 0x64
c0d0151e:	434a      	muls	r2, r1
c0d01520:	1815      	adds	r5, r2, r0
}
c0d01522:	4628      	mov	r0, r5
c0d01524:	bd70      	pop	{r4, r5, r6, pc}
	...

c0d01528 <io_seproxyhal_button_push>:
  G_io_seproxyhal_spi_buffer[3] = (backlight_percentage?0x80:0)|(flags & 0x7F); // power on
  G_io_seproxyhal_spi_buffer[4] = backlight_percentage;
  io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 5);
}

void io_seproxyhal_button_push(button_push_callback_t button_callback, unsigned int new_button_mask) {
c0d01528:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0152a:	b081      	sub	sp, #4
c0d0152c:	4604      	mov	r4, r0
  if (button_callback) {
c0d0152e:	2c00      	cmp	r4, #0
c0d01530:	d02b      	beq.n	c0d0158a <io_seproxyhal_button_push+0x62>
    unsigned int button_mask;
    unsigned int button_same_mask_counter;
    // enable speeded up long push
    if (new_button_mask == G_button_mask) {
c0d01532:	4817      	ldr	r0, [pc, #92]	; (c0d01590 <io_seproxyhal_button_push+0x68>)
c0d01534:	6802      	ldr	r2, [r0, #0]
c0d01536:	428a      	cmp	r2, r1
c0d01538:	d103      	bne.n	c0d01542 <io_seproxyhal_button_push+0x1a>
      // each 100ms ~
      G_button_same_mask_counter++;
c0d0153a:	4a16      	ldr	r2, [pc, #88]	; (c0d01594 <io_seproxyhal_button_push+0x6c>)
c0d0153c:	6813      	ldr	r3, [r2, #0]
c0d0153e:	1c5b      	adds	r3, r3, #1
c0d01540:	6013      	str	r3, [r2, #0]
    }

    // append the button mask
    button_mask = G_button_mask | new_button_mask;
c0d01542:	6806      	ldr	r6, [r0, #0]
c0d01544:	430e      	orrs	r6, r1

    // pre reset variable due to os_sched_exit
    button_same_mask_counter = G_button_same_mask_counter;
c0d01546:	4a13      	ldr	r2, [pc, #76]	; (c0d01594 <io_seproxyhal_button_push+0x6c>)
c0d01548:	6815      	ldr	r5, [r2, #0]
c0d0154a:	4f13      	ldr	r7, [pc, #76]	; (c0d01598 <io_seproxyhal_button_push+0x70>)

    // reset button mask
    if (new_button_mask == 0) {
c0d0154c:	2900      	cmp	r1, #0
c0d0154e:	d001      	beq.n	c0d01554 <io_seproxyhal_button_push+0x2c>

      // notify button released event
      button_mask |= BUTTON_EVT_RELEASED;
    }
    else {
      G_button_mask = button_mask;
c0d01550:	6006      	str	r6, [r0, #0]
c0d01552:	e004      	b.n	c0d0155e <io_seproxyhal_button_push+0x36>
c0d01554:	2300      	movs	r3, #0
    button_same_mask_counter = G_button_same_mask_counter;

    // reset button mask
    if (new_button_mask == 0) {
      // reset next state when button are released
      G_button_mask = 0;
c0d01556:	6003      	str	r3, [r0, #0]
      G_button_same_mask_counter=0;
c0d01558:	6013      	str	r3, [r2, #0]

      // notify button released event
      button_mask |= BUTTON_EVT_RELEASED;
c0d0155a:	1c7b      	adds	r3, r7, #1
c0d0155c:	431e      	orrs	r6, r3
    else {
      G_button_mask = button_mask;
    }

    // reset counter when button mask changes
    if (new_button_mask != G_button_mask) {
c0d0155e:	6800      	ldr	r0, [r0, #0]
c0d01560:	4288      	cmp	r0, r1
c0d01562:	d001      	beq.n	c0d01568 <io_seproxyhal_button_push+0x40>
      G_button_same_mask_counter=0;
c0d01564:	2000      	movs	r0, #0
c0d01566:	6010      	str	r0, [r2, #0]
    }

    if (button_same_mask_counter >= BUTTON_FAST_THRESHOLD_CS) {
c0d01568:	2d08      	cmp	r5, #8
c0d0156a:	d30b      	bcc.n	c0d01584 <io_seproxyhal_button_push+0x5c>
      // fast bit when pressing and timing is right
      if ((button_same_mask_counter%BUTTON_FAST_ACTION_CS) == 0) {
c0d0156c:	2103      	movs	r1, #3
c0d0156e:	4628      	mov	r0, r5
c0d01570:	f001 ff88 	bl	c0d03484 <__aeabi_uidivmod>
        button_mask |= BUTTON_EVT_FAST;
c0d01574:	2001      	movs	r0, #1
c0d01576:	0780      	lsls	r0, r0, #30
c0d01578:	4330      	orrs	r0, r6
      G_button_same_mask_counter=0;
    }

    if (button_same_mask_counter >= BUTTON_FAST_THRESHOLD_CS) {
      // fast bit when pressing and timing is right
      if ((button_same_mask_counter%BUTTON_FAST_ACTION_CS) == 0) {
c0d0157a:	2900      	cmp	r1, #0
c0d0157c:	d000      	beq.n	c0d01580 <io_seproxyhal_button_push+0x58>
c0d0157e:	4630      	mov	r0, r6
      }
      */

      // discard the release event after a fastskip has been detected, to avoid strange at release behavior
      // and also to enable user to cancel an operation by starting triggering the fast skip
      button_mask &= ~BUTTON_EVT_RELEASED;
c0d01580:	4038      	ands	r0, r7
c0d01582:	e000      	b.n	c0d01586 <io_seproxyhal_button_push+0x5e>
c0d01584:	4630      	mov	r0, r6
    }

    // indicate if button have been released
    button_callback(button_mask, button_same_mask_counter);
c0d01586:	4629      	mov	r1, r5
c0d01588:	47a0      	blx	r4
  }
}
c0d0158a:	b001      	add	sp, #4
c0d0158c:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d0158e:	46c0      	nop			; (mov r8, r8)
c0d01590:	20001ee4 	.word	0x20001ee4
c0d01594:	20001ee8 	.word	0x20001ee8
c0d01598:	7fffffff 	.word	0x7fffffff

c0d0159c <io_exchange>:

#ifdef HAVE_IO_U2F
u2f_service_t G_io_u2f;
#endif // HAVE_IO_U2F

unsigned short io_exchange(unsigned char channel, unsigned short tx_len) {
c0d0159c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0159e:	b081      	sub	sp, #4
c0d015a0:	460d      	mov	r5, r1
c0d015a2:	4604      	mov	r4, r0
    }
  }
  after_debug:
#endif // DEBUG_APDU

  switch(channel&~(IO_FLAGS)) {
c0d015a4:	200f      	movs	r0, #15
c0d015a6:	4204      	tst	r4, r0
c0d015a8:	d007      	beq.n	c0d015ba <io_exchange+0x1e>
      }
    }
    break;

  default:
    return io_exchange_al(channel, tx_len);
c0d015aa:	4620      	mov	r0, r4
c0d015ac:	4629      	mov	r1, r5
c0d015ae:	f7fe fe7d 	bl	c0d002ac <io_exchange_al>
c0d015b2:	4605      	mov	r5, r0
  }
}
c0d015b4:	b2a8      	uxth	r0, r5
c0d015b6:	b001      	add	sp, #4
c0d015b8:	bdf0      	pop	{r4, r5, r6, r7, pc}

  switch(channel&~(IO_FLAGS)) {
  case CHANNEL_APDU:
    // TODO work up the spi state machine over the HAL proxy until an APDU is available

    if (tx_len && !(channel&IO_ASYNCH_REPLY)) {
c0d015ba:	2610      	movs	r6, #16
c0d015bc:	4026      	ands	r6, r4
c0d015be:	2d00      	cmp	r5, #0
c0d015c0:	d041      	beq.n	c0d01646 <io_exchange+0xaa>
c0d015c2:	2e00      	cmp	r6, #0
c0d015c4:	d13f      	bne.n	c0d01646 <io_exchange+0xaa>
      // prepare response timeout
      G_io_timeout = IO_RAPDU_TRANSMIT_TIMEOUT_MS;
c0d015c6:	207d      	movs	r0, #125	; 0x7d
c0d015c8:	0100      	lsls	r0, r0, #4
c0d015ca:	494d      	ldr	r1, [pc, #308]	; (c0d01700 <io_exchange+0x164>)
c0d015cc:	6008      	str	r0, [r1, #0]

      // until the whole RAPDU is transmitted, send chunks using the current mode for communication
      for (;;) {
        switch(G_io_apdu_state) {
c0d015ce:	4f4d      	ldr	r7, [pc, #308]	; (c0d01704 <io_exchange+0x168>)
c0d015d0:	7838      	ldrb	r0, [r7, #0]
c0d015d2:	2807      	cmp	r0, #7
c0d015d4:	d00c      	beq.n	c0d015f0 <io_exchange+0x54>
c0d015d6:	280a      	cmp	r0, #10
c0d015d8:	d012      	beq.n	c0d01600 <io_exchange+0x64>
c0d015da:	2800      	cmp	r0, #0
c0d015dc:	d005      	beq.n	c0d015ea <io_exchange+0x4e>
          default: 
            // delegate to the hal in case of not generic transport mode (or asynch)
            if (io_exchange_al(channel, tx_len) == 0) {
c0d015de:	4620      	mov	r0, r4
c0d015e0:	4629      	mov	r1, r5
c0d015e2:	f7fe fe63 	bl	c0d002ac <io_exchange_al>
c0d015e6:	2800      	cmp	r0, #0
c0d015e8:	d01b      	beq.n	c0d01622 <io_exchange+0x86>
              goto break_send;
            }
          case APDU_IDLE:
            LOG("invalid state for APDU reply\n");
            THROW(INVALID_STATE);
c0d015ea:	2009      	movs	r0, #9
c0d015ec:	f7ff fc87 	bl	c0d00efe <os_longjmp>
            goto break_send;

#ifdef HAVE_USB_APDU
          case APDU_USB_HID:
            // only send, don't perform synchronous reception of the next command (will be done later by the seproxyhal packet processing)
            io_usb_hid_exchange(io_usb_send_apdu_data, tx_len, NULL, IO_RETURN_AFTER_TX);
c0d015f0:	484d      	ldr	r0, [pc, #308]	; (c0d01728 <io_exchange+0x18c>)
c0d015f2:	4478      	add	r0, pc
c0d015f4:	2200      	movs	r2, #0
c0d015f6:	2320      	movs	r3, #32
c0d015f8:	4629      	mov	r1, r5
c0d015fa:	f7ff fbed 	bl	c0d00dd8 <io_usb_hid_exchange>
c0d015fe:	e010      	b.n	c0d01622 <io_exchange+0x86>
            LOG("invalid state for APDU reply\n");
            THROW(INVALID_STATE);
            break;

          case APDU_RAW:
            if (tx_len > sizeof(G_io_apdu_buffer)) {
c0d01600:	20ff      	movs	r0, #255	; 0xff
c0d01602:	3006      	adds	r0, #6
c0d01604:	4285      	cmp	r5, r0
c0d01606:	d278      	bcs.n	c0d016fa <io_exchange+0x15e>
              THROW(INVALID_PARAMETER);
            }
            // reply the RAW APDU over SEPROXYHAL protocol
            G_io_seproxyhal_spi_buffer[0]  = SEPROXYHAL_TAG_RAPDU;
c0d01608:	483f      	ldr	r0, [pc, #252]	; (c0d01708 <io_exchange+0x16c>)
c0d0160a:	2153      	movs	r1, #83	; 0x53
c0d0160c:	7001      	strb	r1, [r0, #0]
            G_io_seproxyhal_spi_buffer[1]  = (tx_len)>>8;
c0d0160e:	0a29      	lsrs	r1, r5, #8
c0d01610:	7041      	strb	r1, [r0, #1]
            G_io_seproxyhal_spi_buffer[2]  = (tx_len);
c0d01612:	7085      	strb	r5, [r0, #2]
            io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 3);
c0d01614:	2103      	movs	r1, #3
c0d01616:	f000 fb45 	bl	c0d01ca4 <io_seproxyhal_spi_send>
            io_seproxyhal_spi_send(G_io_apdu_buffer, tx_len);
c0d0161a:	483c      	ldr	r0, [pc, #240]	; (c0d0170c <io_exchange+0x170>)
c0d0161c:	4629      	mov	r1, r5
c0d0161e:	f000 fb41 	bl	c0d01ca4 <io_seproxyhal_spi_send>
c0d01622:	2500      	movs	r5, #0
        }
        continue;

      break_send:
        // reset apdu state
        G_io_apdu_state = APDU_IDLE;
c0d01624:	703d      	strb	r5, [r7, #0]
        G_io_apdu_offset = 0;
c0d01626:	483a      	ldr	r0, [pc, #232]	; (c0d01710 <io_exchange+0x174>)
c0d01628:	8005      	strh	r5, [r0, #0]
        G_io_apdu_length = 0;
c0d0162a:	483a      	ldr	r0, [pc, #232]	; (c0d01714 <io_exchange+0x178>)
c0d0162c:	8005      	strh	r5, [r0, #0]
        G_io_apdu_seq = 0;
c0d0162e:	483a      	ldr	r0, [pc, #232]	; (c0d01718 <io_exchange+0x17c>)
c0d01630:	8005      	strh	r5, [r0, #0]
        G_io_apdu_media = IO_APDU_MEDIA_NONE;
c0d01632:	483a      	ldr	r0, [pc, #232]	; (c0d0171c <io_exchange+0x180>)
c0d01634:	7005      	strb	r5, [r0, #0]

        // continue sending commands, don't issue status yet
        if (channel & IO_RETURN_AFTER_TX) {
c0d01636:	06a0      	lsls	r0, r4, #26
c0d01638:	d4bc      	bmi.n	c0d015b4 <io_exchange+0x18>
          return 0;
        }
        // acknowledge the write request (general status OK) and no more command to follow (wait until another APDU container is received to continue unwrapping)
        io_seproxyhal_general_status();
c0d0163a:	f7ff fc6d 	bl	c0d00f18 <io_seproxyhal_general_status>
        break;
      }

      // perform reset after io exchange
      if (channel & IO_RESET_AFTER_REPLIED) {
c0d0163e:	0620      	lsls	r0, r4, #24
c0d01640:	d501      	bpl.n	c0d01646 <io_exchange+0xaa>
        reset();
c0d01642:	f000 fa79 	bl	c0d01b38 <reset>
      }
    }

    if (!(channel&IO_ASYNCH_REPLY)) {
c0d01646:	2e00      	cmp	r6, #0
c0d01648:	d10c      	bne.n	c0d01664 <io_exchange+0xc8>
      
      // already received the data of the apdu when received the whole apdu
      if ((channel & (CHANNEL_APDU|IO_RECEIVE_DATA)) == (CHANNEL_APDU|IO_RECEIVE_DATA)) {
c0d0164a:	0660      	lsls	r0, r4, #25
c0d0164c:	d450      	bmi.n	c0d016f0 <io_exchange+0x154>
        // return apdu data - header
        return G_io_apdu_length-5;
      }

      // reply has ended, proceed to next apdu reception (reset status only after asynch reply)
      G_io_apdu_state = APDU_IDLE;
c0d0164e:	482d      	ldr	r0, [pc, #180]	; (c0d01704 <io_exchange+0x168>)
c0d01650:	2100      	movs	r1, #0
c0d01652:	7001      	strb	r1, [r0, #0]
      G_io_apdu_offset = 0;
c0d01654:	482e      	ldr	r0, [pc, #184]	; (c0d01710 <io_exchange+0x174>)
c0d01656:	8001      	strh	r1, [r0, #0]
      G_io_apdu_length = 0;
c0d01658:	482e      	ldr	r0, [pc, #184]	; (c0d01714 <io_exchange+0x178>)
c0d0165a:	8001      	strh	r1, [r0, #0]
      G_io_apdu_seq = 0;
c0d0165c:	482e      	ldr	r0, [pc, #184]	; (c0d01718 <io_exchange+0x17c>)
c0d0165e:	8001      	strh	r1, [r0, #0]
      G_io_apdu_media = IO_APDU_MEDIA_NONE;
c0d01660:	482e      	ldr	r0, [pc, #184]	; (c0d0171c <io_exchange+0x180>)
c0d01662:	7001      	strb	r1, [r0, #0]
c0d01664:	4c28      	ldr	r4, [pc, #160]	; (c0d01708 <io_exchange+0x16c>)
c0d01666:	4e2b      	ldr	r6, [pc, #172]	; (c0d01714 <io_exchange+0x178>)
c0d01668:	4f2b      	ldr	r7, [pc, #172]	; (c0d01718 <io_exchange+0x17c>)
c0d0166a:	e002      	b.n	c0d01672 <io_exchange+0xd6>
          break;
#endif // HAVE_IO_USB

        default:
          // tell the application that a non-apdu packet has been received
          io_event(CHANNEL_SPI);
c0d0166c:	2002      	movs	r0, #2
c0d0166e:	f7fe ffef 	bl	c0d00650 <io_event>

    // ensure ready to receive an event (after an apdu processing with asynch flag, it may occur if the channel is not correctly managed)

    // until a new whole CAPDU is received
    for (;;) {
      if (!io_seproxyhal_spi_is_status_sent()) {
c0d01672:	f000 fb2d 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d01676:	2800      	cmp	r0, #0
c0d01678:	d101      	bne.n	c0d0167e <io_exchange+0xe2>
        io_seproxyhal_general_status();
c0d0167a:	f7ff fc4d 	bl	c0d00f18 <io_seproxyhal_general_status>
      }

      // wait until a SPI packet is available
      // NOTE: on ST31, dual wait ISO & RF (ISO instead of SPI)
      rx_len = io_seproxyhal_spi_recv(G_io_seproxyhal_spi_buffer, sizeof(G_io_seproxyhal_spi_buffer), 0);
c0d0167e:	2180      	movs	r1, #128	; 0x80
c0d01680:	2500      	movs	r5, #0
c0d01682:	4620      	mov	r0, r4
c0d01684:	462a      	mov	r2, r5
c0d01686:	f000 fb39 	bl	c0d01cfc <io_seproxyhal_spi_recv>

      // can't process split TLV, continue
      if (rx_len-3 != U2(G_io_seproxyhal_spi_buffer[1],G_io_seproxyhal_spi_buffer[2])) {
c0d0168a:	1ec1      	subs	r1, r0, #3
c0d0168c:	78a2      	ldrb	r2, [r4, #2]
c0d0168e:	7863      	ldrb	r3, [r4, #1]
c0d01690:	021b      	lsls	r3, r3, #8
c0d01692:	4313      	orrs	r3, r2
c0d01694:	4299      	cmp	r1, r3
c0d01696:	d115      	bne.n	c0d016c4 <io_exchange+0x128>
      send_last_command:
        continue;
      }

      // if an apdu is already ongoing, then discard packet as a new packet
      if (G_io_apdu_media != IO_APDU_MEDIA_NONE) {
c0d01698:	4920      	ldr	r1, [pc, #128]	; (c0d0171c <io_exchange+0x180>)
c0d0169a:	7809      	ldrb	r1, [r1, #0]
c0d0169c:	2900      	cmp	r1, #0
c0d0169e:	d002      	beq.n	c0d016a6 <io_exchange+0x10a>
        io_seproxyhal_handle_event();
c0d016a0:	f7ff fcf4 	bl	c0d0108c <io_seproxyhal_handle_event>
c0d016a4:	e7e5      	b.n	c0d01672 <io_exchange+0xd6>
        continue;
      }

      // depending on received TAG
      switch(G_io_seproxyhal_spi_buffer[0]) {
c0d016a6:	7821      	ldrb	r1, [r4, #0]
c0d016a8:	290f      	cmp	r1, #15
c0d016aa:	d006      	beq.n	c0d016ba <io_exchange+0x11e>
c0d016ac:	2910      	cmp	r1, #16
c0d016ae:	d011      	beq.n	c0d016d4 <io_exchange+0x138>
c0d016b0:	2916      	cmp	r1, #22
c0d016b2:	d1db      	bne.n	c0d0166c <io_exchange+0xd0>

        case SEPROXYHAL_TAG_CAPDU_EVENT:
          io_seproxyhal_handle_capdu_event();
c0d016b4:	f7ff fd36 	bl	c0d01124 <io_seproxyhal_handle_capdu_event>
c0d016b8:	e011      	b.n	c0d016de <io_exchange+0x142>
          goto send_last_command;
#endif // HAVE_BLE

#ifdef HAVE_IO_USB
        case SEPROXYHAL_TAG_USB_EVENT:
          if (rx_len != 3+1) {
c0d016ba:	2804      	cmp	r0, #4
c0d016bc:	d102      	bne.n	c0d016c4 <io_exchange+0x128>
            // invalid length, not processable
            goto invalid_apdu_packet;
          }
          io_seproxyhal_handle_usb_event();
c0d016be:	f7ff fc3f 	bl	c0d00f40 <io_seproxyhal_handle_usb_event>
c0d016c2:	e7d6      	b.n	c0d01672 <io_exchange+0xd6>
c0d016c4:	2000      	movs	r0, #0

      // can't process split TLV, continue
      if (rx_len-3 != U2(G_io_seproxyhal_spi_buffer[1],G_io_seproxyhal_spi_buffer[2])) {
        LOG("invalid TLV format\n");
      invalid_apdu_packet:
        G_io_apdu_state = APDU_IDLE;
c0d016c6:	490f      	ldr	r1, [pc, #60]	; (c0d01704 <io_exchange+0x168>)
c0d016c8:	7008      	strb	r0, [r1, #0]
        G_io_apdu_offset = 0;
c0d016ca:	4911      	ldr	r1, [pc, #68]	; (c0d01710 <io_exchange+0x174>)
c0d016cc:	8008      	strh	r0, [r1, #0]
        G_io_apdu_length = 0;
c0d016ce:	8030      	strh	r0, [r6, #0]
        G_io_apdu_seq = 0;
c0d016d0:	8038      	strh	r0, [r7, #0]
c0d016d2:	e7ce      	b.n	c0d01672 <io_exchange+0xd6>

          // no state change, we're not dealing with an apdu yet
          goto send_last_command;

        case SEPROXYHAL_TAG_USB_EP_XFER_EVENT:
          if (rx_len < 3+3) {
c0d016d4:	2806      	cmp	r0, #6
c0d016d6:	d200      	bcs.n	c0d016da <io_exchange+0x13e>
c0d016d8:	e76c      	b.n	c0d015b4 <io_exchange+0x18>
            // error !
            return 0;
          }
          io_seproxyhal_handle_usb_ep_xfer_event();
c0d016da:	f7ff fc67 	bl	c0d00fac <io_seproxyhal_handle_usb_ep_xfer_event>
c0d016de:	8830      	ldrh	r0, [r6, #0]
c0d016e0:	2800      	cmp	r0, #0
c0d016e2:	d0c6      	beq.n	c0d01672 <io_exchange+0xd6>
c0d016e4:	480f      	ldr	r0, [pc, #60]	; (c0d01724 <io_exchange+0x188>)
c0d016e6:	6800      	ldr	r0, [r0, #0]
c0d016e8:	4905      	ldr	r1, [pc, #20]	; (c0d01700 <io_exchange+0x164>)
c0d016ea:	6008      	str	r0, [r1, #0]
c0d016ec:	8835      	ldrh	r5, [r6, #0]
c0d016ee:	e761      	b.n	c0d015b4 <io_exchange+0x18>
    if (!(channel&IO_ASYNCH_REPLY)) {
      
      // already received the data of the apdu when received the whole apdu
      if ((channel & (CHANNEL_APDU|IO_RECEIVE_DATA)) == (CHANNEL_APDU|IO_RECEIVE_DATA)) {
        // return apdu data - header
        return G_io_apdu_length-5;
c0d016f0:	4808      	ldr	r0, [pc, #32]	; (c0d01714 <io_exchange+0x178>)
c0d016f2:	8800      	ldrh	r0, [r0, #0]
c0d016f4:	490a      	ldr	r1, [pc, #40]	; (c0d01720 <io_exchange+0x184>)
c0d016f6:	1845      	adds	r5, r0, r1
c0d016f8:	e75c      	b.n	c0d015b4 <io_exchange+0x18>
            THROW(INVALID_STATE);
            break;

          case APDU_RAW:
            if (tx_len > sizeof(G_io_apdu_buffer)) {
              THROW(INVALID_PARAMETER);
c0d016fa:	2002      	movs	r0, #2
c0d016fc:	f7ff fbff 	bl	c0d00efe <os_longjmp>
c0d01700:	20001ecc 	.word	0x20001ecc
c0d01704:	20001ed7 	.word	0x20001ed7
c0d01708:	20001c28 	.word	0x20001c28
c0d0170c:	20001dbc 	.word	0x20001dbc
c0d01710:	20001eda 	.word	0x20001eda
c0d01714:	20001ed8 	.word	0x20001ed8
c0d01718:	20001edc 	.word	0x20001edc
c0d0171c:	20001ed0 	.word	0x20001ed0
c0d01720:	0000fffb 	.word	0x0000fffb
c0d01724:	20001ec8 	.word	0x20001ec8
c0d01728:	fffffb1f 	.word	0xfffffb1f

c0d0172c <ux_menu_element_preprocessor>:
    return ux_menu.menu_iterator(entry_idx);
  } 
  return &ux_menu.menu_entries[entry_idx];
} 

const bagl_element_t* ux_menu_element_preprocessor(const bagl_element_t* element) {
c0d0172c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0172e:	b081      	sub	sp, #4
c0d01730:	4607      	mov	r7, r0
  //todo avoid center alignment when text_x or icon_x AND text_x are not 0
  os_memmove(&ux_menu.tmp_element, element, sizeof(bagl_element_t));
c0d01732:	4c5f      	ldr	r4, [pc, #380]	; (c0d018b0 <ux_menu_element_preprocessor+0x184>)
c0d01734:	4625      	mov	r5, r4
c0d01736:	3514      	adds	r5, #20
c0d01738:	2238      	movs	r2, #56	; 0x38
c0d0173a:	4628      	mov	r0, r5
c0d0173c:	4639      	mov	r1, r7
c0d0173e:	f7ff fb2a 	bl	c0d00d96 <os_memmove>
  {{BAGL_LABELINE                       , 0x22,  14,  26, 100,  12, 0, 0, 0        , 0xFFFFFF, 0x000000, BAGL_FONT_OPEN_SANS_EXTRABOLD_11px|BAGL_FONT_ALIGNMENT_CENTER, 0  }, NULL, 0, 0, 0, NULL, NULL, NULL },

};

const ux_menu_entry_t* ux_menu_get_entry (unsigned int entry_idx) {
  if (ux_menu.menu_iterator) {
c0d01742:	6921      	ldr	r1, [r4, #16]
const bagl_element_t* ux_menu_element_preprocessor(const bagl_element_t* element) {
  //todo avoid center alignment when text_x or icon_x AND text_x are not 0
  os_memmove(&ux_menu.tmp_element, element, sizeof(bagl_element_t));

  // ask the current entry first, to setup other entries
  const ux_menu_entry_t* current_entry = ux_menu_get_entry(ux_menu.current_entry);
c0d01744:	68a0      	ldr	r0, [r4, #8]
  {{BAGL_LABELINE                       , 0x22,  14,  26, 100,  12, 0, 0, 0        , 0xFFFFFF, 0x000000, BAGL_FONT_OPEN_SANS_EXTRABOLD_11px|BAGL_FONT_ALIGNMENT_CENTER, 0  }, NULL, 0, 0, 0, NULL, NULL, NULL },

};

const ux_menu_entry_t* ux_menu_get_entry (unsigned int entry_idx) {
  if (ux_menu.menu_iterator) {
c0d01746:	2900      	cmp	r1, #0
c0d01748:	d003      	beq.n	c0d01752 <ux_menu_element_preprocessor+0x26>
    return ux_menu.menu_iterator(entry_idx);
c0d0174a:	4788      	blx	r1
c0d0174c:	4603      	mov	r3, r0
c0d0174e:	68a0      	ldr	r0, [r4, #8]
c0d01750:	e003      	b.n	c0d0175a <ux_menu_element_preprocessor+0x2e>
  } 
  return &ux_menu.menu_entries[entry_idx];
c0d01752:	211c      	movs	r1, #28
c0d01754:	4341      	muls	r1, r0
c0d01756:	6822      	ldr	r2, [r4, #0]
c0d01758:	1853      	adds	r3, r2, r1
c0d0175a:	2600      	movs	r6, #0

  // ask the current entry first, to setup other entries
  const ux_menu_entry_t* current_entry = ux_menu_get_entry(ux_menu.current_entry);

  const ux_menu_entry_t* previous_entry = NULL;
  if (ux_menu.current_entry) {
c0d0175c:	2800      	cmp	r0, #0
c0d0175e:	d010      	beq.n	c0d01782 <ux_menu_element_preprocessor+0x56>
  {{BAGL_LABELINE                       , 0x22,  14,  26, 100,  12, 0, 0, 0        , 0xFFFFFF, 0x000000, BAGL_FONT_OPEN_SANS_EXTRABOLD_11px|BAGL_FONT_ALIGNMENT_CENTER, 0  }, NULL, 0, 0, 0, NULL, NULL, NULL },

};

const ux_menu_entry_t* ux_menu_get_entry (unsigned int entry_idx) {
  if (ux_menu.menu_iterator) {
c0d01760:	6922      	ldr	r2, [r4, #16]
  // ask the current entry first, to setup other entries
  const ux_menu_entry_t* current_entry = ux_menu_get_entry(ux_menu.current_entry);

  const ux_menu_entry_t* previous_entry = NULL;
  if (ux_menu.current_entry) {
    previous_entry = ux_menu_get_entry(ux_menu.current_entry-1);
c0d01762:	1e41      	subs	r1, r0, #1
  {{BAGL_LABELINE                       , 0x22,  14,  26, 100,  12, 0, 0, 0        , 0xFFFFFF, 0x000000, BAGL_FONT_OPEN_SANS_EXTRABOLD_11px|BAGL_FONT_ALIGNMENT_CENTER, 0  }, NULL, 0, 0, 0, NULL, NULL, NULL },

};

const ux_menu_entry_t* ux_menu_get_entry (unsigned int entry_idx) {
  if (ux_menu.menu_iterator) {
c0d01764:	2a00      	cmp	r2, #0
c0d01766:	d00f      	beq.n	c0d01788 <ux_menu_element_preprocessor+0x5c>
    return ux_menu.menu_iterator(entry_idx);
c0d01768:	4608      	mov	r0, r1
c0d0176a:	9700      	str	r7, [sp, #0]
c0d0176c:	4637      	mov	r7, r6
c0d0176e:	462e      	mov	r6, r5
c0d01770:	461d      	mov	r5, r3
c0d01772:	4790      	blx	r2
c0d01774:	462b      	mov	r3, r5
c0d01776:	4635      	mov	r5, r6
c0d01778:	463e      	mov	r6, r7
c0d0177a:	9f00      	ldr	r7, [sp, #0]
c0d0177c:	4602      	mov	r2, r0
c0d0177e:	68a0      	ldr	r0, [r4, #8]
c0d01780:	e006      	b.n	c0d01790 <ux_menu_element_preprocessor+0x64>
  const ux_menu_entry_t* previous_entry = NULL;
  if (ux_menu.current_entry) {
    previous_entry = ux_menu_get_entry(ux_menu.current_entry-1);
  }
  const ux_menu_entry_t* next_entry = NULL;
  if (ux_menu.current_entry < ux_menu.menu_entries_count-1) {
c0d01782:	4630      	mov	r0, r6
c0d01784:	4632      	mov	r2, r6
c0d01786:	e003      	b.n	c0d01790 <ux_menu_element_preprocessor+0x64>

const ux_menu_entry_t* ux_menu_get_entry (unsigned int entry_idx) {
  if (ux_menu.menu_iterator) {
    return ux_menu.menu_iterator(entry_idx);
  } 
  return &ux_menu.menu_entries[entry_idx];
c0d01788:	221c      	movs	r2, #28
c0d0178a:	434a      	muls	r2, r1
c0d0178c:	6821      	ldr	r1, [r4, #0]
c0d0178e:	188a      	adds	r2, r1, r2
  const ux_menu_entry_t* previous_entry = NULL;
  if (ux_menu.current_entry) {
    previous_entry = ux_menu_get_entry(ux_menu.current_entry-1);
  }
  const ux_menu_entry_t* next_entry = NULL;
  if (ux_menu.current_entry < ux_menu.menu_entries_count-1) {
c0d01790:	6861      	ldr	r1, [r4, #4]
c0d01792:	1e49      	subs	r1, r1, #1
c0d01794:	4288      	cmp	r0, r1
c0d01796:	d210      	bcs.n	c0d017ba <ux_menu_element_preprocessor+0x8e>
  {{BAGL_LABELINE                       , 0x22,  14,  26, 100,  12, 0, 0, 0        , 0xFFFFFF, 0x000000, BAGL_FONT_OPEN_SANS_EXTRABOLD_11px|BAGL_FONT_ALIGNMENT_CENTER, 0  }, NULL, 0, 0, 0, NULL, NULL, NULL },

};

const ux_menu_entry_t* ux_menu_get_entry (unsigned int entry_idx) {
  if (ux_menu.menu_iterator) {
c0d01798:	6921      	ldr	r1, [r4, #16]
  if (ux_menu.current_entry) {
    previous_entry = ux_menu_get_entry(ux_menu.current_entry-1);
  }
  const ux_menu_entry_t* next_entry = NULL;
  if (ux_menu.current_entry < ux_menu.menu_entries_count-1) {
    next_entry = ux_menu_get_entry(ux_menu.current_entry+1);
c0d0179a:	1c40      	adds	r0, r0, #1
  {{BAGL_LABELINE                       , 0x22,  14,  26, 100,  12, 0, 0, 0        , 0xFFFFFF, 0x000000, BAGL_FONT_OPEN_SANS_EXTRABOLD_11px|BAGL_FONT_ALIGNMENT_CENTER, 0  }, NULL, 0, 0, 0, NULL, NULL, NULL },

};

const ux_menu_entry_t* ux_menu_get_entry (unsigned int entry_idx) {
  if (ux_menu.menu_iterator) {
c0d0179c:	2900      	cmp	r1, #0
c0d0179e:	d008      	beq.n	c0d017b2 <ux_menu_element_preprocessor+0x86>
c0d017a0:	9500      	str	r5, [sp, #0]
c0d017a2:	461d      	mov	r5, r3
c0d017a4:	4616      	mov	r6, r2
    return ux_menu.menu_iterator(entry_idx);
c0d017a6:	4788      	blx	r1
c0d017a8:	4632      	mov	r2, r6
c0d017aa:	462b      	mov	r3, r5
c0d017ac:	9d00      	ldr	r5, [sp, #0]
c0d017ae:	4606      	mov	r6, r0
c0d017b0:	e003      	b.n	c0d017ba <ux_menu_element_preprocessor+0x8e>
  } 
  return &ux_menu.menu_entries[entry_idx];
c0d017b2:	211c      	movs	r1, #28
c0d017b4:	4341      	muls	r1, r0
c0d017b6:	6820      	ldr	r0, [r4, #0]
c0d017b8:	1846      	adds	r6, r0, r1
c0d017ba:	7878      	ldrb	r0, [r7, #1]
  const ux_menu_entry_t* next_entry = NULL;
  if (ux_menu.current_entry < ux_menu.menu_entries_count-1) {
    next_entry = ux_menu_get_entry(ux_menu.current_entry+1);
  }

  switch(element->component.userid) {
c0d017bc:	2840      	cmp	r0, #64	; 0x40
c0d017be:	dc0a      	bgt.n	c0d017d6 <ux_menu_element_preprocessor+0xaa>
c0d017c0:	2820      	cmp	r0, #32
c0d017c2:	dc22      	bgt.n	c0d0180a <ux_menu_element_preprocessor+0xde>
c0d017c4:	2810      	cmp	r0, #16
c0d017c6:	d034      	beq.n	c0d01832 <ux_menu_element_preprocessor+0x106>
c0d017c8:	2820      	cmp	r0, #32
c0d017ca:	d167      	bne.n	c0d0189c <ux_menu_element_preprocessor+0x170>
      if (current_entry->icon_x) {
        ux_menu.tmp_element.component.x = current_entry->icon_x;
      }
      break;
    case 0x20:
      if (current_entry->line2 != NULL) {
c0d017cc:	6959      	ldr	r1, [r3, #20]
c0d017ce:	2000      	movs	r0, #0
c0d017d0:	2900      	cmp	r1, #0
c0d017d2:	d16b      	bne.n	c0d018ac <ux_menu_element_preprocessor+0x180>
c0d017d4:	e051      	b.n	c0d0187a <ux_menu_element_preprocessor+0x14e>
c0d017d6:	2880      	cmp	r0, #128	; 0x80
c0d017d8:	dc22      	bgt.n	c0d01820 <ux_menu_element_preprocessor+0xf4>
c0d017da:	2841      	cmp	r0, #65	; 0x41
c0d017dc:	d033      	beq.n	c0d01846 <ux_menu_element_preprocessor+0x11a>
c0d017de:	2842      	cmp	r0, #66	; 0x42
c0d017e0:	d15c      	bne.n	c0d0189c <ux_menu_element_preprocessor+0x170>
      }
      ux_menu.tmp_element.text = previous_entry->line1;
      break;
    // next setting name
    case 0x42:
      if (current_entry->line2 != NULL 
c0d017e2:	6959      	ldr	r1, [r3, #20]
c0d017e4:	2000      	movs	r0, #0
        || current_entry->icon != NULL
c0d017e6:	2900      	cmp	r1, #0
c0d017e8:	d160      	bne.n	c0d018ac <ux_menu_element_preprocessor+0x180>
c0d017ea:	68d9      	ldr	r1, [r3, #12]
        || ux_menu.current_entry == ux_menu.menu_entries_count-1
c0d017ec:	2900      	cmp	r1, #0
c0d017ee:	d15d      	bne.n	c0d018ac <ux_menu_element_preprocessor+0x180>
c0d017f0:	6862      	ldr	r2, [r4, #4]
c0d017f2:	1e51      	subs	r1, r2, #1
        || ux_menu.menu_entries_count == 1
c0d017f4:	2a01      	cmp	r2, #1
c0d017f6:	d059      	beq.n	c0d018ac <ux_menu_element_preprocessor+0x180>
      break;
    // next setting name
    case 0x42:
      if (current_entry->line2 != NULL 
        || current_entry->icon != NULL
        || ux_menu.current_entry == ux_menu.menu_entries_count-1
c0d017f8:	68a2      	ldr	r2, [r4, #8]
c0d017fa:	428a      	cmp	r2, r1
c0d017fc:	d056      	beq.n	c0d018ac <ux_menu_element_preprocessor+0x180>
        || ux_menu.menu_entries_count == 1
        || next_entry->icon != NULL) {
c0d017fe:	68f1      	ldr	r1, [r6, #12]
      }
      ux_menu.tmp_element.text = previous_entry->line1;
      break;
    // next setting name
    case 0x42:
      if (current_entry->line2 != NULL 
c0d01800:	2900      	cmp	r1, #0
c0d01802:	d153      	bne.n	c0d018ac <ux_menu_element_preprocessor+0x180>
        || ux_menu.current_entry == ux_menu.menu_entries_count-1
        || ux_menu.menu_entries_count == 1
        || next_entry->icon != NULL) {
        return NULL;
      }
      ux_menu.tmp_element.text = next_entry->line1;
c0d01804:	6930      	ldr	r0, [r6, #16]
c0d01806:	6320      	str	r0, [r4, #48]	; 0x30
c0d01808:	e048      	b.n	c0d0189c <ux_menu_element_preprocessor+0x170>
c0d0180a:	2821      	cmp	r0, #33	; 0x21
c0d0180c:	d031      	beq.n	c0d01872 <ux_menu_element_preprocessor+0x146>
c0d0180e:	2822      	cmp	r0, #34	; 0x22
c0d01810:	d144      	bne.n	c0d0189c <ux_menu_element_preprocessor+0x170>
        return NULL;
      }
      ux_menu.tmp_element.text = current_entry->line1;
      goto adjust_text_x;
    case 0x22:
      if (current_entry->line2 == NULL) {
c0d01812:	4619      	mov	r1, r3
c0d01814:	3114      	adds	r1, #20
c0d01816:	695a      	ldr	r2, [r3, #20]
c0d01818:	2000      	movs	r0, #0
c0d0181a:	2a00      	cmp	r2, #0
c0d0181c:	d12f      	bne.n	c0d0187e <ux_menu_element_preprocessor+0x152>
c0d0181e:	e045      	b.n	c0d018ac <ux_menu_element_preprocessor+0x180>
c0d01820:	2882      	cmp	r0, #130	; 0x82
c0d01822:	d035      	beq.n	c0d01890 <ux_menu_element_preprocessor+0x164>
c0d01824:	2881      	cmp	r0, #129	; 0x81
c0d01826:	d139      	bne.n	c0d0189c <ux_menu_element_preprocessor+0x170>
    next_entry = ux_menu_get_entry(ux_menu.current_entry+1);
  }

  switch(element->component.userid) {
    case 0x81:
      if (ux_menu.current_entry == 0) {
c0d01828:	68a1      	ldr	r1, [r4, #8]
c0d0182a:	2000      	movs	r0, #0
c0d0182c:	2900      	cmp	r1, #0
c0d0182e:	d135      	bne.n	c0d0189c <ux_menu_element_preprocessor+0x170>
c0d01830:	e03c      	b.n	c0d018ac <ux_menu_element_preprocessor+0x180>
        return NULL;
      }
      ux_menu.tmp_element.text = next_entry->line1;
      break;
    case 0x10:
      if (current_entry->icon == NULL) {
c0d01832:	68d9      	ldr	r1, [r3, #12]
c0d01834:	2000      	movs	r0, #0
c0d01836:	2900      	cmp	r1, #0
c0d01838:	d038      	beq.n	c0d018ac <ux_menu_element_preprocessor+0x180>
        return NULL;
      }
      ux_menu.tmp_element.text = (const char*)current_entry->icon;
c0d0183a:	6321      	str	r1, [r4, #48]	; 0x30
      if (current_entry->icon_x) {
c0d0183c:	7e58      	ldrb	r0, [r3, #25]
c0d0183e:	2800      	cmp	r0, #0
c0d01840:	d02c      	beq.n	c0d0189c <ux_menu_element_preprocessor+0x170>
        ux_menu.tmp_element.component.x = current_entry->icon_x;
c0d01842:	82e0      	strh	r0, [r4, #22]
c0d01844:	e02a      	b.n	c0d0189c <ux_menu_element_preprocessor+0x170>
        return NULL;
      }
      break;
    // previous setting name
    case 0x41:
      if (current_entry->line2 != NULL 
c0d01846:	6959      	ldr	r1, [r3, #20]
c0d01848:	2000      	movs	r0, #0
        || current_entry->icon != NULL
c0d0184a:	2900      	cmp	r1, #0
c0d0184c:	d12e      	bne.n	c0d018ac <ux_menu_element_preprocessor+0x180>
c0d0184e:	68d9      	ldr	r1, [r3, #12]
        || ux_menu.current_entry == 0
c0d01850:	2900      	cmp	r1, #0
c0d01852:	d12b      	bne.n	c0d018ac <ux_menu_element_preprocessor+0x180>
c0d01854:	68a1      	ldr	r1, [r4, #8]
c0d01856:	2900      	cmp	r1, #0
c0d01858:	d028      	beq.n	c0d018ac <ux_menu_element_preprocessor+0x180>
        || ux_menu.menu_entries_count == 1 
c0d0185a:	6861      	ldr	r1, [r4, #4]
c0d0185c:	2901      	cmp	r1, #1
c0d0185e:	d025      	beq.n	c0d018ac <ux_menu_element_preprocessor+0x180>
        || previous_entry->icon != NULL
c0d01860:	68d1      	ldr	r1, [r2, #12]
        || previous_entry->line2 != NULL) {
c0d01862:	2900      	cmp	r1, #0
c0d01864:	d122      	bne.n	c0d018ac <ux_menu_element_preprocessor+0x180>
c0d01866:	6951      	ldr	r1, [r2, #20]
        return NULL;
      }
      break;
    // previous setting name
    case 0x41:
      if (current_entry->line2 != NULL 
c0d01868:	2900      	cmp	r1, #0
c0d0186a:	d11f      	bne.n	c0d018ac <ux_menu_element_preprocessor+0x180>
        || ux_menu.menu_entries_count == 1 
        || previous_entry->icon != NULL
        || previous_entry->line2 != NULL) {
        return 0;
      }
      ux_menu.tmp_element.text = previous_entry->line1;
c0d0186c:	6910      	ldr	r0, [r2, #16]
c0d0186e:	6320      	str	r0, [r4, #48]	; 0x30
c0d01870:	e014      	b.n	c0d0189c <ux_menu_element_preprocessor+0x170>
        return NULL;
      }
      ux_menu.tmp_element.text = current_entry->line1;
      goto adjust_text_x;
    case 0x21:
      if (current_entry->line2 == NULL) {
c0d01872:	6959      	ldr	r1, [r3, #20]
c0d01874:	2000      	movs	r0, #0
c0d01876:	2900      	cmp	r1, #0
c0d01878:	d018      	beq.n	c0d018ac <ux_menu_element_preprocessor+0x180>
c0d0187a:	4619      	mov	r1, r3
c0d0187c:	3110      	adds	r1, #16
c0d0187e:	6808      	ldr	r0, [r1, #0]
c0d01880:	6320      	str	r0, [r4, #48]	; 0x30
      if (current_entry->line2 == NULL) {
        return NULL;
      }
      ux_menu.tmp_element.text = current_entry->line2;
    adjust_text_x:
      if (current_entry->text_x) {
c0d01882:	7e18      	ldrb	r0, [r3, #24]
c0d01884:	2800      	cmp	r0, #0
c0d01886:	d009      	beq.n	c0d0189c <ux_menu_element_preprocessor+0x170>
        ux_menu.tmp_element.component.x = current_entry->text_x;
c0d01888:	82e0      	strh	r0, [r4, #22]
        // discard the 'center' flag
        ux_menu.tmp_element.component.font_id = BAGL_FONT_OPEN_SANS_EXTRABOLD_11px;
c0d0188a:	2008      	movs	r0, #8
c0d0188c:	85a0      	strh	r0, [r4, #44]	; 0x2c
c0d0188e:	e005      	b.n	c0d0189c <ux_menu_element_preprocessor+0x170>
      if (ux_menu.current_entry == 0) {
        return NULL;
      }
      break;
    case 0x82:
      if (ux_menu.current_entry == ux_menu.menu_entries_count-1) {
c0d01890:	6860      	ldr	r0, [r4, #4]
c0d01892:	68a1      	ldr	r1, [r4, #8]
c0d01894:	1e42      	subs	r2, r0, #1
c0d01896:	2000      	movs	r0, #0
c0d01898:	4291      	cmp	r1, r2
c0d0189a:	d007      	beq.n	c0d018ac <ux_menu_element_preprocessor+0x180>
        ux_menu.tmp_element.component.font_id = BAGL_FONT_OPEN_SANS_EXTRABOLD_11px;
      }
      break;
  }
  // ensure prepro agrees to the element to be displayed
  if (ux_menu.menu_entry_preprocessor) {
c0d0189c:	68e2      	ldr	r2, [r4, #12]
c0d0189e:	2a00      	cmp	r2, #0
c0d018a0:	4628      	mov	r0, r5
c0d018a2:	d003      	beq.n	c0d018ac <ux_menu_element_preprocessor+0x180>
    // menu is denied by the menu entry preprocessor
    return ux_menu.menu_entry_preprocessor(current_entry, &ux_menu.tmp_element);
c0d018a4:	3414      	adds	r4, #20
c0d018a6:	4618      	mov	r0, r3
c0d018a8:	4621      	mov	r1, r4
c0d018aa:	4790      	blx	r2
  }

  return &ux_menu.tmp_element;
}
c0d018ac:	b001      	add	sp, #4
c0d018ae:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d018b0:	20001eec 	.word	0x20001eec

c0d018b4 <ux_menu_elements_button>:

unsigned int ux_menu_elements_button (unsigned int button_mask, unsigned int button_mask_counter) {
c0d018b4:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d018b6:	b081      	sub	sp, #4
c0d018b8:	4605      	mov	r5, r0
  UNUSED(button_mask_counter);

  const ux_menu_entry_t* current_entry = ux_menu_get_entry(ux_menu.current_entry);
c0d018ba:	4f3b      	ldr	r7, [pc, #236]	; (c0d019a8 <ux_menu_elements_button+0xf4>)
  {{BAGL_LABELINE                       , 0x22,  14,  26, 100,  12, 0, 0, 0        , 0xFFFFFF, 0x000000, BAGL_FONT_OPEN_SANS_EXTRABOLD_11px|BAGL_FONT_ALIGNMENT_CENTER, 0  }, NULL, 0, 0, 0, NULL, NULL, NULL },

};

const ux_menu_entry_t* ux_menu_get_entry (unsigned int entry_idx) {
  if (ux_menu.menu_iterator) {
c0d018bc:	6939      	ldr	r1, [r7, #16]
}

unsigned int ux_menu_elements_button (unsigned int button_mask, unsigned int button_mask_counter) {
  UNUSED(button_mask_counter);

  const ux_menu_entry_t* current_entry = ux_menu_get_entry(ux_menu.current_entry);
c0d018be:	68b8      	ldr	r0, [r7, #8]
  {{BAGL_LABELINE                       , 0x22,  14,  26, 100,  12, 0, 0, 0        , 0xFFFFFF, 0x000000, BAGL_FONT_OPEN_SANS_EXTRABOLD_11px|BAGL_FONT_ALIGNMENT_CENTER, 0  }, NULL, 0, 0, 0, NULL, NULL, NULL },

};

const ux_menu_entry_t* ux_menu_get_entry (unsigned int entry_idx) {
  if (ux_menu.menu_iterator) {
c0d018c0:	2900      	cmp	r1, #0
c0d018c2:	d002      	beq.n	c0d018ca <ux_menu_elements_button+0x16>
    return ux_menu.menu_iterator(entry_idx);
c0d018c4:	4788      	blx	r1
c0d018c6:	4606      	mov	r6, r0
c0d018c8:	e003      	b.n	c0d018d2 <ux_menu_elements_button+0x1e>
  } 
  return &ux_menu.menu_entries[entry_idx];
c0d018ca:	211c      	movs	r1, #28
c0d018cc:	4341      	muls	r1, r0
c0d018ce:	6838      	ldr	r0, [r7, #0]
c0d018d0:	1846      	adds	r6, r0, r1
c0d018d2:	2401      	movs	r4, #1
unsigned int ux_menu_elements_button (unsigned int button_mask, unsigned int button_mask_counter) {
  UNUSED(button_mask_counter);

  const ux_menu_entry_t* current_entry = ux_menu_get_entry(ux_menu.current_entry);

  switch (button_mask) {
c0d018d4:	4835      	ldr	r0, [pc, #212]	; (c0d019ac <ux_menu_elements_button+0xf8>)
c0d018d6:	4285      	cmp	r5, r0
c0d018d8:	dd14      	ble.n	c0d01904 <ux_menu_elements_button+0x50>
c0d018da:	4835      	ldr	r0, [pc, #212]	; (c0d019b0 <ux_menu_elements_button+0xfc>)
c0d018dc:	4285      	cmp	r5, r0
c0d018de:	d017      	beq.n	c0d01910 <ux_menu_elements_button+0x5c>
c0d018e0:	4834      	ldr	r0, [pc, #208]	; (c0d019b4 <ux_menu_elements_button+0x100>)
c0d018e2:	4285      	cmp	r5, r0
c0d018e4:	d01c      	beq.n	c0d01920 <ux_menu_elements_button+0x6c>
c0d018e6:	4834      	ldr	r0, [pc, #208]	; (c0d019b8 <ux_menu_elements_button+0x104>)
c0d018e8:	4285      	cmp	r5, r0
c0d018ea:	d15a      	bne.n	c0d019a2 <ux_menu_elements_button+0xee>
    // enter menu or exit menu
    case BUTTON_EVT_RELEASED|BUTTON_LEFT|BUTTON_RIGHT:
      // menu is priority 1
      if (current_entry->menu) {
c0d018ec:	6830      	ldr	r0, [r6, #0]
c0d018ee:	2800      	cmp	r0, #0
c0d018f0:	d04e      	beq.n	c0d01990 <ux_menu_elements_button+0xdc>
        // use userid as the pointer to current entry in the parent menu
        UX_MENU_DISPLAY(current_entry->userid, (const ux_menu_entry_t*)PIC(current_entry->menu), ux_menu.menu_entry_preprocessor);
c0d018f2:	68b4      	ldr	r4, [r6, #8]
c0d018f4:	f000 f8f2 	bl	c0d01adc <pic>
c0d018f8:	4601      	mov	r1, r0
c0d018fa:	68fa      	ldr	r2, [r7, #12]
c0d018fc:	4620      	mov	r0, r4
c0d018fe:	f000 f865 	bl	c0d019cc <ux_menu_display>
c0d01902:	e04d      	b.n	c0d019a0 <ux_menu_elements_button+0xec>
c0d01904:	482d      	ldr	r0, [pc, #180]	; (c0d019bc <ux_menu_elements_button+0x108>)
c0d01906:	4285      	cmp	r5, r0
c0d01908:	d00a      	beq.n	c0d01920 <ux_menu_elements_button+0x6c>
c0d0190a:	4828      	ldr	r0, [pc, #160]	; (c0d019ac <ux_menu_elements_button+0xf8>)
c0d0190c:	4285      	cmp	r5, r0
c0d0190e:	d148      	bne.n	c0d019a2 <ux_menu_elements_button+0xee>
      goto redraw;

    case BUTTON_EVT_FAST|BUTTON_RIGHT:
    case BUTTON_EVT_RELEASED|BUTTON_RIGHT:
      // entry 0 is the number of entries in the menu list
      if (ux_menu.current_entry >= ux_menu.menu_entries_count-1) {
c0d01910:	6879      	ldr	r1, [r7, #4]
c0d01912:	68b8      	ldr	r0, [r7, #8]
c0d01914:	1e4a      	subs	r2, r1, #1
c0d01916:	2400      	movs	r4, #0
c0d01918:	2101      	movs	r1, #1
c0d0191a:	4290      	cmp	r0, r2
c0d0191c:	d305      	bcc.n	c0d0192a <ux_menu_elements_button+0x76>
c0d0191e:	e040      	b.n	c0d019a2 <ux_menu_elements_button+0xee>
c0d01920:	2400      	movs	r4, #0
c0d01922:	43e1      	mvns	r1, r4
      break;

    case BUTTON_EVT_FAST|BUTTON_LEFT:
    case BUTTON_EVT_RELEASED|BUTTON_LEFT:
      // entry 0 is the number of entries in the menu list
      if (ux_menu.current_entry == 0) {
c0d01924:	68b8      	ldr	r0, [r7, #8]
c0d01926:	2800      	cmp	r0, #0
c0d01928:	d03b      	beq.n	c0d019a2 <ux_menu_elements_button+0xee>
c0d0192a:	1840      	adds	r0, r0, r1
c0d0192c:	60b8      	str	r0, [r7, #8]
  io_seproxyhal_init_button();
}

void io_seproxyhal_init_ux(void) {
  // initialize the touch part
  G_bagl_last_touched_not_released_component = NULL;
c0d0192e:	4824      	ldr	r0, [pc, #144]	; (c0d019c0 <ux_menu_elements_button+0x10c>)
c0d01930:	2400      	movs	r4, #0
c0d01932:	6004      	str	r4, [r0, #0]
      ux_menu.current_entry++;
    redraw:
#ifdef HAVE_BOLOS_UX
      screen_display_init(0);
#else
      UX_REDISPLAY();
c0d01934:	4d23      	ldr	r5, [pc, #140]	; (c0d019c4 <ux_menu_elements_button+0x110>)
c0d01936:	60ac      	str	r4, [r5, #8]
c0d01938:	6828      	ldr	r0, [r5, #0]
c0d0193a:	2800      	cmp	r0, #0
c0d0193c:	d031      	beq.n	c0d019a2 <ux_menu_elements_button+0xee>
c0d0193e:	69e8      	ldr	r0, [r5, #28]
c0d01940:	4921      	ldr	r1, [pc, #132]	; (c0d019c8 <ux_menu_elements_button+0x114>)
c0d01942:	4288      	cmp	r0, r1
c0d01944:	d02d      	beq.n	c0d019a2 <ux_menu_elements_button+0xee>
c0d01946:	2800      	cmp	r0, #0
c0d01948:	d02b      	beq.n	c0d019a2 <ux_menu_elements_button+0xee>
c0d0194a:	2400      	movs	r4, #0
c0d0194c:	4620      	mov	r0, r4
c0d0194e:	6869      	ldr	r1, [r5, #4]
c0d01950:	4288      	cmp	r0, r1
c0d01952:	d226      	bcs.n	c0d019a2 <ux_menu_elements_button+0xee>
c0d01954:	f000 f9bc 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d01958:	2800      	cmp	r0, #0
c0d0195a:	d122      	bne.n	c0d019a2 <ux_menu_elements_button+0xee>
c0d0195c:	68a8      	ldr	r0, [r5, #8]
c0d0195e:	68e9      	ldr	r1, [r5, #12]
c0d01960:	2638      	movs	r6, #56	; 0x38
c0d01962:	4370      	muls	r0, r6
c0d01964:	682a      	ldr	r2, [r5, #0]
c0d01966:	1810      	adds	r0, r2, r0
c0d01968:	2900      	cmp	r1, #0
c0d0196a:	d002      	beq.n	c0d01972 <ux_menu_elements_button+0xbe>
c0d0196c:	4788      	blx	r1
c0d0196e:	2800      	cmp	r0, #0
c0d01970:	d007      	beq.n	c0d01982 <ux_menu_elements_button+0xce>
c0d01972:	2801      	cmp	r0, #1
c0d01974:	d103      	bne.n	c0d0197e <ux_menu_elements_button+0xca>
c0d01976:	68a8      	ldr	r0, [r5, #8]
c0d01978:	4346      	muls	r6, r0
c0d0197a:	6828      	ldr	r0, [r5, #0]
c0d0197c:	1980      	adds	r0, r0, r6
c0d0197e:	f7fe fd79 	bl	c0d00474 <io_seproxyhal_display>
c0d01982:	68a8      	ldr	r0, [r5, #8]
c0d01984:	1c40      	adds	r0, r0, #1
c0d01986:	60a8      	str	r0, [r5, #8]
c0d01988:	6829      	ldr	r1, [r5, #0]
c0d0198a:	2900      	cmp	r1, #0
c0d0198c:	d1df      	bne.n	c0d0194e <ux_menu_elements_button+0x9a>
c0d0198e:	e008      	b.n	c0d019a2 <ux_menu_elements_button+0xee>
        // use userid as the pointer to current entry in the parent menu
        UX_MENU_DISPLAY(current_entry->userid, (const ux_menu_entry_t*)PIC(current_entry->menu), ux_menu.menu_entry_preprocessor);
        return 0;
      }
      // else callback
      else if (current_entry->callback) {
c0d01990:	6870      	ldr	r0, [r6, #4]
c0d01992:	2800      	cmp	r0, #0
c0d01994:	d005      	beq.n	c0d019a2 <ux_menu_elements_button+0xee>
        ((ux_menu_callback_t)PIC(current_entry->callback))(current_entry->userid);
c0d01996:	f000 f8a1 	bl	c0d01adc <pic>
c0d0199a:	4601      	mov	r1, r0
c0d0199c:	68b0      	ldr	r0, [r6, #8]
c0d0199e:	4788      	blx	r1
c0d019a0:	2400      	movs	r4, #0
      UX_REDISPLAY();
#endif
      return 0;
  }
  return 1;
}
c0d019a2:	4620      	mov	r0, r4
c0d019a4:	b001      	add	sp, #4
c0d019a6:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d019a8:	20001eec 	.word	0x20001eec
c0d019ac:	80000002 	.word	0x80000002
c0d019b0:	40000002 	.word	0x40000002
c0d019b4:	40000001 	.word	0x40000001
c0d019b8:	80000003 	.word	0x80000003
c0d019bc:	80000001 	.word	0x80000001
c0d019c0:	20001ee0 	.word	0x20001ee0
c0d019c4:	20001830 	.word	0x20001830
c0d019c8:	b0105044 	.word	0xb0105044

c0d019cc <ux_menu_display>:

const ux_menu_entry_t UX_MENU_END_ENTRY = UX_MENU_END;

void ux_menu_display(unsigned int current_entry, 
                     const ux_menu_entry_t* menu_entries,
                     ux_menu_preprocessor_t menu_entry_preprocessor) {
c0d019cc:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d019ce:	b083      	sub	sp, #12
c0d019d0:	9202      	str	r2, [sp, #8]
c0d019d2:	460d      	mov	r5, r1
c0d019d4:	9001      	str	r0, [sp, #4]
  // reset to first entry
  ux_menu.menu_entries_count = 0;
c0d019d6:	4e37      	ldr	r6, [pc, #220]	; (c0d01ab4 <ux_menu_display+0xe8>)
c0d019d8:	2000      	movs	r0, #0
c0d019da:	9000      	str	r0, [sp, #0]
c0d019dc:	6070      	str	r0, [r6, #4]

  // count entries
  if (menu_entries) {
c0d019de:	2d00      	cmp	r5, #0
c0d019e0:	d015      	beq.n	c0d01a0e <ux_menu_display+0x42>
    for(;;) {
      if (os_memcmp(&menu_entries[ux_menu.menu_entries_count], &UX_MENU_END_ENTRY, sizeof(ux_menu_entry_t)) == 0) {
c0d019e2:	4938      	ldr	r1, [pc, #224]	; (c0d01ac4 <ux_menu_display+0xf8>)
c0d019e4:	4479      	add	r1, pc
c0d019e6:	271c      	movs	r7, #28
c0d019e8:	4628      	mov	r0, r5
c0d019ea:	463a      	mov	r2, r7
c0d019ec:	f7ff fa70 	bl	c0d00ed0 <os_memcmp>
c0d019f0:	2800      	cmp	r0, #0
c0d019f2:	d00c      	beq.n	c0d01a0e <ux_menu_display+0x42>
c0d019f4:	4c34      	ldr	r4, [pc, #208]	; (c0d01ac8 <ux_menu_display+0xfc>)
c0d019f6:	447c      	add	r4, pc
        break;
      }
      ux_menu.menu_entries_count++;
c0d019f8:	6870      	ldr	r0, [r6, #4]
c0d019fa:	1c40      	adds	r0, r0, #1
c0d019fc:	6070      	str	r0, [r6, #4]
  ux_menu.menu_entries_count = 0;

  // count entries
  if (menu_entries) {
    for(;;) {
      if (os_memcmp(&menu_entries[ux_menu.menu_entries_count], &UX_MENU_END_ENTRY, sizeof(ux_menu_entry_t)) == 0) {
c0d019fe:	4378      	muls	r0, r7
c0d01a00:	1828      	adds	r0, r5, r0
c0d01a02:	4621      	mov	r1, r4
c0d01a04:	463a      	mov	r2, r7
c0d01a06:	f7ff fa63 	bl	c0d00ed0 <os_memcmp>
c0d01a0a:	2800      	cmp	r0, #0
c0d01a0c:	d1f4      	bne.n	c0d019f8 <ux_menu_display+0x2c>
c0d01a0e:	9901      	ldr	r1, [sp, #4]
      }
      ux_menu.menu_entries_count++;
    }
  }

  if (current_entry != UX_MENU_UNCHANGED_ENTRY) {
c0d01a10:	4608      	mov	r0, r1
c0d01a12:	3001      	adds	r0, #1
c0d01a14:	d005      	beq.n	c0d01a22 <ux_menu_display+0x56>
    ux_menu.current_entry = current_entry;
    if (ux_menu.current_entry > ux_menu.menu_entries_count) {
c0d01a16:	6870      	ldr	r0, [r6, #4]
c0d01a18:	4288      	cmp	r0, r1
c0d01a1a:	9800      	ldr	r0, [sp, #0]
c0d01a1c:	d300      	bcc.n	c0d01a20 <ux_menu_display+0x54>
c0d01a1e:	4608      	mov	r0, r1
      ux_menu.current_entry = 0;
c0d01a20:	60b0      	str	r0, [r6, #8]
    }
  }
  ux_menu.menu_entries = menu_entries;
c0d01a22:	6035      	str	r5, [r6, #0]
c0d01a24:	2500      	movs	r5, #0
  ux_menu.menu_entry_preprocessor = menu_entry_preprocessor;
c0d01a26:	9802      	ldr	r0, [sp, #8]
c0d01a28:	60f0      	str	r0, [r6, #12]
  ux_menu.menu_iterator = NULL;
c0d01a2a:	6135      	str	r5, [r6, #16]
  G_bolos_ux_context.screen_stack[0].button_push_callback = ux_menu_elements_button;

  screen_display_init(0);
#else
  // display the menu current entry
  UX_DISPLAY(ux_menu_elements, ux_menu_element_preprocessor);
c0d01a2c:	4c22      	ldr	r4, [pc, #136]	; (c0d01ab8 <ux_menu_display+0xec>)
c0d01a2e:	4827      	ldr	r0, [pc, #156]	; (c0d01acc <ux_menu_display+0x100>)
c0d01a30:	4478      	add	r0, pc
c0d01a32:	6020      	str	r0, [r4, #0]
c0d01a34:	2009      	movs	r0, #9
c0d01a36:	6060      	str	r0, [r4, #4]
c0d01a38:	4825      	ldr	r0, [pc, #148]	; (c0d01ad0 <ux_menu_display+0x104>)
c0d01a3a:	4478      	add	r0, pc
c0d01a3c:	6120      	str	r0, [r4, #16]
c0d01a3e:	4825      	ldr	r0, [pc, #148]	; (c0d01ad4 <ux_menu_display+0x108>)
c0d01a40:	4478      	add	r0, pc
c0d01a42:	60e0      	str	r0, [r4, #12]
c0d01a44:	2003      	movs	r0, #3
c0d01a46:	7620      	strb	r0, [r4, #24]
c0d01a48:	61e5      	str	r5, [r4, #28]
c0d01a4a:	4620      	mov	r0, r4
c0d01a4c:	3018      	adds	r0, #24
c0d01a4e:	f000 f913 	bl	c0d01c78 <os_ux>
c0d01a52:	61e0      	str	r0, [r4, #28]
c0d01a54:	f000 f840 	bl	c0d01ad8 <ux_check_status_default>
  io_seproxyhal_init_button();
}

void io_seproxyhal_init_ux(void) {
  // initialize the touch part
  G_bagl_last_touched_not_released_component = NULL;
c0d01a58:	4818      	ldr	r0, [pc, #96]	; (c0d01abc <ux_menu_display+0xf0>)
c0d01a5a:	6005      	str	r5, [r0, #0]
  G_bolos_ux_context.screen_stack[0].button_push_callback = ux_menu_elements_button;

  screen_display_init(0);
#else
  // display the menu current entry
  UX_DISPLAY(ux_menu_elements, ux_menu_element_preprocessor);
c0d01a5c:	60a5      	str	r5, [r4, #8]
c0d01a5e:	6820      	ldr	r0, [r4, #0]
c0d01a60:	2800      	cmp	r0, #0
c0d01a62:	d024      	beq.n	c0d01aae <ux_menu_display+0xe2>
c0d01a64:	69e0      	ldr	r0, [r4, #28]
c0d01a66:	4916      	ldr	r1, [pc, #88]	; (c0d01ac0 <ux_menu_display+0xf4>)
c0d01a68:	4288      	cmp	r0, r1
c0d01a6a:	d11e      	bne.n	c0d01aaa <ux_menu_display+0xde>
c0d01a6c:	e01f      	b.n	c0d01aae <ux_menu_display+0xe2>
c0d01a6e:	6860      	ldr	r0, [r4, #4]
c0d01a70:	4285      	cmp	r5, r0
c0d01a72:	d21c      	bcs.n	c0d01aae <ux_menu_display+0xe2>
c0d01a74:	f000 f92c 	bl	c0d01cd0 <io_seproxyhal_spi_is_status_sent>
c0d01a78:	2800      	cmp	r0, #0
c0d01a7a:	d118      	bne.n	c0d01aae <ux_menu_display+0xe2>
c0d01a7c:	68a0      	ldr	r0, [r4, #8]
c0d01a7e:	68e1      	ldr	r1, [r4, #12]
c0d01a80:	2538      	movs	r5, #56	; 0x38
c0d01a82:	4368      	muls	r0, r5
c0d01a84:	6822      	ldr	r2, [r4, #0]
c0d01a86:	1810      	adds	r0, r2, r0
c0d01a88:	2900      	cmp	r1, #0
c0d01a8a:	d002      	beq.n	c0d01a92 <ux_menu_display+0xc6>
c0d01a8c:	4788      	blx	r1
c0d01a8e:	2800      	cmp	r0, #0
c0d01a90:	d007      	beq.n	c0d01aa2 <ux_menu_display+0xd6>
c0d01a92:	2801      	cmp	r0, #1
c0d01a94:	d103      	bne.n	c0d01a9e <ux_menu_display+0xd2>
c0d01a96:	68a0      	ldr	r0, [r4, #8]
c0d01a98:	4345      	muls	r5, r0
c0d01a9a:	6820      	ldr	r0, [r4, #0]
c0d01a9c:	1940      	adds	r0, r0, r5
c0d01a9e:	f7fe fce9 	bl	c0d00474 <io_seproxyhal_display>
c0d01aa2:	68a0      	ldr	r0, [r4, #8]
c0d01aa4:	1c45      	adds	r5, r0, #1
c0d01aa6:	60a5      	str	r5, [r4, #8]
c0d01aa8:	6820      	ldr	r0, [r4, #0]
c0d01aaa:	2800      	cmp	r0, #0
c0d01aac:	d1df      	bne.n	c0d01a6e <ux_menu_display+0xa2>
#endif
}
c0d01aae:	b003      	add	sp, #12
c0d01ab0:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d01ab2:	46c0      	nop			; (mov r8, r8)
c0d01ab4:	20001eec 	.word	0x20001eec
c0d01ab8:	20001830 	.word	0x20001830
c0d01abc:	20001ee0 	.word	0x20001ee0
c0d01ac0:	b0105044 	.word	0xb0105044
c0d01ac4:	00002234 	.word	0x00002234
c0d01ac8:	00002222 	.word	0x00002222
c0d01acc:	00001ff0 	.word	0x00001ff0
c0d01ad0:	fffffe77 	.word	0xfffffe77
c0d01ad4:	fffffce9 	.word	0xfffffce9

c0d01ad8 <ux_check_status_default>:
}

void ux_check_status_default(unsigned int status) {
  // nothing to be done here by default.
  UNUSED(status);
}
c0d01ad8:	4770      	bx	lr
	...

c0d01adc <pic>:

// only apply PIC conversion if link_address is in linked code (over 0xC0D00000 in our example)
// this way, PIC call are armless if the address is not meant to be converted
extern unsigned int _nvram;
extern unsigned int _envram;
unsigned int pic(unsigned int link_address) {
c0d01adc:	b580      	push	{r7, lr}
//  screen_printf(" %08X", link_address);
	if (link_address >= ((unsigned int)&_nvram) && link_address < ((unsigned int)&_envram)) {
c0d01ade:	4904      	ldr	r1, [pc, #16]	; (c0d01af0 <pic+0x14>)
c0d01ae0:	4288      	cmp	r0, r1
c0d01ae2:	d304      	bcc.n	c0d01aee <pic+0x12>
c0d01ae4:	4903      	ldr	r1, [pc, #12]	; (c0d01af4 <pic+0x18>)
c0d01ae6:	4288      	cmp	r0, r1
c0d01ae8:	d201      	bcs.n	c0d01aee <pic+0x12>
		link_address = pic_internal(link_address);
c0d01aea:	f000 f805 	bl	c0d01af8 <pic_internal>
//    screen_printf(" -> %08X\n", link_address);
  }
	return link_address;
c0d01aee:	bd80      	pop	{r7, pc}
c0d01af0:	c0d00000 	.word	0xc0d00000
c0d01af4:	c0d03dc0 	.word	0xc0d03dc0

c0d01af8 <pic_internal>:

unsigned int pic_internal(unsigned int link_address) __attribute__((naked));
unsigned int pic_internal(unsigned int link_address) 
{
  // compute the delta offset between LinkMemAddr & ExecMemAddr
  __asm volatile ("mov r2, pc\n");          // r2 = 0x109004
c0d01af8:	467a      	mov	r2, pc
  __asm volatile ("ldr r1, =pic_internal\n");        // r1 = 0xC0D00001
c0d01afa:	4902      	ldr	r1, [pc, #8]	; (c0d01b04 <pic_internal+0xc>)
  __asm volatile ("adds r1, r1, #3\n");     // r1 = 0xC0D00004
c0d01afc:	1cc9      	adds	r1, r1, #3
  __asm volatile ("subs r1, r1, r2\n");     // r1 = 0xC0BF7000 (delta between load and exec address)
c0d01afe:	1a89      	subs	r1, r1, r2

  // adjust value of the given parameter
  __asm volatile ("subs r0, r0, r1\n");     // r0 = 0xC0D0C244 => r0 = 0x115244
c0d01b00:	1a40      	subs	r0, r0, r1
  __asm volatile ("bx lr\n");
c0d01b02:	4770      	bx	lr
c0d01b04:	c0d01af9 	.word	0xc0d01af9

c0d01b08 <SVC_Call>:
  // avoid a separate asm file, but avoid any intrusion from the compiler
  unsigned int SVC_Call(unsigned int syscall_id, unsigned int * parameters) __attribute__ ((naked));
  //                    r0                       r1
  unsigned int SVC_Call(unsigned int syscall_id, unsigned int * parameters) {
    // delegate svc
    asm volatile("svc #1":::"r0","r1");
c0d01b08:	df01      	svc	1
    // directly return R0 value
    asm volatile("bx  lr");
c0d01b0a:	4770      	bx	lr

c0d01b0c <check_api_level>:
  }
  void check_api_level ( unsigned int apiLevel ) 
{
c0d01b0c:	b580      	push	{r7, lr}
c0d01b0e:	b082      	sub	sp, #8
  unsigned int ret;
  unsigned int retid;
  unsigned int parameters [0+1];
  parameters[0] = (unsigned int)apiLevel;
c0d01b10:	9000      	str	r0, [sp, #0]
  retid = SVC_Call(SYSCALL_check_api_level_ID_IN, parameters);
c0d01b12:	4807      	ldr	r0, [pc, #28]	; (c0d01b30 <check_api_level+0x24>)
c0d01b14:	4669      	mov	r1, sp
c0d01b16:	f7ff fff7 	bl	c0d01b08 <SVC_Call>
c0d01b1a:	aa01      	add	r2, sp, #4
  asm volatile("str r1, %0":"=m"(ret)::"r1");
c0d01b1c:	6011      	str	r1, [r2, #0]
  if (retid != SYSCALL_check_api_level_ID_OUT) {
c0d01b1e:	4905      	ldr	r1, [pc, #20]	; (c0d01b34 <check_api_level+0x28>)
c0d01b20:	4288      	cmp	r0, r1
c0d01b22:	d101      	bne.n	c0d01b28 <check_api_level+0x1c>
    THROW(EXCEPTION_SECURITY);
  }
}
c0d01b24:	b002      	add	sp, #8
c0d01b26:	bd80      	pop	{r7, pc}
  unsigned int parameters [0+1];
  parameters[0] = (unsigned int)apiLevel;
  retid = SVC_Call(SYSCALL_check_api_level_ID_IN, parameters);
  asm volatile("str r1, %0":"=m"(ret)::"r1");
  if (retid != SYSCALL_check_api_level_ID_OUT) {
    THROW(EXCEPTION_SECURITY);
c0d01b28:	2004      	movs	r0, #4
c0d01b2a:	f7ff f9e8 	bl	c0d00efe <os_longjmp>
c0d01b2e:	46c0      	nop			; (mov r8, r8)
c0d01b30:	60000137 	.word	0x60000137
c0d01b34:	900001c6 	.word	0x900001c6

c0d01b38 <reset>:
  }
}

void reset ( void ) 
{
c0d01b38:	b580      	push	{r7, lr}
c0d01b3a:	b082      	sub	sp, #8
  unsigned int ret;
  unsigned int retid;
  unsigned int parameters [0];
  retid = SVC_Call(SYSCALL_reset_ID_IN, parameters);
c0d01b3c:	4806      	ldr	r0, [pc, #24]	; (c0d01b58 <reset+0x20>)
c0d01b3e:	a901      	add	r1, sp, #4
c0d01b40:	f7ff ffe2 	bl	c0d01b08 <SVC_Call>
c0d01b44:	466a      	mov	r2, sp
  asm volatile("str r1, %0":"=m"(ret)::"r1");
c0d01b46:	6011      	str	r1, [r2, #0]
  if (retid != SYSCALL_reset_ID_OUT) {
c0d01b48:	4904      	ldr	r1, [pc, #16]	; (c0d01b5c <reset+0x24>)
c0d01b4a:	4288      	cmp	r0, r1
c0d01b4c:	d101      	bne.n	c0d01b52 <reset+0x1a>
    THROW(EXCEPTION_SECURITY);
  }
}
c0d01b4e:	b002      	add	sp, #8
c0d01b50:	bd80      	pop	{r7, pc}
  unsigned int retid;
  unsigned int parameters [0];
  retid = SVC_Call(SYSCALL_reset_ID_IN, parameters);
  asm volatile("str r1, %0":"=m"(ret)::"r1");
  if (retid != SYSCALL_reset_ID_OUT) {
    THROW(EXCEPTION_SECURITY);
c0d01b52:	2004      	movs	r0, #4
c0d01b54:	f7ff f9d3 	bl	c0d00efe <os_longjmp>
c0d01b58:	60000200 	.word	0x60000200
c0d01b5c:	900002f1 	.word	0x900002f1

c0d01b60 <nvm_write>:
  }
}

void nvm_write ( void * dst_adr, void * src_adr, unsigned int src_len ) 
{
c0d01b60:	b580      	push	{r7, lr}
c0d01b62:	b084      	sub	sp, #16
  unsigned int ret;
  unsigned int retid;
  unsigned int parameters [0+3];
  parameters[0] = (unsigned int)dst_adr;
c0d01b64:	ab00      	add	r3, sp, #0
c0d01b66:	c307      	stmia	r3!, {r0, r1, r2}
  parameters[1] = (unsigned int)src_adr;
  parameters[2] = (unsigned int)src_len;
  retid = SVC_Call(SYSCALL_nvm_write_ID_IN, parameters);
c0d01b68:	4806      	ldr	r0, [pc, #24]	; (c0d01b84 <nvm_write+0x24>)
c0d01b6a:	4669      	mov	r1, sp
c0d01b6c:	f7ff ffcc 	bl	c0d01b08 <SVC_Call>
c0d01b70:	aa03      	add	r2, sp, #12
  asm volatile("str r1, %0":"=m"(ret)::"r1");
c0d01b72:	6011      	str	r1, [r2, #0]
  if (retid != SYSCALL_nvm_write_ID_OUT) {
c0d01b74:	4904      	ldr	r1, [pc, #16]	; (c0d01b88 <nvm_write+0x28>)
c0d01b76:	4288      	cmp	r0, r1
c0d01b78:	d101      	bne.n	c0d01b7e <nvm_write+0x1e>
    THROW(EXCEPTION_SECURITY);
  }
}
c0d01b7a:	b004      	add	sp, #16
c0d01b7c:	bd80      	pop	{r7, pc}
  parameters[1] = (unsigned int)src_adr;
  parameters[2] = (unsigned int)src_len;
  retid = SVC_Call(SYSCALL_nvm_write_ID_IN, parameters);
  asm volatile("str r1, %0":"=m"(ret)::"r1");
  if (retid != SYSCALL_nvm_write_ID_OUT) {
    THROW(EXCEPTION_SECURITY);
c0d01b7e:	2004      	movs	r0, #4
c0d01b80:	f7ff f9bd 	bl	c0d00efe <os_longjmp>
c0d01b84:	6000037f 	.word	0x6000037f
c0d01b88:	900003bc 	.word	0x900003bc

c0d01b8c <cx_rng>:
  }
  return (unsigned char)ret;
}

unsigned char * cx_rng ( unsigned char * buffer, unsigned int len ) 
{
c0d01b8c:	b580      	push	{r7, lr}
c0d01b8e:	b084      	sub	sp, #16
  unsigned int ret;
  unsigned int retid;
  unsigned int parameters [0+2];
  parameters[0] = (unsigned int)buffer;
c0d01b90:	9001      	str	r0, [sp, #4]
  parameters[1] = (unsigned int)len;
c0d01b92:	9102      	str	r1, [sp, #8]
  retid = SVC_Call(SYSCALL_cx_rng_ID_IN, parameters);
c0d01b94:	4807      	ldr	r0, [pc, #28]	; (c0d01bb4 <cx_rng+0x28>)
c0d01b96:	a901      	add	r1, sp, #4
c0d01b98:	f7ff ffb6 	bl	c0d01b08 <SVC_Call>
c0d01b9c:	aa03      	add	r2, sp, #12
  asm volatile("str r1, %0":"=m"(ret)::"r1");
c0d01b9e:	6011      	str	r1, [r2, #0]
  if (retid != SYSCALL_cx_rng_ID_OUT) {
c0d01ba0:	4905      	ldr	r1, [pc, #20]	; (c0d01bb8 <cx_rng+0x2c>)
c0d01ba2:	4288      	cmp	r0, r1
c0d01ba4:	d102      	bne.n	c0d01bac <cx_rng+0x20>
    THROW(EXCEPTION_SECURITY);
  }
  return (unsigned char *)ret;
c0d01ba6:	9803      	ldr	r0, [sp, #12]
c0d01ba8:	b004      	add	sp, #16
c0d01baa:	bd80      	pop	{r7, pc}
  parameters[0] = (unsigned int)buffer;
  parameters[1] = (unsigned int)len;
  retid = SVC_Call(SYSCALL_cx_rng_ID_IN, parameters);
  asm volatile("str r1, %0":"=m"(ret)::"r1");
  if (retid != SYSCALL_cx_rng_ID_OUT) {
    THROW(EXCEPTION_SECURITY);
c0d01bac:	2004      	movs	r0, #4
c0d01bae:	f7ff f9a6 	bl	c0d00efe <os_longjmp>
c0d01bb2:	46c0      	nop			; (mov r8, r8)
c0d01bb4:	6000052c 	.word	0x6000052c
c0d01bb8:	90000567 	.word	0x90000567

c0d01bbc <cx_ecfp_init_private_key>:
  }
  return (int)ret;
}

int cx_ecfp_init_private_key ( cx_curve_t curve, const unsigned char * rawkey, unsigned int key_len, cx_ecfp_private_key_t * pvkey ) 
{
c0d01bbc:	b580      	push	{r7, lr}
c0d01bbe:	b086      	sub	sp, #24
  unsigned int ret;
  unsigned int retid;
  unsigned int parameters [0+4];
  parameters[0] = (unsigned int)curve;
c0d01bc0:	af01      	add	r7, sp, #4
c0d01bc2:	c70f      	stmia	r7!, {r0, r1, r2, r3}
  parameters[1] = (unsigned int)rawkey;
  parameters[2] = (unsigned int)key_len;
  parameters[3] = (unsigned int)pvkey;
  retid = SVC_Call(SYSCALL_cx_ecfp_init_private_key_ID_IN, parameters);
c0d01bc4:	4807      	ldr	r0, [pc, #28]	; (c0d01be4 <cx_ecfp_init_private_key+0x28>)
c0d01bc6:	a901      	add	r1, sp, #4
c0d01bc8:	f7ff ff9e 	bl	c0d01b08 <SVC_Call>
c0d01bcc:	aa05      	add	r2, sp, #20
  asm volatile("str r1, %0":"=m"(ret)::"r1");
c0d01bce:	6011      	str	r1, [r2, #0]
  if (retid != SYSCALL_cx_ecfp_init_private_key_ID_OUT) {
c0d01bd0:	4905      	ldr	r1, [pc, #20]	; (c0d01be8 <cx_ecfp_init_private_key+0x2c>)
c0d01bd2:	4288      	cmp	r0, r1
c0d01bd4:	d102      	bne.n	c0d01bdc <cx_ecfp_init_private_key+0x20>
    THROW(EXCEPTION_SECURITY);
  }
  return (int)ret;
c0d01bd6:	9805      	ldr	r0, [sp, #20]
c0d01bd8:	b006      	add	sp, #24
c0d01bda:	bd80      	pop	{r7, pc}
  parameters[2] = (unsigned int)key_len;
  parameters[3] = (unsigned int)pvkey;
  retid = SVC_Call(SYSCALL_cx_ecfp_init_private_key_ID_IN, parameters);
  asm volatile("str r1, %0":"=m"(ret)::"r1");
  if (retid != SYSCALL_cx_ecfp_init_private_key_ID_OUT) {
    THROW(EXCEPTION_SECURITY);
c0d01bdc:	2004      	movs	r0, #4
c0d01bde:	f7ff f98e 	bl	c0d00efe <os_longjmp>
c0d01be2:	46c0      	nop			; (mov r8, r8)
c0d01be4:	60002bea 	.word	0x60002bea
c0d01be8:	90002b63 	.word	0x90002b63

c0d01bec <cx_ecfp_generate_pair>:
  }
  return (int)ret;
}

int cx_ecfp_generate_pair ( cx_curve_t curve, cx_ecfp_public_key_t * pubkey, cx_ecfp_private_key_t * privkey, int keepprivate ) 
{
c0d01bec:	b580      	push	{r7, lr}
c0d01bee:	b086      	sub	sp, #24
  unsigned int ret;
  unsigned int retid;
  unsigned int parameters [0+4];
  parameters[0] = (unsigned int)curve;
c0d01bf0:	af01      	add	r7, sp, #4
c0d01bf2:	c70f      	stmia	r7!, {r0, r1, r2, r3}
  parameters[1] = (unsigned int)pubkey;
  parameters[2] = (unsigned int)privkey;
  parameters[3] = (unsigned int)keepprivate;
  retid = SVC_Call(SYSCALL_cx_ecfp_generate_pair_ID_IN, parameters);
c0d01bf4:	4807      	ldr	r0, [pc, #28]	; (c0d01c14 <cx_ecfp_generate_pair+0x28>)
c0d01bf6:	a901      	add	r1, sp, #4
c0d01bf8:	f7ff ff86 	bl	c0d01b08 <SVC_Call>
c0d01bfc:	aa05      	add	r2, sp, #20
  asm volatile("str r1, %0":"=m"(ret)::"r1");
c0d01bfe:	6011      	str	r1, [r2, #0]
  if (retid != SYSCALL_cx_ecfp_generate_pair_ID_OUT) {
c0d01c00:	4905      	ldr	r1, [pc, #20]	; (c0d01c18 <cx_ecfp_generate_pair+0x2c>)
c0d01c02:	4288      	cmp	r0, r1
c0d01c04:	d102      	bne.n	c0d01c0c <cx_ecfp_generate_pair+0x20>
    THROW(EXCEPTION_SECURITY);
  }
  return (int)ret;
c0d01c06:	9805      	ldr	r0, [sp, #20]
c0d01c08:	b006      	add	sp, #24
c0d01c0a:	bd80      	pop	{r7, pc}
  parameters[2] = (unsigned int)privkey;
  parameters[3] = (unsigned int)keepprivate;
  retid = SVC_Call(SYSCALL_cx_ecfp_generate_pair_ID_IN, parameters);
  asm volatile("str r1, %0":"=m"(ret)::"r1");
  if (retid != SYSCALL_cx_ecfp_generate_pair_ID_OUT) {
    THROW(EXCEPTION_SECURITY);
c0d01c0c:	2004      	movs	r0, #4
c0d01c0e:	f7ff f976 	bl	c0d00efe <os_longjmp>
c0d01c12:	46c0      	nop			; (mov r8, r8)
c0d01c14:	60002c2e 	.word	0x60002c2e
c0d01c18:	90002c74 	.word	0x90002c74

c0d01c1c <os_perso_derive_node_bip32>:
  }
  return (unsigned int)ret;
}

void os_perso_derive_node_bip32 ( cx_curve_t curve, const unsigned int * path, unsigned int pathLength, unsigned char * privateKey, unsigned char * chain ) 
{
c0d01c1c:	b580      	push	{r7, lr}
c0d01c1e:	b086      	sub	sp, #24
  unsigned int ret;
  unsigned int retid;
  unsigned int parameters [0+5];
  parameters[0] = (unsigned int)curve;
c0d01c20:	af00      	add	r7, sp, #0
c0d01c22:	c70f      	stmia	r7!, {r0, r1, r2, r3}
c0d01c24:	9808      	ldr	r0, [sp, #32]
  parameters[1] = (unsigned int)path;
  parameters[2] = (unsigned int)pathLength;
  parameters[3] = (unsigned int)privateKey;
  parameters[4] = (unsigned int)chain;
c0d01c26:	9004      	str	r0, [sp, #16]
  retid = SVC_Call(SYSCALL_os_perso_derive_node_bip32_ID_IN, parameters);
c0d01c28:	4806      	ldr	r0, [pc, #24]	; (c0d01c44 <os_perso_derive_node_bip32+0x28>)
c0d01c2a:	4669      	mov	r1, sp
c0d01c2c:	f7ff ff6c 	bl	c0d01b08 <SVC_Call>
c0d01c30:	aa05      	add	r2, sp, #20
  asm volatile("str r1, %0":"=m"(ret)::"r1");
c0d01c32:	6011      	str	r1, [r2, #0]
  if (retid != SYSCALL_os_perso_derive_node_bip32_ID_OUT) {
c0d01c34:	4904      	ldr	r1, [pc, #16]	; (c0d01c48 <os_perso_derive_node_bip32+0x2c>)
c0d01c36:	4288      	cmp	r0, r1
c0d01c38:	d101      	bne.n	c0d01c3e <os_perso_derive_node_bip32+0x22>
    THROW(EXCEPTION_SECURITY);
  }
}
c0d01c3a:	b006      	add	sp, #24
c0d01c3c:	bd80      	pop	{r7, pc}
  parameters[3] = (unsigned int)privateKey;
  parameters[4] = (unsigned int)chain;
  retid = SVC_Call(SYSCALL_os_perso_derive_node_bip32_ID_IN, parameters);
  asm volatile("str r1, %0":"=m"(ret)::"r1");
  if (retid != SYSCALL_os_perso_derive_node_bip32_ID_OUT) {
    THROW(EXCEPTION_SECURITY);
c0d01c3e:	2004      	movs	r0, #4
c0d01c40:	f7ff f95d 	bl	c0d00efe <os_longjmp>
c0d01c44:	600050ba 	.word	0x600050ba
c0d01c48:	9000501e 	.word	0x9000501e

c0d01c4c <os_sched_exit>:
  }
  return (unsigned int)ret;
}

void os_sched_exit ( unsigned int exit_code ) 
{
c0d01c4c:	b580      	push	{r7, lr}
c0d01c4e:	b082      	sub	sp, #8
  unsigned int ret;
  unsigned int retid;
  unsigned int parameters [0+1];
  parameters[0] = (unsigned int)exit_code;
c0d01c50:	9000      	str	r0, [sp, #0]
  retid = SVC_Call(SYSCALL_os_sched_exit_ID_IN, parameters);
c0d01c52:	4807      	ldr	r0, [pc, #28]	; (c0d01c70 <os_sched_exit+0x24>)
c0d01c54:	4669      	mov	r1, sp
c0d01c56:	f7ff ff57 	bl	c0d01b08 <SVC_Call>
c0d01c5a:	aa01      	add	r2, sp, #4
  asm volatile("str r1, %0":"=m"(ret)::"r1");
c0d01c5c:	6011      	str	r1, [r2, #0]
  if (retid != SYSCALL_os_sched_exit_ID_OUT) {
c0d01c5e:	4905      	ldr	r1, [pc, #20]	; (c0d01c74 <os_sched_exit+0x28>)
c0d01c60:	4288      	cmp	r0, r1
c0d01c62:	d101      	bne.n	c0d01c68 <os_sched_exit+0x1c>
    THROW(EXCEPTION_SECURITY);
  }
}
c0d01c64:	b002      	add	sp, #8
c0d01c66:	bd80      	pop	{r7, pc}
  unsigned int parameters [0+1];
  parameters[0] = (unsigned int)exit_code;
  retid = SVC_Call(SYSCALL_os_sched_exit_ID_IN, parameters);
  asm volatile("str r1, %0":"=m"(ret)::"r1");
  if (retid != SYSCALL_os_sched_exit_ID_OUT) {
    THROW(EXCEPTION_SECURITY);
c0d01c68:	2004      	movs	r0, #4
c0d01c6a:	f7ff f948 	bl	c0d00efe <os_longjmp>
c0d01c6e:	46c0      	nop			; (mov r8, r8)
c0d01c70:	60005fe1 	.word	0x60005fe1
c0d01c74:	90005f6f 	.word	0x90005f6f

c0d01c78 <os_ux>:
    THROW(EXCEPTION_SECURITY);
  }
}

unsigned int os_ux ( bolos_ux_params_t * params ) 
{
c0d01c78:	b580      	push	{r7, lr}
c0d01c7a:	b082      	sub	sp, #8
  unsigned int ret;
  unsigned int retid;
  unsigned int parameters [0+1];
  parameters[0] = (unsigned int)params;
c0d01c7c:	9000      	str	r0, [sp, #0]
  retid = SVC_Call(SYSCALL_os_ux_ID_IN, parameters);
c0d01c7e:	4807      	ldr	r0, [pc, #28]	; (c0d01c9c <os_ux+0x24>)
c0d01c80:	4669      	mov	r1, sp
c0d01c82:	f7ff ff41 	bl	c0d01b08 <SVC_Call>
c0d01c86:	aa01      	add	r2, sp, #4
  asm volatile("str r1, %0":"=m"(ret)::"r1");
c0d01c88:	6011      	str	r1, [r2, #0]
  if (retid != SYSCALL_os_ux_ID_OUT) {
c0d01c8a:	4905      	ldr	r1, [pc, #20]	; (c0d01ca0 <os_ux+0x28>)
c0d01c8c:	4288      	cmp	r0, r1
c0d01c8e:	d102      	bne.n	c0d01c96 <os_ux+0x1e>
    THROW(EXCEPTION_SECURITY);
  }
  return (unsigned int)ret;
c0d01c90:	9801      	ldr	r0, [sp, #4]
c0d01c92:	b002      	add	sp, #8
c0d01c94:	bd80      	pop	{r7, pc}
  unsigned int parameters [0+1];
  parameters[0] = (unsigned int)params;
  retid = SVC_Call(SYSCALL_os_ux_ID_IN, parameters);
  asm volatile("str r1, %0":"=m"(ret)::"r1");
  if (retid != SYSCALL_os_ux_ID_OUT) {
    THROW(EXCEPTION_SECURITY);
c0d01c96:	2004      	movs	r0, #4
c0d01c98:	f7ff f931 	bl	c0d00efe <os_longjmp>
c0d01c9c:	60006158 	.word	0x60006158
c0d01ca0:	9000611f 	.word	0x9000611f

c0d01ca4 <io_seproxyhal_spi_send>:
  }
  return (unsigned int)ret;
}

void io_seproxyhal_spi_send ( const unsigned char * buffer, unsigned short length ) 
{
c0d01ca4:	b580      	push	{r7, lr}
c0d01ca6:	b084      	sub	sp, #16
  unsigned int ret;
  unsigned int retid;
  unsigned int parameters [0+2];
  parameters[0] = (unsigned int)buffer;
c0d01ca8:	9001      	str	r0, [sp, #4]
  parameters[1] = (unsigned int)length;
c0d01caa:	9102      	str	r1, [sp, #8]
  retid = SVC_Call(SYSCALL_io_seproxyhal_spi_send_ID_IN, parameters);
c0d01cac:	4806      	ldr	r0, [pc, #24]	; (c0d01cc8 <io_seproxyhal_spi_send+0x24>)
c0d01cae:	a901      	add	r1, sp, #4
c0d01cb0:	f7ff ff2a 	bl	c0d01b08 <SVC_Call>
c0d01cb4:	aa03      	add	r2, sp, #12
  asm volatile("str r1, %0":"=m"(ret)::"r1");
c0d01cb6:	6011      	str	r1, [r2, #0]
  if (retid != SYSCALL_io_seproxyhal_spi_send_ID_OUT) {
c0d01cb8:	4904      	ldr	r1, [pc, #16]	; (c0d01ccc <io_seproxyhal_spi_send+0x28>)
c0d01cba:	4288      	cmp	r0, r1
c0d01cbc:	d101      	bne.n	c0d01cc2 <io_seproxyhal_spi_send+0x1e>
    THROW(EXCEPTION_SECURITY);
  }
}
c0d01cbe:	b004      	add	sp, #16
c0d01cc0:	bd80      	pop	{r7, pc}
  parameters[0] = (unsigned int)buffer;
  parameters[1] = (unsigned int)length;
  retid = SVC_Call(SYSCALL_io_seproxyhal_spi_send_ID_IN, parameters);
  asm volatile("str r1, %0":"=m"(ret)::"r1");
  if (retid != SYSCALL_io_seproxyhal_spi_send_ID_OUT) {
    THROW(EXCEPTION_SECURITY);
c0d01cc2:	2004      	movs	r0, #4
c0d01cc4:	f7ff f91b 	bl	c0d00efe <os_longjmp>
c0d01cc8:	60006e1c 	.word	0x60006e1c
c0d01ccc:	90006ef3 	.word	0x90006ef3

c0d01cd0 <io_seproxyhal_spi_is_status_sent>:
  }
}

unsigned int io_seproxyhal_spi_is_status_sent ( void ) 
{
c0d01cd0:	b580      	push	{r7, lr}
c0d01cd2:	b082      	sub	sp, #8
  unsigned int ret;
  unsigned int retid;
  unsigned int parameters [0];
  retid = SVC_Call(SYSCALL_io_seproxyhal_spi_is_status_sent_ID_IN, parameters);
c0d01cd4:	4807      	ldr	r0, [pc, #28]	; (c0d01cf4 <io_seproxyhal_spi_is_status_sent+0x24>)
c0d01cd6:	a901      	add	r1, sp, #4
c0d01cd8:	f7ff ff16 	bl	c0d01b08 <SVC_Call>
c0d01cdc:	466a      	mov	r2, sp
  asm volatile("str r1, %0":"=m"(ret)::"r1");
c0d01cde:	6011      	str	r1, [r2, #0]
  if (retid != SYSCALL_io_seproxyhal_spi_is_status_sent_ID_OUT) {
c0d01ce0:	4905      	ldr	r1, [pc, #20]	; (c0d01cf8 <io_seproxyhal_spi_is_status_sent+0x28>)
c0d01ce2:	4288      	cmp	r0, r1
c0d01ce4:	d102      	bne.n	c0d01cec <io_seproxyhal_spi_is_status_sent+0x1c>
    THROW(EXCEPTION_SECURITY);
  }
  return (unsigned int)ret;
c0d01ce6:	9800      	ldr	r0, [sp, #0]
c0d01ce8:	b002      	add	sp, #8
c0d01cea:	bd80      	pop	{r7, pc}
  unsigned int retid;
  unsigned int parameters [0];
  retid = SVC_Call(SYSCALL_io_seproxyhal_spi_is_status_sent_ID_IN, parameters);
  asm volatile("str r1, %0":"=m"(ret)::"r1");
  if (retid != SYSCALL_io_seproxyhal_spi_is_status_sent_ID_OUT) {
    THROW(EXCEPTION_SECURITY);
c0d01cec:	2004      	movs	r0, #4
c0d01cee:	f7ff f906 	bl	c0d00efe <os_longjmp>
c0d01cf2:	46c0      	nop			; (mov r8, r8)
c0d01cf4:	60006fcf 	.word	0x60006fcf
c0d01cf8:	90006f7f 	.word	0x90006f7f

c0d01cfc <io_seproxyhal_spi_recv>:
  }
  return (unsigned int)ret;
}

unsigned short io_seproxyhal_spi_recv ( unsigned char * buffer, unsigned short maxlength, unsigned int flags ) 
{
c0d01cfc:	b580      	push	{r7, lr}
c0d01cfe:	b084      	sub	sp, #16
  unsigned int ret;
  unsigned int retid;
  unsigned int parameters [0+3];
  parameters[0] = (unsigned int)buffer;
c0d01d00:	ab00      	add	r3, sp, #0
c0d01d02:	c307      	stmia	r3!, {r0, r1, r2}
  parameters[1] = (unsigned int)maxlength;
  parameters[2] = (unsigned int)flags;
  retid = SVC_Call(SYSCALL_io_seproxyhal_spi_recv_ID_IN, parameters);
c0d01d04:	4807      	ldr	r0, [pc, #28]	; (c0d01d24 <io_seproxyhal_spi_recv+0x28>)
c0d01d06:	4669      	mov	r1, sp
c0d01d08:	f7ff fefe 	bl	c0d01b08 <SVC_Call>
c0d01d0c:	aa03      	add	r2, sp, #12
  asm volatile("str r1, %0":"=m"(ret)::"r1");
c0d01d0e:	6011      	str	r1, [r2, #0]
  if (retid != SYSCALL_io_seproxyhal_spi_recv_ID_OUT) {
c0d01d10:	4905      	ldr	r1, [pc, #20]	; (c0d01d28 <io_seproxyhal_spi_recv+0x2c>)
c0d01d12:	4288      	cmp	r0, r1
c0d01d14:	d103      	bne.n	c0d01d1e <io_seproxyhal_spi_recv+0x22>
c0d01d16:	a803      	add	r0, sp, #12
    THROW(EXCEPTION_SECURITY);
  }
  return (unsigned short)ret;
c0d01d18:	8800      	ldrh	r0, [r0, #0]
c0d01d1a:	b004      	add	sp, #16
c0d01d1c:	bd80      	pop	{r7, pc}
  parameters[1] = (unsigned int)maxlength;
  parameters[2] = (unsigned int)flags;
  retid = SVC_Call(SYSCALL_io_seproxyhal_spi_recv_ID_IN, parameters);
  asm volatile("str r1, %0":"=m"(ret)::"r1");
  if (retid != SYSCALL_io_seproxyhal_spi_recv_ID_OUT) {
    THROW(EXCEPTION_SECURITY);
c0d01d1e:	2004      	movs	r0, #4
c0d01d20:	f7ff f8ed 	bl	c0d00efe <os_longjmp>
c0d01d24:	600070d1 	.word	0x600070d1
c0d01d28:	9000702b 	.word	0x9000702b

c0d01d2c <u2f_io_open_session>:
volatile unsigned char u2fFirstCommand = 0;
volatile unsigned char u2fClosed = 0;

void u2f_io_open_session(void) {
    // PRINTF("u2f_io_open_session\n");
    u2fCommandSent = 0;
c0d01d2c:	4804      	ldr	r0, [pc, #16]	; (c0d01d40 <u2f_io_open_session+0x14>)
c0d01d2e:	2100      	movs	r1, #0
c0d01d30:	7001      	strb	r1, [r0, #0]
    u2fFirstCommand = 1;
c0d01d32:	4804      	ldr	r0, [pc, #16]	; (c0d01d44 <u2f_io_open_session+0x18>)
c0d01d34:	2201      	movs	r2, #1
c0d01d36:	7002      	strb	r2, [r0, #0]
    u2fClosed = 0;
c0d01d38:	4803      	ldr	r0, [pc, #12]	; (c0d01d48 <u2f_io_open_session+0x1c>)
c0d01d3a:	7001      	strb	r1, [r0, #0]
}
c0d01d3c:	4770      	bx	lr
c0d01d3e:	46c0      	nop			; (mov r8, r8)
c0d01d40:	20001f78 	.word	0x20001f78
c0d01d44:	20001f79 	.word	0x20001f79
c0d01d48:	20001f7a 	.word	0x20001f7a

c0d01d4c <u2f_io_send>:

unsigned char u2fSegment[MAX_SEGMENT_SIZE];

void u2f_io_send(uint8_t *buffer, uint16_t length,
                 u2f_transport_media_t media) {
c0d01d4c:	b570      	push	{r4, r5, r6, lr}
c0d01d4e:	4614      	mov	r4, r2
c0d01d50:	460d      	mov	r5, r1
c0d01d52:	4606      	mov	r6, r0
    if (media == U2F_MEDIA_USB) {
c0d01d54:	2c01      	cmp	r4, #1
c0d01d56:	d104      	bne.n	c0d01d62 <u2f_io_send+0x16>
        os_memset(u2fSegment, 0, sizeof(u2fSegment));
c0d01d58:	480b      	ldr	r0, [pc, #44]	; (c0d01d88 <u2f_io_send+0x3c>)
c0d01d5a:	2100      	movs	r1, #0
c0d01d5c:	2240      	movs	r2, #64	; 0x40
c0d01d5e:	f7ff f811 	bl	c0d00d84 <os_memset>
    }
    os_memmove(u2fSegment, buffer, length);
c0d01d62:	4809      	ldr	r0, [pc, #36]	; (c0d01d88 <u2f_io_send+0x3c>)
c0d01d64:	4631      	mov	r1, r6
c0d01d66:	462a      	mov	r2, r5
c0d01d68:	f7ff f815 	bl	c0d00d96 <os_memmove>
    // PRINTF("u2f_io_send\n");
    if (u2fFirstCommand) {
c0d01d6c:	4807      	ldr	r0, [pc, #28]	; (c0d01d8c <u2f_io_send+0x40>)
c0d01d6e:	7801      	ldrb	r1, [r0, #0]
c0d01d70:	2900      	cmp	r1, #0
c0d01d72:	d001      	beq.n	c0d01d78 <u2f_io_send+0x2c>
        u2fFirstCommand = 0;
c0d01d74:	2100      	movs	r1, #0
c0d01d76:	7001      	strb	r1, [r0, #0]
    }
    switch (media) {
c0d01d78:	2c01      	cmp	r4, #1
c0d01d7a:	d103      	bne.n	c0d01d84 <u2f_io_send+0x38>
    case U2F_MEDIA_USB:
        io_usb_send_apdu_data(u2fSegment, USB_SEGMENT_SIZE);
c0d01d7c:	4802      	ldr	r0, [pc, #8]	; (c0d01d88 <u2f_io_send+0x3c>)
c0d01d7e:	2140      	movs	r1, #64	; 0x40
c0d01d80:	f7ff f9c8 	bl	c0d01114 <io_usb_send_apdu_data>
#endif
    default:
        PRINTF("Request to send on unsupported media %d\n", media);
        break;
    }
}
c0d01d84:	bd70      	pop	{r4, r5, r6, pc}
c0d01d86:	46c0      	nop			; (mov r8, r8)
c0d01d88:	20001f7b 	.word	0x20001f7b
c0d01d8c:	20001f79 	.word	0x20001f79

c0d01d90 <u2f_io_close_session>:

void u2f_io_close_session(void) {
    // PRINTF("u2f_close_session\n");
    if (!u2fClosed) {
c0d01d90:	4803      	ldr	r0, [pc, #12]	; (c0d01da0 <u2f_io_close_session+0x10>)
c0d01d92:	7801      	ldrb	r1, [r0, #0]
c0d01d94:	2900      	cmp	r1, #0
c0d01d96:	d101      	bne.n	c0d01d9c <u2f_io_close_session+0xc>
        // u2f_reset_display();
        u2fClosed = 1;
c0d01d98:	2101      	movs	r1, #1
c0d01d9a:	7001      	strb	r1, [r0, #0]
    }
}
c0d01d9c:	4770      	bx	lr
c0d01d9e:	46c0      	nop			; (mov r8, r8)
c0d01da0:	20001f7a 	.word	0x20001f7a

c0d01da4 <u2f_handle_enroll>:
#define MAX_KEEPALIVE_TIMEOUT_MS 500

static const uint8_t DUMMY_USER_PRESENCE[] = {SIGN_USER_PRESENCE_MASK};

void u2f_handle_enroll(u2f_service_t *service, uint8_t p1, uint8_t p2,
                       uint8_t *buffer, uint16_t length) {
c0d01da4:	b580      	push	{r7, lr}
c0d01da6:	b082      	sub	sp, #8
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
                                     (uint8_t *)SW_WRONG_LENGTH,
                                     sizeof(SW_WRONG_LENGTH), true);
        return;
    }
    u2f_send_fragmented_response(service, U2F_CMD_MSG, (uint8_t *)SW_INTERNAL,
c0d01da8:	2201      	movs	r2, #1
c0d01daa:	2183      	movs	r1, #131	; 0x83
c0d01dac:	9b04      	ldr	r3, [sp, #16]
void u2f_handle_enroll(u2f_service_t *service, uint8_t p1, uint8_t p2,
                       uint8_t *buffer, uint16_t length) {
    (void)p1;
    (void)p2;
    (void)buffer;
    if (length != 32 + 32) {
c0d01dae:	2b40      	cmp	r3, #64	; 0x40
c0d01db0:	d104      	bne.n	c0d01dbc <u2f_handle_enroll+0x18>
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
                                     (uint8_t *)SW_WRONG_LENGTH,
                                     sizeof(SW_WRONG_LENGTH), true);
        return;
    }
    u2f_send_fragmented_response(service, U2F_CMD_MSG, (uint8_t *)SW_INTERNAL,
c0d01db2:	466b      	mov	r3, sp
c0d01db4:	601a      	str	r2, [r3, #0]
c0d01db6:	4a07      	ldr	r2, [pc, #28]	; (c0d01dd4 <u2f_handle_enroll+0x30>)
c0d01db8:	447a      	add	r2, pc
c0d01dba:	e003      	b.n	c0d01dc4 <u2f_handle_enroll+0x20>
                       uint8_t *buffer, uint16_t length) {
    (void)p1;
    (void)p2;
    (void)buffer;
    if (length != 32 + 32) {
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
c0d01dbc:	466b      	mov	r3, sp
c0d01dbe:	601a      	str	r2, [r3, #0]
c0d01dc0:	4a03      	ldr	r2, [pc, #12]	; (c0d01dd0 <u2f_handle_enroll+0x2c>)
c0d01dc2:	447a      	add	r2, pc
c0d01dc4:	2302      	movs	r3, #2
c0d01dc6:	f000 f9be 	bl	c0d02146 <u2f_send_fragmented_response>
                                     sizeof(SW_WRONG_LENGTH), true);
        return;
    }
    u2f_send_fragmented_response(service, U2F_CMD_MSG, (uint8_t *)SW_INTERNAL,
                                 sizeof(SW_INTERNAL), true);
}
c0d01dca:	b002      	add	sp, #8
c0d01dcc:	bd80      	pop	{r7, pc}
c0d01dce:	46c0      	nop			; (mov r8, r8)
c0d01dd0:	00001e72 	.word	0x00001e72
c0d01dd4:	00001e7e 	.word	0x00001e7e

c0d01dd8 <u2f_handle_sign>:

void u2f_handle_sign(u2f_service_t *service, uint8_t p1, uint8_t p2,
                     uint8_t *buffer, uint16_t length) {
c0d01dd8:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d01dda:	b089      	sub	sp, #36	; 0x24
c0d01ddc:	2700      	movs	r7, #0
    (void)p1;
    (void)p2;
    (void)length;
    uint8_t keyHandleLength;
    uint8_t i;
    volatile unsigned int flags = 0;
c0d01dde:	9708      	str	r7, [sp, #32]
    volatile unsigned int tx = 0;
c0d01de0:	9707      	str	r7, [sp, #28]
c0d01de2:	9e0e      	ldr	r6, [sp, #56]	; 0x38
    for (i = 0; i < keyHandleLength; i++) {
        buffer[65 + i] ^= PROXY_MAGIC[i % sizeof(PROXY_MAGIC)];
    }
    // Check magic
    if (length != (32 + 32 + 1 + 5 + buffer[65 + 4])) {
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
c0d01de4:	2201      	movs	r2, #1
                                     (uint8_t *)SW_WRONG_LENGTH,
                                     sizeof(SW_WRONG_LENGTH), true);
        return;
    }
    if ((p1 != P1_SIGN_CHECK_ONLY) && (p1 != P1_SIGN_SIGN)) {
        u2f_response_error(service, ERROR_PROP_INVALID_PARAMETERS_APDU, true,
c0d01de6:	2483      	movs	r4, #131	; 0x83
    uint8_t keyHandleLength;
    uint8_t i;
    volatile unsigned int flags = 0;
    volatile unsigned int tx = 0;

    if (length < 32 + 32 + 1) {
c0d01de8:	2e40      	cmp	r6, #64	; 0x40
c0d01dea:	d806      	bhi.n	c0d01dfa <u2f_handle_sign+0x22>
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
c0d01dec:	4669      	mov	r1, sp
c0d01dee:	600a      	str	r2, [r1, #0]
c0d01df0:	4a27      	ldr	r2, [pc, #156]	; (c0d01e90 <PROXY_MAGIC+0x8>)
c0d01df2:	447a      	add	r2, pc
c0d01df4:	2302      	movs	r3, #2
c0d01df6:	4621      	mov	r1, r4
c0d01df8:	e041      	b.n	c0d01e7e <u2f_handle_sign+0xa6>
                                     (uint8_t *)SW_WRONG_LENGTH,
                                     sizeof(SW_WRONG_LENGTH), true);
        return;
    }
    if ((p1 != P1_SIGN_CHECK_ONLY) && (p1 != P1_SIGN_SIGN)) {
c0d01dfa:	2504      	movs	r5, #4
c0d01dfc:	4329      	orrs	r1, r5
c0d01dfe:	2907      	cmp	r1, #7
c0d01e00:	d12f      	bne.n	c0d01e62 <u2f_handle_sign+0x8a>
c0d01e02:	9605      	str	r6, [sp, #20]
c0d01e04:	9202      	str	r2, [sp, #8]
c0d01e06:	9403      	str	r4, [sp, #12]
c0d01e08:	9004      	str	r0, [sp, #16]
        u2f_response_error(service, ERROR_PROP_INVALID_PARAMETERS_APDU, true,
                           service->channel);
        return;
    }

    keyHandleLength = buffer[64];
c0d01e0a:	2040      	movs	r0, #64	; 0x40
c0d01e0c:	9306      	str	r3, [sp, #24]
    for (i = 0; i < keyHandleLength; i++) {
c0d01e0e:	5c1c      	ldrb	r4, [r3, r0]
c0d01e10:	2c00      	cmp	r4, #0
c0d01e12:	d00d      	beq.n	c0d01e30 <u2f_handle_sign+0x58>
        buffer[65 + i] ^= PROXY_MAGIC[i % sizeof(PROXY_MAGIC)];
c0d01e14:	9e06      	ldr	r6, [sp, #24]
c0d01e16:	3641      	adds	r6, #65	; 0x41
c0d01e18:	a51b      	add	r5, pc, #108	; (adr r5, c0d01e88 <PROXY_MAGIC>)
c0d01e1a:	b2f8      	uxtb	r0, r7
c0d01e1c:	2103      	movs	r1, #3
c0d01e1e:	f001 fb31 	bl	c0d03484 <__aeabi_uidivmod>
c0d01e22:	5df0      	ldrb	r0, [r6, r7]
c0d01e24:	5c69      	ldrb	r1, [r5, r1]
c0d01e26:	4041      	eors	r1, r0
c0d01e28:	55f1      	strb	r1, [r6, r7]
                           service->channel);
        return;
    }

    keyHandleLength = buffer[64];
    for (i = 0; i < keyHandleLength; i++) {
c0d01e2a:	1c7f      	adds	r7, r7, #1
c0d01e2c:	42bc      	cmp	r4, r7
c0d01e2e:	d1f4      	bne.n	c0d01e1a <u2f_handle_sign+0x42>
        buffer[65 + i] ^= PROXY_MAGIC[i % sizeof(PROXY_MAGIC)];
    }
    // Check magic
    if (length != (32 + 32 + 1 + 5 + buffer[65 + 4])) {
c0d01e30:	2045      	movs	r0, #69	; 0x45
c0d01e32:	9906      	ldr	r1, [sp, #24]
c0d01e34:	5c08      	ldrb	r0, [r1, r0]
c0d01e36:	3046      	adds	r0, #70	; 0x46
c0d01e38:	9a05      	ldr	r2, [sp, #20]
c0d01e3a:	4282      	cmp	r2, r0
c0d01e3c:	d117      	bne.n	c0d01e6e <u2f_handle_sign+0x96>
                                     (uint8_t *)SW_BAD_KEY_HANDLE,
                                     sizeof(SW_BAD_KEY_HANDLE), true);
        return;
    }
    // Check that it looks like an APDU
    os_memmove(G_io_apdu_buffer, buffer + 65, keyHandleLength);
c0d01e3e:	3141      	adds	r1, #65	; 0x41
c0d01e40:	4812      	ldr	r0, [pc, #72]	; (c0d01e8c <PROXY_MAGIC+0x4>)
c0d01e42:	4622      	mov	r2, r4
c0d01e44:	f7fe ffa7 	bl	c0d00d96 <os_memmove>
c0d01e48:	a808      	add	r0, sp, #32
c0d01e4a:	a907      	add	r1, sp, #28
    handleApdu(&flags, &tx);
c0d01e4c:	f7fe fb16 	bl	c0d0047c <handleApdu>
    if ((flags & IO_ASYNCH_REPLY) == 0) {
c0d01e50:	2010      	movs	r0, #16
c0d01e52:	9908      	ldr	r1, [sp, #32]
c0d01e54:	4201      	tst	r1, r0
c0d01e56:	d114      	bne.n	c0d01e82 <u2f_handle_sign+0xaa>
        u2f_proxy_response(service, tx);
c0d01e58:	9907      	ldr	r1, [sp, #28]
c0d01e5a:	9804      	ldr	r0, [sp, #16]
c0d01e5c:	f7fe f932 	bl	c0d000c4 <u2f_proxy_response>
c0d01e60:	e00f      	b.n	c0d01e82 <u2f_handle_sign+0xaa>
                                     (uint8_t *)SW_WRONG_LENGTH,
                                     sizeof(SW_WRONG_LENGTH), true);
        return;
    }
    if ((p1 != P1_SIGN_CHECK_ONLY) && (p1 != P1_SIGN_SIGN)) {
        u2f_response_error(service, ERROR_PROP_INVALID_PARAMETERS_APDU, true,
c0d01e62:	1de1      	adds	r1, r4, #7
c0d01e64:	b2c9      	uxtb	r1, r1
c0d01e66:	4603      	mov	r3, r0
c0d01e68:	f000 fb64 	bl	c0d02534 <u2f_response_error>
c0d01e6c:	e009      	b.n	c0d01e82 <u2f_handle_sign+0xaa>
    for (i = 0; i < keyHandleLength; i++) {
        buffer[65 + i] ^= PROXY_MAGIC[i % sizeof(PROXY_MAGIC)];
    }
    // Check magic
    if (length != (32 + 32 + 1 + 5 + buffer[65 + 4])) {
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
c0d01e6e:	4668      	mov	r0, sp
c0d01e70:	9902      	ldr	r1, [sp, #8]
c0d01e72:	6001      	str	r1, [r0, #0]
c0d01e74:	4a07      	ldr	r2, [pc, #28]	; (c0d01e94 <PROXY_MAGIC+0xc>)
c0d01e76:	447a      	add	r2, pc
c0d01e78:	2302      	movs	r3, #2
c0d01e7a:	9804      	ldr	r0, [sp, #16]
c0d01e7c:	9903      	ldr	r1, [sp, #12]
c0d01e7e:	f000 f962 	bl	c0d02146 <u2f_send_fragmented_response>
    os_memmove(G_io_apdu_buffer, buffer + 65, keyHandleLength);
    handleApdu(&flags, &tx);
    if ((flags & IO_ASYNCH_REPLY) == 0) {
        u2f_proxy_response(service, tx);
    }
}
c0d01e82:	b009      	add	sp, #36	; 0x24
c0d01e84:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d01e86:	46c0      	nop			; (mov r8, r8)

c0d01e88 <PROXY_MAGIC>:
c0d01e88:	00773077 	.word	0x00773077
c0d01e8c:	20001dbc 	.word	0x20001dbc
c0d01e90:	00001e42 	.word	0x00001e42
c0d01e94:	00001dc2 	.word	0x00001dc2

c0d01e98 <u2f_handle_get_version>:

void u2f_handle_get_version(u2f_service_t *service, uint8_t p1, uint8_t p2,
                            uint8_t *buffer, uint16_t length) {
c0d01e98:	b580      	push	{r7, lr}
c0d01e9a:	b082      	sub	sp, #8
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
                                     (uint8_t *)SW_WRONG_LENGTH,
                                     sizeof(SW_WRONG_LENGTH), true);
        return;
    }
    u2f_send_fragmented_response(service, U2F_CMD_MSG, (uint8_t *)VERSION,
c0d01e9c:	2201      	movs	r2, #1
c0d01e9e:	2183      	movs	r1, #131	; 0x83
c0d01ea0:	9b04      	ldr	r3, [sp, #16]
                            uint8_t *buffer, uint16_t length) {
    // screen_printf("U2F version\n");
    (void)p1;
    (void)p2;
    (void)buffer;
    if (length != 0) {
c0d01ea2:	2b00      	cmp	r3, #0
c0d01ea4:	d005      	beq.n	c0d01eb2 <u2f_handle_get_version+0x1a>
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
c0d01ea6:	466b      	mov	r3, sp
c0d01ea8:	601a      	str	r2, [r3, #0]
c0d01eaa:	4a06      	ldr	r2, [pc, #24]	; (c0d01ec4 <u2f_handle_get_version+0x2c>)
c0d01eac:	447a      	add	r2, pc
c0d01eae:	2302      	movs	r3, #2
c0d01eb0:	e004      	b.n	c0d01ebc <u2f_handle_get_version+0x24>
                                     (uint8_t *)SW_WRONG_LENGTH,
                                     sizeof(SW_WRONG_LENGTH), true);
        return;
    }
    u2f_send_fragmented_response(service, U2F_CMD_MSG, (uint8_t *)VERSION,
c0d01eb2:	466b      	mov	r3, sp
c0d01eb4:	601a      	str	r2, [r3, #0]
c0d01eb6:	4a04      	ldr	r2, [pc, #16]	; (c0d01ec8 <u2f_handle_get_version+0x30>)
c0d01eb8:	447a      	add	r2, pc
c0d01eba:	2308      	movs	r3, #8
c0d01ebc:	f000 f943 	bl	c0d02146 <u2f_send_fragmented_response>
                                 sizeof(VERSION), true);
}
c0d01ec0:	b002      	add	sp, #8
c0d01ec2:	bd80      	pop	{r7, pc}
c0d01ec4:	00001d88 	.word	0x00001d88
c0d01ec8:	00001d82 	.word	0x00001d82

c0d01ecc <u2f_handle_cmd_init>:

void u2f_handle_cmd_init(u2f_service_t *service, uint8_t *buffer,
                         uint16_t length, uint8_t *channelInit) {
c0d01ecc:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d01ece:	b083      	sub	sp, #12
c0d01ed0:	461e      	mov	r6, r3
c0d01ed2:	460f      	mov	r7, r1
c0d01ed4:	4604      	mov	r4, r0
    // screen_printf("U2F init\n");
    uint8_t channel[4];
    (void)length;
    uint16_t offset = 0;
    if (u2f_is_channel_forbidden(channelInit)) {
c0d01ed6:	4630      	mov	r0, r6
c0d01ed8:	f000 fb76 	bl	c0d025c8 <u2f_is_channel_forbidden>
        os_memset(service->channel, 0xff, 4);
    } else {
        os_memmove(service->channel, channel, 4);
    }
    service->keepUserPresence = true;
    u2f_send_fragmented_response(service, U2F_CMD_INIT, service->messageBuffer,
c0d01edc:	2501      	movs	r5, #1
                         uint16_t length, uint8_t *channelInit) {
    // screen_printf("U2F init\n");
    uint8_t channel[4];
    (void)length;
    uint16_t offset = 0;
    if (u2f_is_channel_forbidden(channelInit)) {
c0d01ede:	2801      	cmp	r0, #1
c0d01ee0:	d106      	bne.n	c0d01ef0 <u2f_handle_cmd_init+0x24>
        u2f_response_error(service, ERROR_INVALID_CID, true, channelInit);
c0d01ee2:	210b      	movs	r1, #11
c0d01ee4:	4620      	mov	r0, r4
c0d01ee6:	462a      	mov	r2, r5
c0d01ee8:	4633      	mov	r3, r6
c0d01eea:	f000 fb23 	bl	c0d02534 <u2f_response_error>
c0d01eee:	e043      	b.n	c0d01f78 <u2f_handle_cmd_init+0xac>
        return;
    }
    if (u2f_is_channel_broadcast(channelInit)) {
c0d01ef0:	4630      	mov	r0, r6
c0d01ef2:	f000 fb59 	bl	c0d025a8 <u2f_is_channel_broadcast>
c0d01ef6:	2801      	cmp	r0, #1
c0d01ef8:	d104      	bne.n	c0d01f04 <u2f_handle_cmd_init+0x38>
c0d01efa:	a802      	add	r0, sp, #8
        cx_rng(channel, 4);
c0d01efc:	2104      	movs	r1, #4
c0d01efe:	f7ff fe45 	bl	c0d01b8c <cx_rng>
c0d01f02:	e004      	b.n	c0d01f0e <u2f_handle_cmd_init+0x42>
c0d01f04:	a802      	add	r0, sp, #8
    } else {
        os_memmove(channel, channelInit, 4);
c0d01f06:	2204      	movs	r2, #4
c0d01f08:	4631      	mov	r1, r6
c0d01f0a:	f7fe ff44 	bl	c0d00d96 <os_memmove>
    }
    os_memmove(service->messageBuffer + offset, buffer, 8);
c0d01f0e:	6d20      	ldr	r0, [r4, #80]	; 0x50
c0d01f10:	2208      	movs	r2, #8
c0d01f12:	4639      	mov	r1, r7
c0d01f14:	f7fe ff3f 	bl	c0d00d96 <os_memmove>
    offset += 8;
    os_memmove(service->messageBuffer + offset, channel, 4);
c0d01f18:	6d20      	ldr	r0, [r4, #80]	; 0x50
c0d01f1a:	3008      	adds	r0, #8
c0d01f1c:	a902      	add	r1, sp, #8
c0d01f1e:	2204      	movs	r2, #4
c0d01f20:	f7fe ff39 	bl	c0d00d96 <os_memmove>
    offset += 4;
    service->messageBuffer[offset++] = INIT_U2F_VERSION;
c0d01f24:	6d20      	ldr	r0, [r4, #80]	; 0x50
c0d01f26:	2102      	movs	r1, #2
c0d01f28:	7301      	strb	r1, [r0, #12]
    service->messageBuffer[offset++] = INIT_DEVICE_VERSION_MAJOR;
c0d01f2a:	6d20      	ldr	r0, [r4, #80]	; 0x50
c0d01f2c:	2100      	movs	r1, #0
c0d01f2e:	7341      	strb	r1, [r0, #13]
    service->messageBuffer[offset++] = INIT_DEVICE_VERSION_MINOR;
c0d01f30:	6d20      	ldr	r0, [r4, #80]	; 0x50
c0d01f32:	2201      	movs	r2, #1
c0d01f34:	7382      	strb	r2, [r0, #14]
    service->messageBuffer[offset++] = INIT_BUILD_VERSION;
c0d01f36:	6d20      	ldr	r0, [r4, #80]	; 0x50
c0d01f38:	73c1      	strb	r1, [r0, #15]
    service->messageBuffer[offset++] = INIT_CAPABILITIES;
c0d01f3a:	6d20      	ldr	r0, [r4, #80]	; 0x50
c0d01f3c:	7401      	strb	r1, [r0, #16]
    if (u2f_is_channel_broadcast(channelInit)) {
c0d01f3e:	4630      	mov	r0, r6
c0d01f40:	f000 fb32 	bl	c0d025a8 <u2f_is_channel_broadcast>
        os_memset(service->channel, 0xff, 4);
c0d01f44:	2686      	movs	r6, #134	; 0x86
    service->messageBuffer[offset++] = INIT_U2F_VERSION;
    service->messageBuffer[offset++] = INIT_DEVICE_VERSION_MAJOR;
    service->messageBuffer[offset++] = INIT_DEVICE_VERSION_MINOR;
    service->messageBuffer[offset++] = INIT_BUILD_VERSION;
    service->messageBuffer[offset++] = INIT_CAPABILITIES;
    if (u2f_is_channel_broadcast(channelInit)) {
c0d01f46:	2801      	cmp	r0, #1
c0d01f48:	d107      	bne.n	c0d01f5a <u2f_handle_cmd_init+0x8e>
        os_memset(service->channel, 0xff, 4);
c0d01f4a:	4630      	mov	r0, r6
c0d01f4c:	3079      	adds	r0, #121	; 0x79
c0d01f4e:	b2c1      	uxtb	r1, r0
c0d01f50:	2204      	movs	r2, #4
c0d01f52:	4620      	mov	r0, r4
c0d01f54:	f7fe ff16 	bl	c0d00d84 <os_memset>
c0d01f58:	e004      	b.n	c0d01f64 <u2f_handle_cmd_init+0x98>
c0d01f5a:	a902      	add	r1, sp, #8
    } else {
        os_memmove(service->channel, channel, 4);
c0d01f5c:	2204      	movs	r2, #4
c0d01f5e:	4620      	mov	r0, r4
c0d01f60:	f7fe ff19 	bl	c0d00d96 <os_memmove>
    }
    service->keepUserPresence = true;
c0d01f64:	2001      	movs	r0, #1
c0d01f66:	76e0      	strb	r0, [r4, #27]
    u2f_send_fragmented_response(service, U2F_CMD_INIT, service->messageBuffer,
c0d01f68:	6d22      	ldr	r2, [r4, #80]	; 0x50
c0d01f6a:	4668      	mov	r0, sp
c0d01f6c:	6005      	str	r5, [r0, #0]
c0d01f6e:	2311      	movs	r3, #17
c0d01f70:	4620      	mov	r0, r4
c0d01f72:	4631      	mov	r1, r6
c0d01f74:	f000 f8e7 	bl	c0d02146 <u2f_send_fragmented_response>
                                 offset, true);
    // os_memmove(service->channel, channel, 4);
}
c0d01f78:	b003      	add	sp, #12
c0d01f7a:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d01f7c <u2f_handle_cmd_msg>:
    // screen_printf("U2F ping\n");
    u2f_send_fragmented_response(service, U2F_CMD_PING, buffer, length, true);
}

void u2f_handle_cmd_msg(u2f_service_t *service, uint8_t *buffer,
                        uint16_t length) {
c0d01f7c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d01f7e:	b085      	sub	sp, #20
c0d01f80:	9004      	str	r0, [sp, #16]
    // screen_printf("U2F msg\n");
    uint8_t cla = buffer[0];
    uint8_t ins = buffer[1];
    uint8_t p1 = buffer[2];
    uint8_t p2 = buffer[3];
    uint32_t dataLength = (buffer[4] << 16) | (buffer[5] << 8) | (buffer[6]);
c0d01f82:	790b      	ldrb	r3, [r1, #4]
c0d01f84:	041b      	lsls	r3, r3, #16
c0d01f86:	794c      	ldrb	r4, [r1, #5]
c0d01f88:	0224      	lsls	r4, r4, #8
c0d01f8a:	431c      	orrs	r4, r3
c0d01f8c:	798b      	ldrb	r3, [r1, #6]
c0d01f8e:	4323      	orrs	r3, r4
c0d01f90:	4f27      	ldr	r7, [pc, #156]	; (c0d02030 <u2f_handle_cmd_msg+0xb4>)
    if ((dataLength != (uint16_t)(length - 9)) &&
c0d01f92:	19d2      	adds	r2, r2, r7
c0d01f94:	3708      	adds	r7, #8
c0d01f96:	4614      	mov	r4, r2
c0d01f98:	403c      	ands	r4, r7
void u2f_handle_cmd_msg(u2f_service_t *service, uint8_t *buffer,
                        uint16_t length) {
    // screen_printf("U2F msg\n");
    uint8_t cla = buffer[0];
    uint8_t ins = buffer[1];
    uint8_t p1 = buffer[2];
c0d01f9a:	7888      	ldrb	r0, [r1, #2]

void u2f_handle_cmd_msg(u2f_service_t *service, uint8_t *buffer,
                        uint16_t length) {
    // screen_printf("U2F msg\n");
    uint8_t cla = buffer[0];
    uint8_t ins = buffer[1];
c0d01f9c:	9002      	str	r0, [sp, #8]
c0d01f9e:	784e      	ldrb	r6, [r1, #1]
}

void u2f_handle_cmd_msg(u2f_service_t *service, uint8_t *buffer,
                        uint16_t length) {
    // screen_printf("U2F msg\n");
    uint8_t cla = buffer[0];
c0d01fa0:	780d      	ldrb	r5, [r1, #0]
        // screen_printf("version\n");
        u2f_handle_get_version(service, p1, p2, buffer + 7, dataLength);
        break;
    default:
        // screen_printf("unsupported\n");
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
c0d01fa2:	2001      	movs	r0, #1
c0d01fa4:	9003      	str	r0, [sp, #12]
c0d01fa6:	2083      	movs	r0, #131	; 0x83
    uint8_t cla = buffer[0];
    uint8_t ins = buffer[1];
    uint8_t p1 = buffer[2];
    uint8_t p2 = buffer[3];
    uint32_t dataLength = (buffer[4] << 16) | (buffer[5] << 8) | (buffer[6]);
    if ((dataLength != (uint16_t)(length - 9)) &&
c0d01fa8:	42a3      	cmp	r3, r4
c0d01faa:	d003      	beq.n	c0d01fb4 <u2f_handle_cmd_msg+0x38>
        (dataLength != (uint16_t)(length - 7))) { // Le is optional
c0d01fac:	1c92      	adds	r2, r2, #2
c0d01fae:	403a      	ands	r2, r7
    uint8_t cla = buffer[0];
    uint8_t ins = buffer[1];
    uint8_t p1 = buffer[2];
    uint8_t p2 = buffer[3];
    uint32_t dataLength = (buffer[4] << 16) | (buffer[5] << 8) | (buffer[6]);
    if ((dataLength != (uint16_t)(length - 9)) &&
c0d01fb0:	4293      	cmp	r3, r2
c0d01fb2:	d117      	bne.n	c0d01fe4 <u2f_handle_cmd_msg+0x68>
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
                                     (uint8_t *)SW_WRONG_LENGTH,
                                     sizeof(SW_WRONG_LENGTH), true);
        return;
    }
    if (cla != FIDO_CLA) {
c0d01fb4:	2d00      	cmp	r5, #0
c0d01fb6:	d005      	beq.n	c0d01fc4 <u2f_handle_cmd_msg+0x48>
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
c0d01fb8:	4669      	mov	r1, sp
c0d01fba:	9a03      	ldr	r2, [sp, #12]
c0d01fbc:	600a      	str	r2, [r1, #0]
c0d01fbe:	4a1e      	ldr	r2, [pc, #120]	; (c0d02038 <u2f_handle_cmd_msg+0xbc>)
c0d01fc0:	447a      	add	r2, pc
c0d01fc2:	e014      	b.n	c0d01fee <u2f_handle_cmd_msg+0x72>
                                     (uint8_t *)SW_UNKNOWN_CLASS,
                                     sizeof(SW_UNKNOWN_CLASS), true);
        return;
    }
    switch (ins) {
c0d01fc4:	2e03      	cmp	r6, #3
c0d01fc6:	d019      	beq.n	c0d01ffc <u2f_handle_cmd_msg+0x80>
c0d01fc8:	2e02      	cmp	r6, #2
c0d01fca:	d020      	beq.n	c0d0200e <u2f_handle_cmd_msg+0x92>
c0d01fcc:	4601      	mov	r1, r0
c0d01fce:	2e01      	cmp	r6, #1
c0d01fd0:	9804      	ldr	r0, [sp, #16]
c0d01fd2:	d126      	bne.n	c0d02022 <u2f_handle_cmd_msg+0xa6>
    case FIDO_INS_ENROLL:
        // screen_printf("enroll\n");
        u2f_handle_enroll(service, p1, p2, buffer + 7, dataLength);
c0d01fd4:	b29a      	uxth	r2, r3
c0d01fd6:	4669      	mov	r1, sp
c0d01fd8:	600a      	str	r2, [r1, #0]
c0d01fda:	2100      	movs	r1, #0
c0d01fdc:	460a      	mov	r2, r1
c0d01fde:	f7ff fee1 	bl	c0d01da4 <u2f_handle_enroll>
c0d01fe2:	e009      	b.n	c0d01ff8 <u2f_handle_cmd_msg+0x7c>
    uint8_t p1 = buffer[2];
    uint8_t p2 = buffer[3];
    uint32_t dataLength = (buffer[4] << 16) | (buffer[5] << 8) | (buffer[6]);
    if ((dataLength != (uint16_t)(length - 9)) &&
        (dataLength != (uint16_t)(length - 7))) { // Le is optional
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
c0d01fe4:	4669      	mov	r1, sp
c0d01fe6:	9a03      	ldr	r2, [sp, #12]
c0d01fe8:	600a      	str	r2, [r1, #0]
c0d01fea:	4a12      	ldr	r2, [pc, #72]	; (c0d02034 <u2f_handle_cmd_msg+0xb8>)
c0d01fec:	447a      	add	r2, pc
c0d01fee:	2302      	movs	r3, #2
c0d01ff0:	4601      	mov	r1, r0
c0d01ff2:	9804      	ldr	r0, [sp, #16]
c0d01ff4:	f000 f8a7 	bl	c0d02146 <u2f_send_fragmented_response>
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
                                     (uint8_t *)SW_UNKNOWN_INSTRUCTION,
                                     sizeof(SW_UNKNOWN_INSTRUCTION), true);
        return;
    }
}
c0d01ff8:	b005      	add	sp, #20
c0d01ffa:	bdf0      	pop	{r4, r5, r6, r7, pc}
        // screen_printf("sign\n");
        u2f_handle_sign(service, p1, p2, buffer + 7, dataLength);
        break;
    case FIDO_INS_GET_VERSION:
        // screen_printf("version\n");
        u2f_handle_get_version(service, p1, p2, buffer + 7, dataLength);
c0d01ffc:	b298      	uxth	r0, r3
c0d01ffe:	4669      	mov	r1, sp
c0d02000:	6008      	str	r0, [r1, #0]
c0d02002:	2100      	movs	r1, #0
c0d02004:	9804      	ldr	r0, [sp, #16]
c0d02006:	460a      	mov	r2, r1
c0d02008:	f7ff ff46 	bl	c0d01e98 <u2f_handle_get_version>
c0d0200c:	e7f4      	b.n	c0d01ff8 <u2f_handle_cmd_msg+0x7c>
        // screen_printf("enroll\n");
        u2f_handle_enroll(service, p1, p2, buffer + 7, dataLength);
        break;
    case FIDO_INS_SIGN:
        // screen_printf("sign\n");
        u2f_handle_sign(service, p1, p2, buffer + 7, dataLength);
c0d0200e:	b298      	uxth	r0, r3
c0d02010:	466a      	mov	r2, sp
c0d02012:	6010      	str	r0, [r2, #0]
c0d02014:	1dcb      	adds	r3, r1, #7
c0d02016:	2200      	movs	r2, #0
c0d02018:	9804      	ldr	r0, [sp, #16]
c0d0201a:	9902      	ldr	r1, [sp, #8]
c0d0201c:	f7ff fedc 	bl	c0d01dd8 <u2f_handle_sign>
c0d02020:	e7ea      	b.n	c0d01ff8 <u2f_handle_cmd_msg+0x7c>
        // screen_printf("version\n");
        u2f_handle_get_version(service, p1, p2, buffer + 7, dataLength);
        break;
    default:
        // screen_printf("unsupported\n");
        u2f_send_fragmented_response(service, U2F_CMD_MSG,
c0d02022:	466a      	mov	r2, sp
c0d02024:	9b03      	ldr	r3, [sp, #12]
c0d02026:	6013      	str	r3, [r2, #0]
c0d02028:	4a04      	ldr	r2, [pc, #16]	; (c0d0203c <u2f_handle_cmd_msg+0xc0>)
c0d0202a:	447a      	add	r2, pc
c0d0202c:	2302      	movs	r3, #2
c0d0202e:	e7e1      	b.n	c0d01ff4 <u2f_handle_cmd_msg+0x78>
c0d02030:	0000fff7 	.word	0x0000fff7
c0d02034:	00001c48 	.word	0x00001c48
c0d02038:	00001c82 	.word	0x00001c82
c0d0203c:	00001c1a 	.word	0x00001c1a

c0d02040 <u2f_process_message>:
        return;
    }
}

void u2f_process_message(u2f_service_t *service, uint8_t *buffer,
                         uint8_t *channel) {
c0d02040:	b510      	push	{r4, lr}
c0d02042:	b082      	sub	sp, #8
c0d02044:	4614      	mov	r4, r2
    uint8_t cmd = buffer[0];
    uint16_t length = (buffer[1] << 8) | (buffer[2]);
c0d02046:	788a      	ldrb	r2, [r1, #2]
c0d02048:	784b      	ldrb	r3, [r1, #1]
c0d0204a:	021b      	lsls	r3, r3, #8
c0d0204c:	4313      	orrs	r3, r2
    }
}

void u2f_process_message(u2f_service_t *service, uint8_t *buffer,
                         uint8_t *channel) {
    uint8_t cmd = buffer[0];
c0d0204e:	780a      	ldrb	r2, [r1, #0]
    uint16_t length = (buffer[1] << 8) | (buffer[2]);
    switch (cmd) {
c0d02050:	2a81      	cmp	r2, #129	; 0x81
c0d02052:	d009      	beq.n	c0d02068 <u2f_process_message+0x28>
c0d02054:	2a83      	cmp	r2, #131	; 0x83
c0d02056:	d012      	beq.n	c0d0207e <u2f_process_message+0x3e>
c0d02058:	2a86      	cmp	r2, #134	; 0x86
c0d0205a:	d126      	bne.n	c0d020aa <u2f_process_message+0x6a>
    case U2F_CMD_INIT:
        u2f_handle_cmd_init(service, buffer + 3, length, channel);
c0d0205c:	1cc9      	adds	r1, r1, #3
c0d0205e:	2200      	movs	r2, #0
c0d02060:	4623      	mov	r3, r4
c0d02062:	f7ff ff33 	bl	c0d01ecc <u2f_handle_cmd_init>
c0d02066:	e020      	b.n	c0d020aa <u2f_process_message+0x6a>
        break;
    case U2F_CMD_PING:
        service->pendingContinuation = false;
c0d02068:	2230      	movs	r2, #48	; 0x30
c0d0206a:	2400      	movs	r4, #0
c0d0206c:	5484      	strb	r4, [r0, r2]
}

void u2f_handle_cmd_ping(u2f_service_t *service, uint8_t *buffer,
                         uint16_t length) {
    // screen_printf("U2F ping\n");
    u2f_send_fragmented_response(service, U2F_CMD_PING, buffer, length, true);
c0d0206e:	2201      	movs	r2, #1
c0d02070:	466c      	mov	r4, sp
c0d02072:	6022      	str	r2, [r4, #0]
    case U2F_CMD_INIT:
        u2f_handle_cmd_init(service, buffer + 3, length, channel);
        break;
    case U2F_CMD_PING:
        service->pendingContinuation = false;
        u2f_handle_cmd_ping(service, buffer + 3, length);
c0d02074:	1cca      	adds	r2, r1, #3
}

void u2f_handle_cmd_ping(u2f_service_t *service, uint8_t *buffer,
                         uint16_t length) {
    // screen_printf("U2F ping\n");
    u2f_send_fragmented_response(service, U2F_CMD_PING, buffer, length, true);
c0d02076:	2181      	movs	r1, #129	; 0x81
c0d02078:	f000 f865 	bl	c0d02146 <u2f_send_fragmented_response>
c0d0207c:	e015      	b.n	c0d020aa <u2f_process_message+0x6a>
    case U2F_CMD_PING:
        service->pendingContinuation = false;
        u2f_handle_cmd_ping(service, buffer + 3, length);
        break;
    case U2F_CMD_MSG:
        service->pendingContinuation = false;
c0d0207e:	2230      	movs	r2, #48	; 0x30
c0d02080:	2400      	movs	r4, #0
c0d02082:	5484      	strb	r4, [r0, r2]
        if (!service->noReentry && service->runningCommand) {
c0d02084:	225c      	movs	r2, #92	; 0x5c
c0d02086:	5c82      	ldrb	r2, [r0, r2]
c0d02088:	2a00      	cmp	r2, #0
c0d0208a:	d006      	beq.n	c0d0209a <u2f_process_message+0x5a>
            u2f_response_error(service, ERROR_CHANNEL_BUSY, false,
                               service->channel);
            break;
        }
        service->runningCommand = true;
c0d0208c:	2201      	movs	r2, #1
c0d0208e:	7402      	strb	r2, [r0, #16]
        u2f_handle_cmd_msg(service, buffer + 3, length);
c0d02090:	1cc9      	adds	r1, r1, #3
c0d02092:	461a      	mov	r2, r3
c0d02094:	f7ff ff72 	bl	c0d01f7c <u2f_handle_cmd_msg>
c0d02098:	e007      	b.n	c0d020aa <u2f_process_message+0x6a>
        service->pendingContinuation = false;
        u2f_handle_cmd_ping(service, buffer + 3, length);
        break;
    case U2F_CMD_MSG:
        service->pendingContinuation = false;
        if (!service->noReentry && service->runningCommand) {
c0d0209a:	7c02      	ldrb	r2, [r0, #16]
c0d0209c:	2a00      	cmp	r2, #0
c0d0209e:	d0f5      	beq.n	c0d0208c <u2f_process_message+0x4c>
            u2f_response_error(service, ERROR_CHANNEL_BUSY, false,
c0d020a0:	2106      	movs	r1, #6
c0d020a2:	2200      	movs	r2, #0
c0d020a4:	4603      	mov	r3, r0
c0d020a6:	f000 fa45 	bl	c0d02534 <u2f_response_error>
        }
        service->runningCommand = true;
        u2f_handle_cmd_msg(service, buffer + 3, length);
        break;
    }
}
c0d020aa:	b002      	add	sp, #8
c0d020ac:	bd10      	pop	{r4, pc}

c0d020ae <u2f_timeout>:

void u2f_timeout(u2f_service_t *service) {
c0d020ae:	b580      	push	{r7, lr}
    service->timerNeedGeneralStatus = true;
c0d020b0:	2128      	movs	r1, #40	; 0x28
c0d020b2:	2201      	movs	r2, #1
c0d020b4:	5442      	strb	r2, [r0, r1]
    if ((service->transportMedia == U2F_MEDIA_USB) &&
c0d020b6:	7ac1      	ldrb	r1, [r0, #11]
c0d020b8:	2901      	cmp	r1, #1
c0d020ba:	d114      	bne.n	c0d020e6 <u2f_timeout+0x38>
        (service->pendingContinuation)) {
c0d020bc:	2130      	movs	r1, #48	; 0x30
c0d020be:	5c42      	ldrb	r2, [r0, r1]
c0d020c0:	4601      	mov	r1, r0
c0d020c2:	3130      	adds	r1, #48	; 0x30
    }
}

void u2f_timeout(u2f_service_t *service) {
    service->timerNeedGeneralStatus = true;
    if ((service->transportMedia == U2F_MEDIA_USB) &&
c0d020c4:	2a00      	cmp	r2, #0
c0d020c6:	d00e      	beq.n	c0d020e6 <u2f_timeout+0x38>
        (service->pendingContinuation)) {
        service->seqTimeout += service->timerInterval;
c0d020c8:	6a42      	ldr	r2, [r0, #36]	; 0x24
c0d020ca:	6ac3      	ldr	r3, [r0, #44]	; 0x2c
c0d020cc:	189a      	adds	r2, r3, r2
c0d020ce:	62c2      	str	r2, [r0, #44]	; 0x2c
        if (service->seqTimeout > MAX_SEQ_TIMEOUT_MS) {
c0d020d0:	23ff      	movs	r3, #255	; 0xff
c0d020d2:	33f6      	adds	r3, #246	; 0xf6
c0d020d4:	429a      	cmp	r2, r3
c0d020d6:	d306      	bcc.n	c0d020e6 <u2f_timeout+0x38>
            service->pendingContinuation = false;
c0d020d8:	2200      	movs	r2, #0
c0d020da:	700a      	strb	r2, [r1, #0]
            u2f_response_error(service, ERROR_MSG_TIMEOUT, true,
                               service->lastContinuationChannel);
c0d020dc:	1d03      	adds	r3, r0, #4
    if ((service->transportMedia == U2F_MEDIA_USB) &&
        (service->pendingContinuation)) {
        service->seqTimeout += service->timerInterval;
        if (service->seqTimeout > MAX_SEQ_TIMEOUT_MS) {
            service->pendingContinuation = false;
            u2f_response_error(service, ERROR_MSG_TIMEOUT, true,
c0d020de:	2105      	movs	r1, #5
c0d020e0:	2201      	movs	r2, #1
c0d020e2:	f000 fa27 	bl	c0d02534 <u2f_response_error>
                                         sizeof(NOTIFY_USER_PRESENCE_NEEDED),
                                         false);
        }
    }
#endif
}
c0d020e6:	bd80      	pop	{r7, pc}

c0d020e8 <u2f_reset>:
#include "u2f_timer.h"

// not too fast blinking
#define DEFAULT_TIMER_INTERVAL_MS 500

void u2f_reset(u2f_service_t *service, bool keepUserPresence) {
c0d020e8:	2100      	movs	r1, #0
    service->transportState = U2F_IDLE;
c0d020ea:	7281      	strb	r1, [r0, #10]
    service->runningCommand = false;
c0d020ec:	7401      	strb	r1, [r0, #16]
    // service->promptUserPresence = false;
    if (service->keepUserPresence) {
c0d020ee:	7ec2      	ldrb	r2, [r0, #27]
c0d020f0:	2a00      	cmp	r2, #0
c0d020f2:	d000      	beq.n	c0d020f6 <u2f_reset+0xe>
        keepUserPresence = true;
        service->keepUserPresence = false;
c0d020f4:	76c1      	strb	r1, [r0, #27]
    }
#ifdef HAVE_NO_USER_PRESENCE_CHECK
    service->keepUserPresence = true;
    service->userPresence = true;
#endif // HAVE_NO_USER_PRESENCE_CHECK
}
c0d020f6:	4770      	bx	lr

c0d020f8 <u2f_initialize_service>:

void u2f_initialize_service(u2f_service_t *service) {
    service->handleFunction = (u2fHandle_t)u2f_process_message;
c0d020f8:	4908      	ldr	r1, [pc, #32]	; (c0d0211c <u2f_initialize_service+0x24>)
c0d020fa:	4479      	add	r1, pc
c0d020fc:	6141      	str	r1, [r0, #20]
    service->timeoutFunction = (u2fTimer_t)u2f_timeout;
c0d020fe:	4908      	ldr	r1, [pc, #32]	; (c0d02120 <u2f_initialize_service+0x28>)
c0d02100:	4479      	add	r1, pc
    service->timerInterval = DEFAULT_TIMER_INTERVAL_MS;
c0d02102:	227d      	movs	r2, #125	; 0x7d
c0d02104:	0092      	lsls	r2, r2, #2
#endif // HAVE_NO_USER_PRESENCE_CHECK
}

void u2f_initialize_service(u2f_service_t *service) {
    service->handleFunction = (u2fHandle_t)u2f_process_message;
    service->timeoutFunction = (u2fTimer_t)u2f_timeout;
c0d02106:	6201      	str	r1, [r0, #32]
    service->timerInterval = DEFAULT_TIMER_INTERVAL_MS;
c0d02108:	6242      	str	r2, [r0, #36]	; 0x24
c0d0210a:	2100      	movs	r1, #0

// not too fast blinking
#define DEFAULT_TIMER_INTERVAL_MS 500

void u2f_reset(u2f_service_t *service, bool keepUserPresence) {
    service->transportState = U2F_IDLE;
c0d0210c:	7281      	strb	r1, [r0, #10]
    service->runningCommand = false;
c0d0210e:	7401      	strb	r1, [r0, #16]
    // service->promptUserPresence = false;
    if (service->keepUserPresence) {
c0d02110:	7ec2      	ldrb	r2, [r0, #27]
c0d02112:	2a00      	cmp	r2, #0
c0d02114:	d000      	beq.n	c0d02118 <u2f_initialize_service+0x20>
        keepUserPresence = true;
        service->keepUserPresence = false;
c0d02116:	76c1      	strb	r1, [r0, #27]
    service->handleFunction = (u2fHandle_t)u2f_process_message;
    service->timeoutFunction = (u2fTimer_t)u2f_timeout;
    service->timerInterval = DEFAULT_TIMER_INTERVAL_MS;
    u2f_reset(service, false);
    service->promptUserPresence = false;
    service->userPresence = false;
c0d02118:	8301      	strh	r1, [r0, #24]
#ifdef HAVE_NO_USER_PRESENCE_CHECK
    service->keepUserPresence = true;
    service->userPresence = true;
#endif // HAVE_NO_USER_PRESENCE_CHECK
}
c0d0211a:	4770      	bx	lr
c0d0211c:	ffffff43 	.word	0xffffff43
c0d02120:	ffffffab 	.word	0xffffffab

c0d02124 <u2f_send_direct_response_short>:

void u2f_send_direct_response_short(u2f_service_t *service, uint8_t *buffer,
                                    uint16_t len) {
c0d02124:	b510      	push	{r4, lr}
    (void)service;
    uint16_t maxSize = 0;
    switch (service->packetMedia) {
c0d02126:	7b03      	ldrb	r3, [r0, #12]
    default:
        PRINTF("Request to send on unsupported media %d\n",
               service->packetMedia);
        break;
    }
    if (len > maxSize) {
c0d02128:	2040      	movs	r0, #64	; 0x40
c0d0212a:	2400      	movs	r4, #0
c0d0212c:	2b01      	cmp	r3, #1
c0d0212e:	d000      	beq.n	c0d02132 <u2f_send_direct_response_short+0xe>
c0d02130:	4620      	mov	r0, r4
c0d02132:	4282      	cmp	r2, r0
c0d02134:	d806      	bhi.n	c0d02144 <u2f_send_direct_response_short+0x20>
        return;
    }
    u2f_io_send(buffer, len, service->packetMedia);
c0d02136:	4608      	mov	r0, r1
c0d02138:	4611      	mov	r1, r2
c0d0213a:	461a      	mov	r2, r3
c0d0213c:	f7ff fe06 	bl	c0d01d4c <u2f_io_send>
    u2f_io_close_session();
c0d02140:	f7ff fe26 	bl	c0d01d90 <u2f_io_close_session>
}
c0d02144:	bd10      	pop	{r4, pc}

c0d02146 <u2f_send_fragmented_response>:

void u2f_send_fragmented_response(u2f_service_t *service, uint8_t cmd,
                                  uint8_t *buffer, uint16_t len,
                                  bool resetAfterSend) {
c0d02146:	b570      	push	{r4, r5, r6, lr}
c0d02148:	9c04      	ldr	r4, [sp, #16]
    if (resetAfterSend) {
c0d0214a:	2c01      	cmp	r4, #1
c0d0214c:	d101      	bne.n	c0d02152 <u2f_send_fragmented_response+0xc>
        service->transportState = U2F_SENDING_RESPONSE;
c0d0214e:	2503      	movs	r5, #3
c0d02150:	7285      	strb	r5, [r0, #10]
    }
    service->sending = true;
c0d02152:	2538      	movs	r5, #56	; 0x38
c0d02154:	2601      	movs	r6, #1
c0d02156:	5546      	strb	r6, [r0, r5]
    service->sendPacketIndex = 0;
c0d02158:	2539      	movs	r5, #57	; 0x39
c0d0215a:	2600      	movs	r6, #0
c0d0215c:	5546      	strb	r6, [r0, r5]
    service->sendBuffer = buffer;
c0d0215e:	63c2      	str	r2, [r0, #60]	; 0x3c
    service->sendOffset = 0;
c0d02160:	2240      	movs	r2, #64	; 0x40
c0d02162:	5286      	strh	r6, [r0, r2]
    service->sendLength = len;
c0d02164:	2242      	movs	r2, #66	; 0x42
c0d02166:	5283      	strh	r3, [r0, r2]
    service->sendCmd = cmd;
c0d02168:	2244      	movs	r2, #68	; 0x44
c0d0216a:	5481      	strb	r1, [r0, r2]
    service->resetAfterSend = resetAfterSend;
c0d0216c:	2145      	movs	r1, #69	; 0x45
c0d0216e:	5444      	strb	r4, [r0, r1]
    u2f_continue_sending_fragmented_response(service);
c0d02170:	f000 f802 	bl	c0d02178 <u2f_continue_sending_fragmented_response>
}
c0d02174:	bd70      	pop	{r4, r5, r6, pc}
	...

c0d02178 <u2f_continue_sending_fragmented_response>:

void u2f_continue_sending_fragmented_response(u2f_service_t *service) {
c0d02178:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d0217a:	b089      	sub	sp, #36	; 0x24
c0d0217c:	4604      	mov	r4, r0
c0d0217e:	2039      	movs	r0, #57	; 0x39
c0d02180:	5c20      	ldrb	r0, [r4, r0]
c0d02182:	4621      	mov	r1, r4
c0d02184:	315e      	adds	r1, #94	; 0x5e
c0d02186:	9102      	str	r1, [sp, #8]
c0d02188:	4621      	mov	r1, r4
c0d0218a:	3144      	adds	r1, #68	; 0x44
c0d0218c:	9101      	str	r1, [sp, #4]
c0d0218e:	4627      	mov	r7, r4
c0d02190:	3740      	adds	r7, #64	; 0x40
c0d02192:	4621      	mov	r1, r4
c0d02194:	3142      	adds	r1, #66	; 0x42
c0d02196:	9107      	str	r1, [sp, #28]
c0d02198:	4621      	mov	r1, r4
c0d0219a:	3139      	adds	r1, #57	; 0x39
c0d0219c:	9104      	str	r1, [sp, #16]
c0d0219e:	9703      	str	r7, [sp, #12]
    do {
        uint16_t channelHeader =
            (service->transportMedia == U2F_MEDIA_USB ? 4 : 0);
c0d021a0:	7ae1      	ldrb	r1, [r4, #11]
c0d021a2:	2204      	movs	r2, #4
c0d021a4:	2300      	movs	r3, #0
c0d021a6:	2901      	cmp	r1, #1
c0d021a8:	d000      	beq.n	c0d021ac <u2f_continue_sending_fragmented_response+0x34>
c0d021aa:	461a      	mov	r2, r3
        uint8_t headerSize =
            (service->sendPacketIndex == 0 ? (channelHeader + 3)
c0d021ac:	0606      	lsls	r6, r0, #24
c0d021ae:	2503      	movs	r5, #3
c0d021b0:	2301      	movs	r3, #1
c0d021b2:	2e00      	cmp	r6, #0
c0d021b4:	d000      	beq.n	c0d021b8 <u2f_continue_sending_fragmented_response+0x40>
c0d021b6:	461d      	mov	r5, r3
c0d021b8:	4315      	orrs	r5, r2
c0d021ba:	2240      	movs	r2, #64	; 0x40
c0d021bc:	4b34      	ldr	r3, [pc, #208]	; (c0d02290 <u2f_continue_sending_fragmented_response+0x118>)
                                           : (channelHeader + 1));
        uint16_t maxBlockSize =
            (service->transportMedia == U2F_MEDIA_USB ? USB_SEGMENT_SIZE
c0d021be:	9308      	str	r3, [sp, #32]
c0d021c0:	2901      	cmp	r1, #1
c0d021c2:	d001      	beq.n	c0d021c8 <u2f_continue_sending_fragmented_response+0x50>
                                                      : service->bleMtu);
c0d021c4:	9a02      	ldr	r2, [sp, #8]
c0d021c6:	8812      	ldrh	r2, [r2, #0]
        uint16_t blockSize = ((service->sendLength - service->sendOffset) >
                                      (maxBlockSize - headerSize)
c0d021c8:	1b56      	subs	r6, r2, r5
            (service->sendPacketIndex == 0 ? (channelHeader + 3)
                                           : (channelHeader + 1));
        uint16_t maxBlockSize =
            (service->transportMedia == U2F_MEDIA_USB ? USB_SEGMENT_SIZE
                                                      : service->bleMtu);
        uint16_t blockSize = ((service->sendLength - service->sendOffset) >
c0d021ca:	883a      	ldrh	r2, [r7, #0]
c0d021cc:	9b07      	ldr	r3, [sp, #28]
c0d021ce:	881b      	ldrh	r3, [r3, #0]
c0d021d0:	1a9a      	subs	r2, r3, r2
c0d021d2:	42b2      	cmp	r2, r6
c0d021d4:	dc00      	bgt.n	c0d021d8 <u2f_continue_sending_fragmented_response+0x60>
c0d021d6:	4616      	mov	r6, r2
                                      (maxBlockSize - headerSize)
                                  ? (maxBlockSize - headerSize)
                                  : service->sendLength - service->sendOffset);
        uint16_t dataSize = blockSize + headerSize;
c0d021d8:	1972      	adds	r2, r6, r5
c0d021da:	9206      	str	r2, [sp, #24]
c0d021dc:	4633      	mov	r3, r6
c0d021de:	9a08      	ldr	r2, [sp, #32]
c0d021e0:	4013      	ands	r3, r2
c0d021e2:	9305      	str	r3, [sp, #20]
c0d021e4:	2700      	movs	r7, #0
        uint16_t offset = 0;
        // Fragment
        if (service->transportMedia == U2F_MEDIA_USB) {
c0d021e6:	2901      	cmp	r1, #1
c0d021e8:	d10c      	bne.n	c0d02204 <u2f_continue_sending_fragmented_response+0x8c>
            os_memset(service->outputBuffer, 0, USB_SEGMENT_SIZE);
c0d021ea:	6ce0      	ldr	r0, [r4, #76]	; 0x4c
c0d021ec:	2100      	movs	r1, #0
c0d021ee:	2240      	movs	r2, #64	; 0x40
c0d021f0:	f7fe fdc8 	bl	c0d00d84 <os_memset>
            os_memmove(service->outputBuffer + offset, service->channel, 4);
c0d021f4:	6ce0      	ldr	r0, [r4, #76]	; 0x4c
c0d021f6:	2704      	movs	r7, #4
c0d021f8:	4621      	mov	r1, r4
c0d021fa:	463a      	mov	r2, r7
c0d021fc:	f7fe fdcb 	bl	c0d00d96 <os_memmove>
c0d02200:	9804      	ldr	r0, [sp, #16]
c0d02202:	7800      	ldrb	r0, [r0, #0]
            offset += 4;
        }
        if (service->sendPacketIndex == 0) {
c0d02204:	0601      	lsls	r1, r0, #24
c0d02206:	d002      	beq.n	c0d0220e <u2f_continue_sending_fragmented_response+0x96>
c0d02208:	b2c0      	uxtb	r0, r0
            service->outputBuffer[offset++] = service->sendCmd;
            service->outputBuffer[offset++] = (service->sendLength >> 8);
            service->outputBuffer[offset++] = (service->sendLength & 0xff);
        } else {
            service->outputBuffer[offset++] = (service->sendPacketIndex - 1);
c0d0220a:	30ff      	adds	r0, #255	; 0xff
c0d0220c:	e00d      	b.n	c0d0222a <u2f_continue_sending_fragmented_response+0xb2>
            os_memset(service->outputBuffer, 0, USB_SEGMENT_SIZE);
            os_memmove(service->outputBuffer + offset, service->channel, 4);
            offset += 4;
        }
        if (service->sendPacketIndex == 0) {
            service->outputBuffer[offset++] = service->sendCmd;
c0d0220e:	6ce0      	ldr	r0, [r4, #76]	; 0x4c
c0d02210:	9901      	ldr	r1, [sp, #4]
c0d02212:	7809      	ldrb	r1, [r1, #0]
c0d02214:	b2ba      	uxth	r2, r7
c0d02216:	5481      	strb	r1, [r0, r2]
c0d02218:	2001      	movs	r0, #1
c0d0221a:	4338      	orrs	r0, r7
            service->outputBuffer[offset++] = (service->sendLength >> 8);
c0d0221c:	b287      	uxth	r7, r0
c0d0221e:	6ce2      	ldr	r2, [r4, #76]	; 0x4c
c0d02220:	9907      	ldr	r1, [sp, #28]
c0d02222:	784b      	ldrb	r3, [r1, #1]
c0d02224:	55d3      	strb	r3, [r2, r7]
c0d02226:	1c47      	adds	r7, r0, #1
            service->outputBuffer[offset++] = (service->sendLength & 0xff);
c0d02228:	7808      	ldrb	r0, [r1, #0]
c0d0222a:	6ce1      	ldr	r1, [r4, #76]	; 0x4c
c0d0222c:	b2ba      	uxth	r2, r7
c0d0222e:	5488      	strb	r0, [r1, r2]
        } else {
            service->outputBuffer[offset++] = (service->sendPacketIndex - 1);
        }
        if (service->sendBuffer != NULL) {
c0d02230:	6be1      	ldr	r1, [r4, #60]	; 0x3c
c0d02232:	2900      	cmp	r1, #0
c0d02234:	9f03      	ldr	r7, [sp, #12]
c0d02236:	d006      	beq.n	c0d02246 <u2f_continue_sending_fragmented_response+0xce>
            os_memmove(service->outputBuffer + headerSize,
c0d02238:	6ce0      	ldr	r0, [r4, #76]	; 0x4c
c0d0223a:	1940      	adds	r0, r0, r5
                       service->sendBuffer + service->sendOffset, blockSize);
c0d0223c:	883a      	ldrh	r2, [r7, #0]
c0d0223e:	1889      	adds	r1, r1, r2
            service->outputBuffer[offset++] = (service->sendLength & 0xff);
        } else {
            service->outputBuffer[offset++] = (service->sendPacketIndex - 1);
        }
        if (service->sendBuffer != NULL) {
            os_memmove(service->outputBuffer + headerSize,
c0d02240:	9a05      	ldr	r2, [sp, #20]
c0d02242:	f7fe fda8 	bl	c0d00d96 <os_memmove>
                       service->sendBuffer + service->sendOffset, blockSize);
        }
        u2f_io_send(service->outputBuffer, dataSize, service->packetMedia);
c0d02246:	9808      	ldr	r0, [sp, #32]
c0d02248:	9906      	ldr	r1, [sp, #24]
c0d0224a:	4001      	ands	r1, r0
c0d0224c:	7b22      	ldrb	r2, [r4, #12]
c0d0224e:	6ce0      	ldr	r0, [r4, #76]	; 0x4c
c0d02250:	f7ff fd7c 	bl	c0d01d4c <u2f_io_send>
        service->sendOffset += blockSize;
c0d02254:	8838      	ldrh	r0, [r7, #0]
c0d02256:	1981      	adds	r1, r0, r6
c0d02258:	8039      	strh	r1, [r7, #0]
c0d0225a:	9a04      	ldr	r2, [sp, #16]
        service->sendPacketIndex++;
c0d0225c:	7810      	ldrb	r0, [r2, #0]
c0d0225e:	1c40      	adds	r0, r0, #1
c0d02260:	7010      	strb	r0, [r2, #0]
        if (service->sendBuffer != NULL) {
            os_memmove(service->outputBuffer + headerSize,
                       service->sendBuffer + service->sendOffset, blockSize);
        }
        u2f_io_send(service->outputBuffer, dataSize, service->packetMedia);
        service->sendOffset += blockSize;
c0d02262:	b289      	uxth	r1, r1
        service->sendPacketIndex++;
    } while (service->sendOffset != service->sendLength);
c0d02264:	9a07      	ldr	r2, [sp, #28]
c0d02266:	8812      	ldrh	r2, [r2, #0]
c0d02268:	428a      	cmp	r2, r1
c0d0226a:	d199      	bne.n	c0d021a0 <u2f_continue_sending_fragmented_response+0x28>
    if (service->sendOffset == service->sendLength) {
        u2f_io_close_session();
c0d0226c:	f7ff fd90 	bl	c0d01d90 <u2f_io_close_session>
        service->sending = false;
c0d02270:	2138      	movs	r1, #56	; 0x38
c0d02272:	2000      	movs	r0, #0
c0d02274:	5460      	strb	r0, [r4, r1]
        if (service->resetAfterSend) {
c0d02276:	2145      	movs	r1, #69	; 0x45
c0d02278:	5c61      	ldrb	r1, [r4, r1]
c0d0227a:	2900      	cmp	r1, #0
c0d0227c:	d005      	beq.n	c0d0228a <u2f_continue_sending_fragmented_response+0x112>

// not too fast blinking
#define DEFAULT_TIMER_INTERVAL_MS 500

void u2f_reset(u2f_service_t *service, bool keepUserPresence) {
    service->transportState = U2F_IDLE;
c0d0227e:	72a0      	strb	r0, [r4, #10]
    service->runningCommand = false;
c0d02280:	7420      	strb	r0, [r4, #16]
    // service->promptUserPresence = false;
    if (service->keepUserPresence) {
c0d02282:	7ee1      	ldrb	r1, [r4, #27]
c0d02284:	2900      	cmp	r1, #0
c0d02286:	d000      	beq.n	c0d0228a <u2f_continue_sending_fragmented_response+0x112>
        keepUserPresence = true;
        service->keepUserPresence = false;
c0d02288:	76e0      	strb	r0, [r4, #27]
        service->sending = false;
        if (service->resetAfterSend) {
            u2f_reset(service, false);
        }
    }
}
c0d0228a:	b009      	add	sp, #36	; 0x24
c0d0228c:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d0228e:	46c0      	nop			; (mov r8, r8)
c0d02290:	0000ffff 	.word	0x0000ffff

c0d02294 <u2f_transport_handle>:

static const uint8_t const BROADCAST_CHANNEL[] = {0xff, 0xff, 0xff, 0xff};
static const uint8_t const FORBIDDEN_CHANNEL[] = {0x00, 0x00, 0x00, 0x00};

void u2f_transport_handle(u2f_service_t *service, uint8_t *buffer,
                          uint16_t size, u2f_transport_media_t media) {
c0d02294:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02296:	b087      	sub	sp, #28
c0d02298:	461f      	mov	r7, r3
c0d0229a:	9205      	str	r2, [sp, #20]
c0d0229c:	460e      	mov	r6, r1
c0d0229e:	4604      	mov	r4, r0
    uint16_t channelHeader = (media == U2F_MEDIA_USB ? 4 : 0);
    uint8_t channel[4] = {0};
c0d022a0:	2500      	movs	r5, #0
c0d022a2:	9506      	str	r5, [sp, #24]
    if (media == U2F_MEDIA_USB) {
c0d022a4:	2f01      	cmp	r7, #1
c0d022a6:	d104      	bne.n	c0d022b2 <u2f_transport_handle+0x1e>
c0d022a8:	a806      	add	r0, sp, #24
        os_memmove(channel, buffer, 4);
c0d022aa:	2204      	movs	r2, #4
c0d022ac:	4631      	mov	r1, r6
c0d022ae:	f7fe fd72 	bl	c0d00d96 <os_memmove>
    }
    // screen_printf("U2F transport\n");
    service->packetMedia = media;
c0d022b2:	7327      	strb	r7, [r4, #12]
    u2f_io_open_session();
c0d022b4:	f7ff fd3a 	bl	c0d01d2c <u2f_io_open_session>
    // If busy, answer immediately
    if (service->noReentry) {
c0d022b8:	205c      	movs	r0, #92	; 0x5c
c0d022ba:	5c20      	ldrb	r0, [r4, r0]
c0d022bc:	2800      	cmp	r0, #0
c0d022be:	9503      	str	r5, [sp, #12]
c0d022c0:	d00b      	beq.n	c0d022da <u2f_transport_handle+0x46>
        if ((service->transportState == U2F_PROCESSING_COMMAND) ||
c0d022c2:	7aa0      	ldrb	r0, [r4, #10]
c0d022c4:	21fe      	movs	r1, #254	; 0xfe
c0d022c6:	4001      	ands	r1, r0
c0d022c8:	2902      	cmp	r1, #2
c0d022ca:	d106      	bne.n	c0d022da <u2f_transport_handle+0x46>
            (service->transportState == U2F_SENDING_RESPONSE)) {
            u2f_response_error(service, ERROR_CHANNEL_BUSY, false, channel);
c0d022cc:	2106      	movs	r1, #6
c0d022ce:	2200      	movs	r2, #0
c0d022d0:	ab06      	add	r3, sp, #24
c0d022d2:	4620      	mov	r0, r4
c0d022d4:	f000 f92e 	bl	c0d02534 <u2f_response_error>
c0d022d8:	e038      	b.n	c0d0234c <u2f_transport_handle+0xb8>
c0d022da:	4638      	mov	r0, r7
            goto error;
        }
    }
    if (size < (1 + channelHeader)) {
c0d022dc:	2704      	movs	r7, #4
c0d022de:	9004      	str	r0, [sp, #16]
c0d022e0:	2801      	cmp	r0, #1
c0d022e2:	d000      	beq.n	c0d022e6 <u2f_transport_handle+0x52>
c0d022e4:	462f      	mov	r7, r5
c0d022e6:	2201      	movs	r2, #1
c0d022e8:	463d      	mov	r5, r7
c0d022ea:	4315      	orrs	r5, r2
                               channel);
            goto error;
        }
        if (media != service->transportMedia) {
            // Mixed medias
            u2f_response_error(service, ERROR_PROP_MEDIA_MIXED, true, channel);
c0d022ec:	2185      	movs	r1, #133	; 0x85
c0d022ee:	9b05      	ldr	r3, [sp, #20]
            (service->transportState == U2F_SENDING_RESPONSE)) {
            u2f_response_error(service, ERROR_CHANNEL_BUSY, false, channel);
            goto error;
        }
    }
    if (size < (1 + channelHeader)) {
c0d022f0:	42ab      	cmp	r3, r5
c0d022f2:	d202      	bcs.n	c0d022fa <u2f_transport_handle+0x66>
c0d022f4:	ab06      	add	r3, sp, #24
c0d022f6:	4620      	mov	r0, r4
c0d022f8:	e025      	b.n	c0d02346 <u2f_transport_handle+0xb2>
c0d022fa:	9102      	str	r1, [sp, #8]
        // Message to short, abort
        u2f_response_error(service, ERROR_PROP_MESSAGE_TOO_SHORT, true,
                           channel);
        goto error;
    }
    if ((buffer[channelHeader] & U2F_MASK_COMMAND) != 0) {
c0d022fc:	57f0      	ldrsb	r0, [r6, r7]
c0d022fe:	19f1      	adds	r1, r6, r7
c0d02300:	2800      	cmp	r0, #0
c0d02302:	db19      	blt.n	c0d02338 <u2f_transport_handle+0xa4>
c0d02304:	9101      	str	r1, [sp, #4]
c0d02306:	2102      	movs	r1, #2
                   size - channelHeader);
        service->transportOffset = size - channelHeader;
        service->transportMedia = media;
    } else {
        // Continuation
        if (size < (channelHeader + 2)) {
c0d02308:	430f      	orrs	r7, r1
c0d0230a:	42bb      	cmp	r3, r7
c0d0230c:	d318      	bcc.n	c0d02340 <u2f_transport_handle+0xac>
            // Message to short, abort
            u2f_response_error(service, ERROR_PROP_MESSAGE_TOO_SHORT, true,
                               channel);
            goto error;
        }
        if (media != service->transportMedia) {
c0d0230e:	7ae1      	ldrb	r1, [r4, #11]
c0d02310:	9f04      	ldr	r7, [sp, #16]
c0d02312:	42b9      	cmp	r1, r7
c0d02314:	d162      	bne.n	c0d023dc <u2f_transport_handle+0x148>
            // Mixed medias
            u2f_response_error(service, ERROR_PROP_MEDIA_MIXED, true, channel);
            goto error;
        }
        if (service->transportState != U2F_HANDLE_SEGMENTED) {
c0d02316:	7aa1      	ldrb	r1, [r4, #10]
c0d02318:	2901      	cmp	r1, #1
c0d0231a:	d163      	bne.n	c0d023e4 <u2f_transport_handle+0x150>
            } else {
                u2f_response_error(service, ERROR_INVALID_SEQ, true, channel);
                goto error;
            }
        }
        if (media == U2F_MEDIA_USB) {
c0d0231c:	2f01      	cmp	r7, #1
c0d0231e:	d000      	beq.n	c0d02322 <u2f_transport_handle+0x8e>
c0d02320:	e09e      	b.n	c0d02460 <u2f_transport_handle+0x1cc>
c0d02322:	9200      	str	r2, [sp, #0]
            // Check the channel
            if (os_memcmp(buffer, service->channel, 4) != 0) {
c0d02324:	2204      	movs	r2, #4
c0d02326:	4630      	mov	r0, r6
c0d02328:	4621      	mov	r1, r4
c0d0232a:	f7fe fdd1 	bl	c0d00ed0 <os_memcmp>
c0d0232e:	2800      	cmp	r0, #0
c0d02330:	d100      	bne.n	c0d02334 <u2f_transport_handle+0xa0>
c0d02332:	e091      	b.n	c0d02458 <u2f_transport_handle+0x1c4>
                u2f_response_error(service, ERROR_CHANNEL_BUSY, true, channel);
c0d02334:	2106      	movs	r1, #6
c0d02336:	e07c      	b.n	c0d02432 <u2f_transport_handle+0x19e>
        u2f_response_error(service, ERROR_PROP_MESSAGE_TOO_SHORT, true,
                           channel);
        goto error;
    }
    if ((buffer[channelHeader] & U2F_MASK_COMMAND) != 0) {
        if (size < (channelHeader + 3)) {
c0d02338:	2003      	movs	r0, #3
c0d0233a:	4338      	orrs	r0, r7
c0d0233c:	4283      	cmp	r3, r0
c0d0233e:	d218      	bcs.n	c0d02372 <u2f_transport_handle+0xde>
c0d02340:	ab06      	add	r3, sp, #24
c0d02342:	4620      	mov	r0, r4
c0d02344:	9902      	ldr	r1, [sp, #8]
c0d02346:	f000 f8f5 	bl	c0d02534 <u2f_response_error>
c0d0234a:	9f04      	ldr	r7, [sp, #16]
        os_memmove(service->lastContinuationChannel, channel, 4);
        u2f_io_close_session();
    }
    return;
error:
    if ((media == U2F_MEDIA_USB) && (service->pendingContinuation) &&
c0d0234c:	2f01      	cmp	r7, #1
c0d0234e:	d10e      	bne.n	c0d0236e <u2f_transport_handle+0xda>
c0d02350:	2030      	movs	r0, #48	; 0x30
c0d02352:	5c20      	ldrb	r0, [r4, r0]
c0d02354:	4625      	mov	r5, r4
c0d02356:	3530      	adds	r5, #48	; 0x30
c0d02358:	2800      	cmp	r0, #0
c0d0235a:	d008      	beq.n	c0d0236e <u2f_transport_handle+0xda>
        (os_memcmp(channel, service->lastContinuationChannel, 4) == 0)) {
c0d0235c:	1d21      	adds	r1, r4, #4
c0d0235e:	a806      	add	r0, sp, #24
c0d02360:	2204      	movs	r2, #4
c0d02362:	f7fe fdb5 	bl	c0d00ed0 <os_memcmp>
        os_memmove(service->lastContinuationChannel, channel, 4);
        u2f_io_close_session();
    }
    return;
error:
    if ((media == U2F_MEDIA_USB) && (service->pendingContinuation) &&
c0d02366:	2800      	cmp	r0, #0
c0d02368:	d101      	bne.n	c0d0236e <u2f_transport_handle+0xda>
        (os_memcmp(channel, service->lastContinuationChannel, 4) == 0)) {
        service->pendingContinuation = false;
c0d0236a:	9803      	ldr	r0, [sp, #12]
c0d0236c:	7028      	strb	r0, [r5, #0]
    }
    return;
}
c0d0236e:	b007      	add	sp, #28
c0d02370:	bdf0      	pop	{r4, r5, r6, r7, pc}
                               channel);
            goto error;
        }
        // If waiting for a continuation on a different channel, reply BUSY
        // immediately
        if (media == U2F_MEDIA_USB) {
c0d02372:	9804      	ldr	r0, [sp, #16]
c0d02374:	2801      	cmp	r0, #1
c0d02376:	d115      	bne.n	c0d023a4 <u2f_transport_handle+0x110>
            if ((service->pendingContinuation) &&
c0d02378:	2030      	movs	r0, #48	; 0x30
c0d0237a:	5c20      	ldrb	r0, [r4, r0]
c0d0237c:	2800      	cmp	r0, #0
c0d0237e:	d011      	beq.n	c0d023a4 <u2f_transport_handle+0x110>
c0d02380:	9101      	str	r1, [sp, #4]
                (os_memcmp(channel, service->lastContinuationChannel, 4) !=
c0d02382:	1d21      	adds	r1, r4, #4
c0d02384:	a806      	add	r0, sp, #24
c0d02386:	9200      	str	r2, [sp, #0]
c0d02388:	2204      	movs	r2, #4
c0d0238a:	f7fe fda1 	bl	c0d00ed0 <os_memcmp>
c0d0238e:	9901      	ldr	r1, [sp, #4]
c0d02390:	9a00      	ldr	r2, [sp, #0]
                 0) &&
c0d02392:	2800      	cmp	r0, #0
c0d02394:	d006      	beq.n	c0d023a4 <u2f_transport_handle+0x110>
                (buffer[channelHeader] != U2F_CMD_INIT)) {
c0d02396:	7808      	ldrb	r0, [r1, #0]
c0d02398:	9902      	ldr	r1, [sp, #8]
c0d0239a:	1c49      	adds	r1, r1, #1
c0d0239c:	b2c9      	uxtb	r1, r1
            goto error;
        }
        // If waiting for a continuation on a different channel, reply BUSY
        // immediately
        if (media == U2F_MEDIA_USB) {
            if ((service->pendingContinuation) &&
c0d0239e:	4288      	cmp	r0, r1
c0d023a0:	9901      	ldr	r1, [sp, #4]
c0d023a2:	d152      	bne.n	c0d0244a <u2f_transport_handle+0x1b6>
                goto error;
            }
        }
        // If a command was already sent, and we are not processing a INIT
        // command, abort
        if ((service->transportState == U2F_HANDLE_SEGMENTED) &&
c0d023a4:	7aa0      	ldrb	r0, [r4, #10]
c0d023a6:	2801      	cmp	r0, #1
c0d023a8:	d10a      	bne.n	c0d023c0 <u2f_transport_handle+0x12c>
            !((media == U2F_MEDIA_USB) &&
c0d023aa:	9804      	ldr	r0, [sp, #16]
c0d023ac:	2801      	cmp	r0, #1
c0d023ae:	d120      	bne.n	c0d023f2 <u2f_transport_handle+0x15e>
              (buffer[channelHeader] == U2F_CMD_INIT))) {
c0d023b0:	7808      	ldrb	r0, [r1, #0]
c0d023b2:	460b      	mov	r3, r1
c0d023b4:	9902      	ldr	r1, [sp, #8]
c0d023b6:	1c49      	adds	r1, r1, #1
c0d023b8:	b2c9      	uxtb	r1, r1
                goto error;
            }
        }
        // If a command was already sent, and we are not processing a INIT
        // command, abort
        if ((service->transportState == U2F_HANDLE_SEGMENTED) &&
c0d023ba:	4288      	cmp	r0, r1
c0d023bc:	4619      	mov	r1, r3
c0d023be:	d118      	bne.n	c0d023f2 <u2f_transport_handle+0x15e>
c0d023c0:	9101      	str	r1, [sp, #4]
            u2f_response_error(service, ERROR_INVALID_SEQ, true, channel);
            goto error;
        }
        // Check the length
        uint16_t commandLength =
            (buffer[channelHeader + 1] << 8) | (buffer[channelHeader + 2]);
c0d023c2:	2002      	movs	r0, #2
c0d023c4:	4338      	orrs	r0, r7
c0d023c6:	5c30      	ldrb	r0, [r6, r0]
c0d023c8:	5d71      	ldrb	r1, [r6, r5]
c0d023ca:	020d      	lsls	r5, r1, #8
c0d023cc:	4305      	orrs	r5, r0
        if (commandLength > (service->messageBufferSize - 3)) {
c0d023ce:	2054      	movs	r0, #84	; 0x54
c0d023d0:	5a20      	ldrh	r0, [r4, r0]
c0d023d2:	1ec0      	subs	r0, r0, #3
c0d023d4:	4285      	cmp	r5, r0
c0d023d6:	dd0e      	ble.n	c0d023f6 <u2f_transport_handle+0x162>
            // Overflow in message size, abort
            u2f_response_error(service, ERROR_INVALID_LEN, true, channel);
c0d023d8:	2103      	movs	r1, #3
c0d023da:	e78b      	b.n	c0d022f4 <u2f_transport_handle+0x60>
c0d023dc:	9802      	ldr	r0, [sp, #8]
                               channel);
            goto error;
        }
        if (media != service->transportMedia) {
            // Mixed medias
            u2f_response_error(service, ERROR_PROP_MEDIA_MIXED, true, channel);
c0d023de:	3008      	adds	r0, #8
c0d023e0:	b2c1      	uxtb	r1, r0
c0d023e2:	e775      	b.n	c0d022d0 <u2f_transport_handle+0x3c>
            goto error;
        }
        if (service->transportState != U2F_HANDLE_SEGMENTED) {
            // Unexpected continuation at this stage, abort
            // TODO : review the behavior is HID only
            if (media == U2F_MEDIA_USB) {
c0d023e4:	2f01      	cmp	r7, #1
c0d023e6:	d12a      	bne.n	c0d0243e <u2f_transport_handle+0x1aa>
                u2f_reset(service, true);
c0d023e8:	4620      	mov	r0, r4
c0d023ea:	4611      	mov	r1, r2
c0d023ec:	f7ff fe7c 	bl	c0d020e8 <u2f_reset>
c0d023f0:	e7ae      	b.n	c0d02350 <u2f_transport_handle+0xbc>
        // command, abort
        if ((service->transportState == U2F_HANDLE_SEGMENTED) &&
            !((media == U2F_MEDIA_USB) &&
              (buffer[channelHeader] == U2F_CMD_INIT))) {
            // Unexpected continuation at this stage, abort
            u2f_response_error(service, ERROR_INVALID_SEQ, true, channel);
c0d023f2:	2104      	movs	r1, #4
c0d023f4:	e77e      	b.n	c0d022f4 <u2f_transport_handle+0x60>
            // Overflow in message size, abort
            u2f_response_error(service, ERROR_INVALID_LEN, true, channel);
            goto error;
        }
        // Check if the command is supported
        switch (buffer[channelHeader]) {
c0d023f6:	9801      	ldr	r0, [sp, #4]
c0d023f8:	7800      	ldrb	r0, [r0, #0]
c0d023fa:	2881      	cmp	r0, #129	; 0x81
c0d023fc:	d004      	beq.n	c0d02408 <u2f_transport_handle+0x174>
c0d023fe:	2886      	cmp	r0, #134	; 0x86
c0d02400:	d050      	beq.n	c0d024a4 <u2f_transport_handle+0x210>
c0d02402:	2883      	cmp	r0, #131	; 0x83
c0d02404:	d000      	beq.n	c0d02408 <u2f_transport_handle+0x174>
c0d02406:	e088      	b.n	c0d0251a <u2f_transport_handle+0x286>
c0d02408:	9200      	str	r2, [sp, #0]
        case U2F_CMD_PING:
        case U2F_CMD_MSG:
            if (media == U2F_MEDIA_USB) {
c0d0240a:	9804      	ldr	r0, [sp, #16]
c0d0240c:	2801      	cmp	r0, #1
c0d0240e:	d14d      	bne.n	c0d024ac <u2f_transport_handle+0x218>
c0d02410:	a806      	add	r0, sp, #24
        u2f_reset(service, true);
    }
}

bool u2f_is_channel_broadcast(uint8_t *channel) {
    return (os_memcmp(channel, BROADCAST_CHANNEL, 4) == 0);
c0d02412:	4946      	ldr	r1, [pc, #280]	; (c0d0252c <u2f_transport_handle+0x298>)
c0d02414:	4479      	add	r1, pc
c0d02416:	2204      	movs	r2, #4
c0d02418:	f7fe fd5a 	bl	c0d00ed0 <os_memcmp>
        // Check if the command is supported
        switch (buffer[channelHeader]) {
        case U2F_CMD_PING:
        case U2F_CMD_MSG:
            if (media == U2F_MEDIA_USB) {
                if (u2f_is_channel_broadcast(channel) ||
c0d0241c:	2800      	cmp	r0, #0
c0d0241e:	d007      	beq.n	c0d02430 <u2f_transport_handle+0x19c>
c0d02420:	a806      	add	r0, sp, #24
bool u2f_is_channel_broadcast(uint8_t *channel) {
    return (os_memcmp(channel, BROADCAST_CHANNEL, 4) == 0);
}

bool u2f_is_channel_forbidden(uint8_t *channel) {
    return (os_memcmp(channel, FORBIDDEN_CHANNEL, 4) == 0);
c0d02422:	4943      	ldr	r1, [pc, #268]	; (c0d02530 <u2f_transport_handle+0x29c>)
c0d02424:	4479      	add	r1, pc
c0d02426:	2204      	movs	r2, #4
c0d02428:	f7fe fd52 	bl	c0d00ed0 <os_memcmp>
        // Check if the command is supported
        switch (buffer[channelHeader]) {
        case U2F_CMD_PING:
        case U2F_CMD_MSG:
            if (media == U2F_MEDIA_USB) {
                if (u2f_is_channel_broadcast(channel) ||
c0d0242c:	2800      	cmp	r0, #0
c0d0242e:	d13d      	bne.n	c0d024ac <u2f_transport_handle+0x218>
                    u2f_is_channel_forbidden(channel)) {
                    u2f_response_error(service, ERROR_INVALID_CID, true,
c0d02430:	210b      	movs	r1, #11
c0d02432:	ab06      	add	r3, sp, #24
c0d02434:	4620      	mov	r0, r4
c0d02436:	9a00      	ldr	r2, [sp, #0]
c0d02438:	f000 f87c 	bl	c0d02534 <u2f_response_error>
c0d0243c:	e788      	b.n	c0d02350 <u2f_transport_handle+0xbc>
            // TODO : review the behavior is HID only
            if (media == U2F_MEDIA_USB) {
                u2f_reset(service, true);
                goto error;
            } else {
                u2f_response_error(service, ERROR_INVALID_SEQ, true, channel);
c0d0243e:	2104      	movs	r1, #4
c0d02440:	ab06      	add	r3, sp, #24
c0d02442:	4620      	mov	r0, r4
c0d02444:	f000 f876 	bl	c0d02534 <u2f_response_error>
c0d02448:	e791      	b.n	c0d0236e <u2f_transport_handle+0xda>
        if (media == U2F_MEDIA_USB) {
            if ((service->pendingContinuation) &&
                (os_memcmp(channel, service->lastContinuationChannel, 4) !=
                 0) &&
                (buffer[channelHeader] != U2F_CMD_INIT)) {
                u2f_response_error(service, ERROR_CHANNEL_BUSY, false, channel);
c0d0244a:	2106      	movs	r1, #6
c0d0244c:	2200      	movs	r2, #0
c0d0244e:	ab06      	add	r3, sp, #24
c0d02450:	4620      	mov	r0, r4
c0d02452:	f000 f86f 	bl	c0d02534 <u2f_response_error>
c0d02456:	e77b      	b.n	c0d02350 <u2f_transport_handle+0xbc>
c0d02458:	9801      	ldr	r0, [sp, #4]
c0d0245a:	7800      	ldrb	r0, [r0, #0]
c0d0245c:	9a00      	ldr	r2, [sp, #0]
c0d0245e:	9b05      	ldr	r3, [sp, #20]
                u2f_response_error(service, ERROR_CHANNEL_BUSY, true, channel);
                goto error;
            }
        }

        if (buffer[channelHeader] != service->expectedContinuationPacket) {
c0d02460:	7b61      	ldrb	r1, [r4, #13]
c0d02462:	b2c0      	uxtb	r0, r0
c0d02464:	4288      	cmp	r0, r1
c0d02466:	d10d      	bne.n	c0d02484 <u2f_transport_handle+0x1f0>
c0d02468:	9200      	str	r2, [sp, #0]
            // Bad continuation packet, abort
            u2f_response_error(service, ERROR_INVALID_SEQ, true, channel);
            goto error;
        }
        if ((service->transportOffset + (size - (channelHeader + 1))) >
c0d0246a:	1b5e      	subs	r6, r3, r5
c0d0246c:	8920      	ldrh	r0, [r4, #8]
c0d0246e:	1981      	adds	r1, r0, r6
            (service->messageBufferSize - 3)) {
c0d02470:	2254      	movs	r2, #84	; 0x54
c0d02472:	5aa2      	ldrh	r2, [r4, r2]
c0d02474:	1ed2      	subs	r2, r2, #3
        if (buffer[channelHeader] != service->expectedContinuationPacket) {
            // Bad continuation packet, abort
            u2f_response_error(service, ERROR_INVALID_SEQ, true, channel);
            goto error;
        }
        if ((service->transportOffset + (size - (channelHeader + 1))) >
c0d02476:	4291      	cmp	r1, r2
c0d02478:	dd06      	ble.n	c0d02488 <u2f_transport_handle+0x1f4>
            (service->messageBufferSize - 3)) {
            // Overflow, abort
            u2f_response_error(service, ERROR_INVALID_LEN, true, channel);
c0d0247a:	2103      	movs	r1, #3
c0d0247c:	ab06      	add	r3, sp, #24
c0d0247e:	4620      	mov	r0, r4
c0d02480:	9a00      	ldr	r2, [sp, #0]
c0d02482:	e727      	b.n	c0d022d4 <u2f_transport_handle+0x40>
            }
        }

        if (buffer[channelHeader] != service->expectedContinuationPacket) {
            // Bad continuation packet, abort
            u2f_response_error(service, ERROR_INVALID_SEQ, true, channel);
c0d02484:	2104      	movs	r1, #4
c0d02486:	e723      	b.n	c0d022d0 <u2f_transport_handle+0x3c>
            (service->messageBufferSize - 3)) {
            // Overflow, abort
            u2f_response_error(service, ERROR_INVALID_LEN, true, channel);
            goto error;
        }
        os_memmove(service->messageBuffer + service->transportOffset,
c0d02488:	6d21      	ldr	r1, [r4, #80]	; 0x50
c0d0248a:	1808      	adds	r0, r1, r0
                   buffer + channelHeader + 1, size - (channelHeader + 1));
c0d0248c:	9901      	ldr	r1, [sp, #4]
c0d0248e:	1c49      	adds	r1, r1, #1
            (service->messageBufferSize - 3)) {
            // Overflow, abort
            u2f_response_error(service, ERROR_INVALID_LEN, true, channel);
            goto error;
        }
        os_memmove(service->messageBuffer + service->transportOffset,
c0d02490:	4632      	mov	r2, r6
c0d02492:	f7fe fc80 	bl	c0d00d96 <os_memmove>
                   buffer + channelHeader + 1, size - (channelHeader + 1));
        service->transportOffset += size - (channelHeader + 1);
c0d02496:	8920      	ldrh	r0, [r4, #8]
c0d02498:	1986      	adds	r6, r0, r6
c0d0249a:	8126      	strh	r6, [r4, #8]
        service->expectedContinuationPacket++;
c0d0249c:	7b60      	ldrb	r0, [r4, #13]
c0d0249e:	1c40      	adds	r0, r0, #1
c0d024a0:	7360      	strb	r0, [r4, #13]
c0d024a2:	e015      	b.n	c0d024d0 <u2f_transport_handle+0x23c>
c0d024a4:	9200      	str	r2, [sp, #0]
                    goto error;
                }
            }
            break;
        case U2F_CMD_INIT:
            if (media != U2F_MEDIA_USB) {
c0d024a6:	9804      	ldr	r0, [sp, #16]
c0d024a8:	2801      	cmp	r0, #1
c0d024aa:	d138      	bne.n	c0d0251e <u2f_transport_handle+0x28a>
c0d024ac:	a906      	add	r1, sp, #24
            // Unknown command, abort
            u2f_response_error(service, ERROR_INVALID_CMD, true, channel);
            goto error;
        }
        // Ok, initialize the buffer
        os_memmove(service->channel, channel, 4);
c0d024ae:	2204      	movs	r2, #4
c0d024b0:	4620      	mov	r0, r4
c0d024b2:	f7fe fc70 	bl	c0d00d96 <os_memmove>
        service->lastCommandLength = commandLength;
c0d024b6:	81e5      	strh	r5, [r4, #14]
        service->expectedContinuationPacket = 0;
c0d024b8:	2000      	movs	r0, #0
c0d024ba:	7360      	strb	r0, [r4, #13]
        os_memmove(service->messageBuffer, buffer + channelHeader,
                   size - channelHeader);
c0d024bc:	9805      	ldr	r0, [sp, #20]
c0d024be:	1bc6      	subs	r6, r0, r7
        }
        // Ok, initialize the buffer
        os_memmove(service->channel, channel, 4);
        service->lastCommandLength = commandLength;
        service->expectedContinuationPacket = 0;
        os_memmove(service->messageBuffer, buffer + channelHeader,
c0d024c0:	6d20      	ldr	r0, [r4, #80]	; 0x50
c0d024c2:	9901      	ldr	r1, [sp, #4]
c0d024c4:	4632      	mov	r2, r6
c0d024c6:	f7fe fc66 	bl	c0d00d96 <os_memmove>
                   size - channelHeader);
        service->transportOffset = size - channelHeader;
c0d024ca:	8126      	strh	r6, [r4, #8]
c0d024cc:	9f04      	ldr	r7, [sp, #16]
        service->transportMedia = media;
c0d024ce:	72e7      	strb	r7, [r4, #11]
        service->transportOffset += size - (channelHeader + 1);
        service->expectedContinuationPacket++;
    }
    // See if we can process the command
    if ((media != U2F_MEDIA_USB) &&
        (service->transportOffset >
c0d024d0:	b2b0      	uxth	r0, r6
                   buffer + channelHeader + 1, size - (channelHeader + 1));
        service->transportOffset += size - (channelHeader + 1);
        service->expectedContinuationPacket++;
    }
    // See if we can process the command
    if ((media != U2F_MEDIA_USB) &&
c0d024d2:	2f01      	cmp	r7, #1
c0d024d4:	d102      	bne.n	c0d024dc <u2f_transport_handle+0x248>
c0d024d6:	89e1      	ldrh	r1, [r4, #14]
c0d024d8:	9a00      	ldr	r2, [sp, #0]
c0d024da:	e006      	b.n	c0d024ea <u2f_transport_handle+0x256>
        (service->transportOffset >
         (service->lastCommandLength + U2F_COMMAND_HEADER_SIZE))) {
c0d024dc:	89e1      	ldrh	r1, [r4, #14]
c0d024de:	1cca      	adds	r2, r1, #3
                   buffer + channelHeader + 1, size - (channelHeader + 1));
        service->transportOffset += size - (channelHeader + 1);
        service->expectedContinuationPacket++;
    }
    // See if we can process the command
    if ((media != U2F_MEDIA_USB) &&
c0d024e0:	4290      	cmp	r0, r2
c0d024e2:	9a00      	ldr	r2, [sp, #0]
c0d024e4:	d901      	bls.n	c0d024ea <u2f_transport_handle+0x256>
        (service->transportOffset >
         (service->lastCommandLength + U2F_COMMAND_HEADER_SIZE))) {
        // Overflow, abort
        u2f_response_error(service, ERROR_INVALID_LEN, true, channel);
c0d024e6:	2103      	movs	r1, #3
c0d024e8:	e7aa      	b.n	c0d02440 <u2f_transport_handle+0x1ac>
        goto error;
    } else if (service->transportOffset >=
               (service->lastCommandLength + U2F_COMMAND_HEADER_SIZE)) {
c0d024ea:	1cc9      	adds	r1, r1, #3
        (service->transportOffset >
         (service->lastCommandLength + U2F_COMMAND_HEADER_SIZE))) {
        // Overflow, abort
        u2f_response_error(service, ERROR_INVALID_LEN, true, channel);
        goto error;
    } else if (service->transportOffset >=
c0d024ec:	4288      	cmp	r0, r1
c0d024ee:	d20c      	bcs.n	c0d0250a <u2f_transport_handle+0x276>
c0d024f0:	2000      	movs	r0, #0
        // screen_printf("Process command\n");
        service->transportState = U2F_PROCESSING_COMMAND;
        service->handleFunction(service, service->messageBuffer, channel);
    } else {
        // screen_printf("segmented\n");
        service->seqTimeout = 0;
c0d024f2:	62e0      	str	r0, [r4, #44]	; 0x2c
        service->transportState = U2F_HANDLE_SEGMENTED;
c0d024f4:	72a2      	strb	r2, [r4, #10]
        service->pendingContinuation = true;
c0d024f6:	2030      	movs	r0, #48	; 0x30
c0d024f8:	5422      	strb	r2, [r4, r0]
        os_memmove(service->lastContinuationChannel, channel, 4);
c0d024fa:	1d20      	adds	r0, r4, #4
c0d024fc:	a906      	add	r1, sp, #24
c0d024fe:	2204      	movs	r2, #4
c0d02500:	f7fe fc49 	bl	c0d00d96 <os_memmove>
        u2f_io_close_session();
c0d02504:	f7ff fc44 	bl	c0d01d90 <u2f_io_close_session>
c0d02508:	e731      	b.n	c0d0236e <u2f_transport_handle+0xda>
        u2f_response_error(service, ERROR_INVALID_LEN, true, channel);
        goto error;
    } else if (service->transportOffset >=
               (service->lastCommandLength + U2F_COMMAND_HEADER_SIZE)) {
        // screen_printf("Process command\n");
        service->transportState = U2F_PROCESSING_COMMAND;
c0d0250a:	2002      	movs	r0, #2
c0d0250c:	72a0      	strb	r0, [r4, #10]
        service->handleFunction(service, service->messageBuffer, channel);
c0d0250e:	6d21      	ldr	r1, [r4, #80]	; 0x50
c0d02510:	6963      	ldr	r3, [r4, #20]
c0d02512:	aa06      	add	r2, sp, #24
c0d02514:	4620      	mov	r0, r4
c0d02516:	4798      	blx	r3
c0d02518:	e729      	b.n	c0d0236e <u2f_transport_handle+0xda>
                goto error;
            }
            break;
        default:
            // Unknown command, abort
            u2f_response_error(service, ERROR_INVALID_CMD, true, channel);
c0d0251a:	2101      	movs	r1, #1
c0d0251c:	e6ea      	b.n	c0d022f4 <u2f_transport_handle+0x60>
            }
            break;
        case U2F_CMD_INIT:
            if (media != U2F_MEDIA_USB) {
                // Unknown command, abort
                u2f_response_error(service, ERROR_INVALID_CMD, true, channel);
c0d0251e:	2101      	movs	r1, #1
c0d02520:	ab06      	add	r3, sp, #24
c0d02522:	4620      	mov	r0, r4
c0d02524:	9a00      	ldr	r2, [sp, #0]
c0d02526:	f000 f805 	bl	c0d02534 <u2f_response_error>
c0d0252a:	e720      	b.n	c0d0236e <u2f_transport_handle+0xda>
c0d0252c:	00001832 	.word	0x00001832
c0d02530:	00001826 	.word	0x00001826

c0d02534 <u2f_response_error>:
    }
    return;
}

void u2f_response_error(u2f_service_t *service, char errorCode, bool reset,
                        uint8_t *channel) {
c0d02534:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02536:	b083      	sub	sp, #12
c0d02538:	461e      	mov	r6, r3
c0d0253a:	9202      	str	r2, [sp, #8]
c0d0253c:	9101      	str	r1, [sp, #4]
c0d0253e:	4604      	mov	r4, r0
    uint8_t offset = 0;
    os_memset(service->outputBuffer, 0, MAX_SEGMENT_SIZE);
c0d02540:	6ce0      	ldr	r0, [r4, #76]	; 0x4c
c0d02542:	2700      	movs	r7, #0
c0d02544:	2240      	movs	r2, #64	; 0x40
c0d02546:	4639      	mov	r1, r7
c0d02548:	f7fe fc1c 	bl	c0d00d84 <os_memset>
    if (service->transportMedia == U2F_MEDIA_USB) {
c0d0254c:	7ae0      	ldrb	r0, [r4, #11]
c0d0254e:	2801      	cmp	r0, #1
c0d02550:	463d      	mov	r5, r7
c0d02552:	d105      	bne.n	c0d02560 <u2f_response_error+0x2c>
        os_memmove(service->outputBuffer + offset, channel, 4);
c0d02554:	6ce0      	ldr	r0, [r4, #76]	; 0x4c
c0d02556:	2504      	movs	r5, #4
c0d02558:	4631      	mov	r1, r6
c0d0255a:	462a      	mov	r2, r5
c0d0255c:	f7fe fc1b 	bl	c0d00d96 <os_memmove>
        offset += 4;
    }
    service->outputBuffer[offset++] = U2F_STATUS_ERROR;
c0d02560:	6ce0      	ldr	r0, [r4, #76]	; 0x4c
c0d02562:	b2e9      	uxtb	r1, r5
c0d02564:	22bf      	movs	r2, #191	; 0xbf
c0d02566:	5442      	strb	r2, [r0, r1]
c0d02568:	2001      	movs	r0, #1
c0d0256a:	4629      	mov	r1, r5
c0d0256c:	4301      	orrs	r1, r0
    service->outputBuffer[offset++] = 0x00;
c0d0256e:	b2ca      	uxtb	r2, r1
c0d02570:	6ce3      	ldr	r3, [r4, #76]	; 0x4c
c0d02572:	549f      	strb	r7, [r3, r2]
c0d02574:	1c49      	adds	r1, r1, #1
    service->outputBuffer[offset++] = 0x01;
c0d02576:	b2c9      	uxtb	r1, r1
c0d02578:	6ce2      	ldr	r2, [r4, #76]	; 0x4c
c0d0257a:	5450      	strb	r0, [r2, r1]
c0d0257c:	2003      	movs	r0, #3
c0d0257e:	4328      	orrs	r0, r5
    service->outputBuffer[offset++] = errorCode;
c0d02580:	b2c1      	uxtb	r1, r0
c0d02582:	6ce2      	ldr	r2, [r4, #76]	; 0x4c
c0d02584:	9b01      	ldr	r3, [sp, #4]
c0d02586:	5453      	strb	r3, [r2, r1]
c0d02588:	1c40      	adds	r0, r0, #1
    u2f_send_direct_response_short(service, service->outputBuffer, offset);
c0d0258a:	b2c2      	uxtb	r2, r0
c0d0258c:	6ce1      	ldr	r1, [r4, #76]	; 0x4c
c0d0258e:	4620      	mov	r0, r4
c0d02590:	f7ff fdc8 	bl	c0d02124 <u2f_send_direct_response_short>
    if (reset) {
c0d02594:	9802      	ldr	r0, [sp, #8]
c0d02596:	2801      	cmp	r0, #1
c0d02598:	d103      	bne.n	c0d025a2 <u2f_response_error+0x6e>
        u2f_reset(service, true);
c0d0259a:	2101      	movs	r1, #1
c0d0259c:	4620      	mov	r0, r4
c0d0259e:	f7ff fda3 	bl	c0d020e8 <u2f_reset>
    }
}
c0d025a2:	b003      	add	sp, #12
c0d025a4:	bdf0      	pop	{r4, r5, r6, r7, pc}
	...

c0d025a8 <u2f_is_channel_broadcast>:

bool u2f_is_channel_broadcast(uint8_t *channel) {
c0d025a8:	b580      	push	{r7, lr}
    return (os_memcmp(channel, BROADCAST_CHANNEL, 4) == 0);
c0d025aa:	4906      	ldr	r1, [pc, #24]	; (c0d025c4 <u2f_is_channel_broadcast+0x1c>)
c0d025ac:	4479      	add	r1, pc
c0d025ae:	2204      	movs	r2, #4
c0d025b0:	f7fe fc8e 	bl	c0d00ed0 <os_memcmp>
c0d025b4:	4601      	mov	r1, r0
c0d025b6:	2001      	movs	r0, #1
c0d025b8:	2200      	movs	r2, #0
c0d025ba:	2900      	cmp	r1, #0
c0d025bc:	d000      	beq.n	c0d025c0 <u2f_is_channel_broadcast+0x18>
c0d025be:	4610      	mov	r0, r2
c0d025c0:	bd80      	pop	{r7, pc}
c0d025c2:	46c0      	nop			; (mov r8, r8)
c0d025c4:	0000169a 	.word	0x0000169a

c0d025c8 <u2f_is_channel_forbidden>:
}

bool u2f_is_channel_forbidden(uint8_t *channel) {
c0d025c8:	b580      	push	{r7, lr}
    return (os_memcmp(channel, FORBIDDEN_CHANNEL, 4) == 0);
c0d025ca:	4906      	ldr	r1, [pc, #24]	; (c0d025e4 <u2f_is_channel_forbidden+0x1c>)
c0d025cc:	4479      	add	r1, pc
c0d025ce:	2204      	movs	r2, #4
c0d025d0:	f7fe fc7e 	bl	c0d00ed0 <os_memcmp>
c0d025d4:	4601      	mov	r1, r0
c0d025d6:	2001      	movs	r0, #1
c0d025d8:	2200      	movs	r2, #0
c0d025da:	2900      	cmp	r1, #0
c0d025dc:	d000      	beq.n	c0d025e0 <u2f_is_channel_forbidden+0x18>
c0d025de:	4610      	mov	r0, r2
c0d025e0:	bd80      	pop	{r7, pc}
c0d025e2:	46c0      	nop			; (mov r8, r8)
c0d025e4:	0000167e 	.word	0x0000167e

c0d025e8 <USBD_LL_Init>:
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_Init (USBD_HandleTypeDef *pdev)
{ 
  UNUSED(pdev);
  ep_in_stall = 0;
c0d025e8:	4902      	ldr	r1, [pc, #8]	; (c0d025f4 <USBD_LL_Init+0xc>)
c0d025ea:	2000      	movs	r0, #0
c0d025ec:	6008      	str	r0, [r1, #0]
  ep_out_stall = 0;
c0d025ee:	4902      	ldr	r1, [pc, #8]	; (c0d025f8 <USBD_LL_Init+0x10>)
c0d025f0:	6008      	str	r0, [r1, #0]
  return USBD_OK;
c0d025f2:	4770      	bx	lr
c0d025f4:	20001fbc 	.word	0x20001fbc
c0d025f8:	20001fc0 	.word	0x20001fc0

c0d025fc <USBD_LL_DeInit>:
  * @brief  De-Initializes the Low Level portion of the Device driver.
  * @param  pdev: Device handle
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_DeInit (USBD_HandleTypeDef *pdev)
{
c0d025fc:	b510      	push	{r4, lr}
  UNUSED(pdev);
  // usb off
  G_io_seproxyhal_spi_buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d025fe:	4807      	ldr	r0, [pc, #28]	; (c0d0261c <USBD_LL_DeInit+0x20>)
c0d02600:	214f      	movs	r1, #79	; 0x4f
c0d02602:	7001      	strb	r1, [r0, #0]
c0d02604:	2400      	movs	r4, #0
  G_io_seproxyhal_spi_buffer[1] = 0;
c0d02606:	7044      	strb	r4, [r0, #1]
c0d02608:	2101      	movs	r1, #1
  G_io_seproxyhal_spi_buffer[2] = 1;
c0d0260a:	7081      	strb	r1, [r0, #2]
c0d0260c:	2102      	movs	r1, #2
  G_io_seproxyhal_spi_buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_DISCONNECT;
c0d0260e:	70c1      	strb	r1, [r0, #3]
  io_seproxyhal_spi_send(G_io_seproxyhal_spi_buffer, 4);
c0d02610:	2104      	movs	r1, #4
c0d02612:	f7ff fb47 	bl	c0d01ca4 <io_seproxyhal_spi_send>

  return USBD_OK; 
c0d02616:	4620      	mov	r0, r4
c0d02618:	bd10      	pop	{r4, pc}
c0d0261a:	46c0      	nop			; (mov r8, r8)
c0d0261c:	20001c28 	.word	0x20001c28

c0d02620 <USBD_LL_Start>:
  * @brief  Starts the Low Level portion of the Device driver. 
  * @param  pdev: Device handle
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_Start(USBD_HandleTypeDef *pdev)
{
c0d02620:	b570      	push	{r4, r5, r6, lr}
c0d02622:	b082      	sub	sp, #8
c0d02624:	466d      	mov	r5, sp
  uint8_t buffer[5];
  UNUSED(pdev);

  // reset address
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d02626:	264f      	movs	r6, #79	; 0x4f
c0d02628:	702e      	strb	r6, [r5, #0]
c0d0262a:	2400      	movs	r4, #0
  buffer[1] = 0;
c0d0262c:	706c      	strb	r4, [r5, #1]
c0d0262e:	2002      	movs	r0, #2
  buffer[2] = 2;
c0d02630:	70a8      	strb	r0, [r5, #2]
c0d02632:	2003      	movs	r0, #3
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_ADDR;
c0d02634:	70e8      	strb	r0, [r5, #3]
  buffer[4] = 0;
c0d02636:	712c      	strb	r4, [r5, #4]
  io_seproxyhal_spi_send(buffer, 5);
c0d02638:	2105      	movs	r1, #5
c0d0263a:	4628      	mov	r0, r5
c0d0263c:	f7ff fb32 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  
  // start usb operation
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d02640:	702e      	strb	r6, [r5, #0]
  buffer[1] = 0;
c0d02642:	706c      	strb	r4, [r5, #1]
c0d02644:	2001      	movs	r0, #1
  buffer[2] = 1;
c0d02646:	70a8      	strb	r0, [r5, #2]
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_CONNECT;
c0d02648:	70e8      	strb	r0, [r5, #3]
c0d0264a:	2104      	movs	r1, #4
  io_seproxyhal_spi_send(buffer, 4);
c0d0264c:	4628      	mov	r0, r5
c0d0264e:	f7ff fb29 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  return USBD_OK; 
c0d02652:	4620      	mov	r0, r4
c0d02654:	b002      	add	sp, #8
c0d02656:	bd70      	pop	{r4, r5, r6, pc}

c0d02658 <USBD_LL_Stop>:
  * @brief  Stops the Low Level portion of the Device driver.
  * @param  pdev: Device handle
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_Stop (USBD_HandleTypeDef *pdev)
{
c0d02658:	b510      	push	{r4, lr}
c0d0265a:	b082      	sub	sp, #8
c0d0265c:	a801      	add	r0, sp, #4
  UNUSED(pdev);
  uint8_t buffer[4];
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d0265e:	214f      	movs	r1, #79	; 0x4f
c0d02660:	7001      	strb	r1, [r0, #0]
c0d02662:	2400      	movs	r4, #0
  buffer[1] = 0;
c0d02664:	7044      	strb	r4, [r0, #1]
c0d02666:	2101      	movs	r1, #1
  buffer[2] = 1;
c0d02668:	7081      	strb	r1, [r0, #2]
c0d0266a:	2102      	movs	r1, #2
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_DISCONNECT;
c0d0266c:	70c1      	strb	r1, [r0, #3]
  io_seproxyhal_spi_send(buffer, 4);
c0d0266e:	2104      	movs	r1, #4
c0d02670:	f7ff fb18 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  return USBD_OK; 
c0d02674:	4620      	mov	r0, r4
c0d02676:	b002      	add	sp, #8
c0d02678:	bd10      	pop	{r4, pc}
	...

c0d0267c <USBD_LL_OpenEP>:
  */
USBD_StatusTypeDef  USBD_LL_OpenEP  (USBD_HandleTypeDef *pdev, 
                                      uint8_t  ep_addr,                                      
                                      uint8_t  ep_type,
                                      uint16_t ep_mps)
{
c0d0267c:	b5b0      	push	{r4, r5, r7, lr}
c0d0267e:	b082      	sub	sp, #8
  uint8_t buffer[8];
  UNUSED(pdev);

  ep_in_stall = 0;
c0d02680:	480e      	ldr	r0, [pc, #56]	; (c0d026bc <USBD_LL_OpenEP+0x40>)
c0d02682:	2400      	movs	r4, #0
c0d02684:	6004      	str	r4, [r0, #0]
  ep_out_stall = 0;
c0d02686:	480e      	ldr	r0, [pc, #56]	; (c0d026c0 <USBD_LL_OpenEP+0x44>)
c0d02688:	6004      	str	r4, [r0, #0]
c0d0268a:	4668      	mov	r0, sp

  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d0268c:	254f      	movs	r5, #79	; 0x4f
c0d0268e:	7005      	strb	r5, [r0, #0]
  buffer[1] = 0;
c0d02690:	7044      	strb	r4, [r0, #1]
c0d02692:	2505      	movs	r5, #5
  buffer[2] = 5;
c0d02694:	7085      	strb	r5, [r0, #2]
c0d02696:	2504      	movs	r5, #4
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_ENDPOINTS;
c0d02698:	70c5      	strb	r5, [r0, #3]
c0d0269a:	2501      	movs	r5, #1
  buffer[4] = 1;
c0d0269c:	7105      	strb	r5, [r0, #4]
  buffer[5] = ep_addr;
c0d0269e:	7141      	strb	r1, [r0, #5]
  buffer[6] = 0;
  switch(ep_type) {
c0d026a0:	2a03      	cmp	r2, #3
c0d026a2:	d802      	bhi.n	c0d026aa <USBD_LL_OpenEP+0x2e>
c0d026a4:	00d0      	lsls	r0, r2, #3
c0d026a6:	4c07      	ldr	r4, [pc, #28]	; (c0d026c4 <USBD_LL_OpenEP+0x48>)
c0d026a8:	40c4      	lsrs	r4, r0
c0d026aa:	4668      	mov	r0, sp
  buffer[1] = 0;
  buffer[2] = 5;
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_ENDPOINTS;
  buffer[4] = 1;
  buffer[5] = ep_addr;
  buffer[6] = 0;
c0d026ac:	7184      	strb	r4, [r0, #6]
      break;
    case USBD_EP_TYPE_INTR:
      buffer[6] = SEPROXYHAL_TAG_USB_CONFIG_TYPE_INTERRUPT;
      break;
  }
  buffer[7] = ep_mps;
c0d026ae:	71c3      	strb	r3, [r0, #7]
  io_seproxyhal_spi_send(buffer, 8);
c0d026b0:	2108      	movs	r1, #8
c0d026b2:	f7ff faf7 	bl	c0d01ca4 <io_seproxyhal_spi_send>
c0d026b6:	2000      	movs	r0, #0
  return USBD_OK; 
c0d026b8:	b002      	add	sp, #8
c0d026ba:	bdb0      	pop	{r4, r5, r7, pc}
c0d026bc:	20001fbc 	.word	0x20001fbc
c0d026c0:	20001fc0 	.word	0x20001fc0
c0d026c4:	02030401 	.word	0x02030401

c0d026c8 <USBD_LL_CloseEP>:
  * @param  pdev: Device handle
  * @param  ep_addr: Endpoint Number
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_CloseEP (USBD_HandleTypeDef *pdev, uint8_t ep_addr)   
{
c0d026c8:	b510      	push	{r4, lr}
c0d026ca:	b082      	sub	sp, #8
c0d026cc:	4668      	mov	r0, sp
  UNUSED(pdev);
  uint8_t buffer[8];
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d026ce:	224f      	movs	r2, #79	; 0x4f
c0d026d0:	7002      	strb	r2, [r0, #0]
c0d026d2:	2400      	movs	r4, #0
  buffer[1] = 0;
c0d026d4:	7044      	strb	r4, [r0, #1]
c0d026d6:	2205      	movs	r2, #5
  buffer[2] = 5;
c0d026d8:	7082      	strb	r2, [r0, #2]
c0d026da:	2204      	movs	r2, #4
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_ENDPOINTS;
c0d026dc:	70c2      	strb	r2, [r0, #3]
c0d026de:	2201      	movs	r2, #1
  buffer[4] = 1;
c0d026e0:	7102      	strb	r2, [r0, #4]
  buffer[5] = ep_addr;
c0d026e2:	7141      	strb	r1, [r0, #5]
  buffer[6] = SEPROXYHAL_TAG_USB_CONFIG_TYPE_DISABLED;
c0d026e4:	7184      	strb	r4, [r0, #6]
  buffer[7] = 0;
c0d026e6:	71c4      	strb	r4, [r0, #7]
  io_seproxyhal_spi_send(buffer, 8);
c0d026e8:	2108      	movs	r1, #8
c0d026ea:	f7ff fadb 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  return USBD_OK; 
c0d026ee:	4620      	mov	r0, r4
c0d026f0:	b002      	add	sp, #8
c0d026f2:	bd10      	pop	{r4, pc}

c0d026f4 <USBD_LL_StallEP>:
  * @param  pdev: Device handle
  * @param  ep_addr: Endpoint Number
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_StallEP (USBD_HandleTypeDef *pdev, uint8_t ep_addr)   
{ 
c0d026f4:	b5b0      	push	{r4, r5, r7, lr}
c0d026f6:	b082      	sub	sp, #8
c0d026f8:	460d      	mov	r5, r1
c0d026fa:	4668      	mov	r0, sp
  UNUSED(pdev);
  uint8_t buffer[6];
  buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
c0d026fc:	2150      	movs	r1, #80	; 0x50
c0d026fe:	7001      	strb	r1, [r0, #0]
c0d02700:	2400      	movs	r4, #0
  buffer[1] = 0;
c0d02702:	7044      	strb	r4, [r0, #1]
c0d02704:	2103      	movs	r1, #3
  buffer[2] = 3;
c0d02706:	7081      	strb	r1, [r0, #2]
  buffer[3] = ep_addr;
c0d02708:	70c5      	strb	r5, [r0, #3]
  buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_STALL;
c0d0270a:	2140      	movs	r1, #64	; 0x40
c0d0270c:	7101      	strb	r1, [r0, #4]
  buffer[5] = 0;
c0d0270e:	7144      	strb	r4, [r0, #5]
  io_seproxyhal_spi_send(buffer, 6);
c0d02710:	2106      	movs	r1, #6
c0d02712:	f7ff fac7 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  if (ep_addr & 0x80) {
c0d02716:	2080      	movs	r0, #128	; 0x80
c0d02718:	4205      	tst	r5, r0
c0d0271a:	d101      	bne.n	c0d02720 <USBD_LL_StallEP+0x2c>
c0d0271c:	4807      	ldr	r0, [pc, #28]	; (c0d0273c <USBD_LL_StallEP+0x48>)
c0d0271e:	e000      	b.n	c0d02722 <USBD_LL_StallEP+0x2e>
c0d02720:	4805      	ldr	r0, [pc, #20]	; (c0d02738 <USBD_LL_StallEP+0x44>)
c0d02722:	6801      	ldr	r1, [r0, #0]
c0d02724:	227f      	movs	r2, #127	; 0x7f
c0d02726:	4015      	ands	r5, r2
c0d02728:	2201      	movs	r2, #1
c0d0272a:	40aa      	lsls	r2, r5
c0d0272c:	430a      	orrs	r2, r1
c0d0272e:	6002      	str	r2, [r0, #0]
    ep_in_stall |= (1<<(ep_addr&0x7F));
  }
  else {
    ep_out_stall |= (1<<(ep_addr&0x7F)); 
  }
  return USBD_OK; 
c0d02730:	4620      	mov	r0, r4
c0d02732:	b002      	add	sp, #8
c0d02734:	bdb0      	pop	{r4, r5, r7, pc}
c0d02736:	46c0      	nop			; (mov r8, r8)
c0d02738:	20001fbc 	.word	0x20001fbc
c0d0273c:	20001fc0 	.word	0x20001fc0

c0d02740 <USBD_LL_ClearStallEP>:
  * @param  pdev: Device handle
  * @param  ep_addr: Endpoint Number
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_ClearStallEP (USBD_HandleTypeDef *pdev, uint8_t ep_addr)   
{
c0d02740:	b570      	push	{r4, r5, r6, lr}
c0d02742:	b082      	sub	sp, #8
c0d02744:	460d      	mov	r5, r1
c0d02746:	4668      	mov	r0, sp
  UNUSED(pdev);
  uint8_t buffer[6];
  buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
c0d02748:	2150      	movs	r1, #80	; 0x50
c0d0274a:	7001      	strb	r1, [r0, #0]
c0d0274c:	2400      	movs	r4, #0
  buffer[1] = 0;
c0d0274e:	7044      	strb	r4, [r0, #1]
c0d02750:	2103      	movs	r1, #3
  buffer[2] = 3;
c0d02752:	7081      	strb	r1, [r0, #2]
  buffer[3] = ep_addr;
c0d02754:	70c5      	strb	r5, [r0, #3]
c0d02756:	2680      	movs	r6, #128	; 0x80
  buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_UNSTALL;
c0d02758:	7106      	strb	r6, [r0, #4]
  buffer[5] = 0;
c0d0275a:	7144      	strb	r4, [r0, #5]
  io_seproxyhal_spi_send(buffer, 6);
c0d0275c:	2106      	movs	r1, #6
c0d0275e:	f7ff faa1 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  if (ep_addr & 0x80) {
c0d02762:	4235      	tst	r5, r6
c0d02764:	d101      	bne.n	c0d0276a <USBD_LL_ClearStallEP+0x2a>
c0d02766:	4807      	ldr	r0, [pc, #28]	; (c0d02784 <USBD_LL_ClearStallEP+0x44>)
c0d02768:	e000      	b.n	c0d0276c <USBD_LL_ClearStallEP+0x2c>
c0d0276a:	4805      	ldr	r0, [pc, #20]	; (c0d02780 <USBD_LL_ClearStallEP+0x40>)
c0d0276c:	6801      	ldr	r1, [r0, #0]
c0d0276e:	227f      	movs	r2, #127	; 0x7f
c0d02770:	4015      	ands	r5, r2
c0d02772:	2201      	movs	r2, #1
c0d02774:	40aa      	lsls	r2, r5
c0d02776:	4391      	bics	r1, r2
c0d02778:	6001      	str	r1, [r0, #0]
    ep_in_stall &= ~(1<<(ep_addr&0x7F));
  }
  else {
    ep_out_stall &= ~(1<<(ep_addr&0x7F)); 
  }
  return USBD_OK; 
c0d0277a:	4620      	mov	r0, r4
c0d0277c:	b002      	add	sp, #8
c0d0277e:	bd70      	pop	{r4, r5, r6, pc}
c0d02780:	20001fbc 	.word	0x20001fbc
c0d02784:	20001fc0 	.word	0x20001fc0

c0d02788 <USBD_LL_IsStallEP>:
  * @retval Stall (1: Yes, 0: No)
  */
uint8_t USBD_LL_IsStallEP (USBD_HandleTypeDef *pdev, uint8_t ep_addr)   
{
  UNUSED(pdev);
  if((ep_addr & 0x80) == 0x80)
c0d02788:	2080      	movs	r0, #128	; 0x80
c0d0278a:	4201      	tst	r1, r0
c0d0278c:	d001      	beq.n	c0d02792 <USBD_LL_IsStallEP+0xa>
c0d0278e:	4806      	ldr	r0, [pc, #24]	; (c0d027a8 <USBD_LL_IsStallEP+0x20>)
c0d02790:	e000      	b.n	c0d02794 <USBD_LL_IsStallEP+0xc>
c0d02792:	4804      	ldr	r0, [pc, #16]	; (c0d027a4 <USBD_LL_IsStallEP+0x1c>)
c0d02794:	6800      	ldr	r0, [r0, #0]
c0d02796:	227f      	movs	r2, #127	; 0x7f
c0d02798:	4011      	ands	r1, r2
c0d0279a:	2201      	movs	r2, #1
c0d0279c:	408a      	lsls	r2, r1
c0d0279e:	4002      	ands	r2, r0
  }
  else
  {
    return ep_out_stall & (1<<(ep_addr&0x7F));
  }
}
c0d027a0:	b2d0      	uxtb	r0, r2
c0d027a2:	4770      	bx	lr
c0d027a4:	20001fc0 	.word	0x20001fc0
c0d027a8:	20001fbc 	.word	0x20001fbc

c0d027ac <USBD_LL_SetUSBAddress>:
  * @param  pdev: Device handle
  * @param  ep_addr: Endpoint Number
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_SetUSBAddress (USBD_HandleTypeDef *pdev, uint8_t dev_addr)   
{
c0d027ac:	b510      	push	{r4, lr}
c0d027ae:	b082      	sub	sp, #8
c0d027b0:	4668      	mov	r0, sp
  UNUSED(pdev);
  uint8_t buffer[5];
  buffer[0] = SEPROXYHAL_TAG_USB_CONFIG;
c0d027b2:	224f      	movs	r2, #79	; 0x4f
c0d027b4:	7002      	strb	r2, [r0, #0]
c0d027b6:	2400      	movs	r4, #0
  buffer[1] = 0;
c0d027b8:	7044      	strb	r4, [r0, #1]
c0d027ba:	2202      	movs	r2, #2
  buffer[2] = 2;
c0d027bc:	7082      	strb	r2, [r0, #2]
c0d027be:	2203      	movs	r2, #3
  buffer[3] = SEPROXYHAL_TAG_USB_CONFIG_ADDR;
c0d027c0:	70c2      	strb	r2, [r0, #3]
  buffer[4] = dev_addr;
c0d027c2:	7101      	strb	r1, [r0, #4]
  io_seproxyhal_spi_send(buffer, 5);
c0d027c4:	2105      	movs	r1, #5
c0d027c6:	f7ff fa6d 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  return USBD_OK; 
c0d027ca:	4620      	mov	r0, r4
c0d027cc:	b002      	add	sp, #8
c0d027ce:	bd10      	pop	{r4, pc}

c0d027d0 <USBD_LL_Transmit>:
  */
USBD_StatusTypeDef  USBD_LL_Transmit (USBD_HandleTypeDef *pdev, 
                                      uint8_t  ep_addr,                                      
                                      uint8_t  *pbuf,
                                      uint16_t  size)
{
c0d027d0:	b5b0      	push	{r4, r5, r7, lr}
c0d027d2:	b082      	sub	sp, #8
c0d027d4:	461c      	mov	r4, r3
c0d027d6:	4615      	mov	r5, r2
c0d027d8:	4668      	mov	r0, sp
  UNUSED(pdev);
  uint8_t buffer[6];
  buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
c0d027da:	2250      	movs	r2, #80	; 0x50
c0d027dc:	7002      	strb	r2, [r0, #0]
  buffer[1] = (3+size)>>8;
c0d027de:	1ce2      	adds	r2, r4, #3
c0d027e0:	0a13      	lsrs	r3, r2, #8
c0d027e2:	7043      	strb	r3, [r0, #1]
  buffer[2] = (3+size);
c0d027e4:	7082      	strb	r2, [r0, #2]
  buffer[3] = ep_addr;
c0d027e6:	70c1      	strb	r1, [r0, #3]
  buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_IN;
c0d027e8:	2120      	movs	r1, #32
c0d027ea:	7101      	strb	r1, [r0, #4]
  buffer[5] = size;
c0d027ec:	7144      	strb	r4, [r0, #5]
  io_seproxyhal_spi_send(buffer, 6);
c0d027ee:	2106      	movs	r1, #6
c0d027f0:	f7ff fa58 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  io_seproxyhal_spi_send(pbuf, size);
c0d027f4:	4628      	mov	r0, r5
c0d027f6:	4621      	mov	r1, r4
c0d027f8:	f7ff fa54 	bl	c0d01ca4 <io_seproxyhal_spi_send>
c0d027fc:	2000      	movs	r0, #0
  return USBD_OK;   
c0d027fe:	b002      	add	sp, #8
c0d02800:	bdb0      	pop	{r4, r5, r7, pc}

c0d02802 <USBD_LL_PrepareReceive>:
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_LL_PrepareReceive(USBD_HandleTypeDef *pdev, 
                                           uint8_t  ep_addr,
                                           uint16_t  size)
{
c0d02802:	b510      	push	{r4, lr}
c0d02804:	b082      	sub	sp, #8
c0d02806:	4668      	mov	r0, sp
  UNUSED(pdev);
  uint8_t buffer[6];
  buffer[0] = SEPROXYHAL_TAG_USB_EP_PREPARE;
c0d02808:	2350      	movs	r3, #80	; 0x50
c0d0280a:	7003      	strb	r3, [r0, #0]
c0d0280c:	2400      	movs	r4, #0
  buffer[1] = (3/*+size*/)>>8;
c0d0280e:	7044      	strb	r4, [r0, #1]
c0d02810:	2303      	movs	r3, #3
  buffer[2] = (3/*+size*/);
c0d02812:	7083      	strb	r3, [r0, #2]
  buffer[3] = ep_addr;
c0d02814:	70c1      	strb	r1, [r0, #3]
  buffer[4] = SEPROXYHAL_TAG_USB_EP_PREPARE_DIR_OUT;
c0d02816:	2130      	movs	r1, #48	; 0x30
c0d02818:	7101      	strb	r1, [r0, #4]
  buffer[5] = size; // expected size, not transmitted here !
c0d0281a:	7142      	strb	r2, [r0, #5]
  io_seproxyhal_spi_send(buffer, 6);
c0d0281c:	2106      	movs	r1, #6
c0d0281e:	f7ff fa41 	bl	c0d01ca4 <io_seproxyhal_spi_send>
  return USBD_OK;   
c0d02822:	4620      	mov	r0, r4
c0d02824:	b002      	add	sp, #8
c0d02826:	bd10      	pop	{r4, pc}

c0d02828 <USBD_Init>:
* @param  pdesc: Descriptor structure address
* @param  id: Low level core index
* @retval None
*/
USBD_StatusTypeDef USBD_Init(USBD_HandleTypeDef *pdev, USBD_DescriptorsTypeDef *pdesc, uint8_t id)
{
c0d02828:	b570      	push	{r4, r5, r6, lr}
c0d0282a:	4615      	mov	r5, r2
c0d0282c:	460e      	mov	r6, r1
c0d0282e:	4604      	mov	r4, r0
c0d02830:	2002      	movs	r0, #2
  /* Check whether the USB Host handle is valid */
  if(pdev == NULL)
c0d02832:	2c00      	cmp	r4, #0
c0d02834:	d010      	beq.n	c0d02858 <USBD_Init+0x30>
  {
    USBD_ErrLog("Invalid Device handle");
    return USBD_FAIL; 
  }

  memset(pdev, 0, sizeof(USBD_HandleTypeDef));
c0d02836:	2045      	movs	r0, #69	; 0x45
c0d02838:	0081      	lsls	r1, r0, #2
c0d0283a:	4620      	mov	r0, r4
c0d0283c:	f000 fe28 	bl	c0d03490 <__aeabi_memclr>
  
  /* Assign USBD Descriptors */
  if(pdesc != NULL)
c0d02840:	2e00      	cmp	r6, #0
c0d02842:	d001      	beq.n	c0d02848 <USBD_Init+0x20>
  {
    pdev->pDesc = pdesc;
c0d02844:	20f0      	movs	r0, #240	; 0xf0
c0d02846:	5026      	str	r6, [r4, r0]
  }
  
  /* Set Device initial State */
  pdev->dev_state  = USBD_STATE_DEFAULT;
c0d02848:	20dc      	movs	r0, #220	; 0xdc
c0d0284a:	2101      	movs	r1, #1
c0d0284c:	5421      	strb	r1, [r4, r0]
  pdev->id = id;
c0d0284e:	7025      	strb	r5, [r4, #0]
  /* Initialize low level driver */
  USBD_LL_Init(pdev);
c0d02850:	4620      	mov	r0, r4
c0d02852:	f7ff fec9 	bl	c0d025e8 <USBD_LL_Init>
c0d02856:	2000      	movs	r0, #0
  
  return USBD_OK; 
}
c0d02858:	b2c0      	uxtb	r0, r0
c0d0285a:	bd70      	pop	{r4, r5, r6, pc}

c0d0285c <USBD_DeInit>:
*         Re-Initialize th device library
* @param  pdev: device instance
* @retval status: status
*/
USBD_StatusTypeDef USBD_DeInit(USBD_HandleTypeDef *pdev)
{
c0d0285c:	b5b0      	push	{r4, r5, r7, lr}
c0d0285e:	4604      	mov	r4, r0
  /* Set Default State */
  pdev->dev_state  = USBD_STATE_DEFAULT;
c0d02860:	20dc      	movs	r0, #220	; 0xdc
c0d02862:	2101      	movs	r1, #1
c0d02864:	5421      	strb	r1, [r4, r0]
c0d02866:	2500      	movs	r5, #0
  
  /* Free Class Resources */
  uint8_t intf;
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
    if(pdev->interfacesClass[intf].pClass != NULL) {
c0d02868:	00e8      	lsls	r0, r5, #3
c0d0286a:	1820      	adds	r0, r4, r0
c0d0286c:	21f4      	movs	r1, #244	; 0xf4
c0d0286e:	5840      	ldr	r0, [r0, r1]
c0d02870:	2800      	cmp	r0, #0
c0d02872:	d006      	beq.n	c0d02882 <USBD_DeInit+0x26>
      ((DeInit_t)PIC(pdev->interfacesClass[intf].pClass->DeInit))(pdev, pdev->dev_config);  
c0d02874:	6840      	ldr	r0, [r0, #4]
c0d02876:	f7ff f931 	bl	c0d01adc <pic>
c0d0287a:	4602      	mov	r2, r0
c0d0287c:	7921      	ldrb	r1, [r4, #4]
c0d0287e:	4620      	mov	r0, r4
c0d02880:	4790      	blx	r2
  /* Set Default State */
  pdev->dev_state  = USBD_STATE_DEFAULT;
  
  /* Free Class Resources */
  uint8_t intf;
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d02882:	1c6d      	adds	r5, r5, #1
c0d02884:	2d03      	cmp	r5, #3
c0d02886:	d1ef      	bne.n	c0d02868 <USBD_DeInit+0xc>
      ((DeInit_t)PIC(pdev->interfacesClass[intf].pClass->DeInit))(pdev, pdev->dev_config);  
    }
  }
  
    /* Stop the low level driver  */
  USBD_LL_Stop(pdev); 
c0d02888:	4620      	mov	r0, r4
c0d0288a:	f7ff fee5 	bl	c0d02658 <USBD_LL_Stop>
  
  /* Initialize low level driver */
  USBD_LL_DeInit(pdev);
c0d0288e:	4620      	mov	r0, r4
c0d02890:	f7ff feb4 	bl	c0d025fc <USBD_LL_DeInit>
  
  return USBD_OK;
c0d02894:	2000      	movs	r0, #0
c0d02896:	bdb0      	pop	{r4, r5, r7, pc}

c0d02898 <USBD_RegisterClass>:
}

USBD_StatusTypeDef USBD_RegisterClass(USBD_HandleTypeDef *pdev, USBD_ClassTypeDef *pclass) {
c0d02898:	2202      	movs	r2, #2
  * @retval USBD Status
  */
USBD_StatusTypeDef USBD_RegisterClassForInterface(uint8_t interfaceidx, USBD_HandleTypeDef *pdev, USBD_ClassTypeDef *pclass)
{
  USBD_StatusTypeDef   status = USBD_OK;
  if(pclass != 0)
c0d0289a:	2900      	cmp	r1, #0
c0d0289c:	d002      	beq.n	c0d028a4 <USBD_RegisterClass+0xc>
  {
    if (interfaceidx < USBD_MAX_NUM_INTERFACES) {
      /* link the class to the USB Device handle */
      pdev->interfacesClass[interfaceidx].pClass = pclass;
c0d0289e:	22f4      	movs	r2, #244	; 0xf4
c0d028a0:	5081      	str	r1, [r0, r2]
c0d028a2:	2200      	movs	r2, #0
  
  return USBD_OK;
}

USBD_StatusTypeDef USBD_RegisterClass(USBD_HandleTypeDef *pdev, USBD_ClassTypeDef *pclass) {
  return USBD_RegisterClassForInterface(0, pdev, pclass);
c0d028a4:	b2d0      	uxtb	r0, r2
c0d028a6:	4770      	bx	lr

c0d028a8 <USBD_Start>:
  *         Start the USB Device Core.
  * @param  pdev: Device Handle
  * @retval USBD Status
  */
USBD_StatusTypeDef  USBD_Start  (USBD_HandleTypeDef *pdev)
{
c0d028a8:	b580      	push	{r7, lr}
  
  /* Start the low level driver  */
  USBD_LL_Start(pdev); 
c0d028aa:	f7ff feb9 	bl	c0d02620 <USBD_LL_Start>
  
  return USBD_OK;  
c0d028ae:	2000      	movs	r0, #0
c0d028b0:	bd80      	pop	{r7, pc}

c0d028b2 <USBD_SetClassConfig>:
* @param  cfgidx: configuration index
* @retval status
*/

USBD_StatusTypeDef USBD_SetClassConfig(USBD_HandleTypeDef  *pdev, uint8_t cfgidx)
{
c0d028b2:	b570      	push	{r4, r5, r6, lr}
c0d028b4:	460c      	mov	r4, r1
c0d028b6:	4605      	mov	r5, r0
c0d028b8:	2600      	movs	r6, #0
  /* Set configuration  and Start the Class*/
  uint8_t intf;
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
    if(usbd_is_valid_intf(pdev, intf)) {
c0d028ba:	4628      	mov	r0, r5
c0d028bc:	4631      	mov	r1, r6
c0d028be:	f000 f96f 	bl	c0d02ba0 <usbd_is_valid_intf>
c0d028c2:	2800      	cmp	r0, #0
c0d028c4:	d00a      	beq.n	c0d028dc <USBD_SetClassConfig+0x2a>
      ((Init_t)PIC(pdev->interfacesClass[intf].pClass->Init))(pdev, cfgidx);
c0d028c6:	00f0      	lsls	r0, r6, #3
c0d028c8:	1828      	adds	r0, r5, r0
c0d028ca:	21f4      	movs	r1, #244	; 0xf4
c0d028cc:	5840      	ldr	r0, [r0, r1]
c0d028ce:	6800      	ldr	r0, [r0, #0]
c0d028d0:	f7ff f904 	bl	c0d01adc <pic>
c0d028d4:	4602      	mov	r2, r0
c0d028d6:	4628      	mov	r0, r5
c0d028d8:	4621      	mov	r1, r4
c0d028da:	4790      	blx	r2

USBD_StatusTypeDef USBD_SetClassConfig(USBD_HandleTypeDef  *pdev, uint8_t cfgidx)
{
  /* Set configuration  and Start the Class*/
  uint8_t intf;
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d028dc:	1c76      	adds	r6, r6, #1
c0d028de:	2e03      	cmp	r6, #3
c0d028e0:	d1eb      	bne.n	c0d028ba <USBD_SetClassConfig+0x8>
    if(usbd_is_valid_intf(pdev, intf)) {
      ((Init_t)PIC(pdev->interfacesClass[intf].pClass->Init))(pdev, cfgidx);
    }
  }

  return USBD_OK; 
c0d028e2:	2000      	movs	r0, #0
c0d028e4:	bd70      	pop	{r4, r5, r6, pc}

c0d028e6 <USBD_ClrClassConfig>:
* @param  pdev: device instance
* @param  cfgidx: configuration index
* @retval status: USBD_StatusTypeDef
*/
USBD_StatusTypeDef USBD_ClrClassConfig(USBD_HandleTypeDef  *pdev, uint8_t cfgidx)
{
c0d028e6:	b570      	push	{r4, r5, r6, lr}
c0d028e8:	460c      	mov	r4, r1
c0d028ea:	4605      	mov	r5, r0
c0d028ec:	2600      	movs	r6, #0
  /* Clear configuration  and De-initialize the Class process*/
  uint8_t intf;
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
    if(usbd_is_valid_intf(pdev, intf)) {
c0d028ee:	4628      	mov	r0, r5
c0d028f0:	4631      	mov	r1, r6
c0d028f2:	f000 f955 	bl	c0d02ba0 <usbd_is_valid_intf>
c0d028f6:	2800      	cmp	r0, #0
c0d028f8:	d00a      	beq.n	c0d02910 <USBD_ClrClassConfig+0x2a>
      ((DeInit_t)PIC(pdev->interfacesClass[intf].pClass->DeInit))(pdev, cfgidx);  
c0d028fa:	00f0      	lsls	r0, r6, #3
c0d028fc:	1828      	adds	r0, r5, r0
c0d028fe:	21f4      	movs	r1, #244	; 0xf4
c0d02900:	5840      	ldr	r0, [r0, r1]
c0d02902:	6840      	ldr	r0, [r0, #4]
c0d02904:	f7ff f8ea 	bl	c0d01adc <pic>
c0d02908:	4602      	mov	r2, r0
c0d0290a:	4628      	mov	r0, r5
c0d0290c:	4621      	mov	r1, r4
c0d0290e:	4790      	blx	r2
*/
USBD_StatusTypeDef USBD_ClrClassConfig(USBD_HandleTypeDef  *pdev, uint8_t cfgidx)
{
  /* Clear configuration  and De-initialize the Class process*/
  uint8_t intf;
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d02910:	1c76      	adds	r6, r6, #1
c0d02912:	2e03      	cmp	r6, #3
c0d02914:	d1eb      	bne.n	c0d028ee <USBD_ClrClassConfig+0x8>
    if(usbd_is_valid_intf(pdev, intf)) {
      ((DeInit_t)PIC(pdev->interfacesClass[intf].pClass->DeInit))(pdev, cfgidx);  
    }
  }
  return USBD_OK;
c0d02916:	2000      	movs	r0, #0
c0d02918:	bd70      	pop	{r4, r5, r6, pc}

c0d0291a <USBD_LL_SetupStage>:
*         Handle the setup stage
* @param  pdev: device instance
* @retval status
*/
USBD_StatusTypeDef USBD_LL_SetupStage(USBD_HandleTypeDef *pdev, uint8_t *psetup)
{
c0d0291a:	b5b0      	push	{r4, r5, r7, lr}
c0d0291c:	4604      	mov	r4, r0
  USBD_ParseSetupRequest(&pdev->request, psetup);
c0d0291e:	4625      	mov	r5, r4
c0d02920:	35e8      	adds	r5, #232	; 0xe8
c0d02922:	4628      	mov	r0, r5
c0d02924:	f000 fb89 	bl	c0d0303a <USBD_ParseSetupRequest>
  
  pdev->ep0_state = USBD_EP0_SETUP;
c0d02928:	20d4      	movs	r0, #212	; 0xd4
c0d0292a:	2101      	movs	r1, #1
c0d0292c:	5021      	str	r1, [r4, r0]
  pdev->ep0_data_len = pdev->request.wLength;
c0d0292e:	20ee      	movs	r0, #238	; 0xee
c0d02930:	5a20      	ldrh	r0, [r4, r0]
c0d02932:	21d8      	movs	r1, #216	; 0xd8
c0d02934:	5060      	str	r0, [r4, r1]
c0d02936:	20e8      	movs	r0, #232	; 0xe8
  
  switch (pdev->request.bmRequest & 0x1F) 
c0d02938:	5c21      	ldrb	r1, [r4, r0]
c0d0293a:	201f      	movs	r0, #31
c0d0293c:	4008      	ands	r0, r1
c0d0293e:	2802      	cmp	r0, #2
c0d02940:	d008      	beq.n	c0d02954 <USBD_LL_SetupStage+0x3a>
c0d02942:	2801      	cmp	r0, #1
c0d02944:	d00b      	beq.n	c0d0295e <USBD_LL_SetupStage+0x44>
c0d02946:	2800      	cmp	r0, #0
c0d02948:	d10e      	bne.n	c0d02968 <USBD_LL_SetupStage+0x4e>
  {
  case USB_REQ_RECIPIENT_DEVICE:   
    USBD_StdDevReq (pdev, &pdev->request);
c0d0294a:	4620      	mov	r0, r4
c0d0294c:	4629      	mov	r1, r5
c0d0294e:	f000 f934 	bl	c0d02bba <USBD_StdDevReq>
c0d02952:	e00e      	b.n	c0d02972 <USBD_LL_SetupStage+0x58>
  case USB_REQ_RECIPIENT_INTERFACE:     
    USBD_StdItfReq(pdev, &pdev->request);
    break;
    
  case USB_REQ_RECIPIENT_ENDPOINT:        
    USBD_StdEPReq(pdev, &pdev->request);   
c0d02954:	4620      	mov	r0, r4
c0d02956:	4629      	mov	r1, r5
c0d02958:	f000 fae6 	bl	c0d02f28 <USBD_StdEPReq>
c0d0295c:	e009      	b.n	c0d02972 <USBD_LL_SetupStage+0x58>
  case USB_REQ_RECIPIENT_DEVICE:   
    USBD_StdDevReq (pdev, &pdev->request);
    break;
    
  case USB_REQ_RECIPIENT_INTERFACE:     
    USBD_StdItfReq(pdev, &pdev->request);
c0d0295e:	4620      	mov	r0, r4
c0d02960:	4629      	mov	r1, r5
c0d02962:	f000 fabd 	bl	c0d02ee0 <USBD_StdItfReq>
c0d02966:	e004      	b.n	c0d02972 <USBD_LL_SetupStage+0x58>
  case USB_REQ_RECIPIENT_ENDPOINT:        
    USBD_StdEPReq(pdev, &pdev->request);   
    break;
    
  default:           
    USBD_LL_StallEP(pdev , pdev->request.bmRequest & 0x80);
c0d02968:	2080      	movs	r0, #128	; 0x80
c0d0296a:	4001      	ands	r1, r0
c0d0296c:	4620      	mov	r0, r4
c0d0296e:	f7ff fec1 	bl	c0d026f4 <USBD_LL_StallEP>
    break;
  }  
  return USBD_OK;  
c0d02972:	2000      	movs	r0, #0
c0d02974:	bdb0      	pop	{r4, r5, r7, pc}

c0d02976 <USBD_LL_DataOutStage>:
* @param  pdev: device instance
* @param  epnum: endpoint index
* @retval status
*/
USBD_StatusTypeDef USBD_LL_DataOutStage(USBD_HandleTypeDef *pdev , uint8_t epnum, uint8_t *pdata)
{
c0d02976:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02978:	b081      	sub	sp, #4
c0d0297a:	9200      	str	r2, [sp, #0]
c0d0297c:	460e      	mov	r6, r1
c0d0297e:	4604      	mov	r4, r0
  USBD_EndpointTypeDef    *pep;
  
  if(epnum == 0) 
c0d02980:	2e00      	cmp	r6, #0
c0d02982:	d01d      	beq.n	c0d029c0 <USBD_LL_DataOutStage+0x4a>
c0d02984:	4625      	mov	r5, r4
c0d02986:	35dc      	adds	r5, #220	; 0xdc
c0d02988:	2700      	movs	r7, #0
  }
  else {

    uint8_t intf;
    for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
      if( usbd_is_valid_intf(pdev, intf) &&  (pdev->interfacesClass[intf].pClass->DataOut != NULL)&&
c0d0298a:	4620      	mov	r0, r4
c0d0298c:	4639      	mov	r1, r7
c0d0298e:	f000 f907 	bl	c0d02ba0 <usbd_is_valid_intf>
c0d02992:	2800      	cmp	r0, #0
c0d02994:	d010      	beq.n	c0d029b8 <USBD_LL_DataOutStage+0x42>
c0d02996:	00f8      	lsls	r0, r7, #3
c0d02998:	1820      	adds	r0, r4, r0
c0d0299a:	21f4      	movs	r1, #244	; 0xf4
c0d0299c:	5840      	ldr	r0, [r0, r1]
c0d0299e:	6980      	ldr	r0, [r0, #24]
c0d029a0:	2800      	cmp	r0, #0
c0d029a2:	d009      	beq.n	c0d029b8 <USBD_LL_DataOutStage+0x42>
         (pdev->dev_state == USBD_STATE_CONFIGURED))
c0d029a4:	7829      	ldrb	r1, [r5, #0]
  }
  else {

    uint8_t intf;
    for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
      if( usbd_is_valid_intf(pdev, intf) &&  (pdev->interfacesClass[intf].pClass->DataOut != NULL)&&
c0d029a6:	2903      	cmp	r1, #3
c0d029a8:	d106      	bne.n	c0d029b8 <USBD_LL_DataOutStage+0x42>
         (pdev->dev_state == USBD_STATE_CONFIGURED))
      {
        ((DataOut_t)PIC(pdev->interfacesClass[intf].pClass->DataOut))(pdev, epnum, pdata); 
c0d029aa:	f7ff f897 	bl	c0d01adc <pic>
c0d029ae:	4603      	mov	r3, r0
c0d029b0:	4620      	mov	r0, r4
c0d029b2:	4631      	mov	r1, r6
c0d029b4:	9a00      	ldr	r2, [sp, #0]
c0d029b6:	4798      	blx	r3
    }
  }
  else {

    uint8_t intf;
    for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d029b8:	1c7f      	adds	r7, r7, #1
c0d029ba:	2f03      	cmp	r7, #3
c0d029bc:	d1e5      	bne.n	c0d0298a <USBD_LL_DataOutStage+0x14>
c0d029be:	e031      	b.n	c0d02a24 <USBD_LL_DataOutStage+0xae>
  
  if(epnum == 0) 
  {
    pep = &pdev->ep_out[0];
    
    if ( pdev->ep0_state == USBD_EP0_DATA_OUT)
c0d029c0:	20d4      	movs	r0, #212	; 0xd4
c0d029c2:	5820      	ldr	r0, [r4, r0]
c0d029c4:	2803      	cmp	r0, #3
c0d029c6:	d12d      	bne.n	c0d02a24 <USBD_LL_DataOutStage+0xae>
    {
      if(pep->rem_length > pep->maxpacket)
c0d029c8:	2080      	movs	r0, #128	; 0x80
c0d029ca:	5820      	ldr	r0, [r4, r0]
c0d029cc:	6fe1      	ldr	r1, [r4, #124]	; 0x7c
c0d029ce:	4281      	cmp	r1, r0
c0d029d0:	d90a      	bls.n	c0d029e8 <USBD_LL_DataOutStage+0x72>
      {
        pep->rem_length -=  pep->maxpacket;
c0d029d2:	1a09      	subs	r1, r1, r0
c0d029d4:	67e1      	str	r1, [r4, #124]	; 0x7c
c0d029d6:	4281      	cmp	r1, r0
c0d029d8:	d300      	bcc.n	c0d029dc <USBD_LL_DataOutStage+0x66>
c0d029da:	4601      	mov	r1, r0
       
        USBD_CtlContinueRx (pdev, 
c0d029dc:	b28a      	uxth	r2, r1
c0d029de:	4620      	mov	r0, r4
c0d029e0:	9900      	ldr	r1, [sp, #0]
c0d029e2:	f000 fcab 	bl	c0d0333c <USBD_CtlContinueRx>
c0d029e6:	e01d      	b.n	c0d02a24 <USBD_LL_DataOutStage+0xae>
c0d029e8:	4626      	mov	r6, r4
c0d029ea:	36dc      	adds	r6, #220	; 0xdc
c0d029ec:	2500      	movs	r5, #0
      }
      else
      {
        uint8_t intf;
        for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
          if(usbd_is_valid_intf(pdev, intf) &&  (pdev->interfacesClass[intf].pClass->EP0_RxReady != NULL)&&
c0d029ee:	4620      	mov	r0, r4
c0d029f0:	4629      	mov	r1, r5
c0d029f2:	f000 f8d5 	bl	c0d02ba0 <usbd_is_valid_intf>
c0d029f6:	2800      	cmp	r0, #0
c0d029f8:	d00e      	beq.n	c0d02a18 <USBD_LL_DataOutStage+0xa2>
c0d029fa:	00e8      	lsls	r0, r5, #3
c0d029fc:	1820      	adds	r0, r4, r0
c0d029fe:	21f4      	movs	r1, #244	; 0xf4
c0d02a00:	5840      	ldr	r0, [r0, r1]
c0d02a02:	6900      	ldr	r0, [r0, #16]
c0d02a04:	2800      	cmp	r0, #0
c0d02a06:	d007      	beq.n	c0d02a18 <USBD_LL_DataOutStage+0xa2>
             (pdev->dev_state == USBD_STATE_CONFIGURED))
c0d02a08:	7831      	ldrb	r1, [r6, #0]
      }
      else
      {
        uint8_t intf;
        for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
          if(usbd_is_valid_intf(pdev, intf) &&  (pdev->interfacesClass[intf].pClass->EP0_RxReady != NULL)&&
c0d02a0a:	2903      	cmp	r1, #3
c0d02a0c:	d104      	bne.n	c0d02a18 <USBD_LL_DataOutStage+0xa2>
             (pdev->dev_state == USBD_STATE_CONFIGURED))
          {
            ((EP0_RxReady_t)PIC(pdev->interfacesClass[intf].pClass->EP0_RxReady))(pdev); 
c0d02a0e:	f7ff f865 	bl	c0d01adc <pic>
c0d02a12:	4601      	mov	r1, r0
c0d02a14:	4620      	mov	r0, r4
c0d02a16:	4788      	blx	r1
                            MIN(pep->rem_length ,pep->maxpacket));
      }
      else
      {
        uint8_t intf;
        for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d02a18:	1c6d      	adds	r5, r5, #1
c0d02a1a:	2d03      	cmp	r5, #3
c0d02a1c:	d1e7      	bne.n	c0d029ee <USBD_LL_DataOutStage+0x78>
             (pdev->dev_state == USBD_STATE_CONFIGURED))
          {
            ((EP0_RxReady_t)PIC(pdev->interfacesClass[intf].pClass->EP0_RxReady))(pdev); 
          }
        }
        USBD_CtlSendStatus(pdev);
c0d02a1e:	4620      	mov	r0, r4
c0d02a20:	f000 fc93 	bl	c0d0334a <USBD_CtlSendStatus>
      {
        ((DataOut_t)PIC(pdev->interfacesClass[intf].pClass->DataOut))(pdev, epnum, pdata); 
      }
    }
  }  
  return USBD_OK;
c0d02a24:	2000      	movs	r0, #0
c0d02a26:	b001      	add	sp, #4
c0d02a28:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d02a2a <USBD_LL_DataInStage>:
* @param  pdev: device instance
* @param  epnum: endpoint index
* @retval status
*/
USBD_StatusTypeDef USBD_LL_DataInStage(USBD_HandleTypeDef *pdev ,uint8_t epnum, uint8_t *pdata)
{
c0d02a2a:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d02a2c:	b081      	sub	sp, #4
c0d02a2e:	460d      	mov	r5, r1
c0d02a30:	4604      	mov	r4, r0
  USBD_EndpointTypeDef    *pep;
  UNUSED(pdata);
    
  if(epnum == 0) 
c0d02a32:	2d00      	cmp	r5, #0
c0d02a34:	d01c      	beq.n	c0d02a70 <USBD_LL_DataInStage+0x46>
c0d02a36:	4627      	mov	r7, r4
c0d02a38:	37dc      	adds	r7, #220	; 0xdc
c0d02a3a:	2600      	movs	r6, #0
    }
  }
  else {
    uint8_t intf;
    for (intf = 0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
      if( usbd_is_valid_intf(pdev, intf) && (pdev->interfacesClass[intf].pClass->DataIn != NULL)&&
c0d02a3c:	4620      	mov	r0, r4
c0d02a3e:	4631      	mov	r1, r6
c0d02a40:	f000 f8ae 	bl	c0d02ba0 <usbd_is_valid_intf>
c0d02a44:	2800      	cmp	r0, #0
c0d02a46:	d00f      	beq.n	c0d02a68 <USBD_LL_DataInStage+0x3e>
c0d02a48:	00f0      	lsls	r0, r6, #3
c0d02a4a:	1820      	adds	r0, r4, r0
c0d02a4c:	21f4      	movs	r1, #244	; 0xf4
c0d02a4e:	5840      	ldr	r0, [r0, r1]
c0d02a50:	6940      	ldr	r0, [r0, #20]
c0d02a52:	2800      	cmp	r0, #0
c0d02a54:	d008      	beq.n	c0d02a68 <USBD_LL_DataInStage+0x3e>
         (pdev->dev_state == USBD_STATE_CONFIGURED))
c0d02a56:	7839      	ldrb	r1, [r7, #0]
    }
  }
  else {
    uint8_t intf;
    for (intf = 0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
      if( usbd_is_valid_intf(pdev, intf) && (pdev->interfacesClass[intf].pClass->DataIn != NULL)&&
c0d02a58:	2903      	cmp	r1, #3
c0d02a5a:	d105      	bne.n	c0d02a68 <USBD_LL_DataInStage+0x3e>
         (pdev->dev_state == USBD_STATE_CONFIGURED))
      {
        ((DataIn_t)PIC(pdev->interfacesClass[intf].pClass->DataIn))(pdev, epnum); 
c0d02a5c:	f7ff f83e 	bl	c0d01adc <pic>
c0d02a60:	4602      	mov	r2, r0
c0d02a62:	4620      	mov	r0, r4
c0d02a64:	4629      	mov	r1, r5
c0d02a66:	4790      	blx	r2
      pdev->dev_test_mode = 0;
    }
  }
  else {
    uint8_t intf;
    for (intf = 0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d02a68:	1c76      	adds	r6, r6, #1
c0d02a6a:	2e03      	cmp	r6, #3
c0d02a6c:	d1e6      	bne.n	c0d02a3c <USBD_LL_DataInStage+0x12>
c0d02a6e:	e04f      	b.n	c0d02b10 <USBD_LL_DataInStage+0xe6>
    
  if(epnum == 0) 
  {
    pep = &pdev->ep_in[0];
    
    if ( pdev->ep0_state == USBD_EP0_DATA_IN)
c0d02a70:	20d4      	movs	r0, #212	; 0xd4
c0d02a72:	5820      	ldr	r0, [r4, r0]
c0d02a74:	2802      	cmp	r0, #2
c0d02a76:	d144      	bne.n	c0d02b02 <USBD_LL_DataInStage+0xd8>
    {
      if(pep->rem_length > pep->maxpacket)
c0d02a78:	69e0      	ldr	r0, [r4, #28]
c0d02a7a:	6a25      	ldr	r5, [r4, #32]
c0d02a7c:	42a8      	cmp	r0, r5
c0d02a7e:	d90b      	bls.n	c0d02a98 <USBD_LL_DataInStage+0x6e>
      {
        pep->rem_length -=  pep->maxpacket;
c0d02a80:	1b40      	subs	r0, r0, r5
c0d02a82:	61e0      	str	r0, [r4, #28]
        pdev->pData += pep->maxpacket;
c0d02a84:	2111      	movs	r1, #17
c0d02a86:	010a      	lsls	r2, r1, #4
c0d02a88:	58a1      	ldr	r1, [r4, r2]
c0d02a8a:	1949      	adds	r1, r1, r5
c0d02a8c:	50a1      	str	r1, [r4, r2]
        USBD_LL_PrepareReceive (pdev,
                                0,
                                0);  
        */
        
        USBD_CtlContinueSendData (pdev, 
c0d02a8e:	b282      	uxth	r2, r0
c0d02a90:	4620      	mov	r0, r4
c0d02a92:	f000 fc45 	bl	c0d03320 <USBD_CtlContinueSendData>
c0d02a96:	e034      	b.n	c0d02b02 <USBD_LL_DataInStage+0xd8>
                                  pep->rem_length);
        
      }
      else
      { /* last packet is MPS multiple, so send ZLP packet */
        if((pep->total_length % pep->maxpacket == 0) &&
c0d02a98:	69a6      	ldr	r6, [r4, #24]
c0d02a9a:	4630      	mov	r0, r6
c0d02a9c:	4629      	mov	r1, r5
c0d02a9e:	f000 fcf1 	bl	c0d03484 <__aeabi_uidivmod>
c0d02aa2:	42ae      	cmp	r6, r5
c0d02aa4:	d30f      	bcc.n	c0d02ac6 <USBD_LL_DataInStage+0x9c>
c0d02aa6:	2900      	cmp	r1, #0
c0d02aa8:	d10d      	bne.n	c0d02ac6 <USBD_LL_DataInStage+0x9c>
           (pep->total_length >= pep->maxpacket) &&
             (pep->total_length < pdev->ep0_data_len ))
c0d02aaa:	20d8      	movs	r0, #216	; 0xd8
c0d02aac:	5820      	ldr	r0, [r4, r0]
c0d02aae:	4627      	mov	r7, r4
c0d02ab0:	37d8      	adds	r7, #216	; 0xd8
                                  pep->rem_length);
        
      }
      else
      { /* last packet is MPS multiple, so send ZLP packet */
        if((pep->total_length % pep->maxpacket == 0) &&
c0d02ab2:	4286      	cmp	r6, r0
c0d02ab4:	d207      	bcs.n	c0d02ac6 <USBD_LL_DataInStage+0x9c>
c0d02ab6:	2500      	movs	r5, #0
          USBD_LL_PrepareReceive (pdev,
                                  0,
                                  0);
          */

          USBD_CtlContinueSendData(pdev , NULL, 0);
c0d02ab8:	4620      	mov	r0, r4
c0d02aba:	4629      	mov	r1, r5
c0d02abc:	462a      	mov	r2, r5
c0d02abe:	f000 fc2f 	bl	c0d03320 <USBD_CtlContinueSendData>
          pdev->ep0_data_len = 0;
c0d02ac2:	603d      	str	r5, [r7, #0]
c0d02ac4:	e01d      	b.n	c0d02b02 <USBD_LL_DataInStage+0xd8>
c0d02ac6:	4626      	mov	r6, r4
c0d02ac8:	36dc      	adds	r6, #220	; 0xdc
c0d02aca:	2500      	movs	r5, #0
        }
        else
        {
          uint8_t intf;
          for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
            if(usbd_is_valid_intf(pdev, intf) && (pdev->interfacesClass[intf].pClass->EP0_TxSent != NULL)&&
c0d02acc:	4620      	mov	r0, r4
c0d02ace:	4629      	mov	r1, r5
c0d02ad0:	f000 f866 	bl	c0d02ba0 <usbd_is_valid_intf>
c0d02ad4:	2800      	cmp	r0, #0
c0d02ad6:	d00e      	beq.n	c0d02af6 <USBD_LL_DataInStage+0xcc>
c0d02ad8:	00e8      	lsls	r0, r5, #3
c0d02ada:	1820      	adds	r0, r4, r0
c0d02adc:	21f4      	movs	r1, #244	; 0xf4
c0d02ade:	5840      	ldr	r0, [r0, r1]
c0d02ae0:	68c0      	ldr	r0, [r0, #12]
c0d02ae2:	2800      	cmp	r0, #0
c0d02ae4:	d007      	beq.n	c0d02af6 <USBD_LL_DataInStage+0xcc>
               (pdev->dev_state == USBD_STATE_CONFIGURED))
c0d02ae6:	7831      	ldrb	r1, [r6, #0]
        }
        else
        {
          uint8_t intf;
          for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
            if(usbd_is_valid_intf(pdev, intf) && (pdev->interfacesClass[intf].pClass->EP0_TxSent != NULL)&&
c0d02ae8:	2903      	cmp	r1, #3
c0d02aea:	d104      	bne.n	c0d02af6 <USBD_LL_DataInStage+0xcc>
               (pdev->dev_state == USBD_STATE_CONFIGURED))
            {
              ((EP0_RxReady_t)PIC(pdev->interfacesClass[intf].pClass->EP0_TxSent))(pdev); 
c0d02aec:	f7fe fff6 	bl	c0d01adc <pic>
c0d02af0:	4601      	mov	r1, r0
c0d02af2:	4620      	mov	r0, r4
c0d02af4:	4788      	blx	r1
          
        }
        else
        {
          uint8_t intf;
          for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d02af6:	1c6d      	adds	r5, r5, #1
c0d02af8:	2d03      	cmp	r5, #3
c0d02afa:	d1e7      	bne.n	c0d02acc <USBD_LL_DataInStage+0xa2>
               (pdev->dev_state == USBD_STATE_CONFIGURED))
            {
              ((EP0_RxReady_t)PIC(pdev->interfacesClass[intf].pClass->EP0_TxSent))(pdev); 
            }
          }
          USBD_CtlReceiveStatus(pdev);
c0d02afc:	4620      	mov	r0, r4
c0d02afe:	f000 fc30 	bl	c0d03362 <USBD_CtlReceiveStatus>
        }
      }
    }
    if (pdev->dev_test_mode == 1)
c0d02b02:	20e0      	movs	r0, #224	; 0xe0
c0d02b04:	5c20      	ldrb	r0, [r4, r0]
c0d02b06:	34e0      	adds	r4, #224	; 0xe0
c0d02b08:	2801      	cmp	r0, #1
c0d02b0a:	d101      	bne.n	c0d02b10 <USBD_LL_DataInStage+0xe6>
    {
      USBD_RunTestMode(pdev); 
      pdev->dev_test_mode = 0;
c0d02b0c:	2000      	movs	r0, #0
c0d02b0e:	7020      	strb	r0, [r4, #0]
      {
        ((DataIn_t)PIC(pdev->interfacesClass[intf].pClass->DataIn))(pdev, epnum); 
      }
    }
  }
  return USBD_OK;
c0d02b10:	2000      	movs	r0, #0
c0d02b12:	b001      	add	sp, #4
c0d02b14:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d02b16 <USBD_LL_Reset>:
* @param  pdev: device instance
* @retval status
*/

USBD_StatusTypeDef USBD_LL_Reset(USBD_HandleTypeDef  *pdev)
{
c0d02b16:	b5b0      	push	{r4, r5, r7, lr}
c0d02b18:	4604      	mov	r4, r0
  pdev->ep_out[0].maxpacket = USB_MAX_EP0_SIZE;
c0d02b1a:	2080      	movs	r0, #128	; 0x80
c0d02b1c:	2140      	movs	r1, #64	; 0x40
c0d02b1e:	5021      	str	r1, [r4, r0]
  

  pdev->ep_in[0].maxpacket = USB_MAX_EP0_SIZE;
c0d02b20:	6221      	str	r1, [r4, #32]
  /* Upon Reset call user call back */
  pdev->dev_state = USBD_STATE_DEFAULT;
c0d02b22:	20dc      	movs	r0, #220	; 0xdc
c0d02b24:	2101      	movs	r1, #1
c0d02b26:	5421      	strb	r1, [r4, r0]
c0d02b28:	2500      	movs	r5, #0
 
  uint8_t intf;
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
    if( usbd_is_valid_intf(pdev, intf))
c0d02b2a:	4620      	mov	r0, r4
c0d02b2c:	4629      	mov	r1, r5
c0d02b2e:	f000 f837 	bl	c0d02ba0 <usbd_is_valid_intf>
c0d02b32:	2800      	cmp	r0, #0
c0d02b34:	d00a      	beq.n	c0d02b4c <USBD_LL_Reset+0x36>
    {
      ((DeInit_t)PIC(pdev->interfacesClass[intf].pClass->DeInit))(pdev, pdev->dev_config); 
c0d02b36:	00e8      	lsls	r0, r5, #3
c0d02b38:	1820      	adds	r0, r4, r0
c0d02b3a:	21f4      	movs	r1, #244	; 0xf4
c0d02b3c:	5840      	ldr	r0, [r0, r1]
c0d02b3e:	6840      	ldr	r0, [r0, #4]
c0d02b40:	f7fe ffcc 	bl	c0d01adc <pic>
c0d02b44:	4602      	mov	r2, r0
c0d02b46:	7921      	ldrb	r1, [r4, #4]
c0d02b48:	4620      	mov	r0, r4
c0d02b4a:	4790      	blx	r2
  pdev->ep_in[0].maxpacket = USB_MAX_EP0_SIZE;
  /* Upon Reset call user call back */
  pdev->dev_state = USBD_STATE_DEFAULT;
 
  uint8_t intf;
  for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d02b4c:	1c6d      	adds	r5, r5, #1
c0d02b4e:	2d03      	cmp	r5, #3
c0d02b50:	d1eb      	bne.n	c0d02b2a <USBD_LL_Reset+0x14>
    {
      ((DeInit_t)PIC(pdev->interfacesClass[intf].pClass->DeInit))(pdev, pdev->dev_config); 
    }
  }
  
  return USBD_OK;
c0d02b52:	2000      	movs	r0, #0
c0d02b54:	bdb0      	pop	{r4, r5, r7, pc}

c0d02b56 <USBD_LL_SetSpeed>:
* @param  pdev: device instance
* @retval status
*/
USBD_StatusTypeDef USBD_LL_SetSpeed(USBD_HandleTypeDef  *pdev, USBD_SpeedTypeDef speed)
{
  pdev->dev_speed = speed;
c0d02b56:	7401      	strb	r1, [r0, #16]
c0d02b58:	2000      	movs	r0, #0
  return USBD_OK;
c0d02b5a:	4770      	bx	lr

c0d02b5c <USBD_LL_Suspend>:
{
  UNUSED(pdev);
  // Ignored, gently
  //pdev->dev_old_state =  pdev->dev_state;
  //pdev->dev_state  = USBD_STATE_SUSPENDED;
  return USBD_OK;
c0d02b5c:	2000      	movs	r0, #0
c0d02b5e:	4770      	bx	lr

c0d02b60 <USBD_LL_Resume>:
USBD_StatusTypeDef USBD_LL_Resume(USBD_HandleTypeDef  *pdev)
{
  UNUSED(pdev);
  // Ignored, gently
  //pdev->dev_state = pdev->dev_old_state;  
  return USBD_OK;
c0d02b60:	2000      	movs	r0, #0
c0d02b62:	4770      	bx	lr

c0d02b64 <USBD_LL_SOF>:
* @param  pdev: device instance
* @retval status
*/

USBD_StatusTypeDef USBD_LL_SOF(USBD_HandleTypeDef  *pdev)
{
c0d02b64:	b5b0      	push	{r4, r5, r7, lr}
c0d02b66:	4604      	mov	r4, r0
  if(pdev->dev_state == USBD_STATE_CONFIGURED)
c0d02b68:	20dc      	movs	r0, #220	; 0xdc
c0d02b6a:	5c20      	ldrb	r0, [r4, r0]
c0d02b6c:	2803      	cmp	r0, #3
c0d02b6e:	d115      	bne.n	c0d02b9c <USBD_LL_SOF+0x38>
c0d02b70:	2500      	movs	r5, #0
  {
    uint8_t intf;
    for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
      if( usbd_is_valid_intf(pdev, intf) && pdev->interfacesClass[intf].pClass->SOF != NULL)
c0d02b72:	4620      	mov	r0, r4
c0d02b74:	4629      	mov	r1, r5
c0d02b76:	f000 f813 	bl	c0d02ba0 <usbd_is_valid_intf>
c0d02b7a:	2800      	cmp	r0, #0
c0d02b7c:	d00b      	beq.n	c0d02b96 <USBD_LL_SOF+0x32>
c0d02b7e:	00e8      	lsls	r0, r5, #3
c0d02b80:	1820      	adds	r0, r4, r0
c0d02b82:	21f4      	movs	r1, #244	; 0xf4
c0d02b84:	5840      	ldr	r0, [r0, r1]
c0d02b86:	69c0      	ldr	r0, [r0, #28]
c0d02b88:	2800      	cmp	r0, #0
c0d02b8a:	d004      	beq.n	c0d02b96 <USBD_LL_SOF+0x32>
      {
        ((SOF_t)PIC(pdev->interfacesClass[intf].pClass->SOF))(pdev); 
c0d02b8c:	f7fe ffa6 	bl	c0d01adc <pic>
c0d02b90:	4601      	mov	r1, r0
c0d02b92:	4620      	mov	r0, r4
c0d02b94:	4788      	blx	r1
USBD_StatusTypeDef USBD_LL_SOF(USBD_HandleTypeDef  *pdev)
{
  if(pdev->dev_state == USBD_STATE_CONFIGURED)
  {
    uint8_t intf;
    for (intf =0; intf < USBD_MAX_NUM_INTERFACES; intf++) {
c0d02b96:	1c6d      	adds	r5, r5, #1
c0d02b98:	2d03      	cmp	r5, #3
c0d02b9a:	d1ea      	bne.n	c0d02b72 <USBD_LL_SOF+0xe>
      {
        ((SOF_t)PIC(pdev->interfacesClass[intf].pClass->SOF))(pdev); 
      }
    }
  }
  return USBD_OK;
c0d02b9c:	2000      	movs	r0, #0
c0d02b9e:	bdb0      	pop	{r4, r5, r7, pc}

c0d02ba0 <usbd_is_valid_intf>:

/** @defgroup USBD_REQ_Private_Functions
  * @{
  */ 

unsigned int usbd_is_valid_intf(USBD_HandleTypeDef *pdev , unsigned int intf) {
c0d02ba0:	4602      	mov	r2, r0
c0d02ba2:	2000      	movs	r0, #0
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d02ba4:	2902      	cmp	r1, #2
c0d02ba6:	d807      	bhi.n	c0d02bb8 <usbd_is_valid_intf+0x18>
c0d02ba8:	00c8      	lsls	r0, r1, #3
c0d02baa:	1810      	adds	r0, r2, r0
c0d02bac:	21f4      	movs	r1, #244	; 0xf4
c0d02bae:	5841      	ldr	r1, [r0, r1]
c0d02bb0:	2001      	movs	r0, #1
c0d02bb2:	2900      	cmp	r1, #0
c0d02bb4:	d100      	bne.n	c0d02bb8 <usbd_is_valid_intf+0x18>
c0d02bb6:	4608      	mov	r0, r1
c0d02bb8:	4770      	bx	lr

c0d02bba <USBD_StdDevReq>:
* @param  pdev: device instance
* @param  req: usb request
* @retval status
*/
USBD_StatusTypeDef  USBD_StdDevReq (USBD_HandleTypeDef *pdev , USBD_SetupReqTypedef  *req)
{
c0d02bba:	b580      	push	{r7, lr}
c0d02bbc:	784a      	ldrb	r2, [r1, #1]
  USBD_StatusTypeDef ret = USBD_OK;  
  
  switch (req->bRequest) 
c0d02bbe:	2a04      	cmp	r2, #4
c0d02bc0:	dd08      	ble.n	c0d02bd4 <USBD_StdDevReq+0x1a>
c0d02bc2:	2a07      	cmp	r2, #7
c0d02bc4:	dc0f      	bgt.n	c0d02be6 <USBD_StdDevReq+0x2c>
c0d02bc6:	2a05      	cmp	r2, #5
c0d02bc8:	d014      	beq.n	c0d02bf4 <USBD_StdDevReq+0x3a>
c0d02bca:	2a06      	cmp	r2, #6
c0d02bcc:	d11b      	bne.n	c0d02c06 <USBD_StdDevReq+0x4c>
  {
  case USB_REQ_GET_DESCRIPTOR: 
    
    USBD_GetDescriptor (pdev, req) ;
c0d02bce:	f000 f821 	bl	c0d02c14 <USBD_GetDescriptor>
c0d02bd2:	e01d      	b.n	c0d02c10 <USBD_StdDevReq+0x56>
c0d02bd4:	2a00      	cmp	r2, #0
c0d02bd6:	d010      	beq.n	c0d02bfa <USBD_StdDevReq+0x40>
c0d02bd8:	2a01      	cmp	r2, #1
c0d02bda:	d017      	beq.n	c0d02c0c <USBD_StdDevReq+0x52>
c0d02bdc:	2a03      	cmp	r2, #3
c0d02bde:	d112      	bne.n	c0d02c06 <USBD_StdDevReq+0x4c>
    USBD_GetStatus (pdev , req);
    break;
    
    
  case USB_REQ_SET_FEATURE:   
    USBD_SetFeature (pdev , req);    
c0d02be0:	f000 f92f 	bl	c0d02e42 <USBD_SetFeature>
c0d02be4:	e014      	b.n	c0d02c10 <USBD_StdDevReq+0x56>
c0d02be6:	2a08      	cmp	r2, #8
c0d02be8:	d00a      	beq.n	c0d02c00 <USBD_StdDevReq+0x46>
c0d02bea:	2a09      	cmp	r2, #9
c0d02bec:	d10b      	bne.n	c0d02c06 <USBD_StdDevReq+0x4c>
  case USB_REQ_SET_ADDRESS:                      
    USBD_SetAddress(pdev, req);
    break;
    
  case USB_REQ_SET_CONFIGURATION:                    
    USBD_SetConfig (pdev , req);
c0d02bee:	f000 f8b8 	bl	c0d02d62 <USBD_SetConfig>
c0d02bf2:	e00d      	b.n	c0d02c10 <USBD_StdDevReq+0x56>
    
    USBD_GetDescriptor (pdev, req) ;
    break;
    
  case USB_REQ_SET_ADDRESS:                      
    USBD_SetAddress(pdev, req);
c0d02bf4:	f000 f890 	bl	c0d02d18 <USBD_SetAddress>
c0d02bf8:	e00a      	b.n	c0d02c10 <USBD_StdDevReq+0x56>
  case USB_REQ_GET_CONFIGURATION:                 
    USBD_GetConfig (pdev , req);
    break;
    
  case USB_REQ_GET_STATUS:                                  
    USBD_GetStatus (pdev , req);
c0d02bfa:	f000 f900 	bl	c0d02dfe <USBD_GetStatus>
c0d02bfe:	e007      	b.n	c0d02c10 <USBD_StdDevReq+0x56>
  case USB_REQ_SET_CONFIGURATION:                    
    USBD_SetConfig (pdev , req);
    break;
    
  case USB_REQ_GET_CONFIGURATION:                 
    USBD_GetConfig (pdev , req);
c0d02c00:	f000 f8e6 	bl	c0d02dd0 <USBD_GetConfig>
c0d02c04:	e004      	b.n	c0d02c10 <USBD_StdDevReq+0x56>
  case USB_REQ_CLEAR_FEATURE:                                   
    USBD_ClrFeature (pdev , req);
    break;
    
  default:  
    USBD_CtlError(pdev , req);
c0d02c06:	f000 f961 	bl	c0d02ecc <USBD_CtlError>
c0d02c0a:	e001      	b.n	c0d02c10 <USBD_StdDevReq+0x56>
  case USB_REQ_SET_FEATURE:   
    USBD_SetFeature (pdev , req);    
    break;
    
  case USB_REQ_CLEAR_FEATURE:                                   
    USBD_ClrFeature (pdev , req);
c0d02c0c:	f000 f936 	bl	c0d02e7c <USBD_ClrFeature>
  default:  
    USBD_CtlError(pdev , req);
    break;
  }
  
  return ret;
c0d02c10:	2000      	movs	r0, #0
c0d02c12:	bd80      	pop	{r7, pc}

c0d02c14 <USBD_GetDescriptor>:
* @param  req: usb request
* @retval status
*/
void USBD_GetDescriptor(USBD_HandleTypeDef *pdev , 
                               USBD_SetupReqTypedef *req)
{
c0d02c14:	b5b0      	push	{r4, r5, r7, lr}
c0d02c16:	b082      	sub	sp, #8
c0d02c18:	460d      	mov	r5, r1
c0d02c1a:	4604      	mov	r4, r0
  uint16_t len;
  uint8_t *pbuf;
  
    
  switch (req->wValue >> 8)
c0d02c1c:	8869      	ldrh	r1, [r5, #2]
c0d02c1e:	0a08      	lsrs	r0, r1, #8
c0d02c20:	2805      	cmp	r0, #5
c0d02c22:	dc12      	bgt.n	c0d02c4a <USBD_GetDescriptor+0x36>
c0d02c24:	2801      	cmp	r0, #1
c0d02c26:	d01a      	beq.n	c0d02c5e <USBD_GetDescriptor+0x4a>
c0d02c28:	2802      	cmp	r0, #2
c0d02c2a:	d022      	beq.n	c0d02c72 <USBD_GetDescriptor+0x5e>
c0d02c2c:	2803      	cmp	r0, #3
c0d02c2e:	d135      	bne.n	c0d02c9c <USBD_GetDescriptor+0x88>
c0d02c30:	b2c8      	uxtb	r0, r1
      }
    }
    break;
    
  case USB_DESC_TYPE_STRING:
    switch ((uint8_t)(req->wValue))
c0d02c32:	2802      	cmp	r0, #2
c0d02c34:	dc37      	bgt.n	c0d02ca6 <USBD_GetDescriptor+0x92>
c0d02c36:	2800      	cmp	r0, #0
c0d02c38:	d05e      	beq.n	c0d02cf8 <USBD_GetDescriptor+0xe4>
c0d02c3a:	2801      	cmp	r0, #1
c0d02c3c:	d064      	beq.n	c0d02d08 <USBD_GetDescriptor+0xf4>
c0d02c3e:	2802      	cmp	r0, #2
c0d02c40:	d12c      	bne.n	c0d02c9c <USBD_GetDescriptor+0x88>
    case USBD_IDX_MFC_STR:
      pbuf = ((GetManufacturerStrDescriptor_t)PIC(pdev->pDesc->GetManufacturerStrDescriptor))(pdev->dev_speed, &len);
      break;
      
    case USBD_IDX_PRODUCT_STR:
      pbuf = ((GetProductStrDescriptor_t)PIC(pdev->pDesc->GetProductStrDescriptor))(pdev->dev_speed, &len);
c0d02c42:	20f0      	movs	r0, #240	; 0xf0
c0d02c44:	5820      	ldr	r0, [r4, r0]
c0d02c46:	68c0      	ldr	r0, [r0, #12]
c0d02c48:	e00c      	b.n	c0d02c64 <USBD_GetDescriptor+0x50>
c0d02c4a:	2806      	cmp	r0, #6
c0d02c4c:	d01a      	beq.n	c0d02c84 <USBD_GetDescriptor+0x70>
c0d02c4e:	2807      	cmp	r0, #7
c0d02c50:	d021      	beq.n	c0d02c96 <USBD_GetDescriptor+0x82>
c0d02c52:	280f      	cmp	r0, #15
c0d02c54:	d122      	bne.n	c0d02c9c <USBD_GetDescriptor+0x88>
    
  switch (req->wValue >> 8)
  { 
#if (USBD_LPM_ENABLED == 1)
  case USB_DESC_TYPE_BOS:
    pbuf = ((GetBOSDescriptor_t)PIC(pdev->pDesc->GetBOSDescriptor))(pdev->dev_speed, &len);
c0d02c56:	20f0      	movs	r0, #240	; 0xf0
c0d02c58:	5820      	ldr	r0, [r4, r0]
c0d02c5a:	69c0      	ldr	r0, [r0, #28]
c0d02c5c:	e002      	b.n	c0d02c64 <USBD_GetDescriptor+0x50>
    break;
#endif    
  case USB_DESC_TYPE_DEVICE:
    pbuf = ((GetDeviceDescriptor_t)PIC(pdev->pDesc->GetDeviceDescriptor))(pdev->dev_speed, &len);
c0d02c5e:	20f0      	movs	r0, #240	; 0xf0
c0d02c60:	5820      	ldr	r0, [r4, r0]
c0d02c62:	6800      	ldr	r0, [r0, #0]
c0d02c64:	f7fe ff3a 	bl	c0d01adc <pic>
c0d02c68:	4602      	mov	r2, r0
c0d02c6a:	7c20      	ldrb	r0, [r4, #16]
c0d02c6c:	a901      	add	r1, sp, #4
c0d02c6e:	4790      	blx	r2
c0d02c70:	e030      	b.n	c0d02cd4 <USBD_GetDescriptor+0xc0>
    break;
    
  case USB_DESC_TYPE_CONFIGURATION:     
    if(pdev->interfacesClass[0].pClass != NULL) {
c0d02c72:	20f4      	movs	r0, #244	; 0xf4
c0d02c74:	5820      	ldr	r0, [r4, r0]
c0d02c76:	2800      	cmp	r0, #0
c0d02c78:	d01f      	beq.n	c0d02cba <USBD_GetDescriptor+0xa6>
      if(pdev->dev_speed == USBD_SPEED_HIGH )   
c0d02c7a:	7c21      	ldrb	r1, [r4, #16]
c0d02c7c:	2900      	cmp	r1, #0
c0d02c7e:	d023      	beq.n	c0d02cc8 <USBD_GetDescriptor+0xb4>
        pbuf   = (uint8_t *)((GetHSConfigDescriptor_t)PIC(pdev->interfacesClass[0].pClass->GetHSConfigDescriptor))(&len);
        //pbuf[1] = USB_DESC_TYPE_CONFIGURATION; CONST BUFFER KTHX
      }
      else
      {
        pbuf   = (uint8_t *)((GetFSConfigDescriptor_t)PIC(pdev->interfacesClass[0].pClass->GetFSConfigDescriptor))(&len);
c0d02c80:	6ac0      	ldr	r0, [r0, #44]	; 0x2c
c0d02c82:	e022      	b.n	c0d02cca <USBD_GetDescriptor+0xb6>
#endif   
    }
    break;
  case USB_DESC_TYPE_DEVICE_QUALIFIER:                   

    if(pdev->dev_speed == USBD_SPEED_HIGH && pdev->interfacesClass[0].pClass != NULL )   
c0d02c84:	7c20      	ldrb	r0, [r4, #16]
c0d02c86:	2800      	cmp	r0, #0
c0d02c88:	d108      	bne.n	c0d02c9c <USBD_GetDescriptor+0x88>
c0d02c8a:	20f4      	movs	r0, #244	; 0xf4
c0d02c8c:	5820      	ldr	r0, [r4, r0]
c0d02c8e:	2800      	cmp	r0, #0
c0d02c90:	d004      	beq.n	c0d02c9c <USBD_GetDescriptor+0x88>
    {
      pbuf   = (uint8_t *)((GetDeviceQualifierDescriptor_t)PIC(pdev->interfacesClass[0].pClass->GetDeviceQualifierDescriptor))(&len);
c0d02c92:	6b40      	ldr	r0, [r0, #52]	; 0x34
c0d02c94:	e019      	b.n	c0d02cca <USBD_GetDescriptor+0xb6>
      USBD_CtlError(pdev , req);
      return;
    } 

  case USB_DESC_TYPE_OTHER_SPEED_CONFIGURATION:
    if(pdev->dev_speed == USBD_SPEED_HIGH && pdev->interfacesClass[0].pClass != NULL)   
c0d02c96:	7c20      	ldrb	r0, [r4, #16]
c0d02c98:	2800      	cmp	r0, #0
c0d02c9a:	d00f      	beq.n	c0d02cbc <USBD_GetDescriptor+0xa8>
c0d02c9c:	4620      	mov	r0, r4
c0d02c9e:	4629      	mov	r1, r5
c0d02ca0:	f000 f914 	bl	c0d02ecc <USBD_CtlError>
c0d02ca4:	e026      	b.n	c0d02cf4 <USBD_GetDescriptor+0xe0>
c0d02ca6:	2803      	cmp	r0, #3
c0d02ca8:	d02a      	beq.n	c0d02d00 <USBD_GetDescriptor+0xec>
c0d02caa:	2804      	cmp	r0, #4
c0d02cac:	d030      	beq.n	c0d02d10 <USBD_GetDescriptor+0xfc>
c0d02cae:	2805      	cmp	r0, #5
c0d02cb0:	d1f4      	bne.n	c0d02c9c <USBD_GetDescriptor+0x88>
    case USBD_IDX_CONFIG_STR:
      pbuf = ((GetConfigurationStrDescriptor_t)PIC(pdev->pDesc->GetConfigurationStrDescriptor))(pdev->dev_speed, &len);
      break;
      
    case USBD_IDX_INTERFACE_STR:
      pbuf = ((GetInterfaceStrDescriptor_t)PIC(pdev->pDesc->GetInterfaceStrDescriptor))(pdev->dev_speed, &len);
c0d02cb2:	20f0      	movs	r0, #240	; 0xf0
c0d02cb4:	5820      	ldr	r0, [r4, r0]
c0d02cb6:	6980      	ldr	r0, [r0, #24]
c0d02cb8:	e7d4      	b.n	c0d02c64 <USBD_GetDescriptor+0x50>
c0d02cba:	e00c      	b.n	c0d02cd6 <USBD_GetDescriptor+0xc2>
      USBD_CtlError(pdev , req);
      return;
    } 

  case USB_DESC_TYPE_OTHER_SPEED_CONFIGURATION:
    if(pdev->dev_speed == USBD_SPEED_HIGH && pdev->interfacesClass[0].pClass != NULL)   
c0d02cbc:	20f4      	movs	r0, #244	; 0xf4
c0d02cbe:	5820      	ldr	r0, [r4, r0]
c0d02cc0:	2800      	cmp	r0, #0
c0d02cc2:	d0eb      	beq.n	c0d02c9c <USBD_GetDescriptor+0x88>
    {
      pbuf   = (uint8_t *)((GetOtherSpeedConfigDescriptor_t)PIC(pdev->interfacesClass[0].pClass->GetOtherSpeedConfigDescriptor))(&len);
c0d02cc4:	6b00      	ldr	r0, [r0, #48]	; 0x30
c0d02cc6:	e000      	b.n	c0d02cca <USBD_GetDescriptor+0xb6>
    
  case USB_DESC_TYPE_CONFIGURATION:     
    if(pdev->interfacesClass[0].pClass != NULL) {
      if(pdev->dev_speed == USBD_SPEED_HIGH )   
      {
        pbuf   = (uint8_t *)((GetHSConfigDescriptor_t)PIC(pdev->interfacesClass[0].pClass->GetHSConfigDescriptor))(&len);
c0d02cc8:	6a80      	ldr	r0, [r0, #40]	; 0x28
c0d02cca:	f7fe ff07 	bl	c0d01adc <pic>
c0d02cce:	4601      	mov	r1, r0
c0d02cd0:	a801      	add	r0, sp, #4
c0d02cd2:	4788      	blx	r1
c0d02cd4:	4601      	mov	r1, r0
c0d02cd6:	a801      	add	r0, sp, #4
  default: 
     USBD_CtlError(pdev , req);
    return;
  }
  
  if((len != 0)&& (req->wLength != 0))
c0d02cd8:	8802      	ldrh	r2, [r0, #0]
c0d02cda:	2a00      	cmp	r2, #0
c0d02cdc:	d00a      	beq.n	c0d02cf4 <USBD_GetDescriptor+0xe0>
c0d02cde:	88e8      	ldrh	r0, [r5, #6]
c0d02ce0:	2800      	cmp	r0, #0
c0d02ce2:	d007      	beq.n	c0d02cf4 <USBD_GetDescriptor+0xe0>
  {
    
    len = MIN(len , req->wLength);
c0d02ce4:	4282      	cmp	r2, r0
c0d02ce6:	d300      	bcc.n	c0d02cea <USBD_GetDescriptor+0xd6>
c0d02ce8:	4602      	mov	r2, r0
c0d02cea:	a801      	add	r0, sp, #4
c0d02cec:	8002      	strh	r2, [r0, #0]
    
    // prepare abort if host does not read the whole data
    //USBD_CtlReceiveStatus(pdev);

    // start transfer
    USBD_CtlSendData (pdev, 
c0d02cee:	4620      	mov	r0, r4
c0d02cf0:	f000 fb00 	bl	c0d032f4 <USBD_CtlSendData>
                      pbuf,
                      len);
  }
  
}
c0d02cf4:	b002      	add	sp, #8
c0d02cf6:	bdb0      	pop	{r4, r5, r7, pc}
    
  case USB_DESC_TYPE_STRING:
    switch ((uint8_t)(req->wValue))
    {
    case USBD_IDX_LANGID_STR:
     pbuf = ((GetLangIDStrDescriptor_t)PIC(pdev->pDesc->GetLangIDStrDescriptor))(pdev->dev_speed, &len);        
c0d02cf8:	20f0      	movs	r0, #240	; 0xf0
c0d02cfa:	5820      	ldr	r0, [r4, r0]
c0d02cfc:	6840      	ldr	r0, [r0, #4]
c0d02cfe:	e7b1      	b.n	c0d02c64 <USBD_GetDescriptor+0x50>
    case USBD_IDX_PRODUCT_STR:
      pbuf = ((GetProductStrDescriptor_t)PIC(pdev->pDesc->GetProductStrDescriptor))(pdev->dev_speed, &len);
      break;
      
    case USBD_IDX_SERIAL_STR:
      pbuf = ((GetSerialStrDescriptor_t)PIC(pdev->pDesc->GetSerialStrDescriptor))(pdev->dev_speed, &len);
c0d02d00:	20f0      	movs	r0, #240	; 0xf0
c0d02d02:	5820      	ldr	r0, [r4, r0]
c0d02d04:	6900      	ldr	r0, [r0, #16]
c0d02d06:	e7ad      	b.n	c0d02c64 <USBD_GetDescriptor+0x50>
    case USBD_IDX_LANGID_STR:
     pbuf = ((GetLangIDStrDescriptor_t)PIC(pdev->pDesc->GetLangIDStrDescriptor))(pdev->dev_speed, &len);        
      break;
      
    case USBD_IDX_MFC_STR:
      pbuf = ((GetManufacturerStrDescriptor_t)PIC(pdev->pDesc->GetManufacturerStrDescriptor))(pdev->dev_speed, &len);
c0d02d08:	20f0      	movs	r0, #240	; 0xf0
c0d02d0a:	5820      	ldr	r0, [r4, r0]
c0d02d0c:	6880      	ldr	r0, [r0, #8]
c0d02d0e:	e7a9      	b.n	c0d02c64 <USBD_GetDescriptor+0x50>
    case USBD_IDX_SERIAL_STR:
      pbuf = ((GetSerialStrDescriptor_t)PIC(pdev->pDesc->GetSerialStrDescriptor))(pdev->dev_speed, &len);
      break;
      
    case USBD_IDX_CONFIG_STR:
      pbuf = ((GetConfigurationStrDescriptor_t)PIC(pdev->pDesc->GetConfigurationStrDescriptor))(pdev->dev_speed, &len);
c0d02d10:	20f0      	movs	r0, #240	; 0xf0
c0d02d12:	5820      	ldr	r0, [r4, r0]
c0d02d14:	6940      	ldr	r0, [r0, #20]
c0d02d16:	e7a5      	b.n	c0d02c64 <USBD_GetDescriptor+0x50>

c0d02d18 <USBD_SetAddress>:
* @param  req: usb request
* @retval status
*/
void USBD_SetAddress(USBD_HandleTypeDef *pdev , 
                            USBD_SetupReqTypedef *req)
{
c0d02d18:	b570      	push	{r4, r5, r6, lr}
c0d02d1a:	4604      	mov	r4, r0
  uint8_t  dev_addr; 
  
  if ((req->wIndex == 0) && (req->wLength == 0)) 
c0d02d1c:	8888      	ldrh	r0, [r1, #4]
c0d02d1e:	2800      	cmp	r0, #0
c0d02d20:	d10b      	bne.n	c0d02d3a <USBD_SetAddress+0x22>
c0d02d22:	88c8      	ldrh	r0, [r1, #6]
c0d02d24:	2800      	cmp	r0, #0
c0d02d26:	d108      	bne.n	c0d02d3a <USBD_SetAddress+0x22>
  {
    dev_addr = (uint8_t)(req->wValue) & 0x7F;     
c0d02d28:	8848      	ldrh	r0, [r1, #2]
c0d02d2a:	267f      	movs	r6, #127	; 0x7f
c0d02d2c:	4006      	ands	r6, r0
    
    if (pdev->dev_state == USBD_STATE_CONFIGURED) 
c0d02d2e:	20dc      	movs	r0, #220	; 0xdc
c0d02d30:	5c20      	ldrb	r0, [r4, r0]
c0d02d32:	4625      	mov	r5, r4
c0d02d34:	35dc      	adds	r5, #220	; 0xdc
c0d02d36:	2803      	cmp	r0, #3
c0d02d38:	d103      	bne.n	c0d02d42 <USBD_SetAddress+0x2a>
c0d02d3a:	4620      	mov	r0, r4
c0d02d3c:	f000 f8c6 	bl	c0d02ecc <USBD_CtlError>
  } 
  else 
  {
     USBD_CtlError(pdev , req);                        
  } 
}
c0d02d40:	bd70      	pop	{r4, r5, r6, pc}
    {
      USBD_CtlError(pdev , req);
    } 
    else 
    {
      pdev->dev_address = dev_addr;
c0d02d42:	20de      	movs	r0, #222	; 0xde
c0d02d44:	5426      	strb	r6, [r4, r0]
      USBD_LL_SetUSBAddress(pdev, dev_addr);               
c0d02d46:	b2f1      	uxtb	r1, r6
c0d02d48:	4620      	mov	r0, r4
c0d02d4a:	f7ff fd2f 	bl	c0d027ac <USBD_LL_SetUSBAddress>
      USBD_CtlSendStatus(pdev);                         
c0d02d4e:	4620      	mov	r0, r4
c0d02d50:	f000 fafb 	bl	c0d0334a <USBD_CtlSendStatus>
      
      if (dev_addr != 0) 
c0d02d54:	2002      	movs	r0, #2
c0d02d56:	2101      	movs	r1, #1
c0d02d58:	2e00      	cmp	r6, #0
c0d02d5a:	d100      	bne.n	c0d02d5e <USBD_SetAddress+0x46>
c0d02d5c:	4608      	mov	r0, r1
c0d02d5e:	7028      	strb	r0, [r5, #0]
  } 
  else 
  {
     USBD_CtlError(pdev , req);                        
  } 
}
c0d02d60:	bd70      	pop	{r4, r5, r6, pc}

c0d02d62 <USBD_SetConfig>:
* @param  req: usb request
* @retval status
*/
void USBD_SetConfig(USBD_HandleTypeDef *pdev , 
                           USBD_SetupReqTypedef *req)
{
c0d02d62:	b570      	push	{r4, r5, r6, lr}
c0d02d64:	460d      	mov	r5, r1
c0d02d66:	4604      	mov	r4, r0
  
  uint8_t  cfgidx;
  
  cfgidx = (uint8_t)(req->wValue);                 
c0d02d68:	78ae      	ldrb	r6, [r5, #2]
  
  if (cfgidx > USBD_MAX_NUM_CONFIGURATION ) 
c0d02d6a:	2e02      	cmp	r6, #2
c0d02d6c:	d21d      	bcs.n	c0d02daa <USBD_SetConfig+0x48>
  {            
     USBD_CtlError(pdev , req);                              
  } 
  else 
  {
    switch (pdev->dev_state) 
c0d02d6e:	20dc      	movs	r0, #220	; 0xdc
c0d02d70:	5c21      	ldrb	r1, [r4, r0]
c0d02d72:	4620      	mov	r0, r4
c0d02d74:	30dc      	adds	r0, #220	; 0xdc
c0d02d76:	2903      	cmp	r1, #3
c0d02d78:	d007      	beq.n	c0d02d8a <USBD_SetConfig+0x28>
c0d02d7a:	2902      	cmp	r1, #2
c0d02d7c:	d115      	bne.n	c0d02daa <USBD_SetConfig+0x48>
    {
    case USBD_STATE_ADDRESSED:
      if (cfgidx) 
c0d02d7e:	2e00      	cmp	r6, #0
c0d02d80:	d022      	beq.n	c0d02dc8 <USBD_SetConfig+0x66>
      {                                			   							   							   				
        pdev->dev_config = cfgidx;
c0d02d82:	6066      	str	r6, [r4, #4]
        pdev->dev_state = USBD_STATE_CONFIGURED;
c0d02d84:	2103      	movs	r1, #3
c0d02d86:	7001      	strb	r1, [r0, #0]
c0d02d88:	e009      	b.n	c0d02d9e <USBD_SetConfig+0x3c>
      }
      USBD_CtlSendStatus(pdev);
      break;
      
    case USBD_STATE_CONFIGURED:
      if (cfgidx == 0) 
c0d02d8a:	2e00      	cmp	r6, #0
c0d02d8c:	d012      	beq.n	c0d02db4 <USBD_SetConfig+0x52>
        pdev->dev_state = USBD_STATE_ADDRESSED;
        pdev->dev_config = cfgidx;          
        USBD_ClrClassConfig(pdev , cfgidx);
        USBD_CtlSendStatus(pdev);
      } 
      else  if (cfgidx != pdev->dev_config) 
c0d02d8e:	6860      	ldr	r0, [r4, #4]
c0d02d90:	4286      	cmp	r6, r0
c0d02d92:	d019      	beq.n	c0d02dc8 <USBD_SetConfig+0x66>
      {
        /* Clear old configuration */
        USBD_ClrClassConfig(pdev , pdev->dev_config);
c0d02d94:	b2c1      	uxtb	r1, r0
c0d02d96:	4620      	mov	r0, r4
c0d02d98:	f7ff fda5 	bl	c0d028e6 <USBD_ClrClassConfig>
        
        /* set new configuration */
        pdev->dev_config = cfgidx;
c0d02d9c:	6066      	str	r6, [r4, #4]
c0d02d9e:	4620      	mov	r0, r4
c0d02da0:	4631      	mov	r1, r6
c0d02da2:	f7ff fd86 	bl	c0d028b2 <USBD_SetClassConfig>
c0d02da6:	2802      	cmp	r0, #2
c0d02da8:	d10e      	bne.n	c0d02dc8 <USBD_SetConfig+0x66>
c0d02daa:	4620      	mov	r0, r4
c0d02dac:	4629      	mov	r1, r5
c0d02dae:	f000 f88d 	bl	c0d02ecc <USBD_CtlError>
    default:					
       USBD_CtlError(pdev , req);                     
      break;
    }
  }
}
c0d02db2:	bd70      	pop	{r4, r5, r6, pc}
      break;
      
    case USBD_STATE_CONFIGURED:
      if (cfgidx == 0) 
      {                           
        pdev->dev_state = USBD_STATE_ADDRESSED;
c0d02db4:	2102      	movs	r1, #2
c0d02db6:	7001      	strb	r1, [r0, #0]
        pdev->dev_config = cfgidx;          
c0d02db8:	6066      	str	r6, [r4, #4]
        USBD_ClrClassConfig(pdev , cfgidx);
c0d02dba:	4620      	mov	r0, r4
c0d02dbc:	4631      	mov	r1, r6
c0d02dbe:	f7ff fd92 	bl	c0d028e6 <USBD_ClrClassConfig>
        USBD_CtlSendStatus(pdev);
c0d02dc2:	4620      	mov	r0, r4
c0d02dc4:	f000 fac1 	bl	c0d0334a <USBD_CtlSendStatus>
c0d02dc8:	4620      	mov	r0, r4
c0d02dca:	f000 fabe 	bl	c0d0334a <USBD_CtlSendStatus>
    default:					
       USBD_CtlError(pdev , req);                     
      break;
    }
  }
}
c0d02dce:	bd70      	pop	{r4, r5, r6, pc}

c0d02dd0 <USBD_GetConfig>:
* @param  req: usb request
* @retval status
*/
void USBD_GetConfig(USBD_HandleTypeDef *pdev , 
                           USBD_SetupReqTypedef *req)
{
c0d02dd0:	b580      	push	{r7, lr}

  if (req->wLength != 1) 
c0d02dd2:	88ca      	ldrh	r2, [r1, #6]
c0d02dd4:	2a01      	cmp	r2, #1
c0d02dd6:	d10a      	bne.n	c0d02dee <USBD_GetConfig+0x1e>
  {                   
     USBD_CtlError(pdev , req);
  }
  else 
  {
    switch (pdev->dev_state )  
c0d02dd8:	22dc      	movs	r2, #220	; 0xdc
c0d02dda:	5c82      	ldrb	r2, [r0, r2]
c0d02ddc:	2a03      	cmp	r2, #3
c0d02dde:	d009      	beq.n	c0d02df4 <USBD_GetConfig+0x24>
c0d02de0:	2a02      	cmp	r2, #2
c0d02de2:	d104      	bne.n	c0d02dee <USBD_GetConfig+0x1e>
    {
    case USBD_STATE_ADDRESSED:                     
      pdev->dev_default_config = 0;
c0d02de4:	2100      	movs	r1, #0
c0d02de6:	6081      	str	r1, [r0, #8]
c0d02de8:	4601      	mov	r1, r0
c0d02dea:	3108      	adds	r1, #8
c0d02dec:	e003      	b.n	c0d02df6 <USBD_GetConfig+0x26>
c0d02dee:	f000 f86d 	bl	c0d02ecc <USBD_CtlError>
    default:
       USBD_CtlError(pdev , req);
      break;
    }
  }
}
c0d02df2:	bd80      	pop	{r7, pc}
                        1);
      break;
      
    case USBD_STATE_CONFIGURED:   
      USBD_CtlSendData (pdev, 
                        (uint8_t *)&pdev->dev_config,
c0d02df4:	1d01      	adds	r1, r0, #4
c0d02df6:	2201      	movs	r2, #1
c0d02df8:	f000 fa7c 	bl	c0d032f4 <USBD_CtlSendData>
    default:
       USBD_CtlError(pdev , req);
      break;
    }
  }
}
c0d02dfc:	bd80      	pop	{r7, pc}

c0d02dfe <USBD_GetStatus>:
* @param  req: usb request
* @retval status
*/
void USBD_GetStatus(USBD_HandleTypeDef *pdev , 
                           USBD_SetupReqTypedef *req)
{
c0d02dfe:	b5b0      	push	{r4, r5, r7, lr}
c0d02e00:	4604      	mov	r4, r0
  
    
  switch (pdev->dev_state) 
c0d02e02:	20dc      	movs	r0, #220	; 0xdc
c0d02e04:	5c20      	ldrb	r0, [r4, r0]
c0d02e06:	22fe      	movs	r2, #254	; 0xfe
c0d02e08:	4002      	ands	r2, r0
c0d02e0a:	2a02      	cmp	r2, #2
c0d02e0c:	d115      	bne.n	c0d02e3a <USBD_GetStatus+0x3c>
  {
  case USBD_STATE_ADDRESSED:
  case USBD_STATE_CONFIGURED:
    
#if ( USBD_SELF_POWERED == 1)
    pdev->dev_config_status = USB_CONFIG_SELF_POWERED;                                  
c0d02e0e:	2001      	movs	r0, #1
c0d02e10:	60e0      	str	r0, [r4, #12]
#else
    pdev->dev_config_status = 0;                                   
#endif
                      
    if (pdev->dev_remote_wakeup) USBD_CtlReceiveStatus(pdev);
c0d02e12:	20e4      	movs	r0, #228	; 0xe4
c0d02e14:	5821      	ldr	r1, [r4, r0]
  {
  case USBD_STATE_ADDRESSED:
  case USBD_STATE_CONFIGURED:
    
#if ( USBD_SELF_POWERED == 1)
    pdev->dev_config_status = USB_CONFIG_SELF_POWERED;                                  
c0d02e16:	4625      	mov	r5, r4
c0d02e18:	350c      	adds	r5, #12
c0d02e1a:	2003      	movs	r0, #3
#else
    pdev->dev_config_status = 0;                                   
#endif
                      
    if (pdev->dev_remote_wakeup) USBD_CtlReceiveStatus(pdev);
c0d02e1c:	2900      	cmp	r1, #0
c0d02e1e:	d005      	beq.n	c0d02e2c <USBD_GetStatus+0x2e>
c0d02e20:	4620      	mov	r0, r4
c0d02e22:	f000 fa9e 	bl	c0d03362 <USBD_CtlReceiveStatus>
c0d02e26:	68e1      	ldr	r1, [r4, #12]
c0d02e28:	2002      	movs	r0, #2
c0d02e2a:	4308      	orrs	r0, r1
    {
       pdev->dev_config_status |= USB_CONFIG_REMOTE_WAKEUP;                                
c0d02e2c:	60e0      	str	r0, [r4, #12]
    }
    
    USBD_CtlSendData (pdev, 
c0d02e2e:	2202      	movs	r2, #2
c0d02e30:	4620      	mov	r0, r4
c0d02e32:	4629      	mov	r1, r5
c0d02e34:	f000 fa5e 	bl	c0d032f4 <USBD_CtlSendData>
    
  default :
    USBD_CtlError(pdev , req);                        
    break;
  }
}
c0d02e38:	bdb0      	pop	{r4, r5, r7, pc}
                      (uint8_t *)& pdev->dev_config_status,
                      2);
    break;
    
  default :
    USBD_CtlError(pdev , req);                        
c0d02e3a:	4620      	mov	r0, r4
c0d02e3c:	f000 f846 	bl	c0d02ecc <USBD_CtlError>
    break;
  }
}
c0d02e40:	bdb0      	pop	{r4, r5, r7, pc}

c0d02e42 <USBD_SetFeature>:
* @param  req: usb request
* @retval status
*/
void USBD_SetFeature(USBD_HandleTypeDef *pdev , 
                            USBD_SetupReqTypedef *req)
{
c0d02e42:	b5b0      	push	{r4, r5, r7, lr}
c0d02e44:	460d      	mov	r5, r1
c0d02e46:	4604      	mov	r4, r0

  if (req->wValue == USB_FEATURE_REMOTE_WAKEUP)
c0d02e48:	8868      	ldrh	r0, [r5, #2]
c0d02e4a:	2801      	cmp	r0, #1
c0d02e4c:	d115      	bne.n	c0d02e7a <USBD_SetFeature+0x38>
  {
    pdev->dev_remote_wakeup = 1;  
c0d02e4e:	20e4      	movs	r0, #228	; 0xe4
c0d02e50:	2101      	movs	r1, #1
c0d02e52:	5021      	str	r1, [r4, r0]
    if(usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) {
c0d02e54:	7928      	ldrb	r0, [r5, #4]
/** @defgroup USBD_REQ_Private_Functions
  * @{
  */ 

unsigned int usbd_is_valid_intf(USBD_HandleTypeDef *pdev , unsigned int intf) {
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d02e56:	2802      	cmp	r0, #2
c0d02e58:	d80c      	bhi.n	c0d02e74 <USBD_SetFeature+0x32>
c0d02e5a:	00c0      	lsls	r0, r0, #3
c0d02e5c:	1820      	adds	r0, r4, r0
c0d02e5e:	21f4      	movs	r1, #244	; 0xf4
c0d02e60:	5840      	ldr	r0, [r0, r1]
{

  if (req->wValue == USB_FEATURE_REMOTE_WAKEUP)
  {
    pdev->dev_remote_wakeup = 1;  
    if(usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) {
c0d02e62:	2800      	cmp	r0, #0
c0d02e64:	d006      	beq.n	c0d02e74 <USBD_SetFeature+0x32>
      ((Setup_t)PIC(pdev->interfacesClass[LOBYTE(req->wIndex)].pClass->Setup)) (pdev, req);   
c0d02e66:	6880      	ldr	r0, [r0, #8]
c0d02e68:	f7fe fe38 	bl	c0d01adc <pic>
c0d02e6c:	4602      	mov	r2, r0
c0d02e6e:	4620      	mov	r0, r4
c0d02e70:	4629      	mov	r1, r5
c0d02e72:	4790      	blx	r2
    }
    USBD_CtlSendStatus(pdev);
c0d02e74:	4620      	mov	r0, r4
c0d02e76:	f000 fa68 	bl	c0d0334a <USBD_CtlSendStatus>
  }

}
c0d02e7a:	bdb0      	pop	{r4, r5, r7, pc}

c0d02e7c <USBD_ClrFeature>:
* @param  req: usb request
* @retval status
*/
void USBD_ClrFeature(USBD_HandleTypeDef *pdev , 
                            USBD_SetupReqTypedef *req)
{
c0d02e7c:	b5b0      	push	{r4, r5, r7, lr}
c0d02e7e:	460d      	mov	r5, r1
c0d02e80:	4604      	mov	r4, r0
  switch (pdev->dev_state)
c0d02e82:	20dc      	movs	r0, #220	; 0xdc
c0d02e84:	5c20      	ldrb	r0, [r4, r0]
c0d02e86:	21fe      	movs	r1, #254	; 0xfe
c0d02e88:	4001      	ands	r1, r0
c0d02e8a:	2902      	cmp	r1, #2
c0d02e8c:	d119      	bne.n	c0d02ec2 <USBD_ClrFeature+0x46>
  {
  case USBD_STATE_ADDRESSED:
  case USBD_STATE_CONFIGURED:
    if (req->wValue == USB_FEATURE_REMOTE_WAKEUP) 
c0d02e8e:	8868      	ldrh	r0, [r5, #2]
c0d02e90:	2801      	cmp	r0, #1
c0d02e92:	d11a      	bne.n	c0d02eca <USBD_ClrFeature+0x4e>
    {
      pdev->dev_remote_wakeup = 0; 
c0d02e94:	20e4      	movs	r0, #228	; 0xe4
c0d02e96:	2100      	movs	r1, #0
c0d02e98:	5021      	str	r1, [r4, r0]
      if(usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) {
c0d02e9a:	7928      	ldrb	r0, [r5, #4]
/** @defgroup USBD_REQ_Private_Functions
  * @{
  */ 

unsigned int usbd_is_valid_intf(USBD_HandleTypeDef *pdev , unsigned int intf) {
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d02e9c:	2802      	cmp	r0, #2
c0d02e9e:	d80c      	bhi.n	c0d02eba <USBD_ClrFeature+0x3e>
c0d02ea0:	00c0      	lsls	r0, r0, #3
c0d02ea2:	1820      	adds	r0, r4, r0
c0d02ea4:	21f4      	movs	r1, #244	; 0xf4
c0d02ea6:	5840      	ldr	r0, [r0, r1]
  case USBD_STATE_ADDRESSED:
  case USBD_STATE_CONFIGURED:
    if (req->wValue == USB_FEATURE_REMOTE_WAKEUP) 
    {
      pdev->dev_remote_wakeup = 0; 
      if(usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) {
c0d02ea8:	2800      	cmp	r0, #0
c0d02eaa:	d006      	beq.n	c0d02eba <USBD_ClrFeature+0x3e>
        ((Setup_t)PIC(pdev->interfacesClass[LOBYTE(req->wIndex)].pClass->Setup)) (pdev, req);   
c0d02eac:	6880      	ldr	r0, [r0, #8]
c0d02eae:	f7fe fe15 	bl	c0d01adc <pic>
c0d02eb2:	4602      	mov	r2, r0
c0d02eb4:	4620      	mov	r0, r4
c0d02eb6:	4629      	mov	r1, r5
c0d02eb8:	4790      	blx	r2
      }
      USBD_CtlSendStatus(pdev);
c0d02eba:	4620      	mov	r0, r4
c0d02ebc:	f000 fa45 	bl	c0d0334a <USBD_CtlSendStatus>
    
  default :
     USBD_CtlError(pdev , req);
    break;
  }
}
c0d02ec0:	bdb0      	pop	{r4, r5, r7, pc}
      USBD_CtlSendStatus(pdev);
    }
    break;
    
  default :
     USBD_CtlError(pdev , req);
c0d02ec2:	4620      	mov	r0, r4
c0d02ec4:	4629      	mov	r1, r5
c0d02ec6:	f000 f801 	bl	c0d02ecc <USBD_CtlError>
    break;
  }
}
c0d02eca:	bdb0      	pop	{r4, r5, r7, pc}

c0d02ecc <USBD_CtlError>:
  USBD_LL_StallEP(pdev , 0);
}

__weak void USBD_CtlError( USBD_HandleTypeDef *pdev ,
                            USBD_SetupReqTypedef *req)
{
c0d02ecc:	b510      	push	{r4, lr}
c0d02ece:	4604      	mov	r4, r0
* @param  req: usb request
* @retval None
*/
void USBD_CtlStall( USBD_HandleTypeDef *pdev)
{
  USBD_LL_StallEP(pdev , 0x80);
c0d02ed0:	2180      	movs	r1, #128	; 0x80
c0d02ed2:	f7ff fc0f 	bl	c0d026f4 <USBD_LL_StallEP>
  USBD_LL_StallEP(pdev , 0);
c0d02ed6:	2100      	movs	r1, #0
c0d02ed8:	4620      	mov	r0, r4
c0d02eda:	f7ff fc0b 	bl	c0d026f4 <USBD_LL_StallEP>

__weak void USBD_CtlError( USBD_HandleTypeDef *pdev ,
                            USBD_SetupReqTypedef *req)
{
  USBD_CtlStall(pdev);
}
c0d02ede:	bd10      	pop	{r4, pc}

c0d02ee0 <USBD_StdItfReq>:
* @param  pdev: device instance
* @param  req: usb request
* @retval status
*/
USBD_StatusTypeDef  USBD_StdItfReq (USBD_HandleTypeDef *pdev , USBD_SetupReqTypedef  *req)
{
c0d02ee0:	b5b0      	push	{r4, r5, r7, lr}
c0d02ee2:	460d      	mov	r5, r1
c0d02ee4:	4604      	mov	r4, r0
  USBD_StatusTypeDef ret = USBD_OK; 
  
  switch (pdev->dev_state) 
c0d02ee6:	20dc      	movs	r0, #220	; 0xdc
c0d02ee8:	5c20      	ldrb	r0, [r4, r0]
c0d02eea:	2803      	cmp	r0, #3
c0d02eec:	d116      	bne.n	c0d02f1c <USBD_StdItfReq+0x3c>
  {
  case USBD_STATE_CONFIGURED:
    
    if (usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) 
c0d02eee:	7928      	ldrb	r0, [r5, #4]
/** @defgroup USBD_REQ_Private_Functions
  * @{
  */ 

unsigned int usbd_is_valid_intf(USBD_HandleTypeDef *pdev , unsigned int intf) {
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d02ef0:	2802      	cmp	r0, #2
c0d02ef2:	d813      	bhi.n	c0d02f1c <USBD_StdItfReq+0x3c>
c0d02ef4:	00c0      	lsls	r0, r0, #3
c0d02ef6:	1820      	adds	r0, r4, r0
c0d02ef8:	21f4      	movs	r1, #244	; 0xf4
c0d02efa:	5840      	ldr	r0, [r0, r1]
  
  switch (pdev->dev_state) 
  {
  case USBD_STATE_CONFIGURED:
    
    if (usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) 
c0d02efc:	2800      	cmp	r0, #0
c0d02efe:	d00d      	beq.n	c0d02f1c <USBD_StdItfReq+0x3c>
    {
      ((Setup_t)PIC(pdev->interfacesClass[LOBYTE(req->wIndex)].pClass->Setup)) (pdev, req);
c0d02f00:	6880      	ldr	r0, [r0, #8]
c0d02f02:	f7fe fdeb 	bl	c0d01adc <pic>
c0d02f06:	4602      	mov	r2, r0
c0d02f08:	4620      	mov	r0, r4
c0d02f0a:	4629      	mov	r1, r5
c0d02f0c:	4790      	blx	r2
      
      if((req->wLength == 0)&& (ret == USBD_OK))
c0d02f0e:	88e8      	ldrh	r0, [r5, #6]
c0d02f10:	2800      	cmp	r0, #0
c0d02f12:	d107      	bne.n	c0d02f24 <USBD_StdItfReq+0x44>
      {
         USBD_CtlSendStatus(pdev);
c0d02f14:	4620      	mov	r0, r4
c0d02f16:	f000 fa18 	bl	c0d0334a <USBD_CtlSendStatus>
c0d02f1a:	e003      	b.n	c0d02f24 <USBD_StdItfReq+0x44>
c0d02f1c:	4620      	mov	r0, r4
c0d02f1e:	4629      	mov	r1, r5
c0d02f20:	f7ff ffd4 	bl	c0d02ecc <USBD_CtlError>
    
  default:
     USBD_CtlError(pdev , req);
    break;
  }
  return USBD_OK;
c0d02f24:	2000      	movs	r0, #0
c0d02f26:	bdb0      	pop	{r4, r5, r7, pc}

c0d02f28 <USBD_StdEPReq>:
* @param  pdev: device instance
* @param  req: usb request
* @retval status
*/
USBD_StatusTypeDef  USBD_StdEPReq (USBD_HandleTypeDef *pdev , USBD_SetupReqTypedef  *req)
{
c0d02f28:	b570      	push	{r4, r5, r6, lr}
c0d02f2a:	460d      	mov	r5, r1
c0d02f2c:	4604      	mov	r4, r0
  USBD_StatusTypeDef ret = USBD_OK; 
  USBD_EndpointTypeDef   *pep;
  ep_addr  = LOBYTE(req->wIndex);   
  
  /* Check if it is a class request */
  if ((req->bmRequest & 0x60) == 0x20 && usbd_is_valid_intf(pdev, LOBYTE(req->wIndex)))
c0d02f2e:	7828      	ldrb	r0, [r5, #0]
c0d02f30:	2160      	movs	r1, #96	; 0x60
c0d02f32:	4001      	ands	r1, r0
{
  
  uint8_t   ep_addr;
  USBD_StatusTypeDef ret = USBD_OK; 
  USBD_EndpointTypeDef   *pep;
  ep_addr  = LOBYTE(req->wIndex);   
c0d02f34:	792e      	ldrb	r6, [r5, #4]
  
  /* Check if it is a class request */
  if ((req->bmRequest & 0x60) == 0x20 && usbd_is_valid_intf(pdev, LOBYTE(req->wIndex)))
c0d02f36:	2920      	cmp	r1, #32
c0d02f38:	d10f      	bne.n	c0d02f5a <USBD_StdEPReq+0x32>
/** @defgroup USBD_REQ_Private_Functions
  * @{
  */ 

unsigned int usbd_is_valid_intf(USBD_HandleTypeDef *pdev , unsigned int intf) {
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d02f3a:	2e02      	cmp	r6, #2
c0d02f3c:	d80d      	bhi.n	c0d02f5a <USBD_StdEPReq+0x32>
c0d02f3e:	00f0      	lsls	r0, r6, #3
c0d02f40:	1820      	adds	r0, r4, r0
c0d02f42:	21f4      	movs	r1, #244	; 0xf4
c0d02f44:	5840      	ldr	r0, [r0, r1]
  USBD_StatusTypeDef ret = USBD_OK; 
  USBD_EndpointTypeDef   *pep;
  ep_addr  = LOBYTE(req->wIndex);   
  
  /* Check if it is a class request */
  if ((req->bmRequest & 0x60) == 0x20 && usbd_is_valid_intf(pdev, LOBYTE(req->wIndex)))
c0d02f46:	2800      	cmp	r0, #0
c0d02f48:	d007      	beq.n	c0d02f5a <USBD_StdEPReq+0x32>
  {
    ((Setup_t)PIC(pdev->interfacesClass[LOBYTE(req->wIndex)].pClass->Setup)) (pdev, req);
c0d02f4a:	6880      	ldr	r0, [r0, #8]
c0d02f4c:	f7fe fdc6 	bl	c0d01adc <pic>
c0d02f50:	4602      	mov	r2, r0
c0d02f52:	4620      	mov	r0, r4
c0d02f54:	4629      	mov	r1, r5
c0d02f56:	4790      	blx	r2
c0d02f58:	e06d      	b.n	c0d03036 <USBD_StdEPReq+0x10e>
    
    return USBD_OK;
  }
  
  switch (req->bRequest) 
c0d02f5a:	7868      	ldrb	r0, [r5, #1]
c0d02f5c:	2800      	cmp	r0, #0
c0d02f5e:	d017      	beq.n	c0d02f90 <USBD_StdEPReq+0x68>
c0d02f60:	2801      	cmp	r0, #1
c0d02f62:	d01e      	beq.n	c0d02fa2 <USBD_StdEPReq+0x7a>
c0d02f64:	2803      	cmp	r0, #3
c0d02f66:	d166      	bne.n	c0d03036 <USBD_StdEPReq+0x10e>
  {
    
  case USB_REQ_SET_FEATURE :
    
    switch (pdev->dev_state) 
c0d02f68:	20dc      	movs	r0, #220	; 0xdc
c0d02f6a:	5c20      	ldrb	r0, [r4, r0]
c0d02f6c:	2803      	cmp	r0, #3
c0d02f6e:	d11c      	bne.n	c0d02faa <USBD_StdEPReq+0x82>
        USBD_LL_StallEP(pdev , ep_addr);
      }
      break;	
      
    case USBD_STATE_CONFIGURED:   
      if (req->wValue == USB_FEATURE_EP_HALT)
c0d02f70:	8868      	ldrh	r0, [r5, #2]
c0d02f72:	2800      	cmp	r0, #0
c0d02f74:	d108      	bne.n	c0d02f88 <USBD_StdEPReq+0x60>
      {
        if ((ep_addr != 0x00) && (ep_addr != 0x80)) 
c0d02f76:	2080      	movs	r0, #128	; 0x80
c0d02f78:	4330      	orrs	r0, r6
c0d02f7a:	2880      	cmp	r0, #128	; 0x80
c0d02f7c:	d004      	beq.n	c0d02f88 <USBD_StdEPReq+0x60>
        { 
          USBD_LL_StallEP(pdev , ep_addr);
c0d02f7e:	4620      	mov	r0, r4
c0d02f80:	4631      	mov	r1, r6
c0d02f82:	f7ff fbb7 	bl	c0d026f4 <USBD_LL_StallEP>
          
        }
c0d02f86:	792e      	ldrb	r6, [r5, #4]
/** @defgroup USBD_REQ_Private_Functions
  * @{
  */ 

unsigned int usbd_is_valid_intf(USBD_HandleTypeDef *pdev , unsigned int intf) {
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d02f88:	2e02      	cmp	r6, #2
c0d02f8a:	d851      	bhi.n	c0d03030 <USBD_StdEPReq+0x108>
c0d02f8c:	00f0      	lsls	r0, r6, #3
c0d02f8e:	e043      	b.n	c0d03018 <USBD_StdEPReq+0xf0>
      break;    
    }
    break;
    
  case USB_REQ_GET_STATUS:                  
    switch (pdev->dev_state) 
c0d02f90:	20dc      	movs	r0, #220	; 0xdc
c0d02f92:	5c20      	ldrb	r0, [r4, r0]
c0d02f94:	2803      	cmp	r0, #3
c0d02f96:	d018      	beq.n	c0d02fca <USBD_StdEPReq+0xa2>
c0d02f98:	2802      	cmp	r0, #2
c0d02f9a:	d111      	bne.n	c0d02fc0 <USBD_StdEPReq+0x98>
    {
    case USBD_STATE_ADDRESSED:          
      if ((ep_addr & 0x7F) != 0x00) 
c0d02f9c:	0670      	lsls	r0, r6, #25
c0d02f9e:	d10a      	bne.n	c0d02fb6 <USBD_StdEPReq+0x8e>
c0d02fa0:	e049      	b.n	c0d03036 <USBD_StdEPReq+0x10e>
    }
    break;
    
  case USB_REQ_CLEAR_FEATURE :
    
    switch (pdev->dev_state) 
c0d02fa2:	20dc      	movs	r0, #220	; 0xdc
c0d02fa4:	5c20      	ldrb	r0, [r4, r0]
c0d02fa6:	2803      	cmp	r0, #3
c0d02fa8:	d029      	beq.n	c0d02ffe <USBD_StdEPReq+0xd6>
c0d02faa:	2802      	cmp	r0, #2
c0d02fac:	d108      	bne.n	c0d02fc0 <USBD_StdEPReq+0x98>
c0d02fae:	2080      	movs	r0, #128	; 0x80
c0d02fb0:	4330      	orrs	r0, r6
c0d02fb2:	2880      	cmp	r0, #128	; 0x80
c0d02fb4:	d03f      	beq.n	c0d03036 <USBD_StdEPReq+0x10e>
c0d02fb6:	4620      	mov	r0, r4
c0d02fb8:	4631      	mov	r1, r6
c0d02fba:	f7ff fb9b 	bl	c0d026f4 <USBD_LL_StallEP>
c0d02fbe:	e03a      	b.n	c0d03036 <USBD_StdEPReq+0x10e>
c0d02fc0:	4620      	mov	r0, r4
c0d02fc2:	4629      	mov	r1, r5
c0d02fc4:	f7ff ff82 	bl	c0d02ecc <USBD_CtlError>
c0d02fc8:	e035      	b.n	c0d03036 <USBD_StdEPReq+0x10e>
        USBD_LL_StallEP(pdev , ep_addr);
      }
      break;	
      
    case USBD_STATE_CONFIGURED:
      pep = ((ep_addr & 0x80) == 0x80) ? &pdev->ep_in[ep_addr & 0x7F]:\
c0d02fca:	4625      	mov	r5, r4
c0d02fcc:	3514      	adds	r5, #20
                                         &pdev->ep_out[ep_addr & 0x7F];
c0d02fce:	4620      	mov	r0, r4
c0d02fd0:	3074      	adds	r0, #116	; 0x74
        USBD_LL_StallEP(pdev , ep_addr);
      }
      break;	
      
    case USBD_STATE_CONFIGURED:
      pep = ((ep_addr & 0x80) == 0x80) ? &pdev->ep_in[ep_addr & 0x7F]:\
c0d02fd2:	2180      	movs	r1, #128	; 0x80
c0d02fd4:	420e      	tst	r6, r1
c0d02fd6:	d100      	bne.n	c0d02fda <USBD_StdEPReq+0xb2>
c0d02fd8:	4605      	mov	r5, r0
                                         &pdev->ep_out[ep_addr & 0x7F];
      if(USBD_LL_IsStallEP(pdev, ep_addr))
c0d02fda:	4620      	mov	r0, r4
c0d02fdc:	4631      	mov	r1, r6
c0d02fde:	f7ff fbd3 	bl	c0d02788 <USBD_LL_IsStallEP>
c0d02fe2:	2101      	movs	r1, #1
c0d02fe4:	2800      	cmp	r0, #0
c0d02fe6:	d100      	bne.n	c0d02fea <USBD_StdEPReq+0xc2>
c0d02fe8:	4601      	mov	r1, r0
c0d02fea:	207f      	movs	r0, #127	; 0x7f
c0d02fec:	4006      	ands	r6, r0
c0d02fee:	0130      	lsls	r0, r6, #4
c0d02ff0:	5029      	str	r1, [r5, r0]
c0d02ff2:	1829      	adds	r1, r5, r0
      else
      {
        pep->status = 0x0000;  
      }
      
      USBD_CtlSendData (pdev,
c0d02ff4:	2202      	movs	r2, #2
c0d02ff6:	4620      	mov	r0, r4
c0d02ff8:	f000 f97c 	bl	c0d032f4 <USBD_CtlSendData>
c0d02ffc:	e01b      	b.n	c0d03036 <USBD_StdEPReq+0x10e>
        USBD_LL_StallEP(pdev , ep_addr);
      }
      break;	
      
    case USBD_STATE_CONFIGURED:   
      if (req->wValue == USB_FEATURE_EP_HALT)
c0d02ffe:	8868      	ldrh	r0, [r5, #2]
c0d03000:	2800      	cmp	r0, #0
c0d03002:	d118      	bne.n	c0d03036 <USBD_StdEPReq+0x10e>
      {
        if ((ep_addr & 0x7F) != 0x00) 
c0d03004:	0670      	lsls	r0, r6, #25
c0d03006:	d013      	beq.n	c0d03030 <USBD_StdEPReq+0x108>
        {        
          USBD_LL_ClearStallEP(pdev , ep_addr);
c0d03008:	4620      	mov	r0, r4
c0d0300a:	4631      	mov	r1, r6
c0d0300c:	f7ff fb98 	bl	c0d02740 <USBD_LL_ClearStallEP>
          if(usbd_is_valid_intf(pdev, LOBYTE(req->wIndex))) {
c0d03010:	7928      	ldrb	r0, [r5, #4]
/** @defgroup USBD_REQ_Private_Functions
  * @{
  */ 

unsigned int usbd_is_valid_intf(USBD_HandleTypeDef *pdev , unsigned int intf) {
  return intf < USBD_MAX_NUM_INTERFACES && pdev->interfacesClass[intf].pClass != NULL;
c0d03012:	2802      	cmp	r0, #2
c0d03014:	d80c      	bhi.n	c0d03030 <USBD_StdEPReq+0x108>
c0d03016:	00c0      	lsls	r0, r0, #3
c0d03018:	1820      	adds	r0, r4, r0
c0d0301a:	21f4      	movs	r1, #244	; 0xf4
c0d0301c:	5840      	ldr	r0, [r0, r1]
c0d0301e:	2800      	cmp	r0, #0
c0d03020:	d006      	beq.n	c0d03030 <USBD_StdEPReq+0x108>
c0d03022:	6880      	ldr	r0, [r0, #8]
c0d03024:	f7fe fd5a 	bl	c0d01adc <pic>
c0d03028:	4602      	mov	r2, r0
c0d0302a:	4620      	mov	r0, r4
c0d0302c:	4629      	mov	r1, r5
c0d0302e:	4790      	blx	r2
c0d03030:	4620      	mov	r0, r4
c0d03032:	f000 f98a 	bl	c0d0334a <USBD_CtlSendStatus>
    
  default:
    break;
  }
  return ret;
}
c0d03036:	2000      	movs	r0, #0
c0d03038:	bd70      	pop	{r4, r5, r6, pc}

c0d0303a <USBD_ParseSetupRequest>:
* @retval None
*/

void USBD_ParseSetupRequest(USBD_SetupReqTypedef *req, uint8_t *pdata)
{
  req->bmRequest     = *(uint8_t *)  (pdata);
c0d0303a:	780a      	ldrb	r2, [r1, #0]
c0d0303c:	7002      	strb	r2, [r0, #0]
  req->bRequest      = *(uint8_t *)  (pdata +  1);
c0d0303e:	784a      	ldrb	r2, [r1, #1]
c0d03040:	7042      	strb	r2, [r0, #1]
  req->wValue        = SWAPBYTE      (pdata +  2);
c0d03042:	788a      	ldrb	r2, [r1, #2]
c0d03044:	78cb      	ldrb	r3, [r1, #3]
c0d03046:	021b      	lsls	r3, r3, #8
c0d03048:	4313      	orrs	r3, r2
c0d0304a:	8043      	strh	r3, [r0, #2]
  req->wIndex        = SWAPBYTE      (pdata +  4);
c0d0304c:	790a      	ldrb	r2, [r1, #4]
c0d0304e:	794b      	ldrb	r3, [r1, #5]
c0d03050:	021b      	lsls	r3, r3, #8
c0d03052:	4313      	orrs	r3, r2
c0d03054:	8083      	strh	r3, [r0, #4]
  req->wLength       = SWAPBYTE      (pdata +  6);
c0d03056:	798a      	ldrb	r2, [r1, #6]
c0d03058:	79c9      	ldrb	r1, [r1, #7]
c0d0305a:	0209      	lsls	r1, r1, #8
c0d0305c:	4311      	orrs	r1, r2
c0d0305e:	80c1      	strh	r1, [r0, #6]

}
c0d03060:	4770      	bx	lr

c0d03062 <USBD_HID_Setup>:
  * @param  req: usb requests
  * @retval status
  */
uint8_t  USBD_HID_Setup (USBD_HandleTypeDef *pdev, 
                                USBD_SetupReqTypedef *req)
{
c0d03062:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d03064:	b083      	sub	sp, #12
c0d03066:	460d      	mov	r5, r1
c0d03068:	4604      	mov	r4, r0
c0d0306a:	a802      	add	r0, sp, #8
c0d0306c:	2700      	movs	r7, #0
  uint16_t len = 0;
c0d0306e:	8007      	strh	r7, [r0, #0]
c0d03070:	a801      	add	r0, sp, #4
  uint8_t  *pbuf = NULL;

  uint8_t val = 0;
c0d03072:	7007      	strb	r7, [r0, #0]

  switch (req->bmRequest & USB_REQ_TYPE_MASK)
c0d03074:	7829      	ldrb	r1, [r5, #0]
c0d03076:	2060      	movs	r0, #96	; 0x60
c0d03078:	4008      	ands	r0, r1
c0d0307a:	2800      	cmp	r0, #0
c0d0307c:	d010      	beq.n	c0d030a0 <USBD_HID_Setup+0x3e>
c0d0307e:	2820      	cmp	r0, #32
c0d03080:	d138      	bne.n	c0d030f4 <USBD_HID_Setup+0x92>
c0d03082:	7868      	ldrb	r0, [r5, #1]
  {
  case USB_REQ_TYPE_CLASS :  
    switch (req->bRequest)
c0d03084:	4601      	mov	r1, r0
c0d03086:	390a      	subs	r1, #10
c0d03088:	2902      	cmp	r1, #2
c0d0308a:	d333      	bcc.n	c0d030f4 <USBD_HID_Setup+0x92>
c0d0308c:	2802      	cmp	r0, #2
c0d0308e:	d01c      	beq.n	c0d030ca <USBD_HID_Setup+0x68>
c0d03090:	2803      	cmp	r0, #3
c0d03092:	d01a      	beq.n	c0d030ca <USBD_HID_Setup+0x68>
                        (uint8_t *)&val,
                        1);      
      break;      
      
    default:
      USBD_CtlError (pdev, req);
c0d03094:	4620      	mov	r0, r4
c0d03096:	4629      	mov	r1, r5
c0d03098:	f7ff ff18 	bl	c0d02ecc <USBD_CtlError>
c0d0309c:	2702      	movs	r7, #2
c0d0309e:	e029      	b.n	c0d030f4 <USBD_HID_Setup+0x92>
      return USBD_FAIL; 
    }
    break;
    
  case USB_REQ_TYPE_STANDARD:
    switch (req->bRequest)
c0d030a0:	7868      	ldrb	r0, [r5, #1]
c0d030a2:	280b      	cmp	r0, #11
c0d030a4:	d014      	beq.n	c0d030d0 <USBD_HID_Setup+0x6e>
c0d030a6:	280a      	cmp	r0, #10
c0d030a8:	d00f      	beq.n	c0d030ca <USBD_HID_Setup+0x68>
c0d030aa:	2806      	cmp	r0, #6
c0d030ac:	d122      	bne.n	c0d030f4 <USBD_HID_Setup+0x92>
    {
    case USB_REQ_GET_DESCRIPTOR: 
      // 0x22
      if( req->wValue >> 8 == HID_REPORT_DESC)
c0d030ae:	8868      	ldrh	r0, [r5, #2]
c0d030b0:	0a00      	lsrs	r0, r0, #8
c0d030b2:	2700      	movs	r7, #0
c0d030b4:	2821      	cmp	r0, #33	; 0x21
c0d030b6:	d00f      	beq.n	c0d030d8 <USBD_HID_Setup+0x76>
c0d030b8:	2822      	cmp	r0, #34	; 0x22
      
      //USBD_CtlReceiveStatus(pdev);
      
      USBD_CtlSendData (pdev, 
                        pbuf,
                        len);
c0d030ba:	463a      	mov	r2, r7
c0d030bc:	4639      	mov	r1, r7
c0d030be:	d116      	bne.n	c0d030ee <USBD_HID_Setup+0x8c>
c0d030c0:	ae02      	add	r6, sp, #8
    {
    case USB_REQ_GET_DESCRIPTOR: 
      // 0x22
      if( req->wValue >> 8 == HID_REPORT_DESC)
      {
        pbuf =  USBD_HID_GetReportDescriptor_impl(&len);
c0d030c2:	4630      	mov	r0, r6
c0d030c4:	f000 f88e 	bl	c0d031e4 <USBD_HID_GetReportDescriptor_impl>
c0d030c8:	e00a      	b.n	c0d030e0 <USBD_HID_Setup+0x7e>
c0d030ca:	a901      	add	r1, sp, #4
c0d030cc:	2201      	movs	r2, #1
c0d030ce:	e00e      	b.n	c0d030ee <USBD_HID_Setup+0x8c>
                        len);
      break;

    case USB_REQ_SET_INTERFACE :
      //hhid->AltSetting = (uint8_t)(req->wValue);
      USBD_CtlSendStatus(pdev);
c0d030d0:	4620      	mov	r0, r4
c0d030d2:	f000 f93a 	bl	c0d0334a <USBD_CtlSendStatus>
c0d030d6:	e00d      	b.n	c0d030f4 <USBD_HID_Setup+0x92>
c0d030d8:	ae02      	add	r6, sp, #8
        len = MIN(len , req->wLength);
      }
      // 0x21
      else if( req->wValue >> 8 == HID_DESCRIPTOR_TYPE)
      {
        pbuf = USBD_HID_GetHidDescriptor_impl(&len);
c0d030da:	4630      	mov	r0, r6
c0d030dc:	f000 f87a 	bl	c0d031d4 <USBD_HID_GetHidDescriptor_impl>
c0d030e0:	4601      	mov	r1, r0
c0d030e2:	8832      	ldrh	r2, [r6, #0]
c0d030e4:	88e8      	ldrh	r0, [r5, #6]
c0d030e6:	4282      	cmp	r2, r0
c0d030e8:	d300      	bcc.n	c0d030ec <USBD_HID_Setup+0x8a>
c0d030ea:	4602      	mov	r2, r0
c0d030ec:	8032      	strh	r2, [r6, #0]
c0d030ee:	4620      	mov	r0, r4
c0d030f0:	f000 f900 	bl	c0d032f4 <USBD_CtlSendData>
      
    }
  }

  return USBD_OK;
}
c0d030f4:	b2f8      	uxtb	r0, r7
c0d030f6:	b003      	add	sp, #12
c0d030f8:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d030fa <USBD_HID_Init>:
  * @param  cfgidx: Configuration index
  * @retval status
  */
uint8_t  USBD_HID_Init (USBD_HandleTypeDef *pdev, 
                               uint8_t cfgidx)
{
c0d030fa:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d030fc:	b081      	sub	sp, #4
c0d030fe:	4604      	mov	r4, r0
  UNUSED(cfgidx);

  /* Open EP IN */
  USBD_LL_OpenEP(pdev,
c0d03100:	2182      	movs	r1, #130	; 0x82
c0d03102:	2603      	movs	r6, #3
c0d03104:	2540      	movs	r5, #64	; 0x40
c0d03106:	4632      	mov	r2, r6
c0d03108:	462b      	mov	r3, r5
c0d0310a:	f7ff fab7 	bl	c0d0267c <USBD_LL_OpenEP>
c0d0310e:	2702      	movs	r7, #2
                 HID_EPIN_ADDR,
                 USBD_EP_TYPE_INTR,
                 HID_EPIN_SIZE);
  
  /* Open EP OUT */
  USBD_LL_OpenEP(pdev,
c0d03110:	4620      	mov	r0, r4
c0d03112:	4639      	mov	r1, r7
c0d03114:	4632      	mov	r2, r6
c0d03116:	462b      	mov	r3, r5
c0d03118:	f7ff fab0 	bl	c0d0267c <USBD_LL_OpenEP>
                 HID_EPOUT_ADDR,
                 USBD_EP_TYPE_INTR,
                 HID_EPOUT_SIZE);

        /* Prepare Out endpoint to receive 1st packet */ 
  USBD_LL_PrepareReceive(pdev, HID_EPOUT_ADDR, HID_EPOUT_SIZE);
c0d0311c:	4620      	mov	r0, r4
c0d0311e:	4639      	mov	r1, r7
c0d03120:	462a      	mov	r2, r5
c0d03122:	f7ff fb6e 	bl	c0d02802 <USBD_LL_PrepareReceive>
  USBD_LL_Transmit (pdev, 
                    HID_EPIN_ADDR,                                      
                    NULL,
                    0);
  */
  return USBD_OK;
c0d03126:	2000      	movs	r0, #0
c0d03128:	b001      	add	sp, #4
c0d0312a:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d0312c <USBD_HID_DeInit>:
  * @param  cfgidx: Configuration index
  * @retval status
  */
uint8_t  USBD_HID_DeInit (USBD_HandleTypeDef *pdev, 
                                 uint8_t cfgidx)
{
c0d0312c:	b510      	push	{r4, lr}
c0d0312e:	4604      	mov	r4, r0
  UNUSED(cfgidx);
  /* Close HID EP IN */
  USBD_LL_CloseEP(pdev,
c0d03130:	2182      	movs	r1, #130	; 0x82
c0d03132:	f7ff fac9 	bl	c0d026c8 <USBD_LL_CloseEP>
                  HID_EPIN_ADDR);
  
  /* Close HID EP OUT */
  USBD_LL_CloseEP(pdev,
c0d03136:	2102      	movs	r1, #2
c0d03138:	4620      	mov	r0, r4
c0d0313a:	f7ff fac5 	bl	c0d026c8 <USBD_LL_CloseEP>
                  HID_EPOUT_ADDR);
  
  return USBD_OK;
c0d0313e:	2000      	movs	r0, #0
c0d03140:	bd10      	pop	{r4, pc}
	...

c0d03144 <USBD_HID_DeviceDescriptor>:
  * @param  length: Pointer to data length variable
  * @retval Pointer to descriptor buffer
  */
uint8_t *USBD_HID_DeviceDescriptor(USBD_SpeedTypeDef speed, uint16_t *length) {
    UNUSED(speed);
    *length = sizeof(USBD_DeviceDesc);
c0d03144:	2012      	movs	r0, #18
c0d03146:	8008      	strh	r0, [r1, #0]
    return (uint8_t *)USBD_DeviceDesc;
c0d03148:	4801      	ldr	r0, [pc, #4]	; (c0d03150 <USBD_HID_DeviceDescriptor+0xc>)
c0d0314a:	4478      	add	r0, pc
c0d0314c:	4770      	bx	lr
c0d0314e:	46c0      	nop			; (mov r8, r8)
c0d03150:	00000b94 	.word	0x00000b94

c0d03154 <USBD_HID_LangIDStrDescriptor>:
  * @retval Pointer to descriptor buffer
  */
uint8_t *USBD_HID_LangIDStrDescriptor(USBD_SpeedTypeDef speed,
                                      uint16_t *length) {
    UNUSED(speed);
    *length = sizeof(USBD_LangIDDesc);
c0d03154:	2004      	movs	r0, #4
c0d03156:	8008      	strh	r0, [r1, #0]
    return (uint8_t *)USBD_LangIDDesc;
c0d03158:	4801      	ldr	r0, [pc, #4]	; (c0d03160 <USBD_HID_LangIDStrDescriptor+0xc>)
c0d0315a:	4478      	add	r0, pc
c0d0315c:	4770      	bx	lr
c0d0315e:	46c0      	nop			; (mov r8, r8)
c0d03160:	00000b02 	.word	0x00000b02

c0d03164 <USBD_HID_ProductStrDescriptor>:
  * @retval Pointer to descriptor buffer
  */
uint8_t *USBD_HID_ProductStrDescriptor(USBD_SpeedTypeDef speed,
                                       uint16_t *length) {
    UNUSED(speed);
    *length = sizeof(USBD_PRODUCT_FS_STRING);
c0d03164:	200e      	movs	r0, #14
c0d03166:	8008      	strh	r0, [r1, #0]
    return (uint8_t *)USBD_PRODUCT_FS_STRING;
c0d03168:	4801      	ldr	r0, [pc, #4]	; (c0d03170 <USBD_HID_ProductStrDescriptor+0xc>)
c0d0316a:	4478      	add	r0, pc
c0d0316c:	4770      	bx	lr
c0d0316e:	46c0      	nop			; (mov r8, r8)
c0d03170:	00000ae4 	.word	0x00000ae4

c0d03174 <USBD_HID_ManufacturerStrDescriptor>:
  * @retval Pointer to descriptor buffer
  */
uint8_t *USBD_HID_ManufacturerStrDescriptor(USBD_SpeedTypeDef speed,
                                            uint16_t *length) {
    UNUSED(speed);
    *length = sizeof(USBD_MANUFACTURER_STRING);
c0d03174:	200e      	movs	r0, #14
c0d03176:	8008      	strh	r0, [r1, #0]
    return (uint8_t *)USBD_MANUFACTURER_STRING;
c0d03178:	4801      	ldr	r0, [pc, #4]	; (c0d03180 <USBD_HID_ManufacturerStrDescriptor+0xc>)
c0d0317a:	4478      	add	r0, pc
c0d0317c:	4770      	bx	lr
c0d0317e:	46c0      	nop			; (mov r8, r8)
c0d03180:	00000af0 	.word	0x00000af0

c0d03184 <USBD_HID_SerialStrDescriptor>:
  * @retval Pointer to descriptor buffer
  */
uint8_t *USBD_HID_SerialStrDescriptor(USBD_SpeedTypeDef speed,
                                      uint16_t *length) {
    UNUSED(speed);
    *length = sizeof(USB_SERIAL_STRING);
c0d03184:	200a      	movs	r0, #10
c0d03186:	8008      	strh	r0, [r1, #0]
    return (uint8_t *)USB_SERIAL_STRING;
c0d03188:	4801      	ldr	r0, [pc, #4]	; (c0d03190 <USBD_HID_SerialStrDescriptor+0xc>)
c0d0318a:	4478      	add	r0, pc
c0d0318c:	4770      	bx	lr
c0d0318e:	46c0      	nop			; (mov r8, r8)
c0d03190:	00000ad6 	.word	0x00000ad6

c0d03194 <USBD_HID_ConfigStrDescriptor>:
  * @retval Pointer to descriptor buffer
  */
uint8_t *USBD_HID_ConfigStrDescriptor(USBD_SpeedTypeDef speed,
                                      uint16_t *length) {
    UNUSED(speed);
    *length = sizeof(USBD_CONFIGURATION_FS_STRING);
c0d03194:	200e      	movs	r0, #14
c0d03196:	8008      	strh	r0, [r1, #0]
    return (uint8_t *)USBD_CONFIGURATION_FS_STRING;
c0d03198:	4801      	ldr	r0, [pc, #4]	; (c0d031a0 <USBD_HID_ConfigStrDescriptor+0xc>)
c0d0319a:	4478      	add	r0, pc
c0d0319c:	4770      	bx	lr
c0d0319e:	46c0      	nop			; (mov r8, r8)
c0d031a0:	00000ab4 	.word	0x00000ab4

c0d031a4 <USBD_HID_InterfaceStrDescriptor>:
  * @retval Pointer to descriptor buffer
  */
uint8_t *USBD_HID_InterfaceStrDescriptor(USBD_SpeedTypeDef speed,
                                         uint16_t *length) {
    UNUSED(speed);
    *length = sizeof(USBD_INTERFACE_FS_STRING);
c0d031a4:	200e      	movs	r0, #14
c0d031a6:	8008      	strh	r0, [r1, #0]
    return (uint8_t *)USBD_INTERFACE_FS_STRING;
c0d031a8:	4801      	ldr	r0, [pc, #4]	; (c0d031b0 <USBD_HID_InterfaceStrDescriptor+0xc>)
c0d031aa:	4478      	add	r0, pc
c0d031ac:	4770      	bx	lr
c0d031ae:	46c0      	nop			; (mov r8, r8)
c0d031b0:	00000aa4 	.word	0x00000aa4

c0d031b4 <USBD_HID_GetDeviceQualifierDesc_impl>:
*         return Device Qualifier descriptor
* @param  length : pointer data length
* @retval pointer to descriptor buffer
*/
uint8_t *USBD_HID_GetDeviceQualifierDesc_impl(uint16_t *length) {
    *length = sizeof(USBD_HID_DeviceQualifierDesc);
c0d031b4:	210a      	movs	r1, #10
c0d031b6:	8001      	strh	r1, [r0, #0]
    return (uint8_t *)USBD_HID_DeviceQualifierDesc;
c0d031b8:	4801      	ldr	r0, [pc, #4]	; (c0d031c0 <USBD_HID_GetDeviceQualifierDesc_impl+0xc>)
c0d031ba:	4478      	add	r0, pc
c0d031bc:	4770      	bx	lr
c0d031be:	46c0      	nop			; (mov r8, r8)
c0d031c0:	00000b1a 	.word	0x00000b1a

c0d031c4 <USBD_HID_GetCfgDesc_impl>:
  * @param  speed : current device speed
  * @param  length : pointer data length
  * @retval pointer to descriptor buffer
  */
uint8_t *USBD_HID_GetCfgDesc_impl(uint16_t *length) {
    *length = sizeof(USBD_HID_CfgDesc);
c0d031c4:	2129      	movs	r1, #41	; 0x29
c0d031c6:	8001      	strh	r1, [r0, #0]
    return (uint8_t *)USBD_HID_CfgDesc;
c0d031c8:	4801      	ldr	r0, [pc, #4]	; (c0d031d0 <USBD_HID_GetCfgDesc_impl+0xc>)
c0d031ca:	4478      	add	r0, pc
c0d031cc:	4770      	bx	lr
c0d031ce:	46c0      	nop			; (mov r8, r8)
c0d031d0:	00000ad2 	.word	0x00000ad2

c0d031d4 <USBD_HID_GetHidDescriptor_impl>:
}

uint8_t *USBD_HID_GetHidDescriptor_impl(uint16_t *len) {
    *len = sizeof(USBD_HID_Desc);
c0d031d4:	2109      	movs	r1, #9
c0d031d6:	8001      	strh	r1, [r0, #0]
    return (uint8_t *)USBD_HID_Desc;
c0d031d8:	4801      	ldr	r0, [pc, #4]	; (c0d031e0 <USBD_HID_GetHidDescriptor_impl+0xc>)
c0d031da:	4478      	add	r0, pc
c0d031dc:	4770      	bx	lr
c0d031de:	46c0      	nop			; (mov r8, r8)
c0d031e0:	00000aee 	.word	0x00000aee

c0d031e4 <USBD_HID_GetReportDescriptor_impl>:
}

uint8_t *USBD_HID_GetReportDescriptor_impl(uint16_t *len) {
    *len = sizeof(HID_DynReportDesc);
c0d031e4:	2122      	movs	r1, #34	; 0x22
c0d031e6:	8001      	strh	r1, [r0, #0]
    return (uint8_t *)HID_DynReportDesc;
c0d031e8:	4800      	ldr	r0, [pc, #0]	; (c0d031ec <USBD_HID_GetReportDescriptor_impl+0x8>)
c0d031ea:	4770      	bx	lr
c0d031ec:	200020d8 	.word	0x200020d8

c0d031f0 <USBD_HID_DataOut_impl>:
 * sent over the out hid endpoint
  */
extern volatile unsigned short G_io_apdu_length;

uint8_t USBD_HID_DataOut_impl(USBD_HandleTypeDef *pdev, uint8_t epnum,
                              uint8_t *buffer) {
c0d031f0:	b570      	push	{r4, r5, r6, lr}
c0d031f2:	4614      	mov	r4, r2
c0d031f4:	2502      	movs	r5, #2
    UNUSED(epnum);

    // prepare receiving the next chunk (masked time)
    USBD_LL_PrepareReceive(pdev, HID_EPOUT_ADDR, HID_EPOUT_SIZE);
c0d031f6:	2240      	movs	r2, #64	; 0x40
c0d031f8:	4629      	mov	r1, r5
c0d031fa:	f7ff fb02 	bl	c0d02802 <USBD_LL_PrepareReceive>

    if (fidoActivated) {
c0d031fe:	4810      	ldr	r0, [pc, #64]	; (c0d03240 <USBD_HID_DataOut_impl+0x50>)
c0d03200:	7806      	ldrb	r6, [r0, #0]
#ifdef HAVE_U2F
        u2f_transport_handle(&u2fService, buffer,
                             io_seproxyhal_get_ep_rx_size(HID_EPOUT_ADDR),
c0d03202:	4628      	mov	r0, r5
c0d03204:	f7fd feca 	bl	c0d00f9c <io_seproxyhal_get_ep_rx_size>
c0d03208:	4602      	mov	r2, r0
    UNUSED(epnum);

    // prepare receiving the next chunk (masked time)
    USBD_LL_PrepareReceive(pdev, HID_EPOUT_ADDR, HID_EPOUT_SIZE);

    if (fidoActivated) {
c0d0320a:	2e00      	cmp	r6, #0
c0d0320c:	d005      	beq.n	c0d0321a <USBD_HID_DataOut_impl+0x2a>
#ifdef HAVE_U2F
        u2f_transport_handle(&u2fService, buffer,
c0d0320e:	480d      	ldr	r0, [pc, #52]	; (c0d03244 <USBD_HID_DataOut_impl+0x54>)
c0d03210:	2301      	movs	r3, #1
c0d03212:	4621      	mov	r1, r4
c0d03214:	f7ff f83e 	bl	c0d02294 <u2f_transport_handle>
c0d03218:	e010      	b.n	c0d0323c <USBD_HID_DataOut_impl+0x4c>
                             U2F_MEDIA_USB);
#endif
    } else {
        // add to the hid transport
        switch (
            io_usb_hid_receive(io_usb_send_apdu_data, buffer,
c0d0321a:	480f      	ldr	r0, [pc, #60]	; (c0d03258 <USBD_HID_DataOut_impl+0x68>)
c0d0321c:	4478      	add	r0, pc
c0d0321e:	4621      	mov	r1, r4
c0d03220:	f7fd fd06 	bl	c0d00c30 <io_usb_hid_receive>
                             io_seproxyhal_get_ep_rx_size(HID_EPOUT_ADDR),
                             U2F_MEDIA_USB);
#endif
    } else {
        // add to the hid transport
        switch (
c0d03224:	2802      	cmp	r0, #2
c0d03226:	d109      	bne.n	c0d0323c <USBD_HID_DataOut_impl+0x4c>
                               io_seproxyhal_get_ep_rx_size(HID_EPOUT_ADDR))) {
        default:
            break;

        case IO_USB_APDU_RECEIVED:
            G_io_apdu_media = IO_APDU_MEDIA_USB_HID; // for application code
c0d03228:	4807      	ldr	r0, [pc, #28]	; (c0d03248 <USBD_HID_DataOut_impl+0x58>)
c0d0322a:	2101      	movs	r1, #1
c0d0322c:	7001      	strb	r1, [r0, #0]
            G_io_apdu_state = APDU_USB_HID; // for next call to io_exchange
c0d0322e:	4807      	ldr	r0, [pc, #28]	; (c0d0324c <USBD_HID_DataOut_impl+0x5c>)
c0d03230:	2107      	movs	r1, #7
c0d03232:	7001      	strb	r1, [r0, #0]
            G_io_apdu_length = G_io_usb_hid_total_length;
c0d03234:	4806      	ldr	r0, [pc, #24]	; (c0d03250 <USBD_HID_DataOut_impl+0x60>)
c0d03236:	6800      	ldr	r0, [r0, #0]
c0d03238:	4906      	ldr	r1, [pc, #24]	; (c0d03254 <USBD_HID_DataOut_impl+0x64>)
c0d0323a:	8008      	strh	r0, [r1, #0]
            break;
        }
    }

    return USBD_OK;
c0d0323c:	2000      	movs	r0, #0
c0d0323e:	bd70      	pop	{r4, r5, r6, pc}
c0d03240:	200020fa 	.word	0x200020fa
c0d03244:	200018e0 	.word	0x200018e0
c0d03248:	20001ed0 	.word	0x20001ed0
c0d0324c:	20001ed7 	.word	0x20001ed7
c0d03250:	20001db4 	.word	0x20001db4
c0d03254:	20001ed8 	.word	0x20001ed8
c0d03258:	ffffdef5 	.word	0xffffdef5

c0d0325c <USB_power_U2F>:
    NULL,                                                 /*SOF */
    NULL, NULL, USBD_HID_GetCfgDesc_impl, USBD_HID_GetCfgDesc_impl,
    USBD_HID_GetCfgDesc_impl, USBD_HID_GetDeviceQualifierDesc_impl,
};

void USB_power_U2F(unsigned char enabled, unsigned char fido) {
c0d0325c:	b570      	push	{r4, r5, r6, lr}
c0d0325e:	460d      	mov	r5, r1
c0d03260:	4604      	mov	r4, r0
    uint16_t page = (fido ? PAGE_FIDO : PAGE_GENERIC);
    os_memmove(HID_DynReportDesc, HID_ReportDesc, sizeof(HID_ReportDesc));
c0d03262:	4e1c      	ldr	r6, [pc, #112]	; (c0d032d4 <USB_power_U2F+0x78>)
c0d03264:	4920      	ldr	r1, [pc, #128]	; (c0d032e8 <USB_power_U2F+0x8c>)
c0d03266:	4479      	add	r1, pc
c0d03268:	2222      	movs	r2, #34	; 0x22
c0d0326a:	4630      	mov	r0, r6
c0d0326c:	f7fd fd93 	bl	c0d00d96 <os_memmove>
    HID_DynReportDesc[1] = (page & 0xff);
c0d03270:	4819      	ldr	r0, [pc, #100]	; (c0d032d8 <USB_power_U2F+0x7c>)
c0d03272:	491a      	ldr	r1, [pc, #104]	; (c0d032dc <USB_power_U2F+0x80>)
c0d03274:	2d00      	cmp	r5, #0
c0d03276:	d100      	bne.n	c0d0327a <USB_power_U2F+0x1e>
c0d03278:	4608      	mov	r0, r1
c0d0327a:	7070      	strb	r0, [r6, #1]
    HID_DynReportDesc[2] = ((page >> 8) & 0xff);
c0d0327c:	0a00      	lsrs	r0, r0, #8
c0d0327e:	70b0      	strb	r0, [r6, #2]
c0d03280:	2001      	movs	r0, #1
    NULL, NULL, USBD_HID_GetCfgDesc_impl, USBD_HID_GetCfgDesc_impl,
    USBD_HID_GetCfgDesc_impl, USBD_HID_GetDeviceQualifierDesc_impl,
};

void USB_power_U2F(unsigned char enabled, unsigned char fido) {
    uint16_t page = (fido ? PAGE_FIDO : PAGE_GENERIC);
c0d03282:	2d00      	cmp	r5, #0
c0d03284:	d100      	bne.n	c0d03288 <USB_power_U2F+0x2c>
c0d03286:	4628      	mov	r0, r5
    os_memmove(HID_DynReportDesc, HID_ReportDesc, sizeof(HID_ReportDesc));
    HID_DynReportDesc[1] = (page & 0xff);
    HID_DynReportDesc[2] = ((page >> 8) & 0xff);
    fidoActivated = (fido ? true : false);
c0d03288:	4915      	ldr	r1, [pc, #84]	; (c0d032e0 <USB_power_U2F+0x84>)
c0d0328a:	7008      	strb	r0, [r1, #0]
c0d0328c:	2045      	movs	r0, #69	; 0x45
c0d0328e:	0085      	lsls	r5, r0, #2

    os_memset(&USBD_Device, 0, sizeof(USBD_Device));
c0d03290:	4814      	ldr	r0, [pc, #80]	; (c0d032e4 <USB_power_U2F+0x88>)
c0d03292:	2100      	movs	r1, #0
c0d03294:	462a      	mov	r2, r5
c0d03296:	f7fd fd75 	bl	c0d00d84 <os_memset>

    if (enabled) {
c0d0329a:	2c00      	cmp	r4, #0
c0d0329c:	d015      	beq.n	c0d032ca <USB_power_U2F+0x6e>
        os_memset(&USBD_Device, 0, sizeof(USBD_Device));
c0d0329e:	4c11      	ldr	r4, [pc, #68]	; (c0d032e4 <USB_power_U2F+0x88>)
c0d032a0:	2600      	movs	r6, #0
c0d032a2:	4620      	mov	r0, r4
c0d032a4:	4631      	mov	r1, r6
c0d032a6:	462a      	mov	r2, r5
c0d032a8:	f7fd fd6c 	bl	c0d00d84 <os_memset>
        /* Init Device Library */
        USBD_Init(&USBD_Device, (USBD_DescriptorsTypeDef *)&HID_Desc, 0);
c0d032ac:	490f      	ldr	r1, [pc, #60]	; (c0d032ec <USB_power_U2F+0x90>)
c0d032ae:	4479      	add	r1, pc
c0d032b0:	4620      	mov	r0, r4
c0d032b2:	4632      	mov	r2, r6
c0d032b4:	f7ff fab8 	bl	c0d02828 <USBD_Init>

        /* Register the HID class */
        USBD_RegisterClass(&USBD_Device, (USBD_ClassTypeDef *)&USBD_HID);
c0d032b8:	490d      	ldr	r1, [pc, #52]	; (c0d032f0 <USB_power_U2F+0x94>)
c0d032ba:	4479      	add	r1, pc
c0d032bc:	4620      	mov	r0, r4
c0d032be:	f7ff faeb 	bl	c0d02898 <USBD_RegisterClass>

        /* Start Device Process */
        USBD_Start(&USBD_Device);
c0d032c2:	4620      	mov	r0, r4
c0d032c4:	f7ff faf0 	bl	c0d028a8 <USBD_Start>
    } else {
        USBD_DeInit(&USBD_Device);
    }
}
c0d032c8:	bd70      	pop	{r4, r5, r6, pc}
        USBD_RegisterClass(&USBD_Device, (USBD_ClassTypeDef *)&USBD_HID);

        /* Start Device Process */
        USBD_Start(&USBD_Device);
    } else {
        USBD_DeInit(&USBD_Device);
c0d032ca:	4806      	ldr	r0, [pc, #24]	; (c0d032e4 <USB_power_U2F+0x88>)
c0d032cc:	f7ff fac6 	bl	c0d0285c <USBD_DeInit>
    }
}
c0d032d0:	bd70      	pop	{r4, r5, r6, pc}
c0d032d2:	46c0      	nop			; (mov r8, r8)
c0d032d4:	200020d8 	.word	0x200020d8
c0d032d8:	0000f1d0 	.word	0x0000f1d0
c0d032dc:	0000ffa0 	.word	0x0000ffa0
c0d032e0:	200020fa 	.word	0x200020fa
c0d032e4:	20001fc4 	.word	0x20001fc4
c0d032e8:	00000a12 	.word	0x00000a12
c0d032ec:	00000a42 	.word	0x00000a42
c0d032f0:	00000a56 	.word	0x00000a56

c0d032f4 <USBD_CtlSendData>:
* @retval status
*/
USBD_StatusTypeDef  USBD_CtlSendData (USBD_HandleTypeDef  *pdev, 
                               uint8_t *pbuf,
                               uint16_t len)
{
c0d032f4:	b5b0      	push	{r4, r5, r7, lr}
c0d032f6:	460c      	mov	r4, r1
  /* Set EP0 State */
  pdev->ep0_state          = USBD_EP0_DATA_IN;                                      
c0d032f8:	21d4      	movs	r1, #212	; 0xd4
c0d032fa:	2302      	movs	r3, #2
c0d032fc:	5043      	str	r3, [r0, r1]
  pdev->ep_in[0].total_length = len;
c0d032fe:	6182      	str	r2, [r0, #24]
  pdev->ep_in[0].rem_length   = len;
c0d03300:	61c2      	str	r2, [r0, #28]
  // store the continuation data if needed
  pdev->pData = pbuf;
c0d03302:	2111      	movs	r1, #17
c0d03304:	0109      	lsls	r1, r1, #4
c0d03306:	5044      	str	r4, [r0, r1]
 /* Start the transfer */
  USBD_LL_Transmit (pdev, 0x00, pbuf, MIN(len, pdev->ep_in[0].maxpacket));  
c0d03308:	6a01      	ldr	r1, [r0, #32]
c0d0330a:	428a      	cmp	r2, r1
c0d0330c:	d300      	bcc.n	c0d03310 <USBD_CtlSendData+0x1c>
c0d0330e:	460a      	mov	r2, r1
c0d03310:	b293      	uxth	r3, r2
c0d03312:	2500      	movs	r5, #0
c0d03314:	4629      	mov	r1, r5
c0d03316:	4622      	mov	r2, r4
c0d03318:	f7ff fa5a 	bl	c0d027d0 <USBD_LL_Transmit>
  
  return USBD_OK;
c0d0331c:	4628      	mov	r0, r5
c0d0331e:	bdb0      	pop	{r4, r5, r7, pc}

c0d03320 <USBD_CtlContinueSendData>:
* @retval status
*/
USBD_StatusTypeDef  USBD_CtlContinueSendData (USBD_HandleTypeDef  *pdev, 
                                       uint8_t *pbuf,
                                       uint16_t len)
{
c0d03320:	b5b0      	push	{r4, r5, r7, lr}
c0d03322:	460c      	mov	r4, r1
 /* Start the next transfer */
  USBD_LL_Transmit (pdev, 0x00, pbuf, MIN(len, pdev->ep_in[0].maxpacket));   
c0d03324:	6a01      	ldr	r1, [r0, #32]
c0d03326:	428a      	cmp	r2, r1
c0d03328:	d300      	bcc.n	c0d0332c <USBD_CtlContinueSendData+0xc>
c0d0332a:	460a      	mov	r2, r1
c0d0332c:	b293      	uxth	r3, r2
c0d0332e:	2500      	movs	r5, #0
c0d03330:	4629      	mov	r1, r5
c0d03332:	4622      	mov	r2, r4
c0d03334:	f7ff fa4c 	bl	c0d027d0 <USBD_LL_Transmit>
  return USBD_OK;
c0d03338:	4628      	mov	r0, r5
c0d0333a:	bdb0      	pop	{r4, r5, r7, pc}

c0d0333c <USBD_CtlContinueRx>:
* @retval status
*/
USBD_StatusTypeDef  USBD_CtlContinueRx (USBD_HandleTypeDef  *pdev, 
                                          uint8_t *pbuf,                                          
                                          uint16_t len)
{
c0d0333c:	b510      	push	{r4, lr}
c0d0333e:	2400      	movs	r4, #0
  UNUSED(pbuf);
  USBD_LL_PrepareReceive (pdev,
c0d03340:	4621      	mov	r1, r4
c0d03342:	f7ff fa5e 	bl	c0d02802 <USBD_LL_PrepareReceive>
                          0,                                            
                          len);
  return USBD_OK;
c0d03346:	4620      	mov	r0, r4
c0d03348:	bd10      	pop	{r4, pc}

c0d0334a <USBD_CtlSendStatus>:
*         send zero lzngth packet on the ctl pipe
* @param  pdev: device instance
* @retval status
*/
USBD_StatusTypeDef  USBD_CtlSendStatus (USBD_HandleTypeDef  *pdev)
{
c0d0334a:	b510      	push	{r4, lr}

  /* Set EP0 State */
  pdev->ep0_state = USBD_EP0_STATUS_IN;
c0d0334c:	21d4      	movs	r1, #212	; 0xd4
c0d0334e:	2204      	movs	r2, #4
c0d03350:	5042      	str	r2, [r0, r1]
c0d03352:	2400      	movs	r4, #0
  
 /* Start the transfer */
  USBD_LL_Transmit (pdev, 0x00, NULL, 0);   
c0d03354:	4621      	mov	r1, r4
c0d03356:	4622      	mov	r2, r4
c0d03358:	4623      	mov	r3, r4
c0d0335a:	f7ff fa39 	bl	c0d027d0 <USBD_LL_Transmit>
  
  return USBD_OK;
c0d0335e:	4620      	mov	r0, r4
c0d03360:	bd10      	pop	{r4, pc}

c0d03362 <USBD_CtlReceiveStatus>:
*         receive zero lzngth packet on the ctl pipe
* @param  pdev: device instance
* @retval status
*/
USBD_StatusTypeDef  USBD_CtlReceiveStatus (USBD_HandleTypeDef  *pdev)
{
c0d03362:	b510      	push	{r4, lr}
  /* Set EP0 State */
  pdev->ep0_state = USBD_EP0_STATUS_OUT; 
c0d03364:	21d4      	movs	r1, #212	; 0xd4
c0d03366:	2205      	movs	r2, #5
c0d03368:	5042      	str	r2, [r0, r1]
c0d0336a:	2400      	movs	r4, #0
  
 /* Start the transfer */  
  USBD_LL_PrepareReceive ( pdev,
c0d0336c:	4621      	mov	r1, r4
c0d0336e:	4622      	mov	r2, r4
c0d03370:	f7ff fa47 	bl	c0d02802 <USBD_LL_PrepareReceive>
                    0,
                    0);  

  return USBD_OK;
c0d03374:	4620      	mov	r0, r4
c0d03376:	bd10      	pop	{r4, pc}

c0d03378 <__aeabi_uidiv>:
c0d03378:	2200      	movs	r2, #0
c0d0337a:	0843      	lsrs	r3, r0, #1
c0d0337c:	428b      	cmp	r3, r1
c0d0337e:	d374      	bcc.n	c0d0346a <__aeabi_uidiv+0xf2>
c0d03380:	0903      	lsrs	r3, r0, #4
c0d03382:	428b      	cmp	r3, r1
c0d03384:	d35f      	bcc.n	c0d03446 <__aeabi_uidiv+0xce>
c0d03386:	0a03      	lsrs	r3, r0, #8
c0d03388:	428b      	cmp	r3, r1
c0d0338a:	d344      	bcc.n	c0d03416 <__aeabi_uidiv+0x9e>
c0d0338c:	0b03      	lsrs	r3, r0, #12
c0d0338e:	428b      	cmp	r3, r1
c0d03390:	d328      	bcc.n	c0d033e4 <__aeabi_uidiv+0x6c>
c0d03392:	0c03      	lsrs	r3, r0, #16
c0d03394:	428b      	cmp	r3, r1
c0d03396:	d30d      	bcc.n	c0d033b4 <__aeabi_uidiv+0x3c>
c0d03398:	22ff      	movs	r2, #255	; 0xff
c0d0339a:	0209      	lsls	r1, r1, #8
c0d0339c:	ba12      	rev	r2, r2
c0d0339e:	0c03      	lsrs	r3, r0, #16
c0d033a0:	428b      	cmp	r3, r1
c0d033a2:	d302      	bcc.n	c0d033aa <__aeabi_uidiv+0x32>
c0d033a4:	1212      	asrs	r2, r2, #8
c0d033a6:	0209      	lsls	r1, r1, #8
c0d033a8:	d065      	beq.n	c0d03476 <__aeabi_uidiv+0xfe>
c0d033aa:	0b03      	lsrs	r3, r0, #12
c0d033ac:	428b      	cmp	r3, r1
c0d033ae:	d319      	bcc.n	c0d033e4 <__aeabi_uidiv+0x6c>
c0d033b0:	e000      	b.n	c0d033b4 <__aeabi_uidiv+0x3c>
c0d033b2:	0a09      	lsrs	r1, r1, #8
c0d033b4:	0bc3      	lsrs	r3, r0, #15
c0d033b6:	428b      	cmp	r3, r1
c0d033b8:	d301      	bcc.n	c0d033be <__aeabi_uidiv+0x46>
c0d033ba:	03cb      	lsls	r3, r1, #15
c0d033bc:	1ac0      	subs	r0, r0, r3
c0d033be:	4152      	adcs	r2, r2
c0d033c0:	0b83      	lsrs	r3, r0, #14
c0d033c2:	428b      	cmp	r3, r1
c0d033c4:	d301      	bcc.n	c0d033ca <__aeabi_uidiv+0x52>
c0d033c6:	038b      	lsls	r3, r1, #14
c0d033c8:	1ac0      	subs	r0, r0, r3
c0d033ca:	4152      	adcs	r2, r2
c0d033cc:	0b43      	lsrs	r3, r0, #13
c0d033ce:	428b      	cmp	r3, r1
c0d033d0:	d301      	bcc.n	c0d033d6 <__aeabi_uidiv+0x5e>
c0d033d2:	034b      	lsls	r3, r1, #13
c0d033d4:	1ac0      	subs	r0, r0, r3
c0d033d6:	4152      	adcs	r2, r2
c0d033d8:	0b03      	lsrs	r3, r0, #12
c0d033da:	428b      	cmp	r3, r1
c0d033dc:	d301      	bcc.n	c0d033e2 <__aeabi_uidiv+0x6a>
c0d033de:	030b      	lsls	r3, r1, #12
c0d033e0:	1ac0      	subs	r0, r0, r3
c0d033e2:	4152      	adcs	r2, r2
c0d033e4:	0ac3      	lsrs	r3, r0, #11
c0d033e6:	428b      	cmp	r3, r1
c0d033e8:	d301      	bcc.n	c0d033ee <__aeabi_uidiv+0x76>
c0d033ea:	02cb      	lsls	r3, r1, #11
c0d033ec:	1ac0      	subs	r0, r0, r3
c0d033ee:	4152      	adcs	r2, r2
c0d033f0:	0a83      	lsrs	r3, r0, #10
c0d033f2:	428b      	cmp	r3, r1
c0d033f4:	d301      	bcc.n	c0d033fa <__aeabi_uidiv+0x82>
c0d033f6:	028b      	lsls	r3, r1, #10
c0d033f8:	1ac0      	subs	r0, r0, r3
c0d033fa:	4152      	adcs	r2, r2
c0d033fc:	0a43      	lsrs	r3, r0, #9
c0d033fe:	428b      	cmp	r3, r1
c0d03400:	d301      	bcc.n	c0d03406 <__aeabi_uidiv+0x8e>
c0d03402:	024b      	lsls	r3, r1, #9
c0d03404:	1ac0      	subs	r0, r0, r3
c0d03406:	4152      	adcs	r2, r2
c0d03408:	0a03      	lsrs	r3, r0, #8
c0d0340a:	428b      	cmp	r3, r1
c0d0340c:	d301      	bcc.n	c0d03412 <__aeabi_uidiv+0x9a>
c0d0340e:	020b      	lsls	r3, r1, #8
c0d03410:	1ac0      	subs	r0, r0, r3
c0d03412:	4152      	adcs	r2, r2
c0d03414:	d2cd      	bcs.n	c0d033b2 <__aeabi_uidiv+0x3a>
c0d03416:	09c3      	lsrs	r3, r0, #7
c0d03418:	428b      	cmp	r3, r1
c0d0341a:	d301      	bcc.n	c0d03420 <__aeabi_uidiv+0xa8>
c0d0341c:	01cb      	lsls	r3, r1, #7
c0d0341e:	1ac0      	subs	r0, r0, r3
c0d03420:	4152      	adcs	r2, r2
c0d03422:	0983      	lsrs	r3, r0, #6
c0d03424:	428b      	cmp	r3, r1
c0d03426:	d301      	bcc.n	c0d0342c <__aeabi_uidiv+0xb4>
c0d03428:	018b      	lsls	r3, r1, #6
c0d0342a:	1ac0      	subs	r0, r0, r3
c0d0342c:	4152      	adcs	r2, r2
c0d0342e:	0943      	lsrs	r3, r0, #5
c0d03430:	428b      	cmp	r3, r1
c0d03432:	d301      	bcc.n	c0d03438 <__aeabi_uidiv+0xc0>
c0d03434:	014b      	lsls	r3, r1, #5
c0d03436:	1ac0      	subs	r0, r0, r3
c0d03438:	4152      	adcs	r2, r2
c0d0343a:	0903      	lsrs	r3, r0, #4
c0d0343c:	428b      	cmp	r3, r1
c0d0343e:	d301      	bcc.n	c0d03444 <__aeabi_uidiv+0xcc>
c0d03440:	010b      	lsls	r3, r1, #4
c0d03442:	1ac0      	subs	r0, r0, r3
c0d03444:	4152      	adcs	r2, r2
c0d03446:	08c3      	lsrs	r3, r0, #3
c0d03448:	428b      	cmp	r3, r1
c0d0344a:	d301      	bcc.n	c0d03450 <__aeabi_uidiv+0xd8>
c0d0344c:	00cb      	lsls	r3, r1, #3
c0d0344e:	1ac0      	subs	r0, r0, r3
c0d03450:	4152      	adcs	r2, r2
c0d03452:	0883      	lsrs	r3, r0, #2
c0d03454:	428b      	cmp	r3, r1
c0d03456:	d301      	bcc.n	c0d0345c <__aeabi_uidiv+0xe4>
c0d03458:	008b      	lsls	r3, r1, #2
c0d0345a:	1ac0      	subs	r0, r0, r3
c0d0345c:	4152      	adcs	r2, r2
c0d0345e:	0843      	lsrs	r3, r0, #1
c0d03460:	428b      	cmp	r3, r1
c0d03462:	d301      	bcc.n	c0d03468 <__aeabi_uidiv+0xf0>
c0d03464:	004b      	lsls	r3, r1, #1
c0d03466:	1ac0      	subs	r0, r0, r3
c0d03468:	4152      	adcs	r2, r2
c0d0346a:	1a41      	subs	r1, r0, r1
c0d0346c:	d200      	bcs.n	c0d03470 <__aeabi_uidiv+0xf8>
c0d0346e:	4601      	mov	r1, r0
c0d03470:	4152      	adcs	r2, r2
c0d03472:	4610      	mov	r0, r2
c0d03474:	4770      	bx	lr
c0d03476:	e7ff      	b.n	c0d03478 <__aeabi_uidiv+0x100>
c0d03478:	b501      	push	{r0, lr}
c0d0347a:	2000      	movs	r0, #0
c0d0347c:	f000 f806 	bl	c0d0348c <__aeabi_idiv0>
c0d03480:	bd02      	pop	{r1, pc}
c0d03482:	46c0      	nop			; (mov r8, r8)

c0d03484 <__aeabi_uidivmod>:
c0d03484:	2900      	cmp	r1, #0
c0d03486:	d0f7      	beq.n	c0d03478 <__aeabi_uidiv+0x100>
c0d03488:	e776      	b.n	c0d03378 <__aeabi_uidiv>
c0d0348a:	4770      	bx	lr

c0d0348c <__aeabi_idiv0>:
c0d0348c:	4770      	bx	lr
c0d0348e:	46c0      	nop			; (mov r8, r8)

c0d03490 <__aeabi_memclr>:
c0d03490:	b510      	push	{r4, lr}
c0d03492:	2200      	movs	r2, #0
c0d03494:	f000 f802 	bl	c0d0349c <__aeabi_memset>
c0d03498:	bd10      	pop	{r4, pc}
c0d0349a:	46c0      	nop			; (mov r8, r8)

c0d0349c <__aeabi_memset>:
c0d0349c:	0013      	movs	r3, r2
c0d0349e:	b510      	push	{r4, lr}
c0d034a0:	000a      	movs	r2, r1
c0d034a2:	0019      	movs	r1, r3
c0d034a4:	f000 f802 	bl	c0d034ac <memset>
c0d034a8:	bd10      	pop	{r4, pc}
c0d034aa:	46c0      	nop			; (mov r8, r8)

c0d034ac <memset>:
c0d034ac:	b570      	push	{r4, r5, r6, lr}
c0d034ae:	0783      	lsls	r3, r0, #30
c0d034b0:	d03f      	beq.n	c0d03532 <memset+0x86>
c0d034b2:	1e54      	subs	r4, r2, #1
c0d034b4:	2a00      	cmp	r2, #0
c0d034b6:	d03b      	beq.n	c0d03530 <memset+0x84>
c0d034b8:	b2ce      	uxtb	r6, r1
c0d034ba:	0003      	movs	r3, r0
c0d034bc:	2503      	movs	r5, #3
c0d034be:	e003      	b.n	c0d034c8 <memset+0x1c>
c0d034c0:	1e62      	subs	r2, r4, #1
c0d034c2:	2c00      	cmp	r4, #0
c0d034c4:	d034      	beq.n	c0d03530 <memset+0x84>
c0d034c6:	0014      	movs	r4, r2
c0d034c8:	3301      	adds	r3, #1
c0d034ca:	1e5a      	subs	r2, r3, #1
c0d034cc:	7016      	strb	r6, [r2, #0]
c0d034ce:	422b      	tst	r3, r5
c0d034d0:	d1f6      	bne.n	c0d034c0 <memset+0x14>
c0d034d2:	2c03      	cmp	r4, #3
c0d034d4:	d924      	bls.n	c0d03520 <memset+0x74>
c0d034d6:	25ff      	movs	r5, #255	; 0xff
c0d034d8:	400d      	ands	r5, r1
c0d034da:	022a      	lsls	r2, r5, #8
c0d034dc:	4315      	orrs	r5, r2
c0d034de:	042a      	lsls	r2, r5, #16
c0d034e0:	4315      	orrs	r5, r2
c0d034e2:	2c0f      	cmp	r4, #15
c0d034e4:	d911      	bls.n	c0d0350a <memset+0x5e>
c0d034e6:	0026      	movs	r6, r4
c0d034e8:	3e10      	subs	r6, #16
c0d034ea:	0936      	lsrs	r6, r6, #4
c0d034ec:	3601      	adds	r6, #1
c0d034ee:	0136      	lsls	r6, r6, #4
c0d034f0:	001a      	movs	r2, r3
c0d034f2:	199b      	adds	r3, r3, r6
c0d034f4:	6015      	str	r5, [r2, #0]
c0d034f6:	6055      	str	r5, [r2, #4]
c0d034f8:	6095      	str	r5, [r2, #8]
c0d034fa:	60d5      	str	r5, [r2, #12]
c0d034fc:	3210      	adds	r2, #16
c0d034fe:	4293      	cmp	r3, r2
c0d03500:	d1f8      	bne.n	c0d034f4 <memset+0x48>
c0d03502:	220f      	movs	r2, #15
c0d03504:	4014      	ands	r4, r2
c0d03506:	2c03      	cmp	r4, #3
c0d03508:	d90a      	bls.n	c0d03520 <memset+0x74>
c0d0350a:	1f26      	subs	r6, r4, #4
c0d0350c:	08b6      	lsrs	r6, r6, #2
c0d0350e:	3601      	adds	r6, #1
c0d03510:	00b6      	lsls	r6, r6, #2
c0d03512:	001a      	movs	r2, r3
c0d03514:	199b      	adds	r3, r3, r6
c0d03516:	c220      	stmia	r2!, {r5}
c0d03518:	4293      	cmp	r3, r2
c0d0351a:	d1fc      	bne.n	c0d03516 <memset+0x6a>
c0d0351c:	2203      	movs	r2, #3
c0d0351e:	4014      	ands	r4, r2
c0d03520:	2c00      	cmp	r4, #0
c0d03522:	d005      	beq.n	c0d03530 <memset+0x84>
c0d03524:	b2c9      	uxtb	r1, r1
c0d03526:	191c      	adds	r4, r3, r4
c0d03528:	7019      	strb	r1, [r3, #0]
c0d0352a:	3301      	adds	r3, #1
c0d0352c:	429c      	cmp	r4, r3
c0d0352e:	d1fb      	bne.n	c0d03528 <memset+0x7c>
c0d03530:	bd70      	pop	{r4, r5, r6, pc}
c0d03532:	0014      	movs	r4, r2
c0d03534:	0003      	movs	r3, r0
c0d03536:	e7cc      	b.n	c0d034d2 <memset+0x26>

c0d03538 <setjmp>:
c0d03538:	c0f0      	stmia	r0!, {r4, r5, r6, r7}
c0d0353a:	4641      	mov	r1, r8
c0d0353c:	464a      	mov	r2, r9
c0d0353e:	4653      	mov	r3, sl
c0d03540:	465c      	mov	r4, fp
c0d03542:	466d      	mov	r5, sp
c0d03544:	4676      	mov	r6, lr
c0d03546:	c07e      	stmia	r0!, {r1, r2, r3, r4, r5, r6}
c0d03548:	3828      	subs	r0, #40	; 0x28
c0d0354a:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d0354c:	2000      	movs	r0, #0
c0d0354e:	4770      	bx	lr

c0d03550 <longjmp>:
c0d03550:	3010      	adds	r0, #16
c0d03552:	c87c      	ldmia	r0!, {r2, r3, r4, r5, r6}
c0d03554:	4690      	mov	r8, r2
c0d03556:	4699      	mov	r9, r3
c0d03558:	46a2      	mov	sl, r4
c0d0355a:	46ab      	mov	fp, r5
c0d0355c:	46b5      	mov	sp, r6
c0d0355e:	c808      	ldmia	r0!, {r3}
c0d03560:	3828      	subs	r0, #40	; 0x28
c0d03562:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d03564:	1c08      	adds	r0, r1, #0
c0d03566:	d100      	bne.n	c0d0356a <longjmp+0x1a>
c0d03568:	2001      	movs	r0, #1
c0d0356a:	4718      	bx	r3

c0d0356c <strlen>:
c0d0356c:	b510      	push	{r4, lr}
c0d0356e:	0783      	lsls	r3, r0, #30
c0d03570:	d027      	beq.n	c0d035c2 <strlen+0x56>
c0d03572:	7803      	ldrb	r3, [r0, #0]
c0d03574:	2b00      	cmp	r3, #0
c0d03576:	d026      	beq.n	c0d035c6 <strlen+0x5a>
c0d03578:	0003      	movs	r3, r0
c0d0357a:	2103      	movs	r1, #3
c0d0357c:	e002      	b.n	c0d03584 <strlen+0x18>
c0d0357e:	781a      	ldrb	r2, [r3, #0]
c0d03580:	2a00      	cmp	r2, #0
c0d03582:	d01c      	beq.n	c0d035be <strlen+0x52>
c0d03584:	3301      	adds	r3, #1
c0d03586:	420b      	tst	r3, r1
c0d03588:	d1f9      	bne.n	c0d0357e <strlen+0x12>
c0d0358a:	6819      	ldr	r1, [r3, #0]
c0d0358c:	4a0f      	ldr	r2, [pc, #60]	; (c0d035cc <strlen+0x60>)
c0d0358e:	4c10      	ldr	r4, [pc, #64]	; (c0d035d0 <strlen+0x64>)
c0d03590:	188a      	adds	r2, r1, r2
c0d03592:	438a      	bics	r2, r1
c0d03594:	4222      	tst	r2, r4
c0d03596:	d10f      	bne.n	c0d035b8 <strlen+0x4c>
c0d03598:	3304      	adds	r3, #4
c0d0359a:	6819      	ldr	r1, [r3, #0]
c0d0359c:	4a0b      	ldr	r2, [pc, #44]	; (c0d035cc <strlen+0x60>)
c0d0359e:	188a      	adds	r2, r1, r2
c0d035a0:	438a      	bics	r2, r1
c0d035a2:	4222      	tst	r2, r4
c0d035a4:	d108      	bne.n	c0d035b8 <strlen+0x4c>
c0d035a6:	3304      	adds	r3, #4
c0d035a8:	6819      	ldr	r1, [r3, #0]
c0d035aa:	4a08      	ldr	r2, [pc, #32]	; (c0d035cc <strlen+0x60>)
c0d035ac:	188a      	adds	r2, r1, r2
c0d035ae:	438a      	bics	r2, r1
c0d035b0:	4222      	tst	r2, r4
c0d035b2:	d0f1      	beq.n	c0d03598 <strlen+0x2c>
c0d035b4:	e000      	b.n	c0d035b8 <strlen+0x4c>
c0d035b6:	3301      	adds	r3, #1
c0d035b8:	781a      	ldrb	r2, [r3, #0]
c0d035ba:	2a00      	cmp	r2, #0
c0d035bc:	d1fb      	bne.n	c0d035b6 <strlen+0x4a>
c0d035be:	1a18      	subs	r0, r3, r0
c0d035c0:	bd10      	pop	{r4, pc}
c0d035c2:	0003      	movs	r3, r0
c0d035c4:	e7e1      	b.n	c0d0358a <strlen+0x1e>
c0d035c6:	2000      	movs	r0, #0
c0d035c8:	e7fa      	b.n	c0d035c0 <strlen+0x54>
c0d035ca:	46c0      	nop			; (mov r8, r8)
c0d035cc:	fefefeff 	.word	0xfefefeff
c0d035d0:	80808080 	.word	0x80808080

c0d035d4 <C_icon_colors>:
c0d035d4:	00000000 00ffffff                       ........

c0d035dc <C_icon_bitmap>:
c0d035dc:	ffffffff ffc3ffff e003f003 c133c793     ..............3.
c0d035ec:	e667cc67 f85fe24f fe3ffc1f ffffff7f     g.g.O._...?.....

c0d035fc <C_icon>:
c0d035fc:	00000010 00000010 00000001 c0d035d4     .............5..
c0d0360c:	c0d035dc                                .5..

c0d03610 <C_icon_back_colors>:
c0d03610:	00000000 00ffffff                       ........

c0d03618 <C_icon_back_bitmap>:
c0d03618:	c1fe01e0 067f38fd c4ff81df bcfff37f     .....8..........
c0d03628:	f1e7e71f 7807f83f 00000000              ....?..x....

c0d03634 <C_icon_back>:
c0d03634:	0000000e 0000000e 00000001 c0d03610     .............6..
c0d03644:	c0d03618                                .6..

c0d03648 <C_icon_dashboard_colors>:
c0d03648:	00000000 00ffffff                       ........

c0d03650 <C_icon_dashboard_bitmap>:
c0d03650:	c1fe01e0 067038ff 9e7e79d8 b9e7e79f     .....8p..y~.....
c0d03660:	f1c0e601 7807f83f 00000000              ....?..x....

c0d0366c <C_icon_dashboard>:
c0d0366c:	0000000e 0000000e 00000001 c0d03648     ............H6..
c0d0367c:	c0d03650 59006f4e 42007365 73776f72     P6..No.Yes.Brows
c0d0368c:	73207265 6f707075 42007472 006b6361     er support.Back.
c0d0369c:	73726556 006e6f69 2e302e30 73550031     Version.0.0.1.Us
c0d036ac:	61772065 74656c6c 006f7420 77656976     e wallet to.view
c0d036bc:	63636120 746e756f 65530073 6e697474      accounts.Settin
c0d036cc:	41007367 74756f62 69755100 70612074     gs.About.Quit ap
c0d036dc:	6f430070 7269666e 6461006d 73657264     p.Confirm.addres
c0d036ec:	64410073 73657264 6d410073 746e756f     s.Address.Amount
c0d036fc:	6e614200 64697764 74006874 736e6172     .Bandwidth.trans
c0d0370c:	69746361 00006e6f                       action..

c0d03714 <menu_settings_browser>:
c0d03714:	00000000 c0d00115 00000000 00000000     ................
c0d03724:	c0d03680 00000000 00000000 00000000     .6..............
c0d03734:	c0d00115 00000001 00000000 c0d03683     .............6..
	...

c0d03768 <menu_settings>:
c0d03768:	00000000 c0d00161 00000000 00000000     ....a...........
c0d03778:	c0d03687 00000000 00000000 c0d03810     .6...........8..
c0d03788:	00000000 00000001 c0d03634 c0d03697     ........46...6..
c0d03798:	00000000 0000283d 00000000 00000000     ....=(..........
	...

c0d037bc <menu_about>:
	...
c0d037cc:	c0d0369c c0d036a4 00000000 c0d03810     .6...6.......8..
c0d037dc:	00000000 00000002 c0d03634 c0d03697     ........46...6..
c0d037ec:	00000000 0000283d 00000000 00000000     ....=(..........
	...

c0d03810 <menu_main>:
	...
c0d0381c:	c0d035fc c0d036aa c0d036b8 00000c21     .5...6...6..!...
c0d0382c:	c0d03768 00000000 00000000 00000000     h7..............
c0d0383c:	c0d036c6 00000000 00000000 c0d037bc     .6...........7..
	...
c0d03858:	c0d036cf 00000000 00000000 00000000     .6..............
c0d03868:	c0d01c4d 00000000 c0d0366c c0d036d5     M.......l6...6..
c0d03878:	00000000 00001d32 00000000 00000000     ....2...........
	...

c0d0389c <ui_address_nanos>:
c0d0389c:	00000003 00800000 00000020 00000001     ........ .......
c0d038ac:	00000000 00ffffff 00000000 00000000     ................
	...
c0d038d4:	00030005 0007000c 00000007 00000000     ................
c0d038e4:	00ffffff 00000000 00070000 00000000     ................
	...
c0d0390c:	00750005 0008000d 00000006 00000000     ..u.............
c0d0391c:	00ffffff 00000000 00060000 00000000     ................
	...
c0d03944:	00000107 0080000c 00000020 00000000     ........ .......
c0d03954:	00ffffff 00000000 00008008 c0d036de     .............6..
	...
c0d0397c:	00000107 0080001a 00000020 00000000     ........ .......
c0d0398c:	00ffffff 00000000 00008008 c0d036e6     .............6..
	...
c0d039b4:	00000207 0080000c 00000020 00000000     ........ .......
c0d039c4:	00ffffff 00000000 0000800a c0d036ee     .............6..
	...
c0d039ec:	00170207 0052001a 008a000c 00000000     ......R.........
c0d039fc:	00ffffff 00000000 001a8008 20001800     ............... 
	...

c0d03a24 <ux_menu_elements>:
c0d03a24:	00008003 00800000 00000020 00000001     ........ .......
c0d03a34:	00000000 00ffffff 00000000 00000000     ................
	...
c0d03a5c:	00038105 0007000e 00000004 00000000     ................
c0d03a6c:	00ffffff 00000000 000b0000 00000000     ................
	...
c0d03a94:	00768205 0007000e 00000004 00000000     ..v.............
c0d03aa4:	00ffffff 00000000 000c0000 00000000     ................
	...
c0d03acc:	000e4107 00640003 0000000c 00000000     .A....d.........
c0d03adc:	00ffffff 00000000 0000800a 00000000     ................
	...
c0d03b04:	000e4207 00640023 0000000c 00000000     .B..#.d.........
c0d03b14:	00ffffff 00000000 0000800a 00000000     ................
	...
c0d03b3c:	000e1005 00000009 00000000 00000000     ................
c0d03b4c:	00ffffff 00000000 00000000 00000000     ................
	...
c0d03b74:	000e2007 00640013 0000000c 00000000     . ....d.........
c0d03b84:	00ffffff 00000000 00008008 00000000     ................
	...
c0d03bac:	000e2107 0064000c 0000000c 00000000     .!....d.........
c0d03bbc:	00ffffff 00000000 00008008 00000000     ................
	...
c0d03be4:	000e2207 0064001a 0000000c 00000000     ."....d.........
c0d03bf4:	00ffffff 00000000 00008008 00000000     ................
	...

c0d03c1c <UX_MENU_END_ENTRY>:
	...

c0d03c38 <SW_WRONG_LENGTH>:
c0d03c38:	006f0067                                         g.

c0d03c3a <SW_INTERNAL>:
c0d03c3a:	806a006f                                         o.

c0d03c3c <SW_BAD_KEY_HANDLE>:
c0d03c3c:	3255806a                                         j.

c0d03c3e <VERSION>:
c0d03c3e:	5f463255 00903256                       U2F_V2..

c0d03c46 <SW_UNKNOWN_CLASS>:
c0d03c46:	006d006e                                         n.

c0d03c48 <SW_UNKNOWN_INSTRUCTION>:
c0d03c48:	ffff006d                                         m.

c0d03c4a <BROADCAST_CHANNEL>:
c0d03c4a:	ffffffff                                ....

c0d03c4e <FORBIDDEN_CHANNEL>:
c0d03c4e:	00000000                                ....

c0d03c52 <USBD_PRODUCT_FS_STRING>:
c0d03c52:	004e030e 006e0061 0020006f 03040053              ..N.a.n.o. .S.

c0d03c60 <USBD_LangIDDesc>:
c0d03c60:	04090304                                ....

c0d03c64 <USB_SERIAL_STRING>:
c0d03c64:	0030030a 00300030 030e0031                       ..0.0.0.1.

c0d03c6e <USBD_MANUFACTURER_STRING>:
c0d03c6e:	004c030e 00640065 00650067 d0060072              ..L.e.d.g.e.r.

c0d03c7c <HID_ReportDesc>:
c0d03c7c:	09f1d006 0901a101 26001503 087500ff     ...........&..u.
c0d03c8c:	08814095 00150409 7500ff26 91409508     .@......&..u..@.
c0d03c9c:	0000c008                                ....

c0d03ca0 <USBD_HID_CfgDesc>:
c0d03ca0:	00290209 c0020101 00040932 00030200     ..).....2.......
c0d03cb0:	21090200 01000111 07002222 40038205     ...!...."".....@
c0d03cc0:	05070100 00400302 00000001              ......@.....

c0d03ccc <USBD_HID_Desc>:
c0d03ccc:	01112109 22220100 00000000              .!....""....

c0d03cd8 <USBD_HID_DeviceQualifierDesc>:
c0d03cd8:	0200060a 40000000 01120001                       .......@..

c0d03ce2 <USBD_DeviceDesc>:
c0d03ce2:	02000112 40000000 00012c97 02010200     .......@.,......
c0d03cf2:	31450103                                         ..

c0d03cf4 <HID_Desc>:
c0d03cf4:	c0d03145 c0d03155 c0d03175 c0d03165     E1..U1..u1..e1..
c0d03d04:	c0d03185 c0d03195 c0d031a5 00000000     .1...1...1......

c0d03d14 <USBD_HID>:
c0d03d14:	c0d030fb c0d0312d c0d03063 00000000     .0..-1..c0......
	...
c0d03d2c:	c0d031f1 00000000 00000000 00000000     .1..............
c0d03d3c:	c0d031c5 c0d031c5 c0d031c5 c0d031b5     .1...1...1...1..

c0d03d4c <_etext>:
	...

c0d03d80 <N_storage_real>:
	...
