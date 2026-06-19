#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define u16 uint16_t
#define u8 uint8_t

#define lo(x) ( (u8) ( (x) & (0xFF) ) )
#define hi(x) ( (u8) ( ((x) >> 8) & (0xFF) ) )




typedef struct {
    char name[64];
    u16 addr;
} Label;

typedef enum {
    R,
    I,
    M,
    J,
    P // For pseudo
} InstrType;

typedef struct {
    char mnemonic[16];
    int count;
    InstrType type;
    u8 id;
} Instr;

const Instr instrs[] = {
    { "ADD",   1, R,  0 },
    { "SUB",   1, R,  1 },
    { "AND",   1, R,  2 },
    { "OR",    1, R,  3 },
    { "XOR",   1, R,  4 },
    { "NOT",   1, R,  5 },
    { "SHL",   1, R,  6 },
    { "SHR",   1, R,  7 },
    { "MOVI",  1, I,  8 },
    { "LOAD",  1, M,  9 },
    { "STORE", 1, M, 10 },
    { "JMP",   3, J, 11 },
    { "JZ",    3, J, 12 },
    { "JNZ",   3, J, 13 },
    { "CALL",  3, J, 14 },
    { "RET",   1, J, 15 },
    { "PUSH",  3, P, 16 },
    { "POP",   3, P, 17 }
};

const int instr_size = sizeof(instrs) / sizeof(Instr);

const Instr* find_instr(const char* mnemonic) {
    for (int i = 0; i < instr_size; i++)
        if (!strcmp(mnemonic, instrs[i].mnemonic))
            return &instrs[i];

    return NULL;
}




void build_labels(FILE* fp, Label* labels, int* label_size) {
    char line[256];
    char mnemonic[256];

    int current_count = 0;

    while(fgets(line, sizeof(line), fp)) {
        char* comm = strchr(line, ';');
        if (comm) *comm = '\0';

        if (sscanf(line, "%s", mnemonic) <= 0)
            continue;

        const int mnemonic_size = strlen(mnemonic);

        if (mnemonic[mnemonic_size - 1] == ':') {
            mnemonic[mnemonic_size - 1] = '\0';

            labels[*label_size].addr = current_count;
            strcpy(labels[*label_size].name, mnemonic);

            (*label_size)++;
        }
        else {
            const Instr* instr = find_instr(mnemonic);
            if (instr == NULL)
                printf("Error unknown instruction: %s\n", mnemonic);
            else
                current_count += 2 * instr->count;
        }
    }

    rewind(fp);
}

int find_label(u16* target, char* label, Label* labels, int label_count) {
    for (int i = 0; i < label_count; i++) {
        if (!strcmp(label, labels[i].name)) {
            *target = labels[i].addr;
            return 1;
        }
    }

    return 0;
}




void build_output(FILE* in, FILE* out, Label* labels, int label_count) {
    char line[256];
    char mnemonic[256];

    while(fgets(line, sizeof(line), in)) {
        char* comm = strchr(line, ';');
        if (comm) *comm = '\0';

        if (sscanf(line, "%s", mnemonic) <= 0)
            continue;
        
        if (mnemonic[strlen(mnemonic) - 1] == ':') continue;

        const Instr* instr = find_instr(mnemonic);

        if (!instr) {
            printf("Unknown instruction: %s\n", mnemonic);
            return;
        }

        if (instr->type == R) {
            int d, s, t;
            sscanf(line, "%s R%d, R%d, R%d", mnemonic, &d, &s, &t);
            fprintf(out, "%1hX%1hX%1hX%1hX\n", instr->id, d, s, t);
        }
        else if (instr->type == I) {
            int d, imm;
            sscanf(line, "%s R%d, %d", mnemonic, &d, &imm);
            fprintf(out, "%1hX%1hX%02hX\n", instr->id, d, imm);
        }
        else if (instr->type == M) {
            int d, rhi, rlo;
            sscanf(line, "%s R%d, R%d, R%d", mnemonic, &d, &rhi, &rlo);
            fprintf(out, "%1hX%1hX%1hX%1hX\n", instr->id, d, rhi, rlo);
        }
        else if (instr->type == J) {
            char label[256];
            int rs = 0;

            if (instr->id == 15) {
                fprintf(out, "F000\n");
                continue;
            }

            if (instr->id == 12 || instr->id == 13)
                sscanf(line, "%s %[^,], R%d", mnemonic, label, &rs);
            else
                sscanf(line, "%s %s", mnemonic, label);

            u16 addr;
            if (!find_label(&addr, label, labels, label_count)) {
                printf("Unknown label: %s\n", label);
                return;
            }

            fprintf(out, "8C%02hX\n", lo(addr));
            fprintf(out, "8F%02hX\n", hi(addr));
            fprintf(out, "%1hXFC%1hX\n", instr->id, rs);
        }
        // Now parsing pseudo instructions
        else if (instr->id == 16) {
            int rs = 0;
            sscanf(line, "%s R%d", mnemonic, &rs);

            fprintf(out, "8F01\n1EEF\nA%1hXEE\n", rs);
        }
        else if (instr->id == 17) {
            int rs = 0;
            sscanf(line, "%s R%d", mnemonic, &rs);

            fprintf(out, "9%1hXEE\n8F01\n0EEF\n", rs);
        }
    }
}




int main(int argc, char* argv[]) {
    if (argc < 3) {
        printf("Please pass a asm file to assemble\n");
        return 0;
    }

    FILE* in = fopen(argv[1], "r");
    FILE* out = fopen(argv[2], "w");

    Label labels[256];
    int label_count = 0;
    
    build_labels(in, labels, &label_count);
    build_output(in, out, labels, label_count);

    fclose(in);
    fclose(out);

    return 0;
}
