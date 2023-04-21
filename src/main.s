.text

.extern setModInfo
.extern onModInit
.extern onModLateInit

.global setup
.global load

setup:
    sub sp, sp, #32
    stp x29, x30, [sp, #16]
    add x29, sp, #16
    str x0, [sp, #8]

    ldr x0, [sp, #8]
    bl setModInfo

    bl onModInit

    ldp x29, x30, [sp, #16]
    add sp, sp, 32
    ret

load:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl onModLateInit

    ldp x29, x30, [sp], #16
    ret