* Project: WB COVID
* Created on: June 2021
* Created by: amf
* Stata v.16.1

* does
	* generates income indices 

* assumes
	* cleaned panel data

* TO DO:
	* 
	
	
* **********************************************************************
* 0 - setup
* **********************************************************************

* Define root folder globals
    if `"`c(username)'"' == "jdmichler" {
        global 		code  	"C:/Users/jdmichler/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
    }

    if `"`c(username)'"' == "aljosephson" {
        global 		code  	"C:/Users/aljosephson/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
    }

	if `"`c(username)'"' == "annfu" {
		global 		code  	"C:/Users/annfu/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
	}	
		
* define
	global	export	=	"$data/analysis"
	global	logout	=	"$data/analysis/logs"
	
* open log
	cap log 			close
	log using			"$logout/ld", append
		
* run panel cleaning (may take a while)
	//run 				"$code/analysis/pnl_cleaning"
	use 				"$export/lsms_panel", clear

	
* **********************************************************************
* 1 - generate, format, and clean variables
* **********************************************************************	
	
* generate other income 2 (NGO, unemployment, non-family assistance)
	gen  				oth_inc2 = 0 if oth_inc == 0 | ngo_inc == 0 ///
							| unemp_inc == 0 | asst_inc == 0
	replace  			oth_inc2 = 1 if oth_inc == 1 | ngo_inc == 1 ///
							| unemp_inc == 1 | asst_inc == 1
							
* generate other income 3 (NGO, unemployment, non-family assistance, gov_inc)
	gen  				oth_inc3 = 0 if oth_inc == 0 | ngo_inc == 0 ///
							| unemp_inc == 0 | asst_inc == 0 | gov_inc == 0
	replace  			oth_inc3 = 1 if oth_inc == 1 | ngo_inc == 1 ///
							| unemp_inc == 1 | asst_inc == 1 | gov_inc == 1
							
* generate government, ngo, unemployment
	gen					gov_ngo_inc = 0 if ngo_inc == 0 | unemp_inc == 0 ///
							| gov_inc == 0
	replace				gov_ngo_inc = 1 if ngo_inc == 1 | unemp_inc == 1 ///
							| gov_inc == 1
		
		
* **********************************************************************
* 2 - uniform indices without secondary variables (excluding BF)
* **********************************************************************

