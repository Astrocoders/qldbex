#include <Python.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <openssl/sha.h>
#include "./base64/base64.h"

void initialize_python();

void generate_ion_hash(char *value, char *output);

void *dot(char *first, char *last, unsigned char output[SHA256_DIGEST_LENGTH]);
