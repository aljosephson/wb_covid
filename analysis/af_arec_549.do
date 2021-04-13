/***********************************************************************
* Builds dataset for AREC 549 term paper

* Merges the following datasets: 	
	* LSMS survey data from UGA round 2
	
* Notes: 
	
* TO DO: 
	* pull data from update_new_data and rerun 
*/
	
	
* **********************************************************************
* Setup
* **********************************************************************	
	* define filepaths
		global				lsms	=	"$data/uganda/raw"
		global				ans		=	"$data/analysis"
	
* **********************************************************************
* LSMS data
* **********************************************************************	


*** Individual level data ***	

	* pull in data - uganda wave 2 section 1
		use					"$lsms/wave_02/SEC1.dta", clear
	
	* clean variables names
		rename 				HHID hhid_uga1
		rename 				s1q02a hh_mem_stat
		rename 				s1q05 sex
		lab def 			sex 1 "Male" 2 "Female"
		lab val 			sex sex 
		rename 				s1q06 age
		rename 				s1q07 relate_hoh
		rename 				s1q09 sch_bef
		rename 				s1q10 sch_aft
		replace 			sch_aft = 0 if sch_bef == 2 
		/* only ask sch_aft if sch_bef is yes, assume here that children
		not in school after outbreak if not in school before outbreak */
		
		forval 				x = 1/10 {
		    rename 			s1q11__`x' sch_aft_why_`x'
		}
		forval 				x = 1/11 {
			rename 			s1q12__`x' edu_act_`x'
		}
		forval 				x = 1/13 {
			rename 			s1q13__`x' edu_chall_`x'
		}
		
		lab def 			yesno 0 "No" 1 "Yes"
		foreach 			var of varlist edu_* sch_*  {
			replace 		`var' = 0 if `var' == 2
			lab val 		`var' yesno
		}
		drop 				BSEQNO t0_ubos_pid Round1_hh_roster_id ///
							pid_ubos s1q* baseline hh_mem_stat
			
	* generate variables
		* number members in household
		preserve
			gen 			hh_size = 1
			collapse 		(sum) hh_size, by(hhid)
			tempfile 		temp_hhsize
			save 			`temp_hhsize'
		restore
		
		merge 				m:1 hhid using `temp_hhsize', assert(3) nogen
		
		* number children in household
		preserve
			gen 			hh_child = 1 if age < 19
			collapse 		(sum) hh_child, by(hhid)
			tempfile 		temp_hhchild
			save 			`temp_hhchild'
		restore
		
		merge 				m:1 hhid using `temp_hhchild', assert(3) nogen
 		
		order 				hhid hh_roster hh_size hh_child 
		
		* school-age indicator
		gen 				sch_age = 1 if age > 5 & age < 19
		
		* hh count of school age children in household
		preserve 
			collapse 		(sum) sch_age, by(hhid)
			rename 			sch_age hhsize_sch_age
			tempfile 		hh_sch_age
			save 			`hh_sch_age'
		restore
		merge 				m:1 hhid using `hh_sch_age', assert(3) nogen
			
	* save
		tempfile 			ind_data
		save 				`ind_data'

		
*** Household level data ***
	
	* pull in panel data all countries
		use					"$ans/lsms_panel", clear
	
	* income loss - count if hh lost income in wave 1 OR 2
		preserve
			keep 			if country == 4 & wave < 3
			collapse 		(sum) dwn, by (hhid)
			gen 			lost_inc = cond(dwn > 0 , 1, 0)
			keep 			hhid lost_inc 
			tempfile 		lost_inc
			save 			`lost_inc'
		restore
	
	* HOH employment before covid & education level (from wave 1) 
		preserve
			keep 			if country == 4 & wave == 1
			replace 		emp_pre = 1 if emp == 1 // assume employed bef covid if currently employed
			keep 			if relate_hoh == 1 // assume HOH is primary income earner (drop if other respondant below)
			keep 			hhid emp_pre edu
			rename 			emp_pre emp_pre_hoh
			rename 			edu edu_hoh
			tempfile 		hoh_data
			save 			`hoh_data'
		restore	
	
	* subset panel data	
		keep 				if country == 4 & wave == 2
		keep 				if relate_hoh == 1
		keep 				hhid region zone p_mod sexhh sector emp credit_cvd
		rename 				sexhh sex_hoh

	* combine subset with generated variable
		merge 1:1 			hhid using `lost_inc'
		drop 				if _m == 2
		drop 				_m

	* save
		tempfile 			hh_data
		save 				`hh_data'
		
		
*** merge household and individual data sets ***
		
	* crosswalk for household and individual data sets hhid	
		
		* define
			global			eth		=	"$data/ethiopia/refined" 
			global			mwi		=	"$data/malawi/refined"
			global			nga		=	"$data/nigeria/refined" 
			global			uga		=	"$data/uganda/refined"
			
		* read in data
			use				"$eth/eth_panel", clear	
			append 			using "$mwi/mwi_panel"	
			append 			using "$nga/nga_panel"
			append 			using "$uga/uga_panel"

		* generate household id
			replace 		hhid_eth = "e" + hhid_eth if hhid_eth != ""
			replace 		hhid_mwi = "m" + hhid_mwi if hhid_mwi != ""	
			tostring		hhid_nga, replace
			replace 		hhid_nga = "n" + hhid_nga if hhid_nga != "."
			replace			hhid_nga = "" if hhid_nga == "."	
			rename 			hhid_uga hhid_uga1
			egen 			hhid_uga = group(hhid_uga1)
			tostring 		hhid_uga, replace 	
			replace 		hhid_uga = "" if country != 4
			replace 		hhid_uga = "u" + hhid_uga if hhid_uga != ""	
			gen				HHID = hhid_eth if hhid_eth != ""
			replace			HHID = hhid_mwi if hhid_mwi != ""
			replace			HHID = hhid_nga if hhid_nga != ""
			replace			HHID = hhid_uga if hhid_uga != ""	
			sort			HHID
			egen			hhid = group(HHID)
			lab var			hhid "Unique household ID"
			order 			country hhid resp_id hhid*

		* generate crosswalk for Uganda
			keep 			if country == 4
			keep 			hhid_uga1 hhid
			duplicates 		drop
			tempfile 		xw_id
			save 			`xw_id'
			
	* merge datasets	
		use 				`ind_data', clear
		
		merge m:1 			hhid_uga1 using `xw_id'
		drop 				if _m == 2
		drop 				_m
		
		merge m:1 			hhid using `hh_data'
		keep 				if _m == 3
		drop 				_m
 	  
		merge 				m:1 hhid using `hoh_data'
		keep 				if _m == 3 // keep only if HOH is respondant
		drop 				_m
  		
	* keep only school aged children	
		keep 				if sch_age == 1
		drop 				sch_age

*** Summary stats & graphics *** (ADD WEIGHTS????)
/*
	* school engagement before and after by gender
		
		catplot 			sch_bef, over(sex, label(labsize(vlarge))) percent(sex) stack l1title("") ///
								title("In school before March 2020", size(large)) ///
								var1opts(label(labsize(large))) legend(col(2) margin(-1.5 0 0 0)) ///
								var2opts(label(nolab)) ytitle("", size(vlarge)) ///
								asyvars bar(1, color(maroon*1.5)) bar(2, color(stone*1.3)) ///
								ylabel(0 "0" 20 "20" 40 "40" 60 "60" 80 "80" 100 "100", labs(large)) ///
								name(sch_bef, replace)
		
		catplot 			sch_aft, over(sex, label(labsize(vlarge))) percent(sex) stack l1title("") ///
								title("Engaged in learning activities after March 2020", size(large)) ///
								var1opts(label(labsize(large))) legend(col(2) margin(-1.5 0 0 0)) ///
								var2opts(label(nolab)) ytitle("", size(vlarge)) ///
								asyvars bar(1, color(maroon*1.5)) bar(2, color(stone*1.3)) ///
								ylabel(0 "0" 20 "20" 40 "40" 60 "60" 80 "80" 100 "100", labs(large)) ///
								name(sch_aft, replace)
		
		grc1leg2 			sch_bef sch_aft, iscale(.5) commonscheme col(1)	

		graph export 		"G:\My Drive\AF\Sem 2 Spring\AREC 549 Econometrics\Term Paper\sch_bef_aft.png", replace
	
	* school engagement before and after by sector
		
		catplot 			sch_bef, over(sector, label(labsize(vlarge))) percent(sector) stack l1title("") ///
								title("In school before March 2020", size(large)) ///
								var1opts(label(labsize(large))) legend(col(2) margin(-1.5 0 0 0)) ///
								var2opts(label(nolab)) ytitle("", size(vlarge)) ///
								asyvars bar(1, color(maroon*1.5)) bar(2, color(stone*1.3)) ///
								ylabel(0 "0" 20 "20" 40 "40" 60 "60" 80 "80" 100 "100", labs(large)) ///
								name(sch_bef_sec, replace)
		
		catplot 			sch_aft, over(sector, label(labsize(vlarge))) percent(sector) stack l1title("") ///
								title("Engaged in learning activities after March 2020", size(large)) ///
								var1opts(label(labsize(large))) legend(col(2) margin(-1.5 0 0 0)) ///
								var2opts(label(nolab)) ytitle("", size(vlarge)) ///
								asyvars bar(1, color(maroon*1.5)) bar(2, color(stone*1.3)) ///
								ylabel(0 "0" 20 "20" 40 "40" 60 "60" 80 "80" 100 "100", labs(large)) ///
								name(sch_aft_sec, replace)
		
		grc1leg2 			sch_bef_sec sch_aft_sec, iscale(.5) commonscheme col(1)	

		graph export 		"G:\My Drive\AF\Sem 2 Spring\AREC 549 Econometrics\Term Paper\sch_bef_aft_sec.png", replace
		
	* why not attending school after pandemic
		gen 				sch_aft_why_3_4 = 1 if sch_aft_why_3 == 1 | sch_aft_why_4 == 1
		replace 			sch_aft_why_3_4 = 0 if sch_aft_why_3_4 == . & (sch_aft_why_3 == 0 | sch_aft_why_4 == 0)
		graph bar 			(mean) sch_aft_why_6 sch_aft_why_7 sch_aft_why_2 sch_aft_why_3_4, ///
								title("Why children not engaged in learning activities after the outbreak", ///
								size(vlarge)) bar(1, color(maroon*1.5)) bar(2, color(navy*1.5)) ///
								bar(3, color(stone*1.5)) bar(4, color(emerald*2)) ///
								ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
								ytitle("", margin( 0 -1 -1 10) size(large)) ///
								legend(	label (1 "Increased household chores") ///
								label (2 "Student not interested") label (3 "No access to radio/tv") ///
								label (4 "Did not receive learning materials") pos(6) col(2) ///
								size(vlarge) margin(-1.5 0 0 0)) name(sch_why,replace)		
													
		graph combine  		sch_why, iscale(.5) commonscheme 							
		
		graph export 		"G:\My Drive\AF\Sem 2 Spring\AREC 549 Econometrics\Term Paper\sch_why.png", replace
		
	* hoh education 
		replace 			edu_hoh = . if edu_hoh < 0
		catplot 			edu_hoh, l1title("") title("Head of Household Highest Level of Education", ///
								size(large)) bar(1, color(maroon*1.5)) name(edu_hoh, replace) ///
								var1opts(sort(1) descending label(labsize(large))) ///
								ytitle("Frequency", size(vlarge)) ylabel(, labs(vlarge))
		
		graph combine  		edu_hoh, iscale(.5) commonscheme 
 
		graph export 		"G:\My Drive\AF\Sem 2 Spring\AREC 549 Econometrics\Term Paper\edu_hoh.png", replace
	
	* sector
		catplot 			sector, l1title("") bar(1, color(emerald*3)) name(sector, replace) ///
								var1opts(sort(1) descending label(labsize(vlarge))) ///
								ytitle("Frequency", size(vlarge)) ylabel(, labs(vlarge))
		
		graph combine  		sector, iscale(.5) commonscheme 
	
		graph export 		"G:\My Drive\AF\Sem 2 Spring\AREC 549 Econometrics\Term Paper\sector.png", replace
		
	* means
		* individual level
		foreach 			var of varlist age sch_bef sch_aft {
			mean 				`var'
			local 				m_`var' = el(e(b),1,1)
			local 				sd_`var' = sqrt(el(e(V),1,1))
		}
		* household level
		preserve
		duplicates 			drop hhid, force
		tempfile 			temp
		save 				`temp'
		foreach 			var of varlist emp_pre_hoh emp hh_size hh_child  {
			use 				`temp', clear
			drop 				if `var' == . | `var' == .a
			mean 				`var'
			local 				m_`var' = el(e(b),1,1)
			local 				sd_`var' = sqrt(el(e(V),1,1))
		}
		restore 
		
		preserve
			clear
			set 			obs 2
			foreach 		var in age sch_bef sch_aft emp_pre_hoh emp hh_size hh_child {
				gen 			`var' = `m_`var''
				replace 		`var' = `sd_`var'' in 2
			}
		restore		
*/
	
*** generate panel ***
 
	* pre-covid
		preserve
			drop 			sch_aft* edu_act_* edu_chall* p_mod lost_inc emp 
			rename 			sch_bef sch
			rename 			emp_pre_hoh emp
			gen 			cov = 0
			tempfile 		temp_pre
			save 			`temp_pre'
		restore
		
	* post-covid
		drop 				sch_bef emp_pre_hoh
		rename 				sch_aft sch
		gen 				cov = 1
		append 				using `temp_pre'
		sort 				cov
		order 				hhid* hh_roster cov age sex relate_hoh hh* sex_hoh sector region zone
		drop 				sch_aft* edu_act_* edu_chall* p_mod lost_inc
		
	* export data to excel
		export 				excel "G:\My Drive\AF\SAS\SASUniversityEdition\myfolders\AREC_549\term_paper\data.xls", ///
								first(var) replace missing(".")		 							
									
									
	probit sch age sex hh_child sex_hoh sector if cov == 0								
									
	probit sch age sex hh_child sex_hoh sector if cov == 1								
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									