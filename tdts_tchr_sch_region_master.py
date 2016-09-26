'''
	Author			: John Mezzanotte
	Project 		: Thinking, Doing, Talking Science 
	Date Last Modified 	: 9/20/2016
	Description		: Stacks all the files we have containing information about regions and sites, 
				  including their number of teachers. Merges in treatment and control indicators
'''

import pandas as pd

# setup some helper functions
def standardize_sources(data, col_labels):
    return pd.read_excel(open(data, 'rb')).rename(columns=col_labels)


if __name__ == "__main__" :

    # Setup directories 
    root_dir = r''
    raw_dir = root_dir + r''
    output_dir = root_dir + r''
    made_dir = root_dir + r''
 
    
    # Setup column label rename mappings

    col_labels_v1 = {
                        'School code' : 'sch_num',
                        'School name' : 'sch_name',
                        'School district' : 'sch_region',
                        '%FSM' : 'fsm_pct',
                        'No. teachers' : 'num_tchrs'
                    }

    col_labels_v2= {
                        'Serial' : 'sch_num',
                        'School' : 'sch_name',
                        'Trainerarea' : 'sch_region',
                        'FSM' : 'fsm_pct',
                        'NoTeachers' : 'num_tchrs'
                    }

    tc_labels={
            'schoolserialno' : 'sch_num',
            'schoolname' : 'sch_name',
            'schoolregion' : 'sch_region',
        }

    # Dictionary of data sources, filename as key
    sources = {
            'demographic_1.xlsx' : {'labels' : col_labels_v1, 'dir' : raw_dir , 'data' : None}, 
            'demographic_2.xlsx' : {'labels' : col_labels_v2, 'dir' : raw_dir, 'data' : None}, 
            'demographic_3.xlsx' : {'labels' : col_labels_v2, 'dir' : raw_dir, 'data' : None},
            'district_1.xlsx' : {'labels' : tc_labels, 'dir' : made_dir, 'data' : None }, 
            'district_2.xlsx' : { 'labels' : tc_labels, 'dir' : made_dir, 'data' : None },
            'district_3.xlsx' : { 'labels' : tc_labels, 'dir' : made_dir, 'data' : None },
            'distrct_4.xlsx' : { 'labels' : tc_labels, 'dir' : made_dir, 'data' : None },
            'district_5.xlsx' : { 'labels' : tc_labels, 'dir' : made_dir, 'data' : None },
            'district_6.xlsx' : { 'labels' : tc_labels, 'dir' : made_dir, 'data' : None },
            'district_7.xlsx' : { 'labels' : tc_labels, 'dir' : made_dir, 'data' : None }
        }

    # used for merge later
    tc_data = [
            'district_1.xlsx', 
            'district_2.xlsx' ,
            'district_3.xlsx' ,
            'district_4.xlsx' ,
            'district_5.xlsx' ,
            'district_6.xlsx' ,
            'district_7.xlsx'
        ]
        

    # Process all source datasets
    # New data frames will be stored under key 'data'. 
    for i in sources:
        target = sources[i]
        target['data'] = standardize_sources(
            target['dir'] + i,
            target['labels']
        )

    # append all datasets from the dictionary together
    master = \
           sources['demographic_1.xlsx']['data'].append(
               sources['demographic_2.xlsx']['data']
               ).append(
                   sources['demographic_3.xlsx']['data']
                   )

    # Merge in Treatment and Control data to master file

    col_drops = ['sch_name', 'sch_region', 'alloc_date']

    temp = []
    for i in tc_data:

        target = sources[i]['data']
        # drop unecessary columns
        for j in col_drops :
            target.drop(j , axis=1, inplace=True)

        # Merge data onto master data frame
        temp.append (pd.merge(master, target, on='sch_num'))
        
    
    master = temp[0]    
    for i in range(1, len(temp)) :
        master = master.append(temp[i])
    

    
    # produce a log file
    log = master.describe()
    log.to_csv(output_dir + 'log.csv', sep=',', encoding='utf-8')
    
    
    master = master.sort_values(['sch_region','sch_name'], ascending=[True, True])
    master.to_csv(output_dir + 'output.csv', sep=',',  encoding='utf-8')


                                                                                                                                          
