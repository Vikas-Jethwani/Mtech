import numpy as np
import sys # For terminating when error
import math # For sqaure root


def encrypt(key_file=None, pl_file=None, ci_file=None):
    
    # Check if path to file provided
    if key_file == None :
        key_file = input().strip()
        pl_file = input().strip()
        ci_file = input().strip()
    
    # Read and process Key
    key = open(key_file, 'r').read().strip()
    if len(key) == 0:
        print('Key can not be of length 0.')
        sys.exit(1)

    if 'a' <= key[0] <= 'z': key = [ord(ch)-ord('a') for ch in key if 'a'<=ch<='z'] # If key is a phrase
    else: key = [int(k) for k in key.split()] # If key is a matrix, flattened out

    n = int(round(math.sqrt(len(key)))) # Find 'n'
    if n*n != len(key):
        print('Key length has to be a perfect square.')
        sys.exit(1)

    key_arr = np.asarray(key)
    key_mat = key_arr.reshape(n, n)
    
    
    # Read and process Plain_Text
    pl_text = open(pl_file, 'r').read().strip()
    pl_text_trim = ''
    for ch in pl_text:
        if 'a' <= ch <= 'z': pl_text_trim += ch # Ensures only lowercase english chars

    # Append'x' to make length a multiple of n
    if len(pl_text_trim)%n != 0:
        pl_text_trim = pl_text_trim + 'x'*( n - (len(pl_text_trim)%n) )
    
    # Convert to integer vector for matrix multiplication
    pl_text_int = [ord(ch)-ord('a') for ch in pl_text_trim]
    
    # Get Cipher_Text
    ci_text = ''
    for i in range(0, len(pl_text_int), n):
        segment = pl_text_int[i:i+n]
        dot_prod = np.dot(key_mat, np.asarray(segment).reshape(n,1)) # Matrix multiplication
        for elem in dot_prod:
            ci_text += chr((elem[0]%26) + ord('a')) # (Mod then add ASCII) to convert back to character

    # Write Result to File
    open(ci_file, 'w').write(ci_text)
    print(ci_text)

if __name__ == '__main__':
    if len(sys.argv) == 4:
        encrypt(sys.argv[1], sys.argv[2], sys.argv[3])
    else:
        encrypt()