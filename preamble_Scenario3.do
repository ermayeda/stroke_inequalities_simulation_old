/********************************************************************************/
/***	Scenario 3/c (U influences stroke for blacks and whites, only ***/
/***	influences mortality for blacks).								  	                    ***/
/********************************************************************************/

/*Step 1: Set parameters*/

*specify prevalence of exposure
global pexp = 0.5 	

*parameters for death 
//effect of exposure on log hazard of death, based on US life tables for 1919-1921 birth cohort 
*values for ages 45+ identified from search loop because U influences death risk from birth for exposure=1 in this scenario
global g1_0to1 =	 .194
global g1_1to5 = 	 .334
global g1_5to10 = 	.186
global g1_10to15 = 	.59799999
global g1_15to20 = 	.92399999
global g1_20to25 = 	.816 
global g1_25to30 = 	.83600001
global g1_30to35 = 	.71799999
global g1_35to40 =  .758
global g1_40to45 = 	.772
global g1_45to50 = 	.628 
global g1_50to55 = 	.61600001 
global g1_55to60 = 	.504 
global g1_60to65 = 	.4 
global g1_65to70 = 	.33800001 
global g1_70to75 = 	.226 
global g1_75to80 = 	.156 
global g1_80to85 = 	.21600001 
global g1_85to90 =  .174 
global g1_90to95 = 	.28 

*effects of covariates on mortality risk
global g2 = 0		    //log(HR) for effect of U on death *this main effect of U on mortality is set to 0 in ths scenario
global g3 = ln(1.5)	//log(HR) for interaction effect of exposure & U on death
global g4 = ln(2)	  //log(HR) for effect of stroke history on death

*baseline hazard of death (whites), based on US life tables for 1919-1921 birth cohort
global lambda_0to1 = 	0.0749
global lambda_1to5 = 	0.0082
global lambda_5to10 = 	0.0028
global lambda_10to15 = 	0.0021
global lambda_15to20 = 	0.0034
global lambda_20to25 = 	0.0048
global lambda_25to30 = 	0.0056
global lambda_30to35 = 	0.0062
global lambda_35to40 = 	0.0068
global lambda_40to45 = 	0.0078
*values for ages 45+ identified from search loop because strokes begin occurring, stroke increase risk of death
global lambda_45to50 =  .0102
global lambda_50to55 = 	.0132
global lambda_55to60 =	.019 
global lambda_60to65 = 	.0262
global lambda_65to70 =  .0388
global lambda_70to75 = 	.0608
global lambda_75to80 = 	.0914
global lambda_80to85 = 	.142 
global lambda_85to90 = 	.216 
global lambda_90to95 = 	.3 

/*baseline hazard of stroke (exp=0 whites)*/ 
*baseline hazard of stroke identified from search loop 
global stk_lambda_exp0_45to50 = .00054
global stk_lambda_exp0_50to55 = .00108
global stk_lambda_exp0_55to60 = .0018 
global stk_lambda_exp0_60to65 = .00334
global stk_lambda_exp0_65to70 = .00458
global stk_lambda_exp0_70to75 = .00724
global stk_lambda_exp0_75to80 = .00968
global stk_lambda_exp0_80to85 = .0118 
global stk_lambda_exp0_85to90 = .0142 
global stk_lambda_exp0_90to95 = .0178 

/*baseline hazard of stroke (exp=1 blacks)*/
global stk_lambda_delta = 0.002 	//age-constant incidence rate difference for exposure=1 vs. exposure=0
global stk_lambda_exp1_45to50 = 	$stk_lambda_exp0_45to50 + $stk_lambda_delta
global stk_lambda_exp1_50to55 = 	$stk_lambda_exp0_50to55 + $stk_lambda_delta
global stk_lambda_exp1_55to60 =		$stk_lambda_exp0_55to60 + $stk_lambda_delta
global stk_lambda_exp1_60to65 = 	$stk_lambda_exp0_60to65 + $stk_lambda_delta
global stk_lambda_exp1_65to70 =  	$stk_lambda_exp0_65to70 + $stk_lambda_delta
global stk_lambda_exp1_70to75 = 	$stk_lambda_exp0_70to75 + $stk_lambda_delta
global stk_lambda_exp1_75to80 = 	$stk_lambda_exp0_75to80 + $stk_lambda_delta
global stk_lambda_exp1_80to85 = 	$stk_lambda_exp0_80to85 + $stk_lambda_delta
global stk_lambda_exp1_85to90 = 	$stk_lambda_exp0_85to90 + $stk_lambda_delta 
global stk_lambda_exp1_90to95 = 	$stk_lambda_exp0_90to95 + $stk_lambda_delta

*effects of covariates on stroke risk
global b1 = ln(1.5)		//log (HR) for U on stroke

*probability of death at stroke
global pstrokedeath = 0.25 

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

