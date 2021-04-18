#!/usr/bin/python

import os
import linecache
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord
from Bio.Seq import Seq
import argparse

parser = argparse.ArgumentParser(
     prog='filterLen.py',
     usage='''python filterLen.py --fasta [fasta file] --path [Path of fasta file] --length [length cut-off] --out [name of output fasta file] --pathOut [directory where output file should go]''',
     description='''This program pulls out specific sequences from a fasta file, given the fasta file and a list of sequences saved in a text file''',
     epilog='''It requires numpy and biopython libraries''')
parser.add_argument('--fasta', type=str, help='The name of the fasta file', required=True)
parser.add_argument('--path', type=str, help='The path of the fasta file', required=False)
parser.add_argument('--length', type=str, help='cut-off length', required=True)
parser.add_argument('--out', type=str, help='name of output fasta file', required=True)
parser.add_argument('--pathOut', type=str, help='path of output fasta file', required=False)

args=parser.parse_args()
fastapath=args.path
fasta=args.fasta
shortLength=args.length
output=args.out
outputPath=args.pathOut

if fastapath==None:
    fastafile=fasta
else:
    fastafile=os.path.join(fastapath,fasta)

if outputPath==None:
    outputfile=output
else:
    outputfile=os.path.join(outputPath,output)

id_dict = SeqIO.to_dict(SeqIO.parse(fastafile, "fasta"))

with open (outputfile, 'w') as out: 
    for record in id_dict:
        print id_dict[record].id
        if len(id_dict[record].seq) >= int(shortLength):
            out.write(">"+id_dict[record].id+"\n")
            out.write(str(id_dict[record].seq)+"\n")
