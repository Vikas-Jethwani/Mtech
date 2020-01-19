import numpy as np
import sys # For terminating when error
import math # For sqaure root


def decrypt(key_file=None, ci_file=None, pl_file=None):

    # Check if path to file provided
    if key_file == None :
        key_file = input().strip()
        ci_file = input().strip()
        pl_file = input().strip()

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

    # Find determinant
    key_det = np.linalg.det(key_mat)
    determ = int(round(key_det))
    if determ == 0:
        print('Key matrix is Singular, Determinant=0.')
        sys.exit(1)

    # Modulo inverse of determinant exists or not
    if math.gcd(determ, 26) != 1:
        print('Key_Determinant & 26 are not co-prime. Modulo inverse not possible.')
        sys.exit(1)

    # Inverse of Key
    key_inv = np.linalg.inv(key_mat)
    # Adjoint of Key
    key_adj = np.around(key_inv*key_det).astype(int, copy=False)

    # Modulo inverse of Determinant
    def modInv(a, m):
        for num in range(1, m):
            if (a*num)%m == 1:
                return num
        return None
    key_det_mod_inv = modInv(determ, 26)

    # Modulo inverse of Key
    key_mod_inv = np.zeros(shape=(n, n), dtype=int)
    for i in range(len(key_adj)):
        for j in range(len(key_adj[i])):
            key_mod_inv[i][j] = (key_adj[i][j] * key_det_mod_inv) % 26

    # Read and process Cipher_Text
    ci_text = open(ci_file, 'r').read().strip()
    ci_text_int = [ord(ch)-ord('a') for ch in ci_text] # Convert to ints

    # Get back Plain_Text
    pl_text = ''
    for i in range(0, len(ci_text_int), n):
        segment = ci_text_int[i:i+n]
        dot_prod = np.dot(key_mod_inv, np.asarray(segment).reshape(n,1)) # Matrix multiplication
        for elem in dot_prod:
            pl_text += chr((elem[0]%26) + ord('a')) # (Mod then add ASCII) to convert back to character

    # Erase trailing 'x', atmost (n-1)
    x_trail, i = 0, len(pl_text)-1
    while i>=0 and pl_text[i]=='x':
        i -= 1
        x_trail += 1

    if x_trail > n-1:
        x_trail = n-1
    if x_trail > 0:
        pl_text = pl_text[:-x_trail]

    # Write Result to File
    open(pl_file, 'w').write(pl_text)
    print(pl_text)


if __name__ == '__main__':
    if len(sys.argv) == 4:
        decrypt(sys.argv[1], sys.argv[2], sys.argv[3])
    else:
        decrypt()
