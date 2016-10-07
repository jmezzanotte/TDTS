/*
	
	Written-by 			: John Mezzanotte
	Project 			: Thinking, Doing, Talking Science
	Data Last Modified	: 9/21/2016
	Desciption 			: Processes datapulls from Survey Gizmo and outputs
						  response rates by region and school 
						 
*/


version 13 
clear 
clear matrix 
set more off
macro drop _all
capture log close
ssc install renames

global ROOT "<root dir goes here>"

//global SOURCE "Survey export source data goes here"

global SVY_DATE = substr("$SOURCE", 1, 10)
global OUTPUT "$SOURCE-rr.xlsx" 
global TEACHER_COUNTS "tdts_sch_region_tchr_list.csv"

#delimit ;

	global REGIONS 
		"district_1"
		"district_2" 
		"district_3" 
		"district_4"
		"district_5"
		"district_6"
		"district_7";
	
#delimit cr

cd "$ROOT"

* This file is pre-processed to include school serial numbers(hand mapped)

import delimited using "<directory goes here>\\$SOURCE.csv", ///
	varnames(1)

// CLEANUP 
	#delimit ; 
	
	
		keep 
			schnum
			status 
			country
			city
			stateregion
			pleaselistthefullnameofyourschoo 
			inwhatregionisyourschoollocated;

	

		renames 
			schnum
			pleaselistthefullnameofyourschoo 
			inwhatregionisyourschoollocated 
			\
			sch_num
			sch_name 
			sch_region; 
			
	#delimit cr
	
	
	* Find those that have missing sch_name and sch_region 
	drop if sch_name == "" 
	
	sort sch_num 
	save "<directory goes here>\\$SOURCE.dta", replace
	
// MERGE IN TEACHER NUMBER INFORMATION
	
	clear
	
	import delimited using "<directory goes here>\\$TEACHER_COUNTS", ///
		varnames(1)
		
// CLEANUP 
		
	drop v1 fsm_pct
	sort sch_num
	
	foreach i in sch_name sch_region {
		rename `i' `i'_demog
	}
	
	merge sch_num using "<directory goes here>\\$SOURCE.dta"
	
	drop  stateregion city country sch_region
	rename sch_region_demog sch_region

	
	replace sch_region = lower(sch_region)
	
	
	* Only want to keep the treatment schools; treatment =  2016-17 
	keep if group == "2016-2017 SY"
	
	* calculate response rates by school
	levelsof sch_num, local(schs)
	gen rr_sch = .
	
	foreach i in `schs'{
		quietly tab sch_num if sch_num == `i' & status == "Complete" | ///
			sch_num == `i' & status == "Partial"
		local numerator = r(N)
		
		* Generate denominator
		levelsof num_yr5_tchrs if sch_num == `i', local(denominator)
		
		replace rr_sch = `numerator' / `denominator' if sch_num == `i'
		
	}

	* Calculate response rates  by region 
	
	gen rr_region = .
	foreach i in "$REGIONS" {
	
		levelsof num_yr5_tchrs if sch_region == "`i'", local (tchrs)
		
		local tchr_denom = 0
		
		preserve
		
			* Only want to take unique schools here for the denom 
			keep sch_num num_yr5_tchrs sch_region
			duplicates drop
			
			foreach j in `tchrs' {
			
				tab num_yr5_tchrs if num_yr5_tchrs == `j' & sch_region == "`i'"
				local tchr_denom = `tchr_denom' + (`j' * r(N))
			}
		
		restore
		
		local tchr_num = 0
		foreach k in `schs' {
			di "HERE IS THE SCHOOL `k' HERE IS THE REGION : `i'"
			quietly tab sch_num if sch_num == `k' & sch_region == "`i'" & ///
				status != ""
			local tchr_num = `tchr_num' + r(N)
		}
		
		di "`i' = `tchr_denom'"
		di "`i' = `tchr_num'" 
		replace rr_region = `tchr_num' / `tchr_denom' if sch_region == "`i'"
	
	}
	

// EXPORT RESPONSE RATES TO FILE 
	
	preserve
	
		keep sch_num sch_name sch_region rr_sch
		gen survey_date = "$SVY_DATE"
		sort sch_region sch_num 
		
		export excel using "<directory goes here>\\$OUTPUT", ///
			firstrow(var) sheetmodify sheet("rr_by_sch")
				
	restore
	
	
	
	preserve 
	
		keep sch_region rr_region
		duplicates drop 
		// Place the survey administration date into the output 
		gen survey_date = "$SVY_DATE"
		export excel using "<directory goes here>\\$OUTPUT", ///
			firstrow(var) sheetmodify sheet("rr_by_region")
	
	restore
	
	




