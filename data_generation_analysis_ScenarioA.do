/**********************************************************************************/
/***	Scenario $causalscenario (1=A, 2=B, 3=C)				***/
/***	Modify the local parameters by changing the preamble file called	***/
/***	to modify the scenario.							***/
/**********************************************************************************/

set more off
clear
*set seed 67208113

/*Create blank data set*/
set obs 40000 //creates blank dataset with XXXXX observations
gen id = _n


/*Step 1: Set parameters*/
do race_slope_preamble_$causalscenario.do

*specify prevalence of exposure
local pexp = $pexp 	

*parameters for Sij 
//effect of exposure on log hazard of death, based on US life tables for 1919-1921 birth cohort 
local g1_0to1 =		$g1_0to1
local g1_1to5 = 	$g1_1to5
local g1_5to10 = 	$g1_5to10
local g1_10to15 = 	$g1_10to15
local g1_15to20 = 	$g1_15to20
local g1_20to25 = 	$g1_20to25
local g1_25to30 = 	$g1_25to30
local g1_30to35 = 	$g1_30to35
local g1_35to40 = 	$g1_35to40
local g1_40to45 = 	$g1_40to45
local g1_45to50 = 	$g1_45to50
local g1_50to55 = 	$g1_50to55
local g1_55to60 = 	$g1_55to60
local g1_60to65 = 	$g1_60to65
local g1_65to70 = 	$g1_65to70
local g1_70to75 = 	$g1_70to75
local g1_75to80 = 	$g1_75to80
local g1_80to85 = 	$g1_80to85
local g1_85to90 = 	$g1_85to90
local g1_90to95 = 	$g1_90to95
local g1_95to100 =	$g1_95to100 

*effects of covariates on mortality risk
local g2 = $g2 //log(HR) for effect of U on death 
local g3 = $g3 //log(HR) for interaction effect of exposure & U on death
local g4 = $g4 //log(HR) for effect of stroke on death	
local g5 = $g5 //delete later	

*baseline hazard of death (whites), based on US life tables for 1919-1921 birth cohort
local lambda_0to1 = 	$lambda_0to1
local lambda_1to5 = 	$lambda_1to5
local lambda_5to10 = 	$lambda_5to10
local lambda_10to15 = 	$lambda_10to15
local lambda_15to20 = 	$lambda_15to20
local lambda_20to25 = 	$lambda_20to25
local lambda_25to30 = 	$lambda_25to30
local lambda_30to35 = 	$lambda_30to35
local lambda_35to40 = 	$lambda_35to40
local lambda_40to45 = 	$lambda_40to45
local lambda_45to50 = 	$lambda_45to50
local lambda_50to55 = 	$lambda_50to55
local lambda_55to60 =	$lambda_55to60
local lambda_60to65 = 	$lambda_60to65
local lambda_65to70 =  	$lambda_65to70
local lambda_70to75 = 	$lambda_70to75 
local lambda_75to80 = 	$lambda_75to80
local lambda_80to85 = 	$lambda_80to85
local lambda_85to90 = 	$lambda_85to90
local lambda_90to95 = 	$lambda_90to95
local lambda_95to100 =	$lambda_95to100

*baseline hazard of stroke (exp=0 whites), based on Howard Ann Neurol 2011
local stk_lambda_exp0_45to50 = 	$stk_lambda_exp0_45to50
local stk_lambda_exp0_50to55 = 	$stk_lambda_exp0_50to55
local stk_lambda_exp0_55to60 =	$stk_lambda_exp0_55to60
local stk_lambda_exp0_60to65 = 	$stk_lambda_exp0_60to65
local stk_lambda_exp0_65to70 =  $stk_lambda_exp0_65to70
local stk_lambda_exp0_70to75 = 	$stk_lambda_exp0_70to75
local stk_lambda_exp0_75to80 = 	$stk_lambda_exp0_75to80
local stk_lambda_exp0_80to85 = 	$stk_lambda_exp0_80to85
local stk_lambda_exp0_85to90 = 	$stk_lambda_exp0_85to90
local stk_lambda_exp0_90to95 = 	$stk_lambda_exp0_90to95

*baseline hazard of stroke (exp=1 blacks), based on Howard Ann Neurol 2011
local stk_lambda_exp1_45to50 = $stk_lambda_exp1_45to50 	 
local stk_lambda_exp1_50to55 = $stk_lambda_exp1_50to55 	
local stk_lambda_exp1_55to60 = $stk_lambda_exp1_55to60 	
local stk_lambda_exp1_60to65 = $stk_lambda_exp1_60to65 	
local stk_lambda_exp1_65to70 = $stk_lambda_exp1_65to70  
local stk_lambda_exp1_70to75 = $stk_lambda_exp1_70to75 	
local stk_lambda_exp1_75to80 = $stk_lambda_exp1_75to80 	
local stk_lambda_exp1_80to85 = $stk_lambda_exp1_80to85 	
local stk_lambda_exp1_85to90 = $stk_lambda_exp1_85to90 	
local stk_lambda_exp1_90to95 = $stk_lambda_exp1_90to95 	

*parameters for stroke risk
local b1 = $b1 			//log (HR) for U on stroke
local b2 = $b2 			//delete later
local b3 = $b3 			//delete later
local b4 = $b3 			//delete later
local b5 = $b4 			//delete later

*probability of death at stroke
local pstrokedeath = $pstrokedeath 


