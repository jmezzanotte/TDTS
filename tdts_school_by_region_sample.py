'''
	Author			: John Mezzanotte
	Project 		: Thinking, Doing, Talking Science 
	Date Last Modified 	: 9/20/2016
	Description		: 
'''

import pandas as pd


# setup some helper functions
def standardize_sources(data, col_labels):
    return pd.read_excel(open(root_dir + data, 'rb')).rename(columns=col_labels)



root_dir = r'\dirname\'
output_dir = r'\dirname\'

# Setup source files and label renaming dicts

col_labels_v1 = {
                    'School serial no.' : 'sch_num',
                    'School name' : 'sch_name',
                    'School region' : 'sch_region',
                    '%FSM' : 'fsm_pct',
                    'No. Year 5 teachers' : 'num_yr5_tchrs'
                }

col_labels_v2= {
                    'Serial' : 'sch_num',
                    'School' : 'sch_name',
                    'Trainerarea' : 'sch_region',
                    'FSM' : 'fsm_pct',
                    'NoY5Teachers' : 'num_yr5_tchrs'
                }


sources = {
            'data1.xlsx' : {'labels' : col_labels_v1, 'data' : None}, 
            'data2.xlsx' : {'labels' : col_labels_v2, 'data' : None}, 
            'data3.xlsx' : {'labels' : col_labels_v2, 'data' : None}
         }

            
# After this loop we have all the new standardized data sets in the dictionary under 'data'. You
# can work with them by referencing the sources dictionary, or you can set new variables from the
# dictionary as a short hand.
for i in sources:
    sources[i]['data'] = standardize_sources(i, sources[i]['labels'])

    
# append all datasets from the dictionary together
master = \
       sources['data1.xlsx']['data'].append(sources['data2.xlsx']['data']).append(sources['data3.xlsx']['data'])  

master.to_csv(output_dir + 'out.csv', sep=',',  encoding='utf-8')


                                                                                                                                      
