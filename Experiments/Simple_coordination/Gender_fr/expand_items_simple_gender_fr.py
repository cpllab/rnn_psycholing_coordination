import os
import sys

import pandas as pd

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

def expand_items(df):
    output_df = pd.DataFrame(rows(df))
    output_df.columns = ['sent_index', 'word_index', 'word', 'region', 'condition']
    return output_df

def rows(df):
    for condition in conditions:
        for sent_index, row in df.iterrows():
            word_index = 0
            for region in conditions[condition]:
                for word in row[region].split():
                    if autocaps and word_index == 0:
                        word = word.title()
                    yield sent_index, word_index, word, region, condition
                    word_index += 1
            if not end_condition_included:
                yield sent_index, word_index + 1, "<eos>", "End", condition

def main(filename, output_file):
    filename=sys.argv[1]
    output_file=sys.argv[2]
    input_df = pd.read_excel(filename)
    output_df = expand_items(input_df)
    try:
        output_df.to_csv(output_file, sep="\t")
    except FileExistsError:
        pass


if __name__ == "__main__":
    main(*sys.argv[1:])