/*Step 2: Generate exposure variable by generating a U(0,1) distribution 
and setting exposure=0 if the random number < pexp, otherwise exposure=1*/
gen exposure = runiform()<`pexp' 
/*generates random numbers~U(0,1). exposure=0 if random number< pexp, else exposure=1*/


/*Step 3: Generate continuous time-constant confounder of death and stroke (U)*/
gen U = rnormal(0,1)


/*Step 4: Generate survival time for each person and strokes for people alive
at each interval. 
a. Each person's underlying time to death is generated for each age interval, 
conditional on the past provided the person has not died in a previous interval, 
under an exponential survival distribtion. If the person’s generated survival 
time exceeds the length of the interval between study visits j and j+1, 
she is considered alive at study visit j+1 and a new survival time is 
generated for the next interval conditional on history up to the start of the 
interval, and the process is repeated until the person’s survival time falls 
within a given interval or the end of the study, whichever comes first. Each 
person’s hazard function is defined as:
h(tij|x) = lambda*exp(g1*exposurei + g2*Ui + g3*exposurei*Ui + g4*stroke_historyi)
A person’s survival time for a given time interval at risk is generated using 
the inverse cumulative hazard function transformation formula described by 
Bender et al. (Stat Med 2011)
b. Stroke code is adapted for survival time code.*/

*ia. Generate uniform random variable for generating survival time
gen U_0to1 = runiform()
gen U_1to5 = runiform()
gen U_5to10 = runiform()
gen U_10to15 = runiform()
gen U_15to20 = runiform()
gen U_20to25 = runiform()
gen U_25to30 = runiform()
gen U_30to35 = runiform()
gen U_35to40 = runiform()
gen U_40to45 = runiform()
gen U_45to50 = runiform()
gen U_50to55 = runiform()
gen U_55to60 = runiform()
gen U_60to65 = runiform()
gen U_65to70 = runiform()
gen U_70to75 = runiform()
gen U_75to80 = runiform()
gen U_80to85 = runiform()
gen U_85to90 = runiform()
gen U_90to95 = runiform()
gen U_95to100 = runiform()

*ib. Generate uniform random variable for generating stroke time
gen U2_45to50 = runiform()
gen U2_50to55 = runiform()
gen U2_55to60 = runiform()
gen U2_60to65 = runiform()
gen U2_65to70 = runiform()
gen U2_70to75 = runiform()
gen U2_75to80 = runiform()
gen U2_80to85 = runiform()
gen U2_85to90 = runiform()
gen U2_90to95 = runiform()


*ii. Generate survival time and stroke time for each interval

gen survage = .
gen strokeage = .

/***Ages 0-45: no strokes, so only need to generate survival***/
/*Interval 0-1*/
*Generate survival time from time 0
gen survtime0to1 = -ln(U_0to1)/(`lambda_0to1'*exp(`g1_0to1'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*0 +`g5'*0))
*Generate death indicator for interval 0-1 
gen death0to1 = 0
replace death0to1 = 1 if (survtime0to1 < 1) 
replace survage = survtime0to1 if (death0to1==1)
*Generate indicator for death before age 1
gen death1 = death0to1


/*Interval 1-5*/
*Generate survival time from time 1
gen survtime1to5 = -ln(U_1to5)/(`lambda_1to5'*exp(`g1_1to5'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*0 +`g5'*0)) ///
				if (death0to1==0) 
*Generate death indicator for interval 1-5 
gen death1to5 = 0 if (death1==0)
replace death1to5 = 1 if (survtime1to5 < 5)
replace survage = 1 + survtime1to5 if (death1to5==1)
*Generate indicator for death before age 5
gen death5 = 0
replace death5 = 1 if survage < 5


/*Interval 5-10*/
*Generate survival time from time 2
gen survtime5to10 = -ln(U_5to10)/(`lambda_5to10'*exp(`g1_5to10'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*0 +`g5'*0)) ///
				if (death5==0)
*Generate death indicator for interval 5-10 
gen death5to10 = 0 if (death5==0)
replace death5to10 = 1 if (survtime5to10 < 5) 
replace survage = 5 + survtime5to10 if (death5to10==1)
*Generate indicator for death before age 10
gen death10 = 0
replace death10 = 1 if survage < 10


/*Interval 10-15*/
*Generate survival time from time 3
gen survtime10to15 = -ln(U_10to15)/(`lambda_10to15'*exp(`g1_10to15'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*0 +`g5'*0)) ///
				if (death10==0)
*Generate death indicator for interval 10-15
gen death10to15 = 0 if (death10==0)
replace death10to15 = 1 if (survtime10to15 < 5) 
replace survage = 10 + survtime10to15 if (death10to15==1)
*Generate indicator for death before age 15
gen death15 = 0
replace death15 = 1 if survage < 15

/*Interval 15-20*/
*Generate survival time from time 4
gen survtime15to20 = -ln(U_15to20)/(`lambda_15to20'*exp(`g1_15to20'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*0 +`g5'*0)) ///
				if (death15==0)
*Generate death indicator for interval 15-20 
gen death15to20 = 0 if (death15==0)
replace death15to20 = 1 if (survtime15to20 < 5) 
replace survage = 15 + survtime15to20 if (death15to20==1)
*Generate indicator for death before age 20
gen death20 = 0
replace death20 = 1 if survage < 20


/*Interval 20-25*/
*Generate survival time from time 5
gen survtime20to25 = -ln(U_20to25)/(`lambda_20to25'*exp(`g1_20to25'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*0 +`g5'*0)) ///
				if (death20==0) 
*Generate death indicator for interval 20-25 
gen death20to25 = 0 if (death20==0)
replace death20to25 = 1 if (survtime20to25 < 5) 
replace survage = 20 + survtime20to25 if (death20to25==1)
*Generate indicator for death before age 25
gen death25 = 0
replace death25 = 1 if survage < 25


/*Interval 25-30*/
*Generate survival time from time 6
gen survtime25to30 = -ln(U_25to30)/(`lambda_25to30'*exp(`g1_25to30'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*0 +`g5'*0)) ///
				if (death25==0)
*Generate death indicator for interval 25-30 
gen death25to30 = 0 if (death25==0)
replace death25to30 = 1 if (survtime25to30 < 5) 
replace survage = 25 + survtime25to30 if (death25to30==1)
*Generate indicator for death before age 30
gen death30 = 0
replace death30 = 1 if survage < 30


/*Interval 30-35*/
*Generate survival time from time 7
gen survtime30to35 = -ln(U_30to35)/(`lambda_30to35'*exp(`g1_30to35'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*0 +`g5'*0)) ///
				if (death30==0)
*Generate death indicator for interval 30-35 
gen death30to35 = 0 if (death30==0)
replace death30to35 = 1 if (survtime30to35 < 5) 
replace survage = 30 + survtime30to35 if (death30to35==1)
*Generate indicator for death before age 35
gen death35 = 0
replace death35 = 1 if survage < 35


/*Interval 35-40*/
*Generate survival time from time 8
gen survtime35to40 = -ln(U_35to40)/(`lambda_35to40'*exp(`g1_35to40'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*0 +`g5'*0)) ///
				if (death35==0)
*Generate death indicator for interval 35-40
gen death35to40 = 0 if (death35==0)
replace death35to40 = 1 if (survtime35to40 < 5) 
replace survage = 35 + survtime35to40 if (death35to40==1)
*Generate indicator for death before age 40
gen death40 = 0
replace death40 = 1 if survage < 40


/*Interval 40-45*/
*Generate survival time from time 9
gen survtime40to45 = -ln(U_40to45)/(`lambda_40to45'*exp(`g1_40to45'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*0 +`g5'*0)) ///
				if (death40==0)
*Generate death indicator for interval 40-45
gen death40to45 = 0 if (death40==0)
replace death40to45 = 1 if (survtime40to45 < 5) 
replace survage = 40 + survtime40to45 if (death40to45==1)
*Generate indicator for death before age 45
gen death45 = 0
replace death45 = 1 if survage < 45


/***Starting at age 45--people are at risk of stroke, and prevalent stroke
increases mortality risk, so we need to start iteratively generating survival 
times and strokes***/


/*Interval 45-50*/
***a. Survival
*Generate survival time from time 10
gen survtime45to50 = -ln(U_45to50)/(`lambda_45to50'*exp(`g1_45to50'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*0 +`g5'*0)) ///
				if (death45==0)
*Generate death indicator for interval 45-50
gen death45to50 = 0 if (death45==0)
replace death45to50 = 1 if (survtime45to50 < 5) 
replace survage = 45 + survtime45to50 if (death45to50==1)
*Generate indicator for death before age 50
gen death50 = 0
replace death50 = 1 if survage < 50

***b. Stroke
*Generate stroke time from time 10 exp==0
gen stroketime45to50 = -ln(U2_45to50)/(`stk_lambda_exp0_45to50'*exp(`b1'*U)) ///
				if (exp==0 & death45==0)
