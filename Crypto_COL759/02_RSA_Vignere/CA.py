from time import time # For self time measurements
import math # For log
import gmpy2 # For prime related stuff and mod_inverse
import random # To generate first random number for input to next_prime

# ========================================================================
# Global Constants
DISTINCT = 37
CHECK = ord('-')-ord('a') # for '-'
FIX = 26 # for '-'
FIX_NUM = 27 # for number '0' and so on...
KEY_LEN = 512

# ========================================================================
# Method 1: Strong Prime Generation
SMALL_PRIMES_UPTO = 100000
SMALL_PRIMES = [i for i in range(SMALL_PRIMES_UPTO) if gmpy2.is_prime(i)]
def remove_small_primes(n):
    for prime in SMALL_PRIMES:
        while n%prime==0:
            n  //= prime
    return n

def is_strong_prime(p):
    if not gmpy2.is_prime(p): return False
    
    # p-1
    q = remove_small_primes(p-1)
    if math.log(q, 2) < 2*KEY_LEN/3 : return False
    if not gmpy2.is_prime(q): return False

    # q-1
    if not gmpy2.is_prime(remove_small_primes(q-1)): return False

    #p+1
    p1 = remove_small_primes(p+1)
    if math.log(p1, 2) < 2*KEY_LEN/3 : return False
    if not gmpy2.is_prime(p1): return False

    return True

def generate_strong_prime(length=512):

    low = 2**length
    high = 2**(length+1) - 1

    strong_prime_candidate = int(gmpy2.next_prime(random.randint(low, high)))
    while not is_strong_prime(strong_prime_candidate):
#         strong_prime_candidate = int(gmpy2.next_prime( strong_prime_candidate + 1 ))
        strong_prime_candidate = int(gmpy2.next_prime(random.randint(low, high)))

    return strong_prime_candidate

# ========================================================================
# Method 2 : Sir's definition: Airthmetic strong prime + (p-1)/2 is prime.
def generate_strong_prime_2(length=512):

    low = 2**length
    high = 2**(length+1) - 1

    # Pn = 2*q + 1
    # also: Pn > (Pn-1 + Pn+1)/2 
    Pn0 = int(gmpy2.next_prime(random.randint(low, high)))
    Pn1 = int(gmpy2.next_prime( Pn0 + 1 ))
    Pn2 = int(gmpy2.next_prime( Pn1 + 1 ))

    q = (Pn1-1)//2

    while not( Pn1 > (Pn0+Pn2)//2 and gmpy2.is_prime(q) ):
        
        Pn0 = int(gmpy2.next_prime(random.randint(low, high)))
        Pn1 = int(gmpy2.next_prime( Pn0 + 1 ))
        Pn2 = int(gmpy2.next_prime( Pn1 + 1 ))

        q = (Pn1-1)//2
    return Pn1

# ========================================================================
# Find dynamic block size by formula mentioned in class
def find_block_size(num_diff_chars, n):
    block_size = int(math.log(n, num_diff_chars))

    if num_diff_chars**block_size >= n:
        return block_size-1
    else:
        return block_size

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

# ========================================================================
# Generate primes for CA
CA_p = generate_strong_prime_2(KEY_LEN)
CA_q = generate_strong_prime_2(KEY_LEN)
CA_n = CA_p * CA_q
CA_phi_n = (CA_p-1) * (CA_q-1)

# Starting point
low = 2**(KEY_LEN-1)
high = CA_phi_n - 1

CA_e = int(gmpy2.next_prime(random.randint(low, high)))
g, s, t = gmpy2.gcdext(CA_e, CA_phi_n)
while g != 1:
    CA_e = int(gmpy2.next_prime(random.randint(low, high)))
    g, s, t = gmpy2.gcdext(CA_e, CA_phi_n)
CA_d = s%CA_phi_n

open('public_CA.txt', 'w+').write(str(CA_e) + ' ' + str(CA_n))

# ========================================================================
def generate_keys_CA(N=2):
    """
        N = No. of people in group for whom public and private keys have to be generated.
        
        Outputs 1 file with everyone's public key.
        and N files with their respective private key.
    """
    # Remove all old keys
    open('public_dir.txt', 'w+').close()

    for i in range(1,N+1):
        p = generate_strong_prime_2(KEY_LEN)
        q = generate_strong_prime_2(KEY_LEN)
        n = p*q
        phi_n = (p-1)*(q-1)
        
        low = 2**(KEY_LEN-1)
        high = phi_n - 1

        e = int(gmpy2.next_prime(random.randint(low, high)))
        g, s, t = gmpy2.gcdext(e, phi_n)
        while g != 1:
            e = int(gmpy2.next_prime(random.randint(low, high)))
            g, s, t = gmpy2.gcdext(e, phi_n)
        d = s%phi_n

        public_details = str(e) + '-' + str(n)
        public_details_RSA = encrypt_RSA(public_details, CA_d, CA_n)
        private_details = str(e) + '-' + str(d) + '-' + str(p) + '-' + str(q)
        private_details_RSA = encrypt_RSA(private_details, CA_d, CA_n)


        public_dir = open('public_dir.txt', 'a+')
        public_dir.write(str(i) + ' ' + public_details_RSA + '\n')
        public_dir.close()

        private_dir = open('private_' + str(i) + '.txt', 'w+')
        private_dir.write(private_details_RSA)
        private_dir.close()


# Generate Keys for Users
generate_keys_CA(2)
print("Keys generated successfully !")