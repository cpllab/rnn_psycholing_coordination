#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Apr 18 15:48:47 2019

@author: aixiuan
"""

import os
import sys
import csv

import pandas as pd


conditions = {
    'that_pl_pl-Vsg': ['prefix_gram','det1', 'np1pl', 'and', 'det2', 'np2pl','is'],
    'that_sg_pl-Vsg': ['prefix_gram','det1', 'np1sg', 'and', 'det2', 'np2pl','is'],
    'that_pl_sg-Vsg': ['prefix_gram','det1', 'np1pl', 'and', 'det2', 'np2sg','is'],
    'that_sg_sg-Vsg': ['prefix_gram','det1', 'np1sg', 'and', 'det2', 'np2sg','is'],
    'that_pl_pl-Vpl': ['prefix_gram','det1', 'np1pl', 'and', 'det2', 'np2pl','are'],
    'that_sg_pl-Vpl': ['prefix_gram','det1', 'np1sg', 'and', 'det2', 'np2pl','are'],
    'that_pl_sg-Vpl': ['prefix_gram','det1', 'np1pl', 'and', 'det2', 'np2sg','are'],
    'that_sg_sg-Vpl': ['prefix_gram','det1', 'np1sg', 'and', 'det2', 'np2sg','are'],
    'verb_pl_pl-Vsg': ['prefix_ungram','det1', 'np1pl', 'and', 'det2', 'np2pl','is'],
    'verb_sg_pl-Vsg': ['prefix_ungram','det1', 'np1sg', 'and', 'det2', 'np2pl','is'],
    'verb_pl_sg-Vsg': ['prefix_ungram','det1', 'np1pl', 'and', 'det2', 'np2sg','is'],
    'verb_sg_sg-Vsg': ['prefix_ungram','det1', 'np1sg', 'and', 'det2', 'np2sg','is'],
    'verb_pl_pl-Vpl': ['prefix_ungram','det1', 'np1pl', 'and', 'det2', 'np2pl','are'],
    'verb_sg_pl-Vpl': ['prefix_ungram','det1', 'np1sg', 'and', 'det2', 'np2pl','are'],
    'verb_pl_sg-Vpl': ['prefix_ungram','det1', 'np1pl', 'and', 'det2', 'np2sg','are'],
    'verb_sg_sg-Vpl': ['prefix_ungram','det1', 'np1sg', 'and', 'det2', 'np2sg','are'],
}



end_condition_included = False
autocaps = True



def rows(df):
    sent=[]
    for condition in conditions.keys():
        sent.append(df[conditions[condition][0]].str.strip()+' '+df[conditions[condition][1]].str.strip()+' '+df[conditions[condition][2]].str.strip()+' '+df[conditions[condition][3]].str.strip()+ ' '+df[conditions[condition][4]].str.strip()+' '+df[conditions[condition][5]].str.strip()+' '+df[conditions[condition][5]].str.strip())
    return sent

def expand_items(df):
    output_df = pd.DataFrame(rows(df))
    return output_df

def main(filename, output_file):
    filename=sys.argv[1]
    output_file=sys.argv[2]
    input_df = pd.read_excel(filename)
    output_df = expand_items(input_df)
    try:
        output_df.to_csv(output_file, index= False, header= False, quoting=csv.QUOTE_NONE, quotechar='"',  sep='\n')
    except FileExistsError:
        pass

if __name__ == "__main__":
    main(*sys.argv[1:])
