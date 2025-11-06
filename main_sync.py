import ctypes
import os

# 1. Load the shared library
if os.name == 'posix':
    LIB_NAME = './libhex.so'
elif os.name == 'nt':
    LIB_NAME = './libhex.dll'
else:
    raise RuntimeError("Unsupported OS")

try:
    _lib = ctypes.CDLL(LIB_NAME)
except OSError as e:
    print(f"Error loading C library: {e}")
    print("Please ensure you have compiled hex_converter.c into a shared library (libhex.so or libhex.dll).")
    exit(1)


# 2. Configure the C function's signature
c_convert_to_hex = _lib.convert_to_hex
# Define the argument types (argtypes)
c_convert_to_hex.argtypes = [ctypes.c_char_p, ctypes.c_char_p]
# Define the return type (restype)
c_convert_to_hex.restype = None


def hex_converter(input_str: str) -> str:
    """
    A Python wrapper function that calls the underlying C implementation.
    (This is the user-facing function, like np.sum or np.dot).
    """
    if not isinstance(input_str, str):
        raise TypeError("Input must be a string.")

    # Convert Python string to bytes needed by C, and determine output size
    input_bytes = input_str.encode('utf-8')
    input_len = len(input_bytes)
    
    # Allocate Output Buffer (The memory where C will write the result)
    hex_chars = input_len * 2
    spaces = input_len - 1
    if input_len == 0:
        output_size = 1
    else:
        output_size = hex_chars + spaces + 1
    output_buffer = ctypes.create_string_buffer(output_size)

    # Call the C Function (The "heavy lifting" is done here)
    c_convert_to_hex(input_bytes, output_buffer)

    return output_buffer.value.decode('utf-8')

if __name__ == "__main__":
    data = input("Insert a string to be converted: ")
    hex_result = hex_converter(data)

    print(f"Original Python String: '{data}'")
    print(f"Hex String from C Function: {hex_result}")
    print(f"Length Check: Input ({len(data)}) vs Output ({(len(hex_result) // 2)})")
    