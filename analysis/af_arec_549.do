/*************************************************************************************************************************************************
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
	
	
* **********************************************************************
* LSMS data
* **********************************************************************	
	
	* pull in data
		use					"$lsms/wave_02/SEC1.dta", clear
	
	* clean variables names
		rename 				HHID hhid
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
		
		drop 				BSEQNO t0_ubos_pid Round1_hh_roster_id ///
							pid_ubos s1q*
	* generate count variables
		* number members in household
		preserve
			gen 				hh_size = 1
			collapse 			(sum) hh_size, by(hhid)
			tempfile 			temp_hhsize
			save 				`temp_hhsize'
		restore
		
		merge 					m:1 hhid using `temp_hhsize', assert(3) nogen
		* number children in household
		preserve
			gen 				hh_child = 1 if age < 19
			collapse 			(sum) hh_child, by(hhid)
			tempfile 			temp_hhchild
			save 				`temp_hhchild'
		restore
		
		merge 					m:1 hhid using `temp_hhchild', assert(3) nogen
		