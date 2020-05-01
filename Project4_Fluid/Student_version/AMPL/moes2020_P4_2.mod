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
param T_ext {Time}; 	#[deg C] external temperature 
param T_hp_4{Time}; 	#[deg C] temperature in 4, see flowsheet


#temperatures that are constant for all fluids and timesteps
param T_evap 			:= 6;  	#[deg C] evaporaion temperature of hp or T_hp5
param T_epfl_low 		:= 22; 	# [deg C] log mean Temperature of low heating network EPFL 
param T_source 			:= 10;	# [deg C] Temperature of heat pump heat source at which the heat is delvered to evaporator, assume as constant
param T_hp1             := 2; 	#[deg C] temperature in 2, see flowsheet

#costing parameters 
param k1  				:= 580000;	#parameter for compressor cost function
param k2 			 	:= 20000; 	#parameter for compressor cost function
param k3  				:= 0.6;    #parameter for compressor cost function
param k1_HEX			:= 1600; 	#parameter for HEX cost function
param k2_HEX	 	 	:= 210;	#parameter for HEX cost function
param k3_HEX  			:= 0.95;	#parameter for HEX cost function
param f_BM 				:= 2.15; 	# bare module factor for compressor (CS) 
param f_BM_HEX			:= 1.80; 	# bare module factor for HEX 
param ref_index 		:= 532.9; 	# CEPCI reference Jan 2010
param index 			:= 596.2;	# CEPCI Jan 2020

param U_water_ref       := 0.642; 	#water-refrigerant global heat transfer coefficient (kW/m2.K)
param U_air_ref         := 0.150; 	#air-refrigerant global heat transfer coefficient (kW/m2.K)
  
  
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
    W_comp2[t] = W_hp[t] - W_comp1[t];

subject to CarnotFactor1{t in Time}:  
#caculates the carnot factor for all time steps of low pressure stage
#we assume that the low pressure stage can provide heat to the low temperature network of epfl over a free heat exchanger (no cost considered!)
#for calculating the carnot factor, assume t_epfl_low as condenser temperature, and source temperature as evaporator temperature
#How can you calculate the condensation heat that is available here? 
#avoid dividing by 0! ,use conditions
    c_factor1[t] = if (Q_cond[t] > 0) then
        ((W_hp[t] + Q_evap[t] - Q_cond[t]) / W_comp1[t]) * ((T_epfl_low - T_source) / T_epfl_low)
        else 0.001;

subject to CarnotFactor2{t in Time}:  #caculates the carnot factor for all time steps with fitting function (2nd degree polynomial)
#if you used conditions in CarnotFactor1,apply the same ones
    c_factor2[t] = if (Q_cond[t] > 0) then
        a * (T_ext[t] + 273)^2 - b * (T_ext[t] + 273) + c
        else 0.001;

subject to DTlnEvap_constraint: #calculated the DTLN of the evap heat exchanger,  source - heat pump
	DTlnEvap = ( (T_source - T_hp1) - (T_source - T_evap) ) / log ((T_source - T_hp1) / (T_source - T_evap));

subject to Evaporator_area: #Area of evap HEX, calclated for extreme period 
	Q_evap[t = 12] = U_water_ref * Evap_area * DTlnEvap; #Set a certain time period!!

subject to Comp2cost: #calculates the cost for comp2 for extreme period 
    comp_cost = (index/ref_index) * (k1 + k2 * (W_comp2[t = 12])^k3) * f_BM * 0.96; #*0.96 to convert from $ to CHF

#subject to HEX1_cost: #calculates the cost forHEX1 for extreme period 
subject to Evaporator_cost:
 	Evap_cost = (index/ref_index) * (k1_HEX + k2_HEX * (Evap_area)^k3_HEX) * f_BM_HEX * 0.96;

subject to Error: #calculates the mean square error between carnot factors that needs to be minimized 
	mse = sum{t in Time} ((c_factor2[t] - c_factor1[t])^2 / 12);

################################
minimize obj : mse; 