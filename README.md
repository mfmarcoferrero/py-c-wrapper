# Convert a sting to hex with Python and C

This is a very simple project to understand how to setup a Python wrapper on compiled C functions. Something similar is done in some of the most popular Python libs like numpy and pytorch. C functions allow to unlock upper performance, and can be wrapped on Python methods to be easily used in Python based projects.

## Getting Started

1. Compile the C source code into a lib
```
gcc -shared -o libhex.dll hex_converter.c
```

2. Include the compiled lib into Python code with ctypes
```python
import ctypes

_lib = ctypes.CDLL(LIB_NAME)

# 2. Configure the C function's signature
c_convert_to_hex = _lib.convert_to_hex

# Define the argument types (argtypes)
# arg 1: const char* (Python string) -> ctypes.c_char_p
# arg 2: char* (output buffer)     -> ctypes.c_char_p
c_convert_to_hex.argtypes = [ctypes.c_char_p, ctypes.c_char_p]

# Define the return type (restype)
# The function is 'void' in C, so it returns None in Python
c_convert_to_hex.restype = None
```

3. Run ```main_sync.py```

## Asyncio and the GIL

Running the ```main_async.py``` file you can see how the Python asyncio lib run threads concurrently. This run shows that when Python execute C code, it releases the Global Interpreter Lock and other threads can then be executed. These are logs for a run of multiple python threads, executing C code:

```
Insert a string to be converted: Hello world!
[Py code 0] Starting run 0 ...
[Py code 1] Starting run 1 ...
[Py code 2] Starting run 2 ...
[Py code 3] Starting run 3 ...
[Py code 4] Starting run 4 ...
[C function 3] 48 65 6C 6C 6F 20 77 6F 72 6C 64 21  --> timeout: 99
[Py code 3] Python thread closed.
[C function 4] 48 65 6C 6C 6F 20 77 6F 72 6C 64 21  --> timeout: 1948
[Py code 4] Python thread closed.
[C function 0] 48 65 6C 6C 6F 20 77 6F 72 6C 64 21  --> timeout: 7904
[Py code 0] Python thread closed.
[C function 1] 48 65 6C 6C 6F 20 77 6F 72 6C 64 21  --> timeout: 7951
[Py code 1] Python thread closed.
[C function 2] 48 65 6C 6C 6F 20 77 6F 72 6C 64 21  --> timeout: 9703
[Py code 2] Python thread closed.
```


All 5 Python threads start quickly.

The C functions complete in a seemingly arbitrary, non-sequential order, showing that they ran concurrently thanks to the GIL being released in the C code. For example, ```[C function 3]``` finishes first, and then ```[C function 4]```, even though they were started sequentially.
