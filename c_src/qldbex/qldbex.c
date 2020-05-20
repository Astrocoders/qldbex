#include "qldbex.h"

#define ION_OK(env, result)                                    \
  if (result)                                                  \
  {                                                            \
    return to_ion_result_error(env, ion_error_to_str(result)); \
  }

UNIFEX_TERM init(UnifexEnv *env)
{
  UNIFEX_UNUSED(env);
  return 0;
}

int handle_load(UnifexEnv *env, void **priv_data)
{
  UNIFEX_UNUSED(env);
  UNIFEX_UNUSED(priv_data);
  return 0;
}

UNIFEX_TERM to_ion(UnifexEnv *env, char *json_text)
{
  hREADER reader;
  ION_READER_OPTIONS reader_options;
  hWRITER writer;
  ION_WRITER_OPTIONS writer_options;
  ION_STREAM *output_stream;

  memset(&reader_options, 0, sizeof(ION_READER_OPTIONS));
  memset(&writer_options, 0, sizeof(ION_WRITER_OPTIONS));
  writer_options.output_as_binary = 1;

  ION_OK(env, ion_reader_open_buffer(&reader,
                                     (BYTE *)json_text,
                                     (SIZE)strlen(json_text),
                                     &reader_options));

  ION_OK(env, ion_stream_open_memory_only(&output_stream));
  ION_OK(env, ion_writer_open(&writer, output_stream, &writer_options));

  ION_OK(env, ion_writer_write_all_values(writer, reader));

  ION_OK(env, ion_writer_close(writer));
  POSITION output_stream_length = ion_stream_get_position(output_stream);
  ION_OK(env, ion_stream_seek(output_stream, 0));
  BYTE *binary_ion = (BYTE *)(malloc((size_t)output_stream_length));
  SIZE binary_ion_length;
  ION_OK(env, ion_stream_read(output_stream, binary_ion, (SIZE)output_stream_length, &binary_ion_length));
  ION_OK(env, ion_stream_close(output_stream));

  if (binary_ion_length != (SIZE)output_stream_length)
  {
    ION_OK(env, IERR_INVALID_STATE);
  }

  char *base64_result = base64_encode(binary_ion, binary_ion_length);

  UNIFEX_TERM result = to_ion_result_ok(env, base64_result);

  free(binary_ion);

  return result;
}

void add_to_json_object(json_object *jobj, char *field_name, json_object *value)
{
  if (json_object_is_type(jobj, json_type_array))
  {
    json_object_array_add(jobj, value);
  }
  else
  {
    json_object_object_add(jobj, field_name, value);
  }
}

char *get_field_name(hREADER *reader)
{
  ION_STRING ion_string;

  ion_reader_get_field_name(*reader, &ion_string);
  return ion_string_strdup(&ion_string);
}

