How to Run:
1. To Encrypt, run the file 'hill_encrypt.py' :
"python hill_encrypt.py key_file_name plain_text_file_name cipher_text_file_name"
hill_encrypt file takes 3 command-line arguments	(i)   Path/Name to the file which has the key.
													(ii)  Path/Name to the file which has the plain text.
													(iii) Path/Name to the file in which cipher text has to be stored.


2. To Decrypt, run the file 'hill_decrypt.py' :
"python hill_decrypt.py key_file_name cipher_text_file_name plain_text_file_name"
hill_decrypt file takes 3 command-line arguments	(i)   Path/Name to the file which has the key.
													(ii)  Path/Name to the file which has the cipher/encrypted text.
													(iii) Path/Name to the file in which plain/decrypted text has to be stored.


Notes : 
1. If all file names have not been passed as arguments then they need to be input via standard-input in the same order.
2. Key file can contain n^2 numbers in a line or a phrase to use as key.
3. Key file can't have length == 0.
4. Final key length has to be a perfect number so as to divide in a matrix of nxn.
5. Spaces and sepcial chars are removed from plain text.
6. If determinant of key matrix == 0 then decryption not possible. (as inverse doesn't exist)
7. If gcd(26, determinant of key matrix) != 1 then decryption not possible. (as modulo inverse doesn't exist)
8. 'x' are appended to plain text to make its length multiple of n.
9. During decryption atmost (n-1) trailing 'x' are removed.


Sample Commands :
python hill_encrypt.py key.txt input.txt cipher_text.txt
python hill_decrypt.py key.txt cipher_text.txt plain_text.txt