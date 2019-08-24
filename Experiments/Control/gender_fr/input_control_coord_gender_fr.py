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
    'Nf_Vm': [ 'Det', 'N2f', 'sont', 'Masc'],
    'Nf_Vf': [  'Det', 'N2f', 'sont', 'Fem'],
    'Nm_Vm': [  'Det', 'N2m', 'sont', 'Masc'],
    'Nm_Vf': [  'Det', 'N2m', 'sont', 'Fem'],

}
end_condition_included = False
autocaps = True



def rows(df):
    sent=[]
    for condition in conditions.keys():
        sent.append(df[conditions[condition][0]].str.title()+' '+df[conditions[condition][1]].str.strip()+' '+df[conditions[condition][2]].str.strip()+' '+df[conditions[condition][3]].str.strip()+' '+'<eos>')
    #.str.cat(df[conditions[condition][2]],sep=" ").str.cat(df[conditions[condition][3]],sep=" ").str.cat(df[conditions[condition][4]],sep=" ").str.cat(df[conditions[condition][5]],sep=" ").str.cat("<eos>", sep=None))
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