*Generate stroke time from time 10 exp==1
replace stroketime45to50 = -ln(U2_45to50)/(`stk_lambda_exp1_45to50'*exp(`b1'*U)) ///
				if (exp==1 & death45==0)
*Generate stroke indicator for interval 45-50
gen stroke45to50 = 0 if (death45==0)
replace stroke45to50 = 1 if (stroketime45to50 < 5) 
replace stroke45to50 = 0 if (death45to50==1 & stroketime45to50 != . & stroketime45to50 > survtime45to50)
*Generate prevalent stroke variable (stroke up to age 50)
gen stroke_history = 0
replace stroke_history = 1 if (stroke45to50==1)
replace strokeage = 45 + stroketime45to50 if (stroke45to50==1)
*Generate indicator for stroke before age 50
gen stroke50 = 0
replace stroke50 = 1 if strokeage < 50

*Generate stroke deaths for interval 45-50, and replace death and survage accordingly if stroke death=1																	
gen strokedeath45to50 = runiform()<`pstrokedeath' if stroke45to50==1
replace death45to50 = 1 if (strokedeath45to50==1) 
replace survage = strokeage if (strokedeath45to50==1) 
*Generate indicator for stroke death before age 50
gen strokedeath50 = 0
replace strokedeath50 = 1 if (strokedeath45to50==1)


/*Interval 50-55*/
***a. Survival
*Generate survival time from time 11
gen survtime50to55 = -ln(U_50to55)/(`lambda_50to55'*exp(`g1_50to55'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*stroke_history +`g5'*0)) ///
				if (death50==0)
*Generate death indicator for interval 50-55
gen death50to55 = 0 if (death50==0)
replace death50to55 = 1 if (survtime50to55 < 5) 
replace survage = 50 + survtime50to55 if (death50to55==1)
*Generate indicator for death before age 55
gen death55 = 0
replace death55 = 1 if survage < 55

***b. Stroke
/*Interval 50-55*/
*Generate stroke time from time 11 exp==0
gen stroketime50to55 = -ln(U2_50to55)/(`stk_lambda_exp0_50to55'*exp(`b1'*U)) ///
				if (exp==0 & death50==0 & stroke50==0)
