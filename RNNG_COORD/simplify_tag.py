#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 14 14:42:14 2019

@author: aixiuan
"""


from nltk.tree import *
from nltk import Tree, Nonterminal
import sys



def simplify_function_tag(tag):
    if '-' in tag:
        tag=tag.split('-')[0]
    if '=' in tag:
        tag=tag.split('=')[0]
    if '|' in tag:
        tag=tag.split('|')[0]
    return tag
    

def simplify(tree):
    for a in tree.subtrees():
        a.set_label(simplify_function_tag(a.label()))
    return tree


'''
a='((S (NP-SBJ (NML (NNP Pacific) (NNP First) (NNP Financial)) (NNP Corp.)) (VP (VBD said) (SBAR (S (NP-SBJ (NNS shareholders)) (VP (VBD approved) (NP (NP (PRP$ its) (NN acquisition)) (PP (IN by) (NP (NP (NML (NNP Royal) (NNP Trustco)) (NNP Ltd.)) (PP (IN of) (NP (NNP Toronto))))) (PP (IN for) (NP-CCP (NP-COORD (NP ($ $) (CD 27)) (NP-ADV (DT a) (NN share))) (, ,) (CC-CC or) (NP-COORD (QP ($ $) (CD 212) (CD million)))))))))) (. .)))'
tree_a=Tree.fromstring(a)
print(simplify(tree_a))

'''
def readtree(input_filename):
    input = open(input_filename,'r')
    output=[]
    for line_J in input.readlines():
        tree=Tree.fromstring(line_J)
        output.append(' '.join(str(simplify(tree)).split()) +'\n' ) 
    return output
    

def main(input_filename, output_filename):
    input_filename=sys.argv[1]
    output_filename=sys.argv[2]
    result=readtree(input_filename)
    out = open(output_filename, "w")
    for line in result:
        out.write(line)

if __name__ == "__main__":
    main(*sys.argv[1:])



