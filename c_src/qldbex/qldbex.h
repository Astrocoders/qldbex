#pragma once

typedef struct Noop UnifexNifState;

struct Noop
{
};

typedef UnifexNifState State;

#define DECNUMDIGITS 34

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <json-c/json.h>
#include "_generated/qldbex.h"
#include "./ion/ion.h"
#include "./base64/base64.h"
// #include "./ionhash.h"
