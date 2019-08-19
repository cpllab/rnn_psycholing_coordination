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
    'Vsg-Nsg-and': ['prefix', 'Vsg', 'det1', 'np1sg','and'],
    'Vpl-Nsg-and': ['prefix', 'Vpl', 'det1', 'np1sg','and'],
    'Vsg-Npl-and': ['prefix', 'Vsg', 'det1', 'np1pl','and'],
    'Vpl-Npl-and': ['prefix', 'Vpl', 'det1', 'np1pl','and'],
    'Vsg-Nsg-or': ['prefix', 'Vsg', 'det1', 'np1sg','or'],
    'Vpl-Nsg-or': ['prefix', 'Vpl', 'det1', 'np1sg','or'],
    'Vsg-Npl-or': ['prefix', 'Vsg', 'det1', 'np1pl','or'],
    'Vpl-Npl-or': ['prefix', 'Vpl', 'det1', 'np1pl','or'],
}

end_condition_included = False
autocaps = True



def rows(df):
    sent=[]
    for condition in conditions.keys():
        sent.append(df[conditions[condition][0]].str.strip() +' '+df[conditions[condition][1]].str.strip()+ ' '+df[conditions[condition][2]].str.strip()+' '+df[conditions[condition][3]].str.strip()+' '+df[conditions[condition][4]].str.strip())
    return sent


def expand_items(df):
    output_df = pd.DataFrame(rows(df))
    return output_df

def main(filename,outputfile):
    filename=sys.argv[1]
    outputfile=sys.argv[2]
    input_df = pd.read_excel(filename)
    output_df = expand_items(input_df)
    try:
        output_df.to_csv(outputfile, index= False, header= False, quoting=csv.QUOTE_NONE, quotechar='"',  sep='\n')
    except FileExistsError:
        pass




if __name__ == "__main__":
    main(*sys.argv[1:])

