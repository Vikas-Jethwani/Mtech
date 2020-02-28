How to Run:
To do crypt-analysis, run the file '2019MCS2573.py' :
"python 2019MCS2573.py key_file_name cipher_text_file_name"
2019MCS2573 file takes 2 command-line arguments	(i)  Path/Name to the file which has the key length.
												(ii) Path/Name to the file in which cipher text has to be stored.

Notes : 
1. If all file names have not been passed as arguments then they need to be input via standard-input in the same order.
2. Key file contains a single integer,N, denoting the size of key(NxN). 
3. Key file can only contain integers = {1,2,3}. Nothing outside this set.
4. During decryption atmost (N-1) trailing 'x' are removed.


Sample Commands :
python 2019MCS2573.py key.txt cipher_text.txt