*Generate stroke time from time 11 exp==1
replace stroketime50to55 = -ln(U2_50to55)/(`stk_lambda_exp1_50to55'*exp(`b1'*U)) ///
				if (exp==1 & death50==0 & stroke50==0)
*Generate stroke indicator for interval 50-55
gen stroke50to55 = 0 if (death50==0 & stroke50==0)
replace stroke50to55 = 1 if (stroketime50to55 < 5) 
replace stroke50to55 = 0 if (death50to55==1 & stroketime50to55 != . & stroketime50to55 > survtime50to55)
*Update prevalent stroke variable (stroke up to age 55)
replace stroke_history = 1 if (stroke50to55==1)
replace strokeage = 50 + stroketime50to55 if (stroke50to55==1)
*Generate indicator for stroke before age 55						
gen stroke55 = 0
replace stroke55 = 1 if strokeage < 55

*Generate stroke deaths for interval 50-55, and replace death and survage accordingly if stroke death=1																	
gen strokedeath50to55 = runiform()<`pstrokedeath' if stroke50to55==1
replace death50to55 = 1 if (strokedeath50to55==1) 
replace survage = strokeage if (strokedeath50to55==1) 
*Generate indicator for stroke death before age 55
gen strokedeath55 = 0
replace strokedeath55 = 1 if (strokedeath45to50==1 | strokedeath50to55==1)


/*Interval 55-60*/
***a. Survival
*Generate survival time from time 12
gen survtime55to60 = -ln(U_55to60)/(`lambda_55to60'*exp(`g1_55to60'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*stroke_history +`g5'*0)) ///
				if (death55==0)
*Generate death indicator for interval 55-60
gen death55to60 = 0 if (death55==0)
replace death55to60 = 1 if (survtime55to60 < 5) 
replace survage = 55 + survtime55to60 if (death55to60==1)
*Generate indicator for death before age 60
gen death60 = 0
replace death60 = 1 if survage < 60

***b. Stroke
*Generate stroke time from time 12 exp==0
gen stroketime55to60 = -ln(U2_55to60)/(`stk_lambda_exp0_55to60'*exp(`b1'*U)) ///
				if (exp==0 & death55==0 & stroke55==0)
*Generate stroke time from time 12 exp==1
replace stroketime55to60 = -ln(U2_55to60)/(`stk_lambda_exp1_55to60'*exp(`b1'*U)) ///
				if (exp==1 & death55==0 & stroke55==0)				
*Generate stroke indicator for interval 55-60
gen stroke55to60 = 0 if (death55==0 & stroke55==0)
replace stroke55to60 = 1 if (stroketime55to60 < 5) 
replace stroke55to60 = 0 if (death55to60==1 & stroketime55to60 != . & stroketime55to60 > survtime55to60)
*Update prevalent stroke variable (stroke up to age 60)
replace stroke_history = 1 if (stroke55to60==1)
replace strokeage = 55 + stroketime55to60 if (stroke55to60==1)
*Generate indicator for stroke before age 60						
gen stroke60 = 0
replace stroke60 = 1 if strokeage < 60

*Generate stroke deaths for interval 55-60, and replace death and survage accordingly if stroke death=1																	
gen strokedeath55to60 = runiform()<`pstrokedeath' if stroke55to60==1
replace death55to60 = 1 if (strokedeath55to60==1) 
replace survage = strokeage if (strokedeath55to60==1) 
*Generate indicator for stroke death before age 60
gen strokedeath60 = 0
replace strokedeath60 = 1 if (strokedeath45to50==1 | strokedeath50to55==1 | strokedeath55to60==1)


/*Interval 60-65*/
***a. Survival
*Generate survival time from time 13
gen survtime60to65 = -ln(U_60to65)/(`lambda_60to65'*exp(`g1_60to65'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*stroke_history +`g5'*0)) ///
				if (death60==0)
*Generate death indicator for interval 60-65
gen death60to65 = 0 if (death60==0)
replace death60to65 = 1 if (survtime60to65 < 5) 
replace survage = 60 + survtime60to65 if (death60to65==1)
*Generate indicator for death before age 65
gen death65 = 0
replace death65 = 1 if survage < 65

***b. Stroke
*Generate stroke time from time 13 exp==0
gen stroketime60to65 = -ln(U2_60to65)/(`stk_lambda_exp0_60to65'*exp(`b1'*U)) ///
				if (exp==0 & death60==0 & stroke60==0)
*Generate stroke time from time 13 exp==1
replace stroketime60to65 = -ln(U2_60to65)/(`stk_lambda_exp1_60to65'*exp(`b1'*U)) ///
				if (exp==1 & death60==0 & stroke60==0)
*Generate stroke indicator for interval 60-65
gen stroke60to65 = 0 if (death60==0 & stroke60==0)
replace stroke60to65 = 1 if (stroketime60to65 < 5) 
replace stroke60to65 = 0 if (death60to65==1 & stroketime60to65 != . & stroketime60to65 > survtime60to65)
*Update prevalent stroke variable (stroke up to age 65)
replace stroke_history = 1 if (stroke60to65==1)
replace strokeage = 60 + stroketime60to65 if (stroke60to65==1)
*Generate indicator for stroke before age 65						
gen stroke65 = 0
replace stroke65 = 1 if strokeage < 65

*Generate stroke deaths for interval 60-65, and replace death and survage accordingly if stroke death=1																	
gen strokedeath60to65 = runiform()<`pstrokedeath' if stroke60to65==1
replace death60to65 = 1 if (strokedeath60to65==1) 
replace survage = strokeage if (strokedeath60to65==1) 
*Generate indicator for stroke death before age 65
gen strokedeath65 = 0
replace strokedeath65 = 1 if (strokedeath45to50==1 | strokedeath50to55==1 | strokedeath55to60==1 | ///
	strokedeath60to65==1)


/*Interval 65-70*/
***a. Survival
*Generate survival time from time 14
gen survtime65to70 = -ln(U_65to70)/(`lambda_65to70'*exp(`g1_65to70'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*stroke_history +`g5'*0)) ///
				if (death65==0)
*Generate death indicator for interval 65-70
gen death65to70 = 0 if (death65==0)
replace death65to70 = 1 if (survtime65to70 < 5) 
replace survage = 65 + survtime65to70 if (death65to70==1)
*Generate indicator for death before age 70
gen death70 = 0
replace death70 = 1 if survage < 70

***b. Stroke
*Generate stroke time from time 14 exp==0
gen stroketime65to70 = -ln(U2_65to70)/(`stk_lambda_exp0_65to70'*exp(`b1'*U)) ///
				if (exp==0 & death65==0 & stroke65==0)
