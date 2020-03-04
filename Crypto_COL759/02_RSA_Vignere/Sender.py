import math # for log
import random # for vignere key
import gmpy2 # for mod_inverse

# ========================================================================
# Global Constants
DISTINCT = 37
S_ID = 1
R_ID = 2
CHECK = ord('-')-ord('a') # for '-'
FIX = 26 # for '-'
FIX_NUM = 27 # for number '0' and so on...

# ========================================================================
# CA Details
CA_e, CA_n = map(int, open('public_CA.txt', 'r').read().split())

# To remove ('a'=0) appended while decrypting RSA
def remove_extra_a(with_a):
    return with_a.rstrip('a')

# Find dynamic block size by formula mentioned in class
def find_block_size(num_diff_chars, n):
    block_size = int(math.log(n, num_diff_chars))

    if num_diff_chars**block_size >= n:
        return block_size-1
    else:
        return block_size

# ========================================================================
# RSA Encryption : Using CRT if possible
def encrypt_RSA(pl_text, key, n, CRT='no', p=None, q=None):
    ci_text = ''
    r = find_block_size(DISTINCT, n)
    s = r+1
    for i in range(0, len(pl_text), r):
        block = pl_text[i:i+r]
        M = 0
        for j, ch in enumerate(block):
            if ch=='-':
                M += (FIX)*(DISTINCT**j)
            elif '0' <= ch <= '9':
                M += (ord(ch) - ord('0') + FIX_NUM)*(DISTINCT**j)
            else:
                M += (ord(ch) - ord('a'))*(DISTINCT**j)

        # ====================================
        if CRT=='no':
            C = pow(M, key, n)
        else:
            dP = key % (p-1)
            dQ = key % (q-1)

            g, ss, t = gmpy2.gcdext(q, p)
            q_inv = int(ss) % p

            x1 = pow(M, dP, p)
            x2 = pow(M, dQ, q)
            h = q_inv*(x1-x2) % p
            C = (x2 + h*q)
        # ====================================

        for j in range(s-1,-1,-1):
            temp = C // (DISTINCT**j)
            C -= temp*(DISTINCT**j)

            # for Numbers
            if FIX_NUM <= temp <= FIX_NUM+9:
                ci_text += chr(temp-FIX_NUM + ord('0'))
            else:
                if temp == FIX: temp = CHECK # for '-'
                ci_text += chr(temp+ord('a'))

    return ci_text

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
# Self Details : e, d, p, q
S_keys = open('private_' + str(S_ID) + '.txt', 'r').read() # Encrypted by CA

S_e, S_d, S_p, S_q = map(int, map(remove_extra_a, decrypt_RSA(S_keys, CA_e, CA_n).split('-')))
S_n = S_p * S_q

# Find Receiver's Details : e, n
for row in open('public_dir.txt', 'r').read().split('\n')[:-1]:
    row_details = row.split(' ')
    if int(row_details[0]) == R_ID:
        R_keys = row_details[1]
        R_e, R_n = map(int, list(map(remove_extra_a, decrypt_RSA(R_keys, CA_e, CA_n).split('-'))))

# ========================================================================
# Filter message : Allow only english characters after converting entire string to lowercase
def clean(msg):
    msg = msg.lower()
    clean_msg = ''

    for ch in msg:
        if 'a' <= ch <= 'z':
            clean_msg += ch
    return clean_msg

# Generate randome vignere key with desired property
def generate_key_vignere(length=20, distinct=True):
    """
        key length should be <= 26, else distinct not possible.
    """
    if distinct and length<=26:
        all_idx = [i for i in range(26)]
        random.shuffle(all_idx)
        return ''.join([chr(idx + ord('a')) for idx in all_idx[:length]])
    else:
        all_idx = [random.randint(0,25) for i in range(length)]
        return ''.join([chr(idx + ord('a')) for idx in all_idx])

# Vignere Encryption
def encrypt_vignere(pl_text, key):
    """
        Takes plain_text(Lowercase Letters) and key as argument and returns encrypted cipher_text.
    """
    ci_text = ''
    key_len = len(key)
    for i in range(len(pl_text)):
        ci_char = ( ord(pl_text[i]) - ord('a') + ord(key[i%key_len]) - ord('a') )%26
        ci_text += chr( ci_char + ord('a') )

    return ci_text

# ========================================================================
# Generate Key -> Clean Msg -> Encrypt Msg -> Prepend the Vig_Key to Enc_Msg
key_vig = generate_key_vignere()

msg = 'hello this is a beautiful day! This has been a crazy ride. The dear departed. And here we are in threat of coronavirus. Will you be number 1?'
msg = clean(msg)
print("Filtered Message: ", msg)

ci_text_vig = encrypt_vignere(msg, key_vig)

msg_for_RSA = key_vig + '-' + ci_text_vig

# Sign the (Vig_key-Msg) by self Private Key   (CRT)
digitally_signed = encrypt_RSA(msg_for_RSA, S_d, S_n, 'yes', S_p, S_q)

# ========================================================================
# RSA using receiver's Public Key
final_to_send = encrypt_RSA(digitally_signed, R_e, R_n)
print("Final Encrypted message with digital signature: ", final_to_send)

# Store final message in file which needs to be transferred over unsafe network
open('send_over_unsafe_network.txt','w+').write(final_to_send)