void parse_ion(hREADER *reader, json_object *jobj)
{
  ION_TYPE ion_type = tid_NULL;

  ion_reader_get_type(*reader, &ion_type);

  if (ion_type == tid_NULL)
  {
    ion_reader_next(*reader, &ion_type);
  }

  ion_reader_get_type(*reader, &ion_type);

  if (ion_type == tid_LIST)
  {
    json_object *jarray = json_object_new_array();
    char *field_name = get_field_name(reader);

    ion_reader_step_in(*reader);

    while (1)
    {
      ion_reader_next(*reader, &ion_type);

      if (ion_type == tid_EOF)
      {
        add_to_json_object(jobj, field_name, jarray);
        ion_reader_step_out(*reader);
        break;
      }

      parse_ion(reader, jarray);
    }
  }

  if (ion_type == tid_STRUCT)
  {
    char *field_name = get_field_name(reader);

    json_object *nested_jobj = json_object_new_object();

    SIZE current_depth = 0;
    ion_reader_get_depth(*reader, &current_depth);
    ion_reader_step_in(*reader);

    while (1)
    {
      SIZE depth = 0;
      ion_reader_get_depth(*reader, &depth);

      if (depth <= current_depth)
        break;

      ion_reader_next(*reader, &ion_type);

      if (ion_type == tid_EOF)
      {
        if (depth > 1)
        {
          add_to_json_object(jobj, field_name, nested_jobj);
        }

        ion_reader_step_out(*reader);
      }
      else
      {
        if (depth == 1)
        {
          parse_ion(reader, jobj);
        }
        else
        {
          parse_ion(reader, nested_jobj);
        }
      }
    }
  }

  ion_reader_get_type(*reader, &ion_type);

  if (ion_type == tid_INT)
  {
    char *field_name = get_field_name(reader);

    int value;

    ion_reader_read_int(*reader, &value);

    add_to_json_object(jobj, field_name, json_object_new_int(value));
  }

  if (ion_type == tid_DECIMAL)
  {
    char *field_name = get_field_name(reader);

    ION_DECIMAL value_ion_decimal;
    ion_reader_read_ion_decimal(*reader, &value_ion_decimal);
    char str_repr[50];
    ion_decimal_to_string(&value_ion_decimal, str_repr);

    add_to_json_object(jobj, field_name, json_object_new_double(strtod(str_repr, NULL)));
  }

  if (ion_type == tid_STRING)
  {
    ION_STRING ion_string;
    char *field_name = get_field_name(reader);

    ion_reader_read_string(*reader, &ion_string);
    char *value = ion_string_strdup(&ion_string);

    add_to_json_object(jobj, field_name, json_object_new_string(value));
  }

  if (ion_type == tid_BOOL)
  {
    char *field_name = get_field_name(reader);

    BOOL value;

    ion_reader_read_bool(*reader, &value);

    add_to_json_object(jobj, field_name, json_object_new_boolean(value));
  }

  if (ion_type == tid_TIMESTAMP)
  {
    char *field_name = get_field_name(reader);

    // iTIMESTAMP timestamp;
    ION_TIMESTAMP ion_time;
    memset(&ion_time, 0, sizeof(ION_TIMESTAMP));

    ion_reader_read_timestamp(*reader, &ion_time);

    time_t time;
    ion_timestamp_to_time_t(&ion_time, &time);

    char buf[ION_TIMESTAMP_STRING_LENGTH + 1];

    strftime(buf, sizeof(buf), "%FT%T%Z", localtime(&time));

    add_to_json_object(jobj, field_name, json_object_new_string(buf));
  }
}

UNIFEX_TERM from_ion(UnifexEnv *env, char *encoded64_ion)
{
  size_t decoded_size = 0;
  char *decoded_binary = base64_decode(encoded64_ion, &decoded_size);
  iERR nRet;

  hREADER reader;
  ION_READER_OPTIONS reader_options;

  memset(&reader_options, 0, sizeof(ION_READER_OPTIONS));

  nRet = ion_reader_open_buffer(&reader,
                                (BYTE *)decoded_binary,
                                decoded_size,
                                &reader_options);

  if (nRet)
  {
    free(decoded_binary);
    return to_ion_result_error(env, ion_error_to_str(nRet));
  }

  json_object *jobj = json_object_new_object();

  parse_ion(&reader, jobj);

  nRet = ion_reader_close(reader);

  if (nRet)
  {
    free(decoded_binary);
    return to_ion_result_error(env, ion_error_to_str(nRet));
  }

  UNIFEX_TERM result = to_ion_result_ok(env, json_object_to_json_string(jobj));

  free(decoded_binary);

  return result;
}

// UNIFEX_TERM generate_commit_digest(UnifexEnv *env, char *transaction_id, char *statement)
// {
//   initialize_python();

//   size_t transaction_id_hash_len;
//   char *transaction_id_hash_encoded = NULL;
//   generate_ion_hash(transaction_id, transaction_id_hash_encoded);
//   char *transaction_id_hash = base64_decode(transaction_id_hash, &transaction_id_hash_len);

//   free(transaction_id_hash_encoded);

//   size_t statement_hash_len;
//   char *statement_hash_encoded = NULL;
//   generate_ion_hash(statement, statement_hash_encoded);
//   char *statement_hash = base64_decode(statement_hash, &statement_hash_len);

//   free(statement_hash_encoded);

//   unsigned char *final_hash[SHA256_DIGEST_LENGTH];
//   dot(transaction_id_hash, statement_hash, final_hash);

//   char *final_hash_base64 = base64_encode(final_hash, SHA256_DIGEST_LENGTH);

//   UNIFEX_TERM result = generate_commit_digest_result_ok(env, final_hash_base64);

//   return result;
// }

void handle_destroy_state(UnifexEnv *env, State *state)
{
  UNIFEX_UNUSED(env);
  UNIFEX_UNUSED(state);
}
