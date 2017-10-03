# convert_genename.py
"""
Takes an input gene list of gene symbols and converts them entrez ids (or vice
versa) and writes the output to a text file.

Example usage:
python convert_genename.py -i mygenelist.txt -o mygenesymbols --entrez2genesymbols
python convert_genename.py -i mygenelist.txt -o myentrezids --genesymbols2entrez
"""

# import modules
import mygene
from optparse import OptionParser
import numpy as np

# function to parse input arguments
def parse_args():
    """
    Parse arguments.
    """
    parser=OptionParser()
    parser.add_option('-i',"",dest='genelist',help="file with genes to convert ex: -i genelist.txt",default=None)
    parser.add_option('-o',"",dest='outname',help="prefix to put on output filename ex: -o myconvertedgenes",default=None)
    parser.add_option('--entrez2genesymbols',"",action="store_true",dest='ent2gs',help="Convert Entrez IDs to gene symbols",default=False)
    parser.add_option('--genesymbols2entrez',"",action="store_true",dest='gs2ent',help="Convert gene symbols to Entrez IDs",default=False)
    parser.add_option('--species',"",dest='species',help="Species to use e.g., --species human",default="human")
    (options,args) = parser.parse_args()
    return(options)


def readin_genelist(fname):
    """
    Read in genelist as list of strings.
    """
    with open(fname) as f:
        lines = f.read().splitlines()

    return(lines)

# function to convert entrez gene id to gene symbol
def entrez2genesymbol(genelist):
    """
    Convert Entrez Gene ID to Gene Symbol.
    """
    mg = mygene.MyGeneInfo()

    res_list = [None] * len(genelist)

    for gidx, gene in enumerate(genelist):
        print(gene)
        res = mg.getgene(gene)
        if res is not None:
            gene_symbol = res["symbol"]
            gene_symbol_ascii = gene_symbol.encode("ascii")
            res_list[gidx] = gene_symbol
        else:
            res_list[gidx] = "NA"
    # turn unicode strings to ascii
    # res_list = [gene.encode('ascii') for gene in res_list]

    return(res_list)

# function to convert gene symbol to entrez gene id
def genesymbol2entrez(genelist, species = "human"):
    """
    Convert Gene Symbol to Entrez Gene ID.
    """
    mg = mygene.MyGeneInfo()

    res_list = [None] * len(genelist)

    for gidx, gene in enumerate(genelist):
        print(gene)
        gene_query = "symbol:%s" % gene
        res = mg.query(gene_query, species = species)
        if not res["hits"]:
            res_list[gidx] = "NA"
        else:
            for i in range(len(res)):
                try:
                    entrez_geneid = res["hits"][i]["entrezgene"]
                    break
                except:
                    print("searching for entrez_geneid")

            res_list[gidx] = entrez_geneid

    return(res_list)

def write_output2file(res_list, outname, ent2gs = False, gs2ent = False):

    if outname is not None:
        if ent2gs:
            output_name = "%s_genesymbols.txt" % outname
        elif gs2ent:
            output_name = "%s_entrezids.txt" % outname
    else:
        if ent2gs:
            output_name = "genesymbols.txt" % outname
        elif gs2ent:
            output_name = "entrezids.txt" % outname

    file2write = open(output_name, 'w')

    for item in res_list:
        file2write.write("%s\n" % item)


# boilerplate code to call main code for executing
if __name__ == '__main__':

    # parse arguments
    opts = parse_args()
    input_file = opts.genelist
    outname = opts.outname
    species = opts.species
    ent2gs = opts.ent2gs
    gs2ent = opts.gs2ent

    genelist = readin_genelist(input_file)

    if ent2gs:
        res_list = entrez2genesymbol(genelist)
        write_output2file(res_list, outname, ent2gs = True)
    if gs2ent:
        res_list = genesymbol2entrez(genelist)
        write_output2file(res_list, outname, gs2ent = True)
