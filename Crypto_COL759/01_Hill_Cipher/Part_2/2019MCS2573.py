import numpy as np
import math # For GCD
import sys # For terminating when error


eng_mono_grams = ['e', 't', 'a', 'o', 'i', 'n', 's', 'h', 'r', 'd', 'l', 'u']
eng_bi_grams   = ['th', 'he', 'in', 'er', 'an', 're', 'nd', 'at', 'on', 'en', 'nt']
eng_tri_grams  = ['the', 'and', 'ing', 'ent', 'ion', 'for', 'tha', 'tio', 'nde', 'oft', 'has', 'sth']

Low_IC = 0.054
High_IC = 0.083

def inverse(N, matrix):
    determinant = np.linalg.det(matrix)
    determ = int(round(determinant))

    # Inverse/Modulo-Inverse of determinant exists or not
    if determ == 0:
        return 0, None
    if math.gcd(determ, 26) != 1:
        return 0, None

    # Inverse of Matrix
    inverse = np.linalg.inv(matrix)
    # Adjoint of Matrix
    adjoint = np.around(inverse*determinant).astype(int, copy=False)

    # Modulo inverse of Determinant
    def modInv(a, m):
        for num in range(1, m):
            if (a*num)%m == 1:
                return num
        return None
    det_mod_inv = modInv(determ, 26)

    # Modulo inverse of Matrix
    modulo_inv = np.zeros(shape=(N, N), dtype=int)
    for i in range(N):
        for j in range(N):
            modulo_inv[i][j] = (adjoint[i][j] * det_mod_inv) % 26

    return 1, modulo_inv


def index_of_coincidence(text):
    freq = [0]*26
    L = len(text)

    for ch in text:
        freq[ord(ch)-ord('a')] += 1

    ans = 0.0
    for i in range(26):
        ans += (freq[i] * (freq[i] - 1))

    ans /= (L*(L-1))
    return ans


def decrypt(N, key_mat, ci_text_int):

    ok, key_mod_inv = inverse(N, key_mat)
    if ok == 0:
        return

    # Get back Plain_Text
    pl_text = ''
    for i in range(0, len(ci_text_int), N):
        segment = ci_text_int[i:i+N]
        dot_prod = np.dot(key_mod_inv, np.asarray(segment).reshape(N,1)) # Matrix multiplication
        for elem in dot_prod:
            pl_text += chr((elem[0]%26) + ord('a')) # (Mod then add ASCII) to convert back to character

    # Erase trailing 'x', atmost (N-1)
    x_trail, i = 0, len(pl_text)-1
    while i>=0 and pl_text[i]=='x':
        i -= 1
        x_trail += 1

    if x_trail > N-1:
        x_trail = N-1
    if x_trail > 0:
        pl_text = pl_text[:-x_trail]

    text_IC = index_of_coincidence(pl_text)
    if (Low_IC <= text_IC <= High_IC):
        # Write Result to File
        to_write = np.array_str(key_mat) + '\n' + pl_text + '\nIC: ' + str(text_IC) + '\n\n\n'
        print(to_write)
        f = open('possible_keys_plain_texts', 'a')
        f.write(to_write)
        f.close()


def key_len_one(N, ci_text_int, ci_grams):
    possible_keys_list = []
    possible_keys_set = set()

    for x in range(len(eng_mono_grams)):
        P = eng_mono_grams[x]
        P_arr = [ord(ch) - ord('a') for ch in P]
        P_mat = np.asarray(P_arr).reshape(N,N)

        ok, P_inv = inverse(N, P_mat)
        if ok == 0:
            continue

        for i in range(len(ci_grams)):
            C = ci_grams[i]    
            C_arr = [ord(ch) - ord('a') for ch in C]
            C_mat = np.asarray(C_arr).reshape(N,N)

            dot_prod = np.dot(C_mat, np.asarray(P_inv))
            for ii in range(N):
                for jj in range(N):
                    dot_prod[ii][jj] = dot_prod[ii][jj] % 26  # Will run only once for [0][0]

            dot_prod_as_str = np.array_str(dot_prod)
            if dot_prod_as_str not in possible_keys_set:
                possible_keys_set.add(dot_prod_as_str)
                possible_keys_list.append(dot_prod)

    for key in possible_keys_list:
        decrypt(N, key, ci_text_int)


