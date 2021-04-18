#!/usr/bin/python

from Bio import SeqIO
import argparse
import os

parser = argparse.ArgumentParser(
     prog='splitfasta.py',
     usage='''python splitfasta.py --fasta [Genome fasta file] --path [Path of genome file] --pieces [No. of pieces desired] --pathOut [direct the output]''',
     description='''This program splits a fasta sequence into several similarly-sized pieces.''',
     epilog='''It requires biopython libraries''')
parser.add_argument('--speciesName', type=str, help='The name of the species', required=True)
parser.add_argument('--fasta', type=str, help='Fasta full path', required=True)
parser.add_argument('--pieces', type=int, help='No. of pieces desired', required=True)
parser.add_argument('--pathOut', type=str, help='path of output files', required=False)

args = parser.parse_args()

pathOut = args.pathOut
genomeFasta = open(args.fasta,'r')
pieces = args.pieces

seqRecords = SeqIO.parse(genomeFasta, "fasta")
seqRecords = list(seqRecords)

genomeLen=0
for seq_record in seqRecords:
   genomeLen+=len(seq_record.seq)

splice=genomeLen/pieces  
j=0 
for i in range(1,pieces+1):
    outFile = os.path.join(pathOut, args.speciesName + ".fasta" + str(i))
    breaks=0
    with open(outFile,'w') as wf:        
         while (breaks < splice) and j < len(seqRecords):
             wf.write("%s%s\n%s\n" % (">",seqRecords[j].id, seqRecords[j].seq)) # Making the fasta file
             breaks+=len(seqRecords[j].seq)
             j+=1
