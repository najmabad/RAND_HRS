* main analysis file - 8 April 2018



/* PANEL DATA */

xtset hhidpn wave

xtsum rgovmd
xttab rgovmd

/* NOTES: The within variation for the "Receives Medicaid" is 0.17.
Moreover, 51% of the people who ever received Medicaid always received Medicaid
during the period of observation, while 94% of the people who did not received
Medicaid never received it. */


/* NOTES: Robust standard errors that cluster on the individual are use in this
analysis. Please notice that HRS RAND documentation suggests also using the
svyset command to declare the survey structure of the data as follows:
svyset raehsamp [pweight=rwtresp], strata (raestrat).
See "http://hrsonline.isr.umich.edu/sitedocs/dmgt/IntroUserGuide.pdf"
for further reference.*/


/* STANDARDIZED COEFFICIENTS */

foreach var of varlist hitot hahous haira {
egen `var'_std =std(`var')
}

lab var hitot_std "Total Household Income"
lab var hahous_std "Value of Primary Residence"
lab var haira_std "Value in IRA Accounts"

global fin_std "hitot_std hahous_std haira_std hampr rwlbrf"


/* NOTES: dummy variables are not standardized since: 
(1) a dummy variable cannot be increased by a standard deviation so the
regular interpretation for standardized coefficients does not apply.
In this case regression coefficients of dummy variables should be interpreted
as the 100*β percentage point change in the probability that the individual is 
in good health.*/



/* PANEL REGRESSIONS */
eststo clear


quietly reg rwshlt $dem $fin_std $insu rsmokev [pweight=rwtresp], ///
vce(cluster hhidpn)

est store A

xi: quietly reg rwshlt $dem $fin_std $insu rsmokev i.wave [pweight=rwtresp], ///
vce(cluster hhidpn)

est store B

xi: quietly reg rwshlt $dem $fin_std $insu rsmokev i.rcendiv ///
[pweight=rwtresp], vce(cluster hhidpn)

est store C

xi: quietly reg rwshlt $dem $fin_std $insu rsmokev i.wave i.rcendiv ///
[pweight=rwtresp],vce(cluster hhidpn)
est store D


esttab A B C D using PanelRegressions.tex, replace ///
title("Table 2: Good Health indicator and Medicaid model, HRS Rand, 1992 - 2014 ") ///
mtitle("Pooled OLS" "Fixed Effect" "Fixed Effect" "Fixed Effect" ) ///
drop(_Iwave_* _Ircendiv_* ) ///
refcat(ragender "\emph{Demographics}" hitot_std "\emph{Financials}" ///
rassrecv "\emph{Insurance}"  rsmokev "\emph{Health}", nolabel) ///
star(* 0.10 ** 0.05 *** 0.01) ///
label collabels(none) booktabs ///
stats(N r2_a, fmt(2)  labels(`"Observations"' `"Adjusted \(R^{2}\)"') ) ///
addnotes("Notes: Pooled OLS and Fixed Effect Estimations Model ")





 