def key_len_two(N, ci_text_int, ci_grams):
    possible_keys_list = []
    possible_keys_set = set()

    for x in range(len(eng_bi_grams)):
        for y in range(x+1, len(eng_bi_grams)):

            P = eng_bi_grams[x] + eng_bi_grams[y]    
            P_arr = [ord(ch) - ord('a') for ch in P]
            P_mat = np.asarray(P_arr).reshape(N,N).transpose()

            ok, P_inv = inverse(N, P_mat)
            if ok == 0:
                continue

            for i in range(len(ci_grams)):
                for j in range(len(ci_grams)):
                    if i == j: continue
                        
                    C = ci_grams[i] + ci_grams[j]    
                    C_arr = [ord(ch) - ord('a') for ch in C]
                    C_mat = np.asarray(C_arr).reshape(N,N).transpose()
                    

                    dot_prod = np.dot(C_mat, np.asarray(P_inv))
                    for ii in range(N):
                        for jj in range(N):
                            dot_prod[ii][jj] = dot_prod[ii][jj] % 26

                    dot_prod_as_str = np.array_str(dot_prod)
                    if dot_prod_as_str not in possible_keys_set:
                        possible_keys_set.add(dot_prod_as_str)
                        possible_keys_list.append(dot_prod)

    for key in possible_keys_list:
        decrypt(N, key, ci_text_int)


def key_len_three(N, ci_text_int, ci_grams):
    possible_keys_list = []
    possible_keys_set = set()

    for x in range(len(eng_tri_grams)):
        for y in range(x+1, len(eng_tri_grams)):
            for z in range(y+1, len(eng_tri_grams)):

                P = eng_tri_grams[x] + eng_tri_grams[y] + eng_tri_grams[z]
                P_arr = [ord(ch) - ord('a') for ch in P]
                P_mat = np.asarray(P_arr).reshape(N,N).transpose()

                ok, P_inv = inverse(N, P_mat)
                if ok == 0:
                    continue

                for i in range(len(ci_grams)):
                    for j in range(len(ci_grams)):
                        if i == j: continue
                        for k in range(len(ci_grams)):
                            if k == i or k == j: continue

                            C = ci_grams[i] + ci_grams[j] + ci_grams[k]
                            # print(P, C)

                            C_arr = [ord(ch) - ord('a') for ch in C]
                            C_mat = np.asarray(C_arr).reshape(N,N).transpose()


                            dot_prod = np.dot(C_mat, np.asarray(P_inv))
                            for ii in range(N):
                                for jj in range(N):
                                    dot_prod[ii][jj] = dot_prod[ii][jj] % 26

                            dot_prod_as_str = np.array_str(dot_prod)
                            if dot_prod_as_str not in possible_keys_set:
                                possible_keys_set.add(dot_prod_as_str)
                            possible_keys_list.append(dot_prod)

    for key in possible_keys_list:
        decrypt(N, key, ci_text_int)


def crypt_analysis(key_len_file=None, ci_file=None):

    # Check if path to file provided
    if key_len_file == None :
        key_len_file = input().strip()
        ci_file = input().strip()

    # Read and process Files
    N = int(open(key_len_file, 'r').read().strip())
    ci_text = open(ci_file, 'r').read().strip()
    ci_text_int = [ord(ch)-ord('a') for ch in ci_text] # Convert to ints

    # Find n-grams frequency
    ci_grams_ = dict()
    for i in range(0, len(ci_text)-N+1, N):
        if ci_text[i:i+N] in ci_grams_:
            ci_grams_[ ci_text[i:i+N] ] += 1
        else:
            ci_grams_[ ci_text[i:i+N] ] = 1

    # Find top-10 n-grams in cipher text
    ci_grams_temp = sorted(ci_grams_.items(), key=lambda ci_grams_: ci_grams_[1], reverse=True)
    freq = ci_grams_temp[12][1]
    idx=0
    for pair in ci_grams_temp :
        if pair[1] >= freq:
            idx += 1
    idx = min(idx, 15)
    ci_grams = [pair[0] for pair in ci_grams_temp[:idx]]

    # Can replace entire thing with below for time-accuracy tradeoff
    # ci_grams = [pair[0] for pair in sorted(ci_grams_.items(), key=lambda ci_grams_: ci_grams_[1], reverse=True)[:10]]

    
    if N == 1:
        key_len_one(N, ci_text_int, ci_grams)
    elif N == 2:
        key_len_two(N, ci_text_int, ci_grams)
    elif N == 3:
        key_len_three(N, ci_text_int, ci_grams)
    else:
        print('Please enter key length less than equal to 3.')
        sys.exit(1)



if __name__ == '__main__':
    if len(sys.argv) == 3:
        crypt_analysis(sys.argv[1], sys.argv[2])
    else:
        crypt_analysis()