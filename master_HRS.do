global NB 1
global ourName 0

if $NB {
global folder "dofiles"
}

if $ourName {
global folder "We will insert our path here"
}

do $folder/data_cleaning.do



* master file for Goda-Honigsberg Predoc Position 7April2018 * 

*do clean*


*do recode*

*do tables*

shell pdflatex HRS_analysis.tex
shell open HRS_analysis.pdf
