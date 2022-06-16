#!/usr/bin/python
import sys
from math import ceil, log2

if(len(sys.argv) == 0):
    print("specify input file")
    exit(-1)

print('Reading file:', sys.argv[0])

with open(sys.argv[1], "r") as file:
    contents = file.read()

print(contents+"\n\n")

idx = 0
encoded = "";

lines = contents.split("\n")

for line in contents.split("\n"):
    if(line.startswith("!")):
        lines.remove(line)
    else:
        line = line.replace(".", "0");
        line = line.replace("O", "1");
        lines[idx] = line;
        idx+=1;

dim = max(idx, len(line))


L = 2**ceil(log2(dim))

print("`define L "+str(L))
print("`define L2 "+str(L*L))
print("PATTERN:")
for idx in range(L):
    if(idx < len(lines)):
        print( lines[idx].rjust(L, "0"), end="" )
    else:
        print( "".rjust(L, "0"), end="")

print("")