*Generate stroke time from time 14 exp==1
replace stroketime65to70 = -ln(U2_65to70)/(`stk_lambda_exp1_65to70'*exp(`b1'*U)) ///
				if (exp==1 & death65==0 & stroke65==0)
*Generate stroke indicator for interval 65-70
gen stroke65to70 = 0 if (death65==0 & stroke65==0)
replace stroke65to70 = 1 if (stroketime65to70 < 5) 
replace stroke65to70 = 0 if (death65to70==1 & stroketime65to70 != . & stroketime65to70 > survtime65to70)
*Update prevalent stroke variable (stroke up to age 70)
replace stroke_history = 1 if (stroke65to70==1)
replace strokeage = 65 + stroketime65to70 if (stroke65to70==1)
*Generate indicator for stroke before age 70						
gen stroke70 = 0
replace stroke70 = 1 if strokeage < 70

*Generate stroke deaths for interval 65-70, and replace death and survage accordingly if stroke death=1																	
gen strokedeath65to70 = runiform()<`pstrokedeath' if stroke65to70==1
replace death65to70 = 1 if (strokedeath65to70==1) 
replace survage = strokeage if (strokedeath65to70==1) 
*Generate indicator for stroke death before age 70
gen strokedeath70 = 0
replace strokedeath70 = 1 if (strokedeath45to50==1 | strokedeath50to55==1 | strokedeath55to60==1 | ///
	strokedeath60to65==1 | strokedeath65to70==1)
	

/*Interval 70-75*/
***a. Survival
*Generate survival time from time 15
gen survtime70to75 = -ln(U_70to75)/(`lambda_70to75'*exp(`g1_70to75'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*stroke_history +`g5'*0)) ///
				if (death70==0)
*Generate death indicator for interval 70-75
gen death70to75 = 0 if (death70==0)
replace death70to75 = 1 if (survtime70to75 < 5) 
replace survage = 70 + survtime70to75 if (death70to75==1)
*Generate indicator for death before age 75
gen death75 = 0
replace death75 = 1 if survage < 75

***b. Stroke
*Generate stroke time from time 15 exp==0
gen stroketime70to75 = -ln(U2_70to75)/(`stk_lambda_exp0_70to75'*exp(`b1'*U)) ///
				if (exp==0 & death70==0 & stroke70==0)
*Generate stroke time from time 15 exp==1
replace stroketime70to75 = -ln(U2_70to75)/(`stk_lambda_exp1_70to75'*exp(`b1'*U)) ///
				if (exp==1 & death70==0 & stroke70==0)
*Generate stroke indicator for interval 70-75
gen stroke70to75 = 0 if (death70==0 & stroke70==0)
replace stroke70to75 = 1 if (stroketime70to75 < 5) 
replace stroke70to75 = 0 if (death70to75==1 & stroketime70to75 != . & stroketime70to75 > survtime70to75)
*Update prevalent stroke variable (stroke up to age 75)
replace stroke_history = 1 if (stroke70to75==1)
replace strokeage = 70 + stroketime70to75 if (stroke70to75==1)
*Generate indicator for stroke before age 75						
gen stroke75 = 0
replace stroke75 = 1 if strokeage < 75

*Generate stroke deaths for interval 70-75, and replace death and survage accordingly if stroke death=1																	
gen strokedeath70to75 = runiform()<`pstrokedeath' if stroke70to75==1
replace death70to75 = 1 if (strokedeath70to75==1) 
replace survage = strokeage if (strokedeath70to75==1) 
*Generate indicator for stroke death before age 75	
gen strokedeath75 = 0
replace strokedeath75 = 1 if (strokedeath45to50==1 | strokedeath50to55==1 | strokedeath55to60==1 | ///
	strokedeath60to65==1 | strokedeath65to70==1 | strokedeath70to75==1)
	

/*Interval 75-80*/
***a. Survival
*Generate survival time from time 16
gen survtime75to80 = -ln(U_75to80)/(`lambda_75to80'*exp(`g1_75to80'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*stroke_history +`g5'*0)) ///
				if (death75==0)
*Generate death indicator for interval 75-80
gen death75to80 = 0 if (death75==0)
replace death75to80 = 1 if (survtime75to80 < 5)
replace survage = 75 + survtime75to80 if (death75to80==1)
*Generate indicator for death before age 80
gen death80 = 0
replace death80 = 1 if survage < 80

***b. Stroke
*Generate stroke time from time 16 exp==0
gen stroketime75to80 = -ln(U2_75to80)/(`stk_lambda_exp0_75to80'*exp(`b1'*U)) ///
				if (exp==0 & death75==0 & stroke75==0)