* keep waves with data 
	forval 					c = 1/5 {
		preserve
			keep 			if country == `c'
			gen 			havedata = bus_inc + farm_inc + gov_inc + ///
								isp_inc + pen_inc + remit_inc + wage_inc 
			collapse 		(sum) havedata, by(country wave)
			drop 			if havedata == 0
			replace 		havedata = 1
			tempfile 		temp`c'
			save 			`temp`c''
		restore
	
		preserve 
			merge 				m:1 country wave using `temp`c'' 
			keep 				if havedata == 1

	* generate index for each country (fraction out of 8 income sources)
			egen 				inc_count = rowtotal(bus_inc farm_inc gov_inc ///
									isp_inc pen_inc remit_inc wage_inc oth_inc2)
			/*
			replace 			inc_count = . if bus_inc >= . & farm_inc >= . & ///
									gov_inc >= . & isp_inc >= . & pen_inc >= . & ///
									remit_inc >= . & wage_inc >= . & oth_inc2 >= .
			*/
			gen 				uni_index = inc_count/8
			keep 				country wave hhid uni_index
			tempfile 			country`c'
			save 				`country`c''
		restore		
	} 

	* merge uniform index into panel
	preserve 
		clear
		forval 				c = 1/5 {
			append 			using `country`c''
		}
		tempfile 			temp_index
		save 				`temp_index'
	restore
	
	merge 					1:1 country wave hhid using `temp_index', nogen

	
	
pause on 
/*
tab uni_index country, missing 	
pause 


WHY SO MANY MISSING VALUES IN NGA AND MWI? CONDITIONING QUESTION? MISSING SHOULD BE 0? THEN WHY UGANDA DIF?
	- uganda and ethiopia ask all households, nga and mwi do not
		to see this, use nga round 1, and get unique hhid from sec 7 vs total
	- Ask Talip?

*/ 
	
* **********************************************************************
* 3 - uniform indices with secondary variables when possible to 
* 		increase number of waves in each country (same 8 as denominator)	
* **********************************************************************
	
** ETHIOPIA **
	* same as uniform index
	gen 				sec_index = uni_index if country == 1
	
** MALAWI ** 
	* add wave 5 - only other wave with wage inc available
	* secondary wage and bus vars (combine emp_stat and ind income data)
		* don't do this for farm because inconsistent with other rounds
			* could be due to seasonal work & dif in question timing 
	* wage
		* wage income for respondent 
			gen					wage_inc_sec = 1 if country == 2 & wave == 5 & ///
									(emp_stat == 4 | emp_stat == 5)
			replace 			wage_inc_sec = 0 if country == 2 & wave == 5 & ///
									emp_stat < 4
			* add in individual employment data to wage income
			replace 			wage_inc_sec = 1 if wage_inc_ind == 1
			replace 			wage_inc_sec = 0 if wage_inc_sec == . & ///
									wage_inc_ind == 0
		* bus income for respondent 
			gen					bus_inc_sec = 1 if country == 2 & wave == 5 & ///
									emp_stat < 3 
			replace 			bus_inc_sec = 0 if country == 2 & wave == 5 & ///
									emp_stat >= 3 & emp_stat < .
			* add in individual employment data to bus income
			replace 			bus_inc_sec = 1 if bus_inc_ind == 1
			replace 			bus_inc_sec = 0 if bus_inc_sec == . & ///
									bus_inc_ind == 0
	/*
		tab wage_inc_sec wave
		tab wage_inc_ind wave
		pause
		THESE END UP BEING EXACTLY THE SAME AS JUST THE IND DATA, WHY?? (same below in NGA)
		
		tab farm_inc_ind 
		tab farm_inc
		pause
		Why is farm inc from individual data so different from farm inc?
		Still okay to use others that are similar or should we not use this sub at all?
		
		Should we include if they will return to job? okay that this is not asked to respondent?
	*/
	
	* secondary farm var
		gen 					farm_inc_sec = ag_crop if country == 2 & wave == 5
		
	* secondary gov var 
		* generated in mwi_build_5
	
	* secondary isp var
		gen 					isp_inc_sec = oth_inc_4 if country == 2 & wave == 5
		replace 				isp_inc_sec = 0 if isp_inc_sec == 2
	
	* secondary pension var
		gen 					pen_inc_sec = oth_inc_5 if country == 2 & wave == 5
		replace 				pen_inc_sec = 0 if pen_inc_sec == 2	
	
	* secondary remittance var
		gen 					remit_inc_sec = oth_inc_2 if country == 2 & wave == 5
		replace 				remit_inc_sec = 1 if oth_inc_1 == 1 & country == 2 & ///
									wave == 5
		replace 				remit_inc_sec = 0 if remit_inc_sec == . & oth_inc_1 == 0 ///
									& country == 2 & wave == 5
		replace 				remit_inc_sec = 0 if remit_inc_sec == 2	
	* secondary other var
		* variables generated in mwi_build_5
		replace 				oth_inc_sec = 1 if oth_inc_3 == 1 & country == 2 ///
									& wave == 5

** NIGERIA ** 		
	* add waves  5 (& 10??)
	* secondary wage and bus vars	
		* wage income for respondent
			replace				wage_inc_sec = 1 if country == 3 & wave == 5 & ///
									(emp_stat == 4 | emp_stat == 5 | emp_stat == 6)
			replace 			wage_inc_sec = 0 if country == 3 & wave == 5 & ///
									emp_stat < 4
			* add in individual employment data to wage income
			replace 			wage_inc_sec = 1 if wage_inc_ind == 1
			replace 			wage_inc_sec = 0 if wage_inc_sec == . & ///
									wage_inc_ind == 0
		* bus income for respondent 
			replace				bus_inc_sec = 1 if country == 3 & wave == 5 & ///
									emp_stat < 3 
			replace 			bus_inc_sec = 0 if country == 3 & wave == 5 & ///
									emp_stat >= 3 & emp_stat < .
			* add in individual employment data to bus income
			replace 			bus_inc_sec = 1 if bus_inc_ind == 1
			replace 			bus_inc_sec = 0 if bus_inc_sec == . & ///
									bus_inc_ind == 0
			
		* farm income for respondent 
			replace 			farm_inc_sec = ag_crop if country == 3 & wave == 5
			
			
			/*
			replace				farm_inc_sec = 1 if farm_inc_sec == . & country == 3 ///
									& wave == 5 & emp_stat == 3 
			replace 			farm_inc_sec = 0 if farm_inc_sec == . & country == 3 ///
									& wave == 5 & emp_stat != 3 & emp_stat != .
			* add in individual employment data to bus income
			replace 			farm_inc_sec = 1 if farm_inc_sec == . & farm_inc_ind == 1 ///
									& country == 3 
			replace 			farm_inc_sec = 0 if farm_inc_sec == . & country == 3 &  ///
									farm_inc_ind == 0
									
			*/						
	* secondary bus var
	asdfsd	

* combine primary and secondary vars
		foreach 				i in wage bus farm gov isp pen remit oth {
			replace 				`i'_inc_sec = `i'_inc if `i'_inc_sec == .
		}	
		
		
* **********************************************************************
* 4 - country indices (allow for dif denominator)
* **********************************************************************




* **********************************************************************
* 5 - 
* **********************************************************************


	
* generate summary statistics and graphs
	* uniform index
	forval 					c = 1/5 {
		sum 					uni if country == `c', detail
	}
	hist 					uni, normal xtitle("Income Index") width(.125) ///
								subtitle("Pooled") color(teal*1.5) graphr(color(grey*.1))
	graph export 			"$export/figures/LD/density/uni_index_all.png", ///
								as(png) replace						
									
	forval 					c = 1/4 {
		preserve 
			keep 				if country == `c'
			hist 				uni, normal xtitle("Income Index") width(.125) ///
									subtitle("Country `c'") color(teal*1.5)
			graph export 		"$export/figures/LD/density/uni_index_`c'.png", ///
									as(png) replace
		restore 
	}
	
	* secondary index
	
	* country indices













