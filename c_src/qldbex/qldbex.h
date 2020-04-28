#pragma once

typedef struct HsmCredentials UnifexNifState;

struct HsmCredentials
{
};

typedef UnifexNifState State;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <json-c/json.h>
#include "_generated/qldbex.h"
#include "./ion/ion.h"
#include "./base64/base64.h"
