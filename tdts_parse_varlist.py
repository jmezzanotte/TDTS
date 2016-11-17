'''
    Written-by         : John Mezzanotte
    Date-last-modified : 11-17-2016
    Description        :

    Simple script to parse out a varlist from Stata. I want to
    add these vars to a csv file, but the list is represented as a single
    string. I cannot just copy and paste over to excel without having
    to manually separate each var name, which can get very tedious.

    This is an operation I might have to several times so I'm just
    going to write a script to handle this for me. 

'''

import os
import csv

def varlist_string_to_csv(infile, outfile):
    
    source_data_obj = open(infile, 'r')
    source_data = source_data_obj.read()

    data_list = source_data.split()
     
    with open(outfile, 'w', newline='') as out:
        writer = csv.writer(out)
        for i in data_list:
            writer.writerow([i])
        out.close()
    
    
    source_data_obj.close()


if __name__ == "__main__" :

    ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
    WORKING_DIR = os.path.join(ROOT_DIR, 'working')

    source_file = 'tdts_vars.txt'
    results_file = 'tdts_vars.csv'

    varlist_string_to_csv(os.path.join(WORKING_DIR, source_file), os.path.join(WORKING_DIR, results_file))



