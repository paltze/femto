#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define u16 uint16_t
#define u8 uint8_t

typedef struct {
    char name[64];
    u16 addr;
} Label;

typedef enum {
    R,
    I,
    M,
    J
} InstrType;

typedef struct {
    char mnemonic[16];
    int count;
    InstrType type;
} Instr;

const Instr instrs[] = {
    {
        "ADD",
        1,
        R
    },
    {
        "SUB",
        1,
        R
    },
    {
        "AND",
        1,
        R
    },
    {
        "OR",
        1,
        R
    },
    {
        "XOR",
        1,
        R
    },
    {
        "NOT",
        1,
        R
    },
    {
        "SHL",
        1,
        R
    },
    {
        "SHR",
        1,
        R
    },
    {
        "MOVI",
        1,
        I
    },
    {
        "LOAD",
        1,
        M
    },
    {
        "STORE",
        1,
        M
    },
    {
        "JMP",
        1,
        J
    },
    {
        "JZ",
        1,
        J
    },
    {
        "JNZ",
        1,
        J
    },
    {
        "CALL",
        1,
        J
    },
    {
        "RET",
        1,
        J
    }
};

const int instr_size = sizeof(instrs) / sizeof(Instr);

int find_count(const char* mnemonic) {
    for (int i = 0; i < instr_size; i++)
        if (!strcmp(mnemonic, instrs[i].mnemonic))
            return instrs[i].count;

    return -1;
}

void build_labels(FILE* fp, Label* labels, int* label_size) {
    char line[256];
    char mnemonic[256];
    int current_count = 0;

    while(fgets(line, sizeof(line), fp)) {
        if (!strcmp(line, "\n")) continue;
        sscanf(line, "%s", mnemonic);

        if (mnemonic[strlen(mnemonic) - 1] == ':') {
            labels[*label_size].addr = current_count;
            strcpy(labels[*label_size].name, mnemonic);
            labels[*label_size].name[strlen(labels[*label_size].name) - 1] = '\0';
            (*label_size)++;
        }
        else {
            const int count = find_count(mnemonic);
            if (count == -1)
                printf("Error unknown instruction: %s\n", mnemonic);
            else
                current_count += 2 * count;
        }
    }

    rewind(fp);
}

int main(int argc, char* argv[]) {
    if (argc <= 1) {
        printf("Please pass a asm file to assemble\n");
        return 0;
    }

    FILE* fp = fopen(argv[1], "r");

    Label labels[256];
    int label_count = 0;
    
    build_labels(fp, labels, &label_count);

    

    return 0;
}
