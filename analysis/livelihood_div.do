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

		
* run panel cleaning (may take a while)
	//run 				"$code/analysis/pnl_cleaning"
	use 				"$export/lsms_panel", clear
	
* open log
	cap log 			close
	log using			"$logout/ld", append

	
* **********************************************************************
* 1 - generate, format, and clean variables
* **********************************************************************	
	
* other income 
	replace 			oth_inc = 1 if ngo_inc == 1 | unemp_inc == 1 ///
							| asst_inc == 1

					
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

	* generate index for each country
			egen 				inc_count = rowtotal(bus_inc farm_inc gov_inc ///
									isp_inc pen_inc remit_inc wage_inc oth_inc)
			replace 			inc_count = . if bus_inc >= . & farm_inc >= . & ///
									gov_inc >= . & isp_inc >= . & pen_inc >= . & ///
									remit_inc >= . & wage_inc >= . & oth_inc >= .
			gen 				uni_index = inc_count/8
			keep 				country wave hhid uni_index
			tempfile 			country`c'
			save 				`country`c''
		restore		
	} 

	* merge indices into panel
	preserve 
		clear
		forval 				c = 1/5 {
			append 			using `country`c''
		}
		tempfile 			temp_index
		save 				`temp_index'
	restore
	
	merge 					1:1 country wave hhid using `temp_index', nogen
	
	
* **********************************************************************
* 3 - country indices 
* **********************************************************************	

** ETHIOPIA **
	* same as uniform index
	gen 				eth_index = uni_index if country == 1
	
** MALAWI **
	* can add wave 5
	* wage income for respondent 
	gen					wage_inc_sec = 1 if country == 2 & wave == 5 & ///
							(emp_stat == 4 | emp_stat == 5)
	replace 			wage_inc_sec = 0 if country == 2 & wave == 5 & ///
							emp_stat < 4
	
	* add in individual employment data to wage income
	replace 			wage_inc_sec = 1 if wage_inc_ind == 1
	replace 			wage_inc_sec = 0 if wage_inc_sec == . & ///
							wage_inc_ind == 0
	
	* could add farm and bus here too if needed 
	
* **********************************************************************
* 4 - uniform indices with secondary variables
* **********************************************************************






* **********************************************************************
* 5 - 
* **********************************************************************


	
* generate summary statistics and graphs
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
	













