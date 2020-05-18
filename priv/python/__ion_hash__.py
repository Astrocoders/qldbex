from amazon.ion.simpleion import loads, dumps
import ionhash
import base64


def to_ion_hash(value):
    if isinstance(value, str):
        value = loads(dumps(value))

    return base64.b64encode(value.ion_hash('SHA256')).decode("utf-8")

