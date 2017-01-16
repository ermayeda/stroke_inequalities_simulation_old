The objective of this study was to assess the extent to which selective survival could explain the age attenuation of racial disparities in stroke incidence. Although selective survival is clearly a mathematical possibility, to our knowledge no prior work has evaluated whether it could plausibly account for the extreme observed age-attenuation of black-white differences in stroke incidence. Using stroke incidence rates from the REGARDS study, survival rates from U.S. life tables, and considering racial disparities in stroke on both additive and multiplicative scales, we conducted a simulation to evaluate the potential impact of selective survival on observed black-white differences in stroke by age under a range of possible underlying causal scenarios.

Outline of simulation study procedures:
(1) Select several causal scenarios for investigation.
(2) Specify data-generating process for hypothetical cohort population corresponding with each causal scenario. Since we are generating the data, we are generating the “true” age-constant effect of race on stroke incidence. 
(3) Run B iterations of sample generation under each causal scenario and estimate the racial disparity in stroke incidence in each age band in each sample. 
(4) Quantify the magnitude of bias in each scenario by comparing the estimated racial disparity in stroke in each age band averaged across the 2,000 samples with the known “true” effect of race on stroke risk. By comparing the observed associations with the “true” effect in our simulations, we are able to quantify the extent to which selective survival contributes to the age attenuation of racial disparities in stroke in each causal scenario.

Explanation of Stata files:
(1) master_simulation.do: Calls all of the necessary files to run B iterations of sample generation for each causal scenario. 
(2) data_generation_analysis.do: Data-generation and analysis file. The specific causal scenario depends on the input parameters specified in the preamble file.
(3) race_slope_preamble_ScenarioX.do (where X=1, 2, or 3. X=1 refers to Scenario A, X=2 refers to Scenario B, and X=3 refers to Scenario C): This file creates global variables for the specific input parameters for each causal scenario.
(4) run_simulation.do: runs B iterations of sample generation and analysis for each causal scenario, summarizes results across each scenario, and stores summarized results in an Excel file. 
