import os
import sys

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

