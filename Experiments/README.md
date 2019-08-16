

This folder contains three experiments in the paper.

In each experiment, there are three files: input.py, expand_items.py, experimental file, as well as a result folder.

*input.py* takes two arguments: experimental filename and output filename, for example 

```
input.py test_simple_coord.xlsx items.txt
```
Experimental file must be in format **xlsx** which contains all the experimental regions. The output is combined sentences which the model will test.

*expand_items.py* take two arguments: experimental filename and output filename, for example 
```
expand_items.py test_simple_coord.xlsx items.txt
```
The output file contains a word in each row, as well as conditions, regions, item number in order to combine with the output results of model.

In result folder, the files are as following:
- item.txt is the output file of expand.py
- results of neutral network models. 
- R script for data analysis
