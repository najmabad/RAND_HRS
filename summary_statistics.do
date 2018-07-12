* summary statistic file - 8 April 2018 * 



ssc install estout, replace

global dem "ragender hhhresp raehsdegr raemcdegr rwmarried rablack racath"
global fin "hitot hahous haira hampr rwlbrf"
global insu "rassrecv rgovmd rhiltc"
global hea "rwshlt rsmokev"




/* TABLE OF SUMMARY STATISTICS */
eststo clear

qui estpost su $dem $fin $insu $hea
est store A

forvalues i=1/5{
	preserve
	keep if riqnt==`i'
	qui estpost su $dem $fin $insu $hea
	
	est store M_`i'
	restore
}

esttab A M_* using SummaryStatistics.tex, replace ///
refcat(ragender "\emph{Demographics}" hitot "\emph{Financials}" ///
rassrecv "\emph{Insurance}"  rwshlt "\emph{Health}", nolabel) ///
title("Table 1: Sample characteristics, HRS Rand, 1992 - 2014") /// 
mtitle("Full Sample" "Q1" "Q2" "Q3" "Q4" "Q5") ///
cells(mean (fmt(2)) sd(par fmt(2))) label booktabs nonum collabels(none) ///
gaps noobs ///
addnotes("Notes: summary of mean value, standard deviation in parenthesis below estimates.") ///
stats(N, fmt(0)  labels("Observations") )


/* GRAPH GOOD HEALTH - MEDICAID */

preserve
keep if riqnt == 1 | riqnt == 5
graph bar (sum) rwshlt rgovmd [pweight=rwtresp], over(riqnt) percentage ///
legend(label(1 "In good health") label(2 "Receives Medicaid")) ///
blabel(bar , format(%9.2fc)) ///
ytitle(Share of respondents) ///
title("Share of respondents in good health and" "share of Medicaid beneficiaries by income quintile") 
graph export graph1.png, replace
restore

/* NOTES: By plotting the share of respondents by income quintile, one can 
notice that many more individuals in the lower income quintile receives 
Medicaid than in the highest one.
This is not surprising since Medicaid is a joint federal and state program 
that provides health coverage for people in the US with limited income and
resources. Conversely, the share of respondents in the highest quintile
also reports being in a good health status much more frequently than individuals
in the bottom of the income distribution. The data seems to suggests a
relationship between income and health which is worth investigation. */


/* WEIGHTS */

/* NOTES: HRS RAND dataset provides two types of weights: r*wtresp 
(weight at individual level) and r*wthh (weight at household level).
RAND documentation suggests using "household weight" in analyses of measures
collected at the household level, such as "income,assets, debts and housing".
Conversely, "Respondent weight" are recommended for measures collected at the
respondent level such as health, labor supply and health care utilization.

In this analysis, we consider both type of measures but, since the level of 
measurement of of interest is the individual, "respondend weights" are selected.

HRS RAND weights classify as "pweight" and hence they are not supported by the 
"estpost summarize" command used to compute summary statistics. Notice that,
however, one could look at estimate of population mean (instead of summary
statistics) which instead must be computed using weights.

See "http://hrsonline.isr.umich.edu/sitedocs/wghtdoc.pdf" for further details.*/



