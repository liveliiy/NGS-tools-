#!/usr/bin/python
from argparse import ArgumentParser
from Bio.Seq import Seq
from Bio import SeqIO
parser = ArgumentParser(description='This Script is to convert nucleotide to amino acid')
parser.add_argument('-i', action='store', dest='sequence', help='Input is direct sequence')
parser.add_argument('-f', action='store', dest='inputfile', help='Input is a fasta file')
parser.add_argument('-r', action='store', dest='reverse_complement', help='Input is file, Reverse Complement the seq')
parser.add_argument('-t', action='store', dest='set_table', default=11, type=int, help='Translation table, default=11')
result = parser.parse_args()
set_table = result.set_table
if result.sequence:
 seq = Seq(result.sequence)
 print (seq.translate(table=set_table))
if result.inputfile:
 fastas = SeqIO.parse(result.inputfile, 'fasta')
 for fasta in fastas:
  print ('>%s' % fasta.id)
  print (fasta.seq.translate(table=set_table))
if result.reverse_complement:
 fastas = SeqIO.parse(result.reverse_complement, 'fasta')
 for fasta in fastas:
  print (">" + fasta.id)
  print (fasta.seq.reverse_complement())
