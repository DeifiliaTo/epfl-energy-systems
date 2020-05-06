reset;
################################
#example for R11, high pressure stage
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
param T_evap 			:= 6;  #[deg C] evaporaion temperature of hp
param T_source 			:= 10 ;# [deg C] Temperature of heat pump heat source at which the heat is delvered to evaporator;


#costing parameters 
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
param U_air_ref         := 0.15; 	#air-refrigerant global heat transfer coefficient (kW/m2.K)

param T_medium_out         :=30; #Medium temperature return EPFL
var T_medium_in         	>=30; #Medium temperature supply EPFL
param Qheating         	 := 30319; #peak heat demand epfl for Medium temperature 
param Mcp               := Qheating/(65-30); # close loop EPFL medium temperature liquid
  
################################
# Variables
################################
var c_factor1{Time} 		>= 0.001; # CarnotFactor, defined as Q/P * ((Tcond/(Tcond-Tevap)))
var c_factor2{Time} 		>= 0.001; # CarnotFactor, calculated as a function of external temperature:  c_factor= -a * T_ext[t]**2 - b *T_ext[t] + c ; 
var a 						>= 0.0000000001; #factor for fitting function for carnot factor 
var b 						>= 0.0000000001;#factor for fitting function for carnot factor 
var c 						>= 0.0000000001; #factor for fitting function for carnot factor 
var mse 					>= 0.0000001; #mean squared error, to be minimized (c_factor1- c_factor2)^2 /n 
var comp_cost 				>= 0.001 ; 

var Cond_cost			>= 0.001 ; #cost of condenser hex 
var Cond_area			>= 0.001 ; #area of condenser hex 
var DTlnCond			>= 0.001 ; #logarithmic mean temperature difference of condenser hex
var TlnCond             >= 0.001; #logaritmic mean temperature of medium temperature loop epfl

################################
# Constraints
################################

subject to CarnotFactor1{t in Time}:  #caculates the carnot factor for all time steps, avoid dividing by 0 in summer! 
#caculates the carnot factor for all time steps of high pressure stage
#we assume that the high pressure stage can provide heat to the medium temperature network of epfl
#TlnCond  is the condensation temperature, what is the evaporation temperature of this stage? 
#avoid dividing by 0! ,use conditions
    c_factor1[t] = if (Q_cond[t] > 0) then
        (Q_cond[t] / W_hp[t]) * ((TlnCond - T_hp_4[t]) / (TlnCond + 273)) #W compressor 2!!!!!!!
        else 0.001;
	

subject to CarnotFactor2{t in Time}:  #caculates the carnot factor for all time steps with fitting function (2nd degree polynomial)
#if you used conditions in CarnotFactor1,apply the same ones 
    c_factor2[t] = if (Q_cond[t] > 0) then
        a * (T_ext[t] + 273)^2 - b * (T_ext[t] + 273) + c
        else 0.001;


subject to TlnCond_constraint: #calculates the Log mean temperatrure of the epfl medium temperature loop 
	TlnCond = (T_medium_in - T_medium_out) / log ((T_medium_in + 273) / (T_medium_out + 273));
	
subject to DTlnCond_constraint: #calculated the DTLN of the condenser heat exchanger EPFL medium temperature loop - heat pump for the expreme period, you can neglect the sensible heat transfer (T variation)
    DTlnCond = ((T_cond[12] - T_medium_in) - (T_cond[12] - T_medium_out)) / log( (T_cond[12] - T_medium_in) / (T_cond[12] - T_medium_out) );

subject to Heat_condenser: #Heat transferred to EPFL network on extreme period, this equation is needed to define T_medium_in
	Q_cond[12] = Mcp * (T_medium_in - T_medium_out);

subject to Condenser_area: #Area of condenser HEX, calculated for extreme period 
	Q_cond[12] = U_air_ref * Cond_area * DTlnCond;

subject to Comp1cost: 
#calculates the cost for comp1 for extreme period 
 	comp_cost = (index/ref_index) * (k1 + k2 * (W_comp1[12])^k3) * f_BM * 0.96; #*0.96 to convert from $ to CHF
 	
#subject to HEX2_cost: #calculates the cost for HEX2 for extreme period 
subject to Condenser_cost:
 	Cond_cost = (index/ref_index) * (k1_HEX + k2_HEX * (Cond_area)^k3_HEX) * f_BM_HEX * 0.96;

subject to Error: #calculates the mean square error that needs to be minimized 
    mse = sum{t in Time} ((c_factor2[t] - c_factor1[t])^2 / 12);

################################
minimize obj : mse; 