*Generate stroke time from time 16 exp==1
replace stroketime75to80 = -ln(U2_75to80)/(`stk_lambda_exp1_75to80'*exp(`b1'*U)) ///
				if (exp==1 & death75==0 & stroke75==0)
*Generate stroke indicator for interval 75-80
gen stroke75to80 = 0 if (death75==0 & stroke75==0)	
replace stroke75to80 = 1 if (stroketime75to80 < 5)
replace stroke75to80 = 0 if (death75to80==1 & stroketime75to80 != . & stroketime75to80 > survtime75to80)
*Update prevalent stroke variable (stroke up to age 80)
replace stroke_history = 1 if (stroke75to80==1)
replace strokeage = 75 + stroketime75to80 if (stroke75to80==1)
*Generate indicator for stroke before age 80						
gen stroke80 = 0
replace stroke80 = 1 if strokeage < 80

*Generate stroke deaths for interval 75-80, and replace death and survage accordingly if stroke death=1																	
gen strokedeath75to80 = runiform()<`pstrokedeath' if stroke75to80==1
replace death75to80 = 1 if (strokedeath75to80==1) 
replace survage = strokeage if (strokedeath75to80==1) 
*Generate indicator for stroke death before age 80	
gen strokedeath80 = 0
replace strokedeath80 = 1 if (strokedeath45to50==1 | strokedeath50to55==1 | strokedeath55to60==1 | ///
	strokedeath60to65==1 | strokedeath65to70==1 | strokedeath70to75==1 | strokedeath75to80==1)
	

/*Interval 80-85*/
***a. Survival
*Generate survival time from time 17
gen survtime80to85 = -ln(U_80to85)/(`lambda_80to85'*exp(`g1_80to85'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*stroke_history +`g5'*0)) ///
				if (death80==0)
*Generate death indicator for interval 80-85
gen death80to85 = 0 if (death80==0)
replace death80to85 = 1 if (survtime80to85 < 5)
replace survage = 80 + survtime80to85 if (death80to85==1)
*Generate indicator for death before age 85
gen death85 = 0
replace death85 = 1 if survage < 85

***b. Stroke
*Generate stroke time from time 17 exp==0
gen stroketime80to85 = -ln(U2_80to85)/(`stk_lambda_exp0_80to85'*exp(`b1'*U)) ///
				if (exp==0 & death80==0 & stroke80==0)
*Generate stroke time from time 17 exp==1
replace stroketime80to85 = -ln(U2_80to85)/(`stk_lambda_exp1_80to85'*exp(`b1'*U)) ///
				if (exp==1 & death80==0 & stroke80==0)
*Generate stroke indicator for interval 80-85
gen stroke80to85 = 0 if (death80==0 & stroke80==0)
replace stroke80to85 = 1 if (stroketime80to85 < 5)
replace stroke80to85 = 0 if (death80to85==1 & stroketime80to85 != . & stroketime80to85 > survtime80to85)
*Update prevalent stroke variable (stroke up to age 85)
replace stroke_history = 1 if (stroke80to85==1)
replace strokeage = 80 + stroketime80to85 if (stroke80to85==1)
*Generate indicator for stroke before age 85						
gen stroke85 = 0
replace stroke85 = 1 if strokeage < 85

*Generate stroke deaths for interval 80-85, and replace death and survage accordingly if stroke death=1																	
gen strokedeath80to85 = runiform()<`pstrokedeath' if stroke80to85==1
replace death80to85 = 1 if (strokedeath80to85==1) 
replace survage = strokeage if (strokedeath80to85==1) 
*Generate indicator for stroke death before age 85	
gen strokedeath85 = 0
replace strokedeath85 = 1 if (strokedeath45to50==1 | strokedeath50to55==1 | strokedeath55to60==1 | ///
	strokedeath60to65==1 | strokedeath65to70==1 | strokedeath70to75==1 | strokedeath75to80==1 | ///
	strokedeath80to85==1)
	

/*Interval 85-90*/
***a. Survival
*Generate survival time from time 18
gen survtime85to90 = -ln(U_85to90)/(`lambda_85to90'*exp(`g1_85to90'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*stroke_history +`g5'*0)) ///
				if (death85==0)
*Generate death indicator for interval 85-90
gen death85to90 = 0 if (death85==0)
replace death85to90 = 1 if (survtime85to90 < 5)
replace survage = 85 + survtime85to90 if (death85to90==1)
*Generate indicator for death before age 90
gen death90 = 0
replace death90 = 1 if survage < 90

***b. Stroke
*Generate stroke time from time 18 exp==0
gen stroketime85to90 = -ln(U2_85to90)/(`stk_lambda_exp0_85to90'*exp(`b1'*U)) ///
				if (exp==0 & death85==0 & stroke85==0)
*Generate stroke time from time 18 exp==1
replace stroketime85to90 = -ln(U2_85to90)/(`stk_lambda_exp1_85to90'*exp(`b1'*U)) ///
				if (exp==1 & death85==0 & stroke85==0)
*Generate stroke indicator for interval 85-90
gen stroke85to90 = 0 if (death85==0 & stroke85==0)
replace stroke85to90 = 1 if (stroketime85to90 < 5)
replace stroke85to90 = 0 if (death85to90==1 & stroketime85to90 != . & stroketime85to90 > survtime85to90)
*Update prevalent stroke variable (stroke up to age 90)
replace stroke_history = 1 if (stroke85to90==1)
replace strokeage = 85 + stroketime85to90 if (stroke85to90==1)
*Generate indicator for stroke before age 90						
gen stroke90 = 0
replace stroke90 = 1 if strokeage < 90

*Generate stroke deaths for interval 85-90, and replace death and survage accordingly if stroke death=1																	
gen strokedeath85to90 = runiform()<`pstrokedeath' if stroke85to90==1
replace death85to90 = 1 if (strokedeath85to90==1) 
replace survage = strokeage if (strokedeath85to90==1) 
*Generate indicator for stroke death before age 90	
gen strokedeath90 = 0
replace strokedeath90 = 1 if (strokedeath45to50==1 | strokedeath50to55==1 | strokedeath55to60==1 | ///
	strokedeath60to65==1 | strokedeath65to70==1 | strokedeath70to75==1 | strokedeath75to80==1 | ///
	strokedeath80to85==1 | strokedeath85to90==1)
	

/*Interval 90-95*/
***a. Survival
*Generate survival time from time 19
gen survtime90to95 = -ln(U_90to95)/(`lambda_90to95'*exp(`g1_90to95'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*stroke_history +`g5'*0)) ///
				if (death90==0)
*Generate death indicator for interval 90-95
gen death90to95 = 0 if (death90==0)
replace death90to95 = 1 if (survtime90to95 < 5)
replace survage = 90 + survtime90to95 if (death90to95==1)
*Generate indicator for death before age 95
gen death95 = 0
replace death95 = 1 if survage < 95

***b. Stroke
/*Interval 90-95*/
*Generate stroke time from time 19 exp==0
gen stroketime90to95 = -ln(U2_90to95)/(`stk_lambda_exp0_90to95'*exp(`b1'*U)) ///
				if (exp==0 & death90==0 & stroke90==0)
