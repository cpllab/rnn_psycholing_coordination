import os
import sys

import pandas as pd

conditions = {
    'and_pl_pl-Vsg': ['det1pl', 'np1pl', 'and', 'det2pl', 'np2pl','Vsg'],
    'and_sg_pl-Vsg': ['det1sg', 'np1sg', 'and', 'det2pl', 'np2pl','Vsg'],
    'and_pl_sg-Vsg': ['det1pl', 'np1pl', 'and', 'det2sg', 'np2sg','Vsg'],
    'and_sg_sg-Vsg': ['det1sg', 'np1sg', 'and', 'det2sg', 'np2sg','Vsg'],
    'and_pl_pl-Vpl': ['det1pl', 'np1pl', 'and', 'det2pl', 'np2pl','Vpl'],
    'and_sg_pl-Vpl': ['det1sg', 'np1sg', 'and', 'det2pl', 'np2pl','Vpl'],
    'and_pl_sg-Vpl': ['det1pl', 'np1pl', 'and', 'det2sg', 'np2sg','Vpl'],
    'and_sg_sg-Vpl': ['det1sg', 'np1sg', 'and', 'det2sg', 'np2sg','Vpl'],
    'or_pl_pl-Vsg': ['det1pl', 'np1pl', 'or', 'det2pl', 'np2pl','Vsg'],
    'or_sg_pl-Vsg': ['det1sg', 'np1sg', 'or', 'det2pl', 'np2pl','Vsg'],
    'or_pl_sg-Vsg': ['det1pl', 'np1pl', 'or', 'det2sg', 'np2sg','Vsg'],
    'or_sg_sg-Vsg': ['det1sg', 'np1sg', 'or', 'det2sg', 'np2sg','Vsg'],
    'or_pl_pl-Vpl': ['det1pl', 'np1pl', 'or', 'det2pl', 'np2pl','Vpl'],
    'or_sg_pl-Vpl': ['det1sg', 'np1sg', 'or', 'det2pl', 'np2pl','Vpl'],
    'or_pl_sg-Vpl': ['det1pl', 'np1pl', 'or', 'det2sg', 'np2sg', 'Vpl'],
    'or_sg_sg-Vpl': ['det1sg', 'np1sg', 'or', 'det2sg', 'np2sg','Vpl'],
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

