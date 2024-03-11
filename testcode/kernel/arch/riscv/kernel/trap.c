// trap.c 

void trap_handler(unsigned long scause, unsigned long sepc) {
    if ((scause >> 63) && ((scause & ((1ull << 63) - 1)) == 5)) {
        //printk("[S] Supervisor Mode Timer Interrupt\n");
        clock_set_next_event();
        do_timer();
        return;
    }
}