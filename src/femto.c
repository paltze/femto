#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define u16 uint16_t
#define u8 uint8_t

#define lo(x) ( (u8) ( (x) & (0xFF) ) )
#define hi(x) ( (u8) ( ((x) >> 8) & (0xFF) ) )
#define comb(hi, lo) ( (((u16)(hi)) << 8) | ((u16)(lo)) )

#define ZERO_FLAG 0x01
#define CARRY_FLAG 0x02

typedef struct {
    u8 r[16];
    u16 sp, pc, ra;
    u8 mem[65536];
} CPU;

int load_from_hex(CPU* cpu, const char* path) {
    FILE* fp = fopen(path, "r");

    char line[8];
    u16 n = 0;

    while(fgets(line, sizeof(line), fp)) {
        u16 instr;
        sscanf(line, "%hx", &instr);

        cpu->mem[n++] = lo(instr);
        cpu->mem[n++] = hi(instr);
    }

    fclose(fp);

    cpu->mem[0xFFF0] = lo(n);
    cpu->mem[0xFFF1] = hi(n);

    cpu->sp = 0xF000;

    return n;
}

void execute(CPU* cpu) {
    u16 instr = comb(cpu->mem[cpu->pc + 1], cpu->mem[cpu->pc]);
    u16 opcode = (instr & 0xF000) >> 12;

    cpu->pc += 2;


    if (opcode <= 0x7) {
        u8 rd_i = (instr & 0x0F00) >> 8;
        u8 rs_i = (instr & 0x00F0) >> 4;

        u8 *rd = &cpu->r[rd_i];
        u8 *rs = &cpu->r[rs_i];
        u8 *rt = &cpu->r[instr & 0x000F];

        if (rd_i == rs_i && rs_i == 14) {
            if (opcode == 0) cpu->sp += *rt;
            else if (opcode == 1) cpu->sp -= *rt;
            return;
        }

        switch (opcode) {
            case 0:
                cpu->r[13] = 0;
                if ( (u16)(*rs) + (u16)(*rt) > 255 )
                    cpu->r[13] |= CARRY_FLAG;

                *rd = *rs + *rt;

                if (*rd == 0)
                    cpu->r[13] |= ZERO_FLAG;

                break;
            case 1:
                cpu->r[13] = 0;
                if ( (*rs) < (*rt) )
                    cpu->r[13] |= CARRY_FLAG;
                
                *rd = *rs - *rt;

                if (*rd == 0)
                    cpu->r[13] |= ZERO_FLAG;

                break;
            case 2:
                *rd = *rs & *rt;
                break;
            case 3:
                *rd = *rs | *rt;
                break;
            case 4:
                *rd = *rs ^ *rt;
                break;
            case 5:
                *rd = ~(*rs);
                break;
            case 6:
                *rd = *rs << *rt;
                break;
            case 7:
                *rd = *rs >> *rt;
        }
    }
    else if (opcode == 0x8) {
        u8 *rd = &cpu->r[(instr & 0x0F00) >> 8];
        u8 imm = instr & 0x00FF;

        *rd = imm;
    }
    else if (opcode == 0x9 || opcode == 0xA) {
        u8 rhi_i = (instr & 0x00F0) >> 4;
        u8 rlo_i = instr & 0x000F;

        u8 *rs = &cpu->r[(instr & 0x0F00) >> 8];
        u8 *rhi = &cpu->r[rhi_i];
        u8 *rlo = &cpu->r[rlo_i];

        u16 mem;
        if (rhi_i == rlo_i && rhi_i == 14) 
            mem = cpu->sp;
        else
            mem = comb(*rhi, *rlo);

        if (opcode == 9)
            *rs = cpu->mem[mem];
        else if (opcode == 10)
            cpu->mem[mem] = *rs;

    }
    else {
        u8 *rhi = &cpu->r[(instr & 0x0F00) >> 8];
        u8 *rlo = &cpu->r[(instr & 0x00F0) >> 4];
        u8 *rs = &cpu->r[instr & 0x000F];

        u16 label = comb(*rhi, *rlo);

        switch (opcode) {
            case 0xB:
                cpu->pc = label;
                break;
            case 0xC:
                if (*rs == 0) cpu->pc = label;
                break;
            case 0xD:
                if (*rs != 0) cpu->pc = label;
                break;
            case 0xE:
                cpu->sp -= 2;

                cpu->mem[cpu->sp] = hi(cpu->pc);
                cpu->mem[cpu->sp + 1] = lo(cpu->pc);

                cpu->pc = label;
                break;
            case 0xF:
                cpu->pc = comb(cpu->mem[cpu->sp], cpu->mem[cpu->sp + 1]);
                cpu->sp += 2;
                break;
        }
    }
}

void dump_registers(CPU* cpu) {
    for (int i = 0; i <= 15; i++)
        printf("R%d: %02hX\n", i, cpu->r[i]);

    printf("SP: %02hX\n", cpu->sp);
    printf("PC: %02hX\n", cpu->pc);
    printf("RA: %02hX\n", cpu->ra);
}

int main(int argc, char* argv[]) {
    if (argc <= 1) {
        printf("Please pass a hex file to execute\n");
        return 0;
    }

    CPU* cpu = calloc(1, sizeof(CPU));
    int off = load_from_hex(cpu, argv[1]);

    uint64_t instruction_count = 0;

    while (cpu->pc < off) {
        instruction_count++;
        execute(cpu);
    }

    printf("\n%lu instructions executed\n\n", instruction_count);
    dump_registers(cpu);

    free(cpu);

    return 0;
}
