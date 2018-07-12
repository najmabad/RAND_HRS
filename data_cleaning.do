* clean file - 8 April 2018
* data provided by Health and Retirement Study at the University of Michigan



cls
clear all


********************************************************************************
*************************** Data setup *****************************************
********************************************************************************

/* VARIABLE SELECTION */

use hhid rahhidpn hhidpn inw* raehsam raestrat r*wtresp ragender h*hhresp ///
raedegrm r*mstat raracem rarelig h*itot h*ahous h*amort h*ahmln h*aira ///
r*lbrf rassrecv r*govmd r*hiltc r*shlt r*smokev r*iearn h*icap r*ipena /// 
r*issdi r*isret r*iunwc r*igxfr h*iothr r*cendiv using rndhrs_p.dta, clear

drop r*inlbrf

/* GENERATE INCOME QUINTILE */

forvalues i=1/12{ 
	gen r`i'icap = h`i'icap/2 if h`i'hhresp ==2
	replace r`i'icap =  h`i'icap if h`i'hhresp ==1
 }
 
forvalues i=1/12{ 
	gen r`i'iothr = h`i'iothr/2 if h`i'hhresp ==2
	replace r`i'iothr =  h`i'iothr if h`i'hhresp ==1
 }

forvalues i=1/12{ 
	egen r`i'itot = rowtotal(r`i'i*), missing
	label var r`i'itot  "individual income"
 }
 
drop r*iearn r*ipena r*issdi r*isret r*iunwc r*igxfr r*icap r*iothr ///
h*icap h*iothr 

forvalues i=1/12{
	pctile p5_`i' = r`i'itot, nq(5)
	return list
	gen r`i'iqnt=.
	replace r`i'iqnt=1 if r`i'itot<=r(r1) 
	replace r`i'iqnt=2 if r`i'itot<=r(r2) & r`i'itot>r(r1)
	replace r`i'iqnt=3 if r`i'itot<=r(r3) & r`i'itot>r(r2) 
	replace r`i'iqnt=4 if r`i'itot<=r(r4) & r`i'itot>r(r3) 
	replace r`i'iqnt=5 if r`i'itot>r(r4)  & r`i'itot<.
	label var r`i'iqnt "income quintile"
 }

drop p5_*

/* NOTES: the individual income quintile in a given wave of interview is
computed considering the income distribution of that specific wave.
Even thought for this analysis inflation was not taken directly into account, 
this solution seems a better option because: (1) level of income could have
varied considerably during the period of analsysis, (2) many research have 
underline the importance of "relative" rather than "absolute" inequality, which
whose effect could be underestimated when "collapsing" the entire dataset. */



/* FROM WIDE TO LONG FORMAT */

reshape long r@mstat inw@  h@hhresp r@wthh r@wtresp r@shlt r@smokev ///
h@aira h@ahous h@amort h@ahmln h@itot r@govmd r@hiltc r@lbrf r@itot ///
r@iqnt r@cendiv, i(rahhidpn) j(wave)


drop if hhhresp==.


/* EXCLUDE MISSING VALUES */

keep if ragender <. & raedegrm <. & rmstat <. & rmstat <. ///
& raracem <. & rarelig <. & ritot <. & hahous <. & hamort <. ///
& hahmln <. & haira <. &rlbrf <. & rassrecv <. & rgovmd <. & ///
rhiltc <. & rshlt  <. & rsmokev <.

/* NOTES: all missing values are dropped. This is a standard approach in 
many micro-econometrics analysis and the sample contains many observations */



/* RECODING OF VARIABLES */

/* Demographics */
replace ragender = ragender <2
replace raedegrm = . if raedegrm == 8
keep if raedegrm <.
gen raehsdegr = raedegrm <= 0
gen raemcdegr = raedegrm > 5 
drop raedegrm
gen rwmarried = rmstat < 3 
drop rmstat
gen rablack = raracem < 3 & raracem > 1
drop raracem
gen racath = rarelig < 3 & rarelig > 1
drop rarelig

label var ragender "Male"
label var hhhresp "N. people in household"
label var raehsdegr "Less than High School"
label var raemcdegr "More than College"
label var rwmarried "Married"
label var rablack "Black"
label var racath "Catholic"

/* NOTES: the values "other" of the variable raedegrm (education) is coded as
missing value (and subsequently excluded) since there is ambiguity on its 
definition and it could contain level of edu < college (see codebook p.144) */


/* Financials */
gen hampr = hamort + hahmln
replace hampr = hampr > 0 
drop hamort hahmln
gen rwlbrf = rlbrf < 2
drop rlbrf

label var hitot  "Total Household Income"
label var hahous  "Value of Primary Residence"
label var hampr  "Mortgage Primary Residence"
label var haira  "Value in IRA Accounts"
label var rwlbrf  "Work Full Time"

/* NOTES: the values of the variable "all mortgages/land contracts
(primary residence)" and "other home loans (primary residence)" are summed to
construct a unique indicator */


/* Insurance */
label var rassrecv "Receives Social Security"
label var rgovmd "Receives Medicaid"
label var rhiltc "Has long-term care insurance"


/* Health */
gen rwshlt = rshlt < 3
drop rshlt

label var rwshlt  "Good Health"
label var rsmokev "Ever Smoked"



/* N. OF OBSERVATION BY WAVE */


table wave inw