*Generate stroke time from time 19 exp==1
replace stroketime90to95 = -ln(U2_90to95)/(`stk_lambda_exp1_90to95'*exp(`b1'*U)) ///
				if (exp==1 & death90==0 & stroke90==0)
*Generate stroke indicator for interval 90-95
gen stroke90to95 = 0 if (death90==0 & stroke90==0)
replace stroke90to95 = 1 if (stroketime90to95 < 5)
replace stroke90to95 = 0 if (death90to95==1 & stroketime90to95 != . & stroketime90to95 > survtime90to95)
*Update prevalent stroke variable (stroke up to age 95)
replace stroke_history = 1 if (stroke90to95==1)
replace strokeage = 90 + stroketime90to95 if (stroke90to95==1)
*Generate indicator for stroke before age 95						
gen stroke95 = 0
replace stroke95 = 1 if strokeage < 95

*Generate stroke deaths for interval 90-95, and replace death and survage accordingly if stroke death=1																	
gen strokedeath90to95 = runiform()<`pstrokedeath' if stroke90to95==1
replace death90to95 = 1 if (strokedeath90to95==1) 
replace survage = strokeage if (strokedeath90to95==1) 
*Generate indicator for stroke death before age 95	
gen strokedeath95 = 0
replace strokedeath95 = 1 if (strokedeath45to50==1 | strokedeath50to55==1 | strokedeath55to60==1 | ///
	strokedeath60to65==1 | strokedeath65to70==1 | strokedeath70to75==1 | strokedeath75to80==1 | ///
	strokedeath80to85==1 | strokedeath85to90==1 | strokedeath90to95==1)
	

/*Interval 95-100*/
***a. Survival
*Generate survival time from time 20
gen survtime95to100 = -ln(U_95to100)/(`lambda_95to100'*exp(`g1_95to100'*exposure +`g2'*U ///
			+`g3'*exposure*U +`g4'*stroke_history +`g5'*0)) ///
				if (death95==0)
*Generate death indicator for interval 95-100
gen death95to100 = 0 if (death95==0)
replace death95to100 = 1 if (survtime95to100 < 5)
replace survage = 95 + survtime95to100 if (survtime95to100!=.)
*Generate indicator for death before age 95
gen death100 = 0
replace death100 = 1 if survage < 100

*everyone dies
gen death = 1

*top code survage at 100
*replace survage = 100 if survage > 100

***b. Stroke: Not generated for ages 95+


*iv. Generate variables for stroke and stroke death between ages 45 to 95
gen stroke = 0
replace stroke = 1 if (stroke45to50==1 | stroke50to55==1 | stroke55to60==1 | ///
stroke60to65==1 | stroke65to70==1 | stroke70to75==1 | stroke75to80==1 | ///
stroke80to85==1 | stroke85to90==1 | stroke90to95==1)
gen strokedeath = 0
replace strokedeath = 1 if (strokedeath45to50==1 | strokedeath50to55==1 | strokedeath55to60==1 | ///
strokedeath60to65==1 | strokedeath65to70==1 | strokedeath70to75==1 | strokedeath75to80==1 | ///
strokedeath80to85==1 | strokedeath85to90==1 | strokedeath90to95==1)


*v. Generate strokeage for people who didn't develop a stroke
replace strokeage = survage if (stroke==0 & death45==0) //no strokeage for people who died before age 45


*vi. Generate age-stratified stroke variables
*ages 45 to 55
gen strokeage45to55_start = 45 if (strokeage !=. & strokeage>=45)
gen strokeage45to55_end = 54.99999 if (strokeage !=. & strokeage>=55)
replace strokeage45to55_end = strokeage if (strokeage !=. & strokeage>=45 & strokeage<55)
gen strokeage45to55_contributor = 1 if (strokeage !=. & strokeage>=45)
replace strokeage45to55_contributor = 0 if (strokeage !=. & strokeage<45)
gen stroke45to55 = .
replace stroke45to55 = 0 
replace stroke45to55 = 1 if (stroke45to50==1 | stroke50to55==1)

*ages 55 to 65
gen strokeage55to65_start = 55 if (strokeage !=. & strokeage>=55)
gen strokeage55to65_end = 64.99999 if (strokeage !=. & strokeage>=65)
replace strokeage55to65_end = strokeage if (strokeage !=. & strokeage>=55 & strokeage<65)
gen strokeage55to65_contributor = 1 if (strokeage !=. & strokeage>=55)
replace strokeage55to65_contributor = 0 if (strokeage !=. & strokeage<55)
gen stroke55to65 = 0
replace stroke55to65 = 1 if (stroke55to60==1 | stroke60to65==1)

*ages 65 to 75
gen strokeage65to75_start = 65 if (strokeage !=. & strokeage>=65)
gen strokeage65to75_end = 74.99999 if (strokeage !=. & strokeage>=75)
replace strokeage65to75_end = strokeage if (strokeage !=. & strokeage>=65 & strokeage<75)
gen strokeage_65to75contributor = 1 if (strokeage !=. & strokeage>=65)
replace strokeage_65to75contributor = 0 if (strokeage !=. & strokeage<65)
gen stroke65to75 = 0
replace stroke65to75 = 1 if (stroke65to70==1 | stroke70to75==1)

*ages 75 to 85
gen strokeage75to85_start = 75 if (strokeage !=. & strokeage>=75)
gen strokeage75to85_end = 84.99999 if (strokeage !=. & strokeage>=85)
replace strokeage75to85_end = strokeage if (strokeage !=. & strokeage>=75 & strokeage<85)
gen strokeage75to85_contributor = 1 if (strokeage !=. & strokeage>=75)
replace strokeage75to85_contributor = 0 if (strokeage !=. & strokeage<75)
gen stroke75to85 = 0
replace stroke75to85 = 1 if (stroke75to80==1 | stroke80to85==1)

*ages 85 to 95
gen strokeage85to95_start = 85 if (strokeage !=. & strokeage>=85)
gen strokeage85to95_end = 94.99999 if (strokeage !=. & strokeage>=85)
replace strokeage85to95_end = strokeage if (strokeage !=. & strokeage>=85 & strokeage<95)
gen strokeage85to95_contributor = 1 if (strokeage !=. & strokeage>=85)
replace strokeage85to95_contributor = 0 if (strokeage !=. & strokeage<85)
gen stroke85to95 = 0
replace stroke85to95 = 1 if (stroke85to90==1 | stroke90to95==1)


/**************************************************************/

/******************************************************************************/
/***	End data generation													***/
/******************************************************************************/


/******************************************************************************/
/***	Select a sample of observations still alive at start of study		***/
/******************************************************************************/
*drop if death_prestudy==1
*sample 2500, count 



/******************************************************************************/
/***	MODELS																***/
/******************************************************************************/

******************************************/
*pull N
scalar N= _N

*pull N in each exposure group
summarize exposure
scalar N_exp1 = r(mean)*r(N)
scalar N_exp0 = r(N) - r(mean)*r(N)
/******************************************/

/******************************************/
*pull percentage of deaths at start and end of stroke f/u
*age 45, 50, 55, ..., 95
foreach x in 45 50 55 60 65 70 75 80 85 90 95 {
	summarize death`x', meanonly
	scalar p_death`x' = r(mean)
	summarize death`x' if (exposure==1), meanonly
	scalar p_death`x'_exp1 = r(mean)
	summarize death`x' if (exposure==0), meanonly
	scalar p_death`x'_exp0 = r(mean)
}


*pull median survival time
summarize survage, detail 
scalar med_survage = r(p50)
qui summarize survage if (exposure==1), detail
scalar med_survage_exp1 = r(p50)
qui summarize survage if (exposure==0), detail
scalar med_survage_exp0 = r(p50)


*pull percentage of strokes
summarize stroke, meanonly 
scalar p_stroke = r(mean)
summarize stroke if (exposure==1), meanonly 
scalar p_stroke_exp1 = r(mean)
summarize stroke if (exposure==0), meanonly 
scalar p_stroke_exp0 = r(mean)
/******************************************/

/******************************************/
*distribution of U among people at risk for stroke in each age group at birth and in 5-year intervals starting at age 45
*birth
qui sum U if (exposure==1)
scalar meanUatrisk0_exp1= r(mean)
qui sum U if (exposure==0)
scalar meanUatrisk0_exp0= r(mean)

*age 45, 50, 55, ..., 95
foreach x in 45 50 55 60 65 70 75 80 85 90 95 {
	qui sum U if (exposure==1 & strokeage !=. & strokeage>=`x')
	scalar meanUatrisk`x'_exp1= r(mean)
	scalar Natrisk`x'_exp1= r(N)
	qui sum U if (exposure==0 & strokeage !=. & strokeage>=`x')
	scalar meanUatrisk`x'_exp0= r(mean)
	scalar Natrisk`x'_exp0= r(N)
}
/******************************************/

/******************************************/
*age-stratified incidence rates by exposure, incidence rate differences, and incidence rate ratios
/*temp loop code*/ 
foreach x in 45to55 55to65 65to75 75to85 85to95 {
	qui stset strokeage, failure(stroke`x'==1) id(id) enter(strokeage`x'_start) exit(strokeage`x'_end)
	*stroke IR for blacks
	qui stptime if (exposure==1), title(person-years) per(10000)
	scalar nstrokes`x'_exp1 = r(failures)
	scalar ptime`x'_exp1 = r(ptime)
	scalar strokerate10000pys`x'_exp1 = r(rate)
	*stroke IR for whites
	qui stptime if (exposure==0), title(person-years) per(10000)
	scalar nstrokes`x'_exp0 = r(failures)
	scalar ptime`x'_exp0 = r(ptime)
	scalar strokerate10000pys`x'_exp0 = r(rate)
	*stroke IRR and IRD for blacks vs. whites
	qui stir exposure
	scalar strokeIRR`x' = r(irr)
	scalar strokelnIRR`x' = ln(r(irr))
	*scalar strokelnIRR`x'_SE = sqrt((1/nstrokes`x'_exp1)+(1/nstrokes`x'_exp0)) //this isn't what I want--I want SE(IRR). also the code i wrote isn't working
	scalar strokeIRR`x'_ub = r(ub_irr)
	scalar strokeIRR`x'_lb = r(lb_irr)
	scalar strokeIRD`x' = r(ird)*10000
	scalar strokeIRD`x'_SE = sqrt((nstrokes`x'_exp1/((ptime`x'_exp1)^2))+(1/nstrokes`x'_exp0/((ptime`x'_exp0)^2)))*10000 //can I simply multiply the SE(IRD) by the PY?
	scalar strokeIRD`x'_ub = r(ub_ird)*10000
	scalar strokeIRD`x'_lb = r(lb_ird)*10000
}
/******************************************/

/******************************************/
*pull n strokes per 5-year intervals
*age 45, 50, 55, ..., 95
foreach x in 45to55 55to65 65to75 75to85 85to95 {
	sum stroke`x' if exposure==0
	scalar nstrokes`x'_exp0 = r(mean)*r(N)

	sum stroke`x' if exposure==1
	scalar nstrokes`x'_exp1 = r(mean)*r(N)
}
/******************************************/

