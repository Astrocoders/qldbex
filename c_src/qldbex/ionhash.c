#define PY_SSIZE_T_CLEAN

#include "./ionhash.h"

void initialize_python()
{
  if (!Py_IsInitialized())
    Py_Initialize();

  PyRun_SimpleString("import sys; import os; sys.path.append(os.path.abspath(os.getcwd()) + '/priv/python/');");
}

void generate_ion_hash(char *value, char *output)
{
  PyObject *module_name = PyUnicode_FromString((char *)"__ion_hash__");
  PyObject *module = PyImport_Import(module_name);

  PyObject *to_qldb_hash_function = PyObject_GetAttrString(module, (char *)"to_ion_hash");
  PyObject *args = PyTuple_Pack(1, PyUnicode_FromString(value));

  PyObject *result = PyObject_CallObject(to_qldb_hash_function, args);

  const char *function_result = PyUnicode_AsUTF8(result);

  output = malloc(sizeof(char) * strlen(function_result));
  strcpy(output, function_result);
}

#define HASH_SIZE 32

int hash_comparator(char *first, char *last)
{
  for (int i = HASH_SIZE - 1; i >= 0; i--)
  {
    int diff = first[i] - last[i];
    if (diff != 0)
      return diff;
  }

  return 0;
}

void *dot(char *first, char *last, unsigned char *output)
{

  size_t len_first = strlen(first);
  size_t len_last = strlen(last);

  size_t concat_size = len_first + len_last + 1;

  char *concat = malloc(concat_size);

  if (len_first == 0)
  {
    strcpy(concat, last);
  }
  else if (len_last == 0)
  {
    strcpy(concat, first);
  }
  else
  {
    if (hash_comparator(first, last) < 0)
    {
      strcpy(concat, first);
      strcat(concat, last);
    }
    else
    {
      strcpy(concat, last);
      strcat(concat, first);
    }
  }

  SHA256((unsigned char *)concat, strlen(concat), output);

  free(concat);
}
