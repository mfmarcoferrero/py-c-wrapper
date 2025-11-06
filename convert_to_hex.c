#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <time.h>


// Set seed
void init_rand(int seed) {
    srand(seed);
}

// Function signature for C code exposed to Python
// The function will write its output directly to a provided buffer
void convert_to_hex(const char *input_str, char *output_buffer, int run_id) {
    const unsigned char *p = (const unsigned char *)input_str;
    size_t len = strlen(input_str);
    char *out = output_buffer; // Pointer to the current position in the output buffer

    for (size_t i = 0; i < len; i++) {
        // Use snprintf to print the hex value of the byte into the output buffer
        // This is safer than direct printf() for a library function.
        // It returns the number of characters printed (always 2 here).
        out += sprintf(out, "%02X", p[i]);
        if (i < len - 1) {
            *out = ' ';
            out ++;
        }
    }
    *out = '\0';
    
    int timeout = rand() % 10000;
    Sleep(timeout);
    printf("[C function %d] %s --> timeout: %d\n", run_id, output_buffer, timeout);
}
