#ifndef __LOAD_BINARY__
#define __LOAD_BINARY__
#include<stdint.h>
typedef struct elf_binary{
    uint64_t target_addr;
    uint64_t binary_len;
    uint64_t inst[];
}* Elf_binary;

typedef struct compress_elf_header{
    uint64_t segnum;
    uint64_t elf_binary[];
}* Compress_elf_header;

void load_binary(Compress_elf_header header);
uint64_t* binary_cpy(uint64_t* dest,uint64_t* src,uint64_t num);
#endif