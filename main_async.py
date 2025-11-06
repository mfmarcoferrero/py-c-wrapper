import ctypes
import os
import asyncio
import random
import textwrap
import time


# Load the shared library
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

# Configure the C function's signature
c_seed = _lib.init_rand
c_seed.argtypes = [ctypes.c_int]
c_seed.restype = None
c_convert_to_hex = _lib.convert_to_hex
c_convert_to_hex.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_int]
c_convert_to_hex.restype = None


def hex_converter_with_py(input_str: str, run_id: int) -> str:
    print(f"[Py code {run_id}] Starting run {run_id} ...")

    bytes_data = input_str.encode('utf-8')
    raw_hex = bytes_data.hex()
    out_string = ' '.join(textwrap.wrap(raw_hex, 2))

    timeout = random.randint(1, 10)
    time.sleep(timeout)
    print(f"[Py code {run_id}] {out_string} --> timeout: {timeout}")
    print(f"[Py code {run_id}] Python thread closed.")
    return out_string


def hex_converter_with_c(input_str: str, run_id: int) -> str:
    """
    A Python wrapper function that calls the underlying C implementation.
    (This is the user-facing function, like np.sum or np.dot).
    """
    print(f"[Py code {run_id}] Starting run {run_id} ...")
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
    # Calling C functions will release the GIL
    seed = random.randint(1000, 10000)
    c_seed(seed) 
    c_convert_to_hex(input_bytes, output_buffer, run_id)
    out_string = output_buffer.value.decode('utf-8')
    print(f"[Py code {run_id}] Python thread closed.")
    return out_string


async def multi_async_run(input_str: str, n_run: int = 10):
    print("C-Py implementation")
    tasks = [asyncio.to_thread(hex_converter_with_c, input_str, i) for i in range(n_run)]
    await asyncio.gather(*tasks)


if __name__ == "__main__":
    data = input("Insert a string to be converted: ")
    asyncio.run(multi_async_run(input_str=data, n_run=5))
    