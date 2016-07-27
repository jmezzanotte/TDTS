/*
		Written by : John Mezzanotte
		Date-last-modified : 7-20-2016
		Project : Thinking Doing Talking Science - Trainer Survey Analysis 
		Description : This program will run an analysis of the trainer 
					  survey output from google forms. This program will 
					  run on all TDTS trainer survey output from google forms.
					  You may have to manually enter the variable names to 
					  be renamed. This is done in the renames command.

*/

clear 
clear matrix
macro drop _all 
capture log close
set more off 
ssc install renames 

global ROOT "<project file path>"
cd "$ROOT"
log using "$ROOT\log\trainer_survey_analysis_`c(current_date)'", text replace

// Program Settings 
	global SOURCE "<source file name>.csv"
	global OUTPUT "tdts_demo_output.xlsx"
	global CONTENT_VARS trainingPreparedMe effectiveMaterials ///
		increasedKnowledge teachingOthers changedApproach
	global QUALITY_VARS materialsQuality trainingPace presenterProficiency ///
		overallTraining interactionsWithPresenter interactionsWithParticipants
	global CONTENT_COLNAMES Strongly_Agree Agree Somewhat_Agree Disagree ///
		Completely_Disagree
	global CONTENT_VALS ""Strongly agree" "Agree" "Somewhat agree" "Disagree" "Completely disagree""
	global QUALITY_COLNAMES Very_Good Good Average Poor Very_Poor
	global QUALITY_VALS ""Very good" "Good" "Average" "Poor" "Very poor""
	
	// create matrices to hold aggregate output
	local COLCOUNT : word count $CONTENT_COLNAMES
	local ROWCOUNT : word count $CONTENT_VARS
	matrix content = J(`ROWCOUNT', `COLCOUNT', .)
	matrix colnames content = $CONTENT_COLNAMES
	matrix rownames content = $CONTENT_VARS
	
	local COLCOUNT : word count $QUALITY_COLNAMES 
	local ROWCOUNT : word count $QUALITY_VARS
	matrix quality = J(`ROWCOUNT', `COLCOUNT', .)
	matrix colnames quality = $QUALITY_COLNAMES 
	matrix rownames quality = $QUALITY_VARS

// Pull in source data 
	import delimited using "raw\\$SOURCE", varnames(1)

// All variables use camel case first case lower
	renames ///
		timestamp firstname lastname currentposition ///
		ratetheleveltowhichyouagreewitht v6 v7 v8 v9 /// 
		pleaseratethefollowingaspectsoft v11 v12 v13 v14 v15 ///
		\ ///
		timeStamp firstName lastName currentPosition trainingPreparedMe ///
		effectiveMaterials increasedKnowledge teachingOthers changedApproach ///
		materialsQuality trainingPace presenterProficiency overallTraining ///
		interactionsWithPresenter interactionsWithParticipants

// Extract the date portion out of the time stamp -- creat new var called date
	gen svyDate = ""
	replace svyDate = regexs(0) if ///
		(regexm(timeStamp, "^[0-9]+[/][0-9]+[/-][0-9]+"))
	 	
// Generate a count variable, this will allow you to collapse the data 
// for output 
	gen counter = _n 
		quietly desc 
		local TOTAL_OBS = r(N) 
		quietly sum counter 
		assert `TOTAL_OBS' == r(max)
		
// Responses by date 
	preserve 
		gen pct = counter 
		collapse (count) counter (percent) pct, by(svyDate)
		rename counter freq
		export excel using "made\\$OUTPUT", firstrow(variables) sheetmodify ///
			sheet("Responses by Date")
	restore 
	
// Content
	foreach i in $CONTENT_VARS {
		preserve 
			gen pct = counter
			collapse (count) counter (percent) pct, by(`i')
			export excel using "made\\$OUTPUT", firstrow(variables) sheetmodify ///
				sheet("`i'")
		restore
	}

// Create master content matrix 
	local COUNT : word count $CONTENT_VARS
	local COLCOUNT : word count $CONTENT_COLNAMES
	local COUNT : word count $CONTENT_VARS 
	local COLCOUNT : word count $CONTENT_COLNAMES
	forvalues i = 1 / `COUNT'{
		local ACTIVE : word `i' of $CONTENT_VARS 
		forvalues j = 1 / `COLCOUNT' {
			local ACTIVE_COL : word `j' of $CONTENT_VALS 
			tab `ACTIVE' if `ACTIVE' == "`ACTIVE_COL'"
			// place number in matrix 
			matrix content[`i', `j'] = r(N)			
		}
	}
	
	
	
// Quality 
	foreach i in $QUALITY_VARS {
		preserve 
			gen pct = counter 
			collapse (count) counter (percent) pct, by(`i')
			export excel using "made\\$OUTPUT", firstrow(variables) sheetmodify ///
				sheet("`i'")
		restore
	}

// Create master quality matrix 
	local COUNT : word count $QUALITY_VARS 
	local COLCOUNT : word count $QUALITY_COLNAMES
	forvalues i = 1 / `COUNT'{
		local ACTIVE : word `i' of $QUALITY_VARS 
		forvalues j = 1 / `COLCOUNT' {
			local ACTIVE_COL : word `j' of $QUALITY_VALS 
			tab `ACTIVE' if `ACTIVE' == "`ACTIVE_COL'"
			// place number in matrix 
			matrix quality[`i', `j'] = r(N)			
		}
	}
	

// Write master matrices to file 
	global MASTER_MAT ""$CONTENT_VARS" "$QUALITY_VARS""
	global MATRICES content quality
	local MASTER_COUNT : word count $MATRICES
	
	preserve 
		forvalues i = 1 / `MASTER_COUNT'{
			clear 
			local MATRIX : word `i' of $MATRICES
			svmat `MATRIX', names(col)
			gen var_name = ""
			local ACTIVE_MAT_VARS : word `i' of $MASTER_MAT
			local COUNT : word count `ACTIVE_MAT_VARS'
			di `COUNT'
			forval j = 1 / `COUNT'{
				local ACTIVE : word `j' of `ACTIVE_MAT_VARS'
				replace var_name = "`ACTIVE'" if _n == `j'
			}
		
		order var_name 
		export excel using "made\\$OUTPUT", firstrow(variables) sheetmodify ///
			sheet("`MATRIX'")
		}
	restore
	
log close	

