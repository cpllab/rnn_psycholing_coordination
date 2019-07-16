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

input_df = pd.read_excel('test_simple_coord.xlsx')

conditions = {
    'Nm_and_Nf_Vm': ['Det', 'N1m', 'et', 'Det', 'N2f', 'sont', 'Masc'],
    'Nm_and_Nf_Vf': [ 'Det', 'N1m', 'et', 'Det', 'N2f', 'sont', 'Fem'],
    'Nf_and_Nm_Vm': [ 'Det', 'N1f', 'et', 'Det', 'N2m', 'sont', 'Masc'],
    'Nf_and_Nm_Vf': [ 'Det', 'N1f', 'et', 'Det', 'N2m', 'sont', 'Fem'],
    'Nm_and_Nm_Vm': ['Det', 'N1m', 'et', 'Det', 'N2m', 'sont', 'Masc'],
    'Nm_and_Nm_Vf': [ 'Det', 'N1m', 'et', 'Det', 'N2m', 'sont', 'Fem'],
    'Nf_and_Nf_Vm': [ 'Det', 'N1f', 'et', 'Det', 'N2f', 'sont', 'Masc'],
    'Nf_and_Nf_Vf': [ 'Det', 'N1f', 'et', 'Det', 'N2f', 'sont', 'Fem'],
    'Nm_or_Nf_Vm': [ 'Det', 'N1m', 'ou', 'Det', 'N2f', 'sont', 'Masc'],
    'Nm_or_Nf_Vf': [ 'Det', 'N1m', 'ou', 'Det', 'N2f', 'sont', 'Fem'],
    'Nf_or_Nm_Vm': [ 'Det', 'N1f', 'ou', 'Det', 'N2m', 'sont', 'Masc'],
    'Nf_or_Nm_Vf': [ 'Det', 'N1f', 'ou', 'Det', 'N2m', 'sont', 'Fem'],
    'Nm_or_Nm_Vm': [ 'Det', 'N1m', 'ou', 'Det', 'N2m', 'sont', 'Masc'],
    'Nm_or_Nm_Vf': [ 'Det', 'N1m', 'ou', 'Det', 'N2m', 'sont', 'Fem'],
    'Nf_or_Nf_Vm': [ 'Det', 'N1f', 'ou', 'Det', 'N2f', 'sont', 'Masc'],
    'Nf_or_Nf_Vf': [ 'Det', 'N1f', 'ou', 'Det', 'N2f', 'sont', 'Fem'],

}
end_condition_included = False
autocaps = True



def rows(df):
    sent=[]
    for condition in conditions.keys():
        sent.append(df[conditions[condition][0]].str.strip()+' '+df[conditions[condition][1]].str.strip()+' '+df[conditions[condition][2]].str.strip()+' '+df[conditions[condition][3]].str.strip()+ ' '+df[conditions[condition][4]].str.strip()+' '+df[conditions[condition][5]].str.strip())
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
        os.mkdir("tests")
    except FileExistsError:
        pass
    output_df.to_csv(output_file, index= False, header= False, quoting=csv.QUOTE_NONE, quotechar='"',  sep='\n')
if __name__ == "__main__":
    main(*sys.argv[1:])
