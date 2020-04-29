reset;
################################
#example for R11, low pressure stage
################################
# Sets & Parameters
################################
set Time default {}; 	#time steps for which we have results 
#parameter defined in dat sheet: 
param Q_cond{Time}; 	#[kW] heat condensor
param Q_evap{Time}; 	#[kW] heat evaporator
param W_hp{Time};  		#[kW] total power consumed by hp 
param W_comp1{Time} ; 	#[kW] power of compressor 1 
param T_cond{Time}; 	#[deg C] condensation temperature of the hp 
param  T_ext {Time}; 	#[deg C] external temperature 
param T_hp_4{Time}; 	#[deg C] temperature in 4, see flowsheet




#temperatures that are constant for all fluids and timesteps
param T_evap 			:= 6;  	#[deg C] evaporaion temperature of hp or T_hp5
param T_epfl_low 		:= 22; 	# [deg C] log mean Temperature of low heating network EPFL 
param T_source 			:= 10;	# [deg C] Temperature of heat pump heat source at which the heat is delvered to evaporator, assume as constant
param T_hp1             := 2; 	#[deg C] temperature in 2, see flowsheet

#costing parameters 
param k1  				:= ;	#parameter for compressor cost function
param k2 			 	:= ; 	#parameter for compressor cost function
param k3  				:= ;    #parameter for compressor cost function
param k1_HEX			:= ; 	#parameter for HEX cost function
param k2_HEX	 	 	:= ;	#parameter for HEX cost function
param k3_HEX  			:= ;	#parameter for HEX cost function
param f_BM 				:= ; 	# bare module factor for compressor (CS) 
param f_BM_HEX			:= ; 	# bare module factor for HEX 
param ref_index 		:= ; 	# CEPCI reference 2001 
param index 			:= ;	# CEPCI 2016

param U_water_ref       := ; 	#water-refrigerant global heat transfer coefficient (kW/m2.K)
param U_air_ref         := ; 	#air-refrigerant global heat transfer coefficient (kW/m2.K)
  
  
################################
# Variables
################################
var c_factor1{Time} 		>= 0.001; # CarnotFactor, defined as Q/P * ((Tcond/(Tcond-Tevap)))
var c_factor2{Time} 		>= 0.001; # CarnotFactor, calculated as a function of external temperature:  c_factor= -a * T_ext[t]**2 - b *T_ext[t] + c ; 
var a 						>= 0.000000001;
var b 						>= 0.000000001;
var c 						>= 0.000000001; 
var mse 					>= 0.000000001; #mean squared error, to be minimized (c_factor- c_factor_rec)^2 /n 
var W_comp2{Time}			>= 0; # electricity demand of second compressor 

var comp_cost				>= 0.001 ;
var Evap_cost				>= 0.001 ;
var Evap_area				>= 0.001 ;
var DTlnEvap				>= 0.001 ;

################################
# Constraints
################################

subject to Wcompressor2{t in Time}: #calculates the electricity demand of the second compressor 



subject to CarnotFactor1{t in Time}:  
#caculates the carnot factor for all time steps of low pressure stage
#we assume that the low pressure stage can provide heat to the low temperature network of epfl over a free heat exchanger (no cost considered!)
#for calculating the carnot factor, assume t_epfl_low as condenser temperature, and source temperature as evaporator temperature
#How can you calculate the condensation heat that is available here? 
#avoid dividing by 0! ,use conditions

subject to CarnotFactor2{t in Time}:  #caculates the carnot factor for all time steps with fitting function (2nd degree polynomial)
#if you used conditions in CarnotFactor1,apply the same ones 



subject to DTlnEvap_constraint: #calculated the DTLN of the evap heat exchanger,  source - heat pump
	

subject to Evaporator_area: #Area of evap HEX, calclated for extreme period 
	

subject to Comp2cost: #calculates the cost for comp2 for extreme period 


 #subject to HEX1_cost: #calculates the cost forHEX1 for extreme period 
 subject to Evaporator_cost:
 	

 subject to Error: #calculates the mean square error between carnot factors that needs to be minimized 
	



################################
minimize obj : mse; 