* summary statistic - 8 April 2018 * 


/* RANDOM GROUPS BY CENSUS DIVISION */

ssc install randtreat, replace
eststo clear



keep if wave==12
keep if rcendiv != 11



forvalues i=1/9{
	randtreat if rcendiv==`i', generate(treatment_`i') ///
	replace strata(hitot rwshlt) setseed(1110101)  misfits(strata)
	
	qui estpost summarize $dem $fin $insu $hea if treatment_`i' == 1
	
	est store M_T`i'
	
	matrix define CT_`i' = e(mean)
	scalar hitot_m_t_`i' = CT_`i'[1,8]
	
	
	qui estpost summarize $dem $fin $insu $hea if treatment_`i' == 0   
	
	est store M_C`i'
	
	matrix define CC_`i' = e(mean)
	scalar hitot_m_c_`i' = CC_`i'[1,8]
}




esttab M_T* M_C*  using BalanceGroups.tex, replace ///
cells(mean (fmt(2)) sd(par fmt(2))) label booktabs nonum ///
title("Table 3: Sample characteristics, HRS Rand, 2014 ") /// 
mtitle("Group 1" "Group 2" "Group 1" "Group 2" "Group 1" "Group 2" "Group 1" ///
"Group 2" "Group 1" "Group 2" "Group 1" "Group 2" "Group 1" "Group 2" ///
"Group 1" "Group 2" "Group 1" "Group 2") ///
mgroups("New England " "Mid Atlantic" "En Central" "Wn Central" ///
"S Atlantic"  "Es Central" "Ws Central" "Mountain" "Pacific", ///
pattern(1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0) ) ///
refcat(ragender "\emph{Demographics}" hitot "\emph{Financials}" ///
rassrecv "\emph{Insurance}"  rwshlt "\emph{Health}", nolabel) ///
collabels(none) gaps noobs ///
addnotes("Notes: summary of mean value, standard deviation in parenthesis below estimates.") 


/* JOINT TEST OF ORTHOGONALITY */

local index = 0

forvalues i=1/9{
	preserve
	keep if rcendiv==`i'
	qui reg treatment_`i' $dem $fin $insu $hea 
	
	if `index' != 0{
		scalar f = e(F)
		scalar df1 =  e(df_m)
		scalar df2 =  e(df_r)
		scalar p_F = Ftail(df1,df2,f)
		matrix F = (F \ f \ p_F)
}
	else{
		scalar f = e(F)
		scalar df1 =  e(df_m)
		scalar df2 =  e(df_r)
		scalar p_F = Ftail(df1,df2,f)
		matrix F = (f \ p_F)
		local index = `index' + 1
}
restore
}	


matrix list F

quietly frmttable using JoinTest, statmat(F) ///
noblankrows title("Joint test of orthogonality when testing for balance") /// 
tex replace rtitles( ///
"New England ", "F stat" \ "", "Prob $>$ F "\ ///
"Mid Atlantic", "F stat" \ "", "Prob $>$ F"\ ///
"En Central ", "F stat" \ "", "Prob $>$ F"\ ///
"Wn Central ", "F stat" \ "", "Prob $>$ F"\ ///
"S Atlantic ", "F stat" \ "", "Prob $>$ F"\ ///
"Es Central ", "F stat" \ "", "Prob $>$ F"\ ///
"Ws Central ", "F stat" \ "", "Prob $>$ F"\ ///
"Mountain ", "F stat" \ "", "Prob $>$ F"\ ///
"Pacific ", "F stat" \ "", "Prob $>$ F")



/* MEAN DIFFERENCES */

gen hitot_md =. 

forvalues i=1/9{
	replace hitot_md =  hitot_m_t_`i' - hitot_m_c_`i' if rcendiv==`i'
}

graph twoway (scatter hitot_md rcendiv), ///
yscale(range(0 69877)) title("Mean difference_Total Household Income") ///
ytitle("Total Household Income") xtitle("Census Division")
