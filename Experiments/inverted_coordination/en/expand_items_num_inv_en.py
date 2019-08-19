import os
import sys

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
                yield sent_index, word_index + 1, "<eos>",condition

def main(filename, output_file):
    filename=sys.argv[1]
    output_file=sys.argv[2]
    input_df = pd.read_excel(filename)
    output_df = expand_items(input_df)
    try:
        output_df.to_csv("items_num_inv.txt", sep="\t")
    except FileExistsError:
        pass

    
if __name__ == "__main__":
    main(*sys.argv[1:])


