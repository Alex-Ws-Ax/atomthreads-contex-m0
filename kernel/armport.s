FPU_USED EQU 0x00000010
SCB_ICSR EQU 0xE000ED04
PENDSVCLR EQU 0x08000000

                            AREA MYCODE, CODE
                            THUMB
                            IMPORT  CTX_SW_NFO
                            IMPORT  __Vectors


_archFirstThreadRestore     PROC
                            EXPORT _archFirstThreadRestore
                            movs r1, #1
                            msr PRIMASK, r1
                            ldr r1, = __Vectors
                            ldr r1, [r1, #0]
                            msr MSP, r1

                            ldr r1, = CTX_SW_NFO
                            str r0, [r1, #0]
                            str r0, [r1, #4]
                            ldr r1, [r0, #0]
                            msr PSP, r1

                            movs r1, #2
                            mrs r2, CONTROL
                            orrs r2, r2, r1
                            msr CONTROL, r2
                            add SP, #16
                            pop {r4 - r7}
                            mov r8, r4
                            mov r9, r5
                            mov r10, r6
                            mov r11, r7

                            sub SP, #32
                            pop {r4 - r7}

                            add SP, #36
                            pop {r0 - r3}
                            mov r12, r0
                            mov lr, r1

                            push {r2}

                            sub SP, #20
                            pop {r1 - r2}
                            add SP, #12
                            push {r1 - r2}

                            sub SP, #20
                            pop {r0 - r1}

                            add SP, #12

                            movs r2, #0
                            msr APSR_nzcvq, r3
                            msr PRIMASK, r2

                            pop {r2, r3, pc}
                            nop
                            ENDP

__pend_sv_handler           PROC
                            EXPORT __pend_sv_handler
                            movs r0, #1
                            msr PRIMASK, r0

                            ldr r0, = SCB_ICSR
                            ldr r1, = PENDSVCLR
                            str r1, [r0, #0]
                            ldr r0, = CTX_SW_NFO
                            ldr r1, [r0, #0]
                            ldr r2, [r0, #4]
                            cmp r1, r2
                            beq no_switch

                            mrs r3, PSP
                            subs r3, r3, #36
                            stmia r3!, {r4 - r7}

                            mov r4, r8
                            mov r5, r9
                            mov r6, r10
                            mov r7, r11
                            stmia r3!, {r4 - r7}

                            mov r4, lr
                            str r4, [r3, #0]

                            subs r3, r3, #32

                            str r3, [r1, #0]

                            str r2, [r0, #0]
                            ldr r3, [r2, #0]
                            adds r3, r3, #16
                            ldmia r3!, {r4 - r7}
                            mov r8, r4
                            mov r9, r5
                            mov r10, r6
                            mov r11, r7

                            ldr r4, [r3, #0]
                            mov lr, r4
                            subs r3, r3, #32

                            ldmia r3!, {r4 - r7}
                            adds r3, r3, #20

                            msr PSP, r3
                            ENDP

no_switch                   PROC
                            movs r0, #0
                            msr PRIMASK, r0

                            bx lr
                            nop
                            ENDP

                            END