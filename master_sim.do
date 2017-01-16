set more off
clear all

di "$S_TIME"

timer clear 1

timer on 1


foreach causalscenario in 1 2 3 {
	global causalscenario = "Scenario`causalscenario'"
	
	global outputrow = `causalscenario'+1 
	
	global B = 2000 //desired number of iterations of sample generation 
	
	include run_simulation.do
	
	}
	
di "$S_TIME"

 timer off 1
 
 timer list 1
