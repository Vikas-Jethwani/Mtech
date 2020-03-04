import math # for log
import gmpy2 # for mod_inverse

# ========================================================================
# Global Constants
DISTINCT = 37
S_ID = 2 # Self Id
R_ID = 1 # Retrieval sender Id
CHECK = ord('-')-ord('a') # for '-'
FIX = 26 # for '-'
FIX_NUM = 27 # for number '0' and so on...

# ========================================================================
# Load final message from file which has been transferred over unsafe network
RCVD_MSG = open('send_over_unsafe_network.txt', 'r').read()

# CA Details
CA_e, CA_n = map(int, open('public_CA.txt', 'r').read().split())

# ========================================================================
# Find dynamic block size by formula mentioned in class
def find_block_size(num_diff_chars, n):
    block_size = int(math.log(n, num_diff_chars))

    if num_diff_chars**block_size >= n:
        return block_size-1
    else:
        return block_size

# RSA Dencryption : Using CRT if possible
def decrypt_RSA(ci_text, key, n, CRT='no', p=None, q=None):
    pl_text = ''
    r = find_block_size(DISTINCT, n)
    s = r+1

    for i in range(0, len(ci_text), s):
        block = ci_text[i:i+s]
        C = 0
        for j, ch in enumerate(block[::-1]): # Reverse of encryption
            if ch=='-':
                C += (FIX)*(DISTINCT**j)
            elif '0' <= ch <= '9':
                C += (ord(ch) - ord('0') + FIX_NUM)*(DISTINCT**j)
            else:
                C += (ord(ch) - ord('a'))*(DISTINCT**j)

        # ====================================
        if CRT=='no':
            M = pow(C, key, n)
        else:
            dP = key % (p-1)
            dQ = key % (q-1)

            g, ss, t = gmpy2.gcdext(q, p)
            q_inv = int(ss) % p

            x1 = pow(C, dP, p)
            x2 = pow(C, dQ, q)
            h = q_inv*(x1-x2) % p
            M = (x2 + h*q)
        # ====================================

        updated_block = ''
        for j in range(r-1,-1,-1):
            temp = M // (DISTINCT**j)
            M -= temp*(DISTINCT**j)

            # for Numbers
            if FIX_NUM <= temp <= FIX_NUM+9:
                updated_block += chr(temp-FIX_NUM + ord('0'))
            else:
                if temp == FIX: temp = CHECK # for '-'
                updated_block += chr(temp+ord('a'))

        pl_text += updated_block[::-1]

    return pl_text

# ========================================================================
# To remove ('a'=0) appended while decrypting RSA
def remove_extra_a(with_a):
    return with_a.rstrip('a')

# Self Details : e, d, p, q
S_keys = open('private_' + str(S_ID) + '.txt', 'r').read() # Encrypted by CA

S_e, S_d, S_p, S_q = map(int, list(map(remove_extra_a, decrypt_RSA(S_keys, CA_e, CA_n).split('-'))))
S_n = S_p * S_q

# Find Receiver's Details : e, n
for row in open('public_dir.txt', 'r').read().split('\n')[:-1]:
    row_details = row.split(' ')
    if int(row_details[0]) == R_ID:
        R_keys = row_details[1]
        R_e, R_n = map(int, list(map(remove_extra_a, decrypt_RSA(R_keys, CA_e, CA_n).split('-'))))

# ========================================================================
# Remove RSA encryption of by self Private key    (CRT)
decrypt1_msg = decrypt_RSA(RCVD_MSG, S_d, S_n, 'yes', S_p, S_q).rstrip('a')

# Vig_key and Enc_Msg separated by '-'
key_vig, encrypt_vig = map(remove_extra_a, decrypt_RSA(decrypt1_msg, R_e, R_n).split('-'))
print("Vignere Key :", key_vig)

# Decrypt to get the original Msg by using Vig_key
def decrypt_vignere(ci_text, key):
    """
        Takes cipher_text(Lowercase Letters) and key as argument and returns decrypted plain_text.
    """
    pl_text = ''
    key_len = len(key)
    for i in range(len(ci_text)):
        pl_char = ( ord(ci_text[i]) - ord('a') - ord(key[i%key_len]) + ord('a') )%26
        pl_text += chr( pl_char + ord('a') )
    
    return pl_text

print("Decrypted Final Message: ", decrypt_vignere(encrypt_vig, key_vig))

# Fails at (3^5 mod 21)^e mod 15 = 0.. So can't recover back the message.
#          (M^S_d mod S_n)^R_e mod R_n 
