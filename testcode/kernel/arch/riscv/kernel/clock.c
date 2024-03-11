// clock.c


unsigned long TIMECLOCK = 0x100000;

unsigned long get_cycles() {
    unsigned long time;
    asm volatile (
        "rdtime %[time]"
        : [time] "=r" (time)
        : : "memory"
    );
    return time;
}

void clock_set_next_event() {
    //unsigned long next_time = get_cycles() + TIMECLOCK;
    sbi_ecall(0x00, 0, TIMECLOCK, 0, 0, 0, 0, 0);
} 