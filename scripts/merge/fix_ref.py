#!/usr/bin/python
import gzip, os, sys
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-i", "--input", dest="input", help="Input file to clean")
parser.add_option("-o", "--output", dest="output", help="Output location (output will not be compressed)")
parser.add_option("-r", "--ref", dest="ref", help="Reference fasta (must be uncompressed and samtools indexed)")
(options, args) = parser.parse_args()

def prep_fasta():
    if not os.path.exists(options.ref+".fai"):
        sys.exit("Reference genome does not have an index file.")

    fasta_dict = {}
    fai_fh = file(options.ref+".fai",'r')
    for line in fai_fh:
        ls = line.strip().split('\t')
        for i in range(1,len(ls)):
            ls[i] = int(ls[i])

        if ls[0].startswith("chr"):
            ls[0] = ls[0][3:]

        fasta_dict[ls[0]] = ls[1:]
    fai_fh.close()
    return fasta_dict

def get_ref(chr,pos,ref_len,fasta_fh):
    pos -= 1
    chr_start = fasta_dict[chr][1]
    base_pl = fasta_dict[chr][2]
    bytes_pl = fasta_dict[chr][3]

    file_seek = chr_start + (( pos / base_pl ) * bytes_pl) + ( pos % base_pl )
    fasta_fh.seek(file_seek,0)
    ref = fasta_fh.read(ref_len)

    ref = ref.replace("\n","")
    while len(ref) < (ref_len):
        ref = ref + fasta_fh.read(1)
        ref = ref.replace("\n","")

    ref = ref.upper()
    return ref

def start(fin,fout):
    fasta_fh = file(options.ref,'r')

    if fin.endswith('.gz'):
        fh_in = gzip.open(fin,'rb')
    else:
        fh_in = file(fin)
    fh_out = file(fout,'w')

    for line in fh_in:
        if line[0] == '#':
            fh_out.write(line)
            continue

        ls = line.strip().split('\t')
        chr = ls[0]
        pos = int(ls[1])
        ref = ls[3]

        check_ref = get_ref(chr,pos,len(ref),fasta_fh)
        
        if ref == check_ref:
            fh_out.write(line)
        else:
            ls[3] = check_ref      
            fh_out.write('\t'.join(ls)+'\n')
                 
    fh_in.close()
    fh_out.close()

fasta_dict = prep_fasta()
start(options.input, options.output)
