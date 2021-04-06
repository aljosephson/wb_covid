/***********************************************************************
* Builds dataset for AREC 549 term paper

* Merges the following datasets: 	
	* LSMS survey data from UGA round 2
	
* Notes: 
	
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
		rename 				s1q06 age
		rename 				s1q07 relate_hoh
		rename 				s1q09 sch_bef
		rename 				s1q10 sch_aft
		
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
							pid_ubos s1q* baseline
			
	* generate count variables
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
		
	* food insecurity
	
		
		
		
		
		
* merge household and individual data sets
		
	* crosswalk for household and individual data sets hhid	
		
		* define
			global			eth		=	"$data/ethiopia/refined" 
			global			mwi		=	"$data/malawi/refined"
			global			nga		=	"$data/nigeria/refined" 
			global			uga		=	"$data/uganda/refined"
			global			export	=	"$data/analysis"
			global			logout	=	"$data/analysis/logs"

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
			tempfile 		id_xw
			save 			`id_xw'
			
	

		
		
		
		
		
		
		
		
		
		
		
		
		
*** Summary stats & graphics ***

	* why not attending school after pandemic (NEED WEIGHTS)
		graph bar 			(mean) sch_aft_why_1 sch_aft_why_2 sch_aft_why_3 sch_aft_why_4 sch_aft_why_5 sch_aft_why_6 ///
								sch_aft_why_7 sch_aft_why_8 sch_aft_why_9 sch_aft_why_10, ///
								bar(1, color(maroon*1.5)) bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
								bar(4, color(cranberry*1.5)) ///
								ytitle("", margin( 0 -1 -1 10) size(large)) ///
								legend(	label (1 "") label (2 "") pos(6) col(3) ///
								size(medsmall) margin(-1.5 0 0 0)) 		
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									