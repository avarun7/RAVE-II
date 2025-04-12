#!/bin/python3

import math
import os
import random
import re
import sys



#
# Complete the 'solution' function below.
#
# The function is expected to return a STRING.
# The function accepts STRING S as parameter.
#

valid_chars = set({a, b, c, d, e, f, "1", "0"})
def solution(S):
    returnString = ""
    for char in hex(S)[2:]:
        if(char in valid_chars):
            if(char == "1"):
                returnString += "I"
            else if(char == "0"):
                returnString += "O"
            else:
                returnString += str(ord(char) - 32)
        else:
            return "ERROR"
            

if __name__ == '__main__':
    
    fptr = open(os.environ['OUTPUT_PATH'], 'w')

    S = input()

    result = solution(S)

    fptr.write(result + '\n')

    fptr.close()