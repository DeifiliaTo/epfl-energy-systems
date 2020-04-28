################################
# DTmin optimisation
################################
# Sets & Parameters
reset;
set Time default {};        				# your time set from the MILP 
set Buildings default {};					# set of buildings
set MediumTempBuildings default {};			# set of buildings heated by medium temperature loop
set LowTempBuildings default {};			# set of buildings heated by low temperature loop

param Text{t in Time};  #external temperature - Part 1
param top{Time}; 		#your operating time from the MILP part
var Areabuilding >= 0.001; #defined .dat file.

param Tint 				:= 21; # internal set point temperature [C]
param mair 				:= 2.5; # m3/m2/h ASSUMPTION: ventilation flow per unit _building floor_ area
param Cpair 			:= 1.152; # kJ/m3K
param Uvent 			:= 0.025; # air-air HEX [kW/m2K]

param EPFLMediumT 		:= 65; #[degC]
param EPFLMediumOut 	:= 30; #[degC]

param CarnotEff 		:= 0.55; #assumption: carnot efficiency of heating heat pumps
param Cel 				:= 0.20; #[CHF/kWh] operating cost for buying electricity from the grid

param THPhighin 		:= 7; #[deg C] temperature of water coming from lake into the evaporator of the HP
param THPhighout 		:= 3; #[deg C] temperature of water coming from lake into the evaporator of the HP
param Cpwater			:= 4.18; #[kJ/kgC]

param i 				:= 0.06 ; #interest rate
param n 				:= 20; #[y] life-time
param FBMHE 			:= 4.74; #bare module factor of the heat exchanger
param INew 				:= 605.7; #chemical engineering plant cost index (2015)
param IRef 				:= 394.1; #chemical engineering plant cost index (2000)
param aHE 				:= 1200; #HE cost parameter
param bHE 				:= 0.6; #HE cost parameter
param eps				:= 1e-5; #Epsilon to avoid singularities

################################
# Variables

var Text_new{Time} 	<= 21; #[degC]
var Trelease{Time}	>= 0; #[degC]
var Qheating{Time} 	>= 0; #your heat demand from the MILP part, is now a variable.

var E{Time} 		>= 0; # [kW] electricity consumed by the heat pump (using pre-heated lake water)
var TLMCond 	 	>= 0.001; #[K] logarithmic mean temperature in the condensor of the heating HP (using pre-heated lake water)
var TLMEvap 		>= 0.001; # K] logarithmic mean temperature in the evaporator of the heating HP (using pre-heated lake water)
var Qevap{Time} 	>= 0; #[kW] heat extracted in the evaporator of the heating HP (using pre-heated lake water)
var Qcond{Time} 	>= 0; #[kW] heat delivered in the condensor of the heating HP (using pre-heated lake water)
var COP 			>= 0.001; #coefficient of performance of the heating HP (using pre-heated lake water)

var OPEX 			>= 0.001; #[CHF/year] operating cost
var IC 				>= 0.001; #[CHF] total investment cost
var CAPEX 			>= 0.001; #[CHF/year] annualized investment cost
var TC 				>= 0.001; #[CHF/year] total cost
var savings; #[CHF/year] total profit compare to the reference case
var Paybt 			>= 0.001; #[year] Time for this case to be profitable

var TLMEvapHP 		>= 0.001; #[K] logarithmic mean temperature in the evaporator of the heating HP (not using pre-heated lake water)

var TEvap 			>= 0.001; #[degC]
var Heat_Vent{Time} >= 0; #[kW]
var DTLNVent{Time} 	>= 0.001; #[degC]
var Area_Vent 		:= 40000	>= 0.001; #[m2]
var DTminVent 		>= 1; #[degC]
var theta_1{Time};	# Temperary variables to make DTLn calculation more readable
var theta_2{Time};

var Flow{Time} 		>= 0; #lake water entering free coling HEX [kg/s]
var MassEPFL{Time} 	>= 0; # MCp of EPFL heating system [KJ/(s degC)]
param reference_cost default 0;

# var Opex_positive{Time} >= 0;

#### Building dependent parameters

param irradiation{Time};# solar irradiation [kW/m2] at each time step									
param specElec{Buildings,Time} default 0;
param FloorArea{Buildings} default 0; #area [m2]
param k_th{Buildings} default 0; # thermal losses and ventilation coefficient in (kW/m2/K)
param U_env{Buildings} default 0; # overall heat transfer coefficient of the building envelope  (kW/m2/K)
param k_sun{Buildings} default 0;# solar radiation coefficient [−]
param share_q_e default 0.8; # share of internal gains from electricity [-]
param specQ_people{Buildings} default 0;# specific average internal gains from people [kW/m2]

################################
# Constraints
################################

## VENTILATION

subject to VariableHeatdemand {t in Time} : #Heat demand calculated as the sum of all buildings -> medium temperature
    Qheating[t] = if (Text[t] < 16) then 
		sum{b in MediumTempBuildings} max (0, FloorArea[b]*(U_env[b]*(Tint-Text[t])+mair/3600*Cpair*(Tint-Text_new[t])-k_sun[b]*irradiation[t]-specQ_people[b]-share_q_e*specElec[b, t]))
		else 
		0;

# total area of building
subject to buildingarea:
 Areabuilding = sum{b in MediumTempBuildings} (FloorArea[b]);

subject to Heat_Vent1 {t in Time}: #HEX heat load from one side;
	Heat_Vent[t] = mair/3600*Areabuilding*Cpair*(Tint - Trelease[t]); # kW

subject to Heat_Vent2 {t in Time}: #HEX heat load from the other side;
	Heat_Vent[t] = mair/3600*Areabuilding*Cpair*(Text_new[t] - Text[t]); # kW

subject to DTHX_1 {t in Time}:
	Trelease[t] <= Tint;

subject to DTHX_2 {t in Time}:
	Text_new[t] >= Text[t];

subject to Theta_1 {t in Time}:
	#theta_1[t] = (Trelease[t]-Text[t]) / log((Trelease[t] + 273) / (Text[t] + 273));
	theta_1[t] = (Trelease[t] - Text[t]);

subject to Theta_2 {t in Time}:
	#theta_2[t] = (Tint - Text_new[t]) / log((Tint + 273) / (Text_new[t] + 273));
	theta_2[t] = (Tint - Text_new[t]);

subject to DTLNVent1 {t in Time}: #DTLN ventilation -> pay attention to this value: why is it special?
	DTLNVent[t] = ((eps + theta_1[t]*theta_2[t]^2 + theta_2[t]*theta_1[t]^2)^(1/3))/2;

subject to Area_Vent1: #Area of ventilation HEX
	Area_Vent = max{t in Time} (Heat_Vent[t] / (DTLNVent[t]*Uvent));

subject to DTminVent1{t in Time}: #DTmin needed on one end of HEX
	DTminVent <= Trelease[t] - Text[t];

subject to DTminVent2{t in Time}: #DTmin needed on the other end of HEX 
    DTminVent <= Tint - Text_new[t];

## MASS BALANCE

# subject to Flows{t in Time}: #MCp of EPFL heating fluid calculation.
#     MassEPFL[t] = Qheating[t] / (EPFLMediumT-EPFLMediumOut); 

## MEETING HEATING DEMAND, ELECTRICAL CONSUMPTION

subject to QEvaporator{t in Time}: #water side of evaporator that takes flow from lake (Reference case)
	Qevap[t] = Flow[t] * Cpwater * (THPhighin - THPhighout);

subject to QCondensator{t in Time}: #EPFL side of condenser delivering heat to EFPL (Reference case)
	Qcond[t] = MassEPFL[t] * (EPFLMediumT - EPFLMediumOut);

subject to Electricity1{t in Time}: #the electricity consumed in the HP can be computed using the heat delivered and the heat extracted (Reference case)
	E[t] = Qcond[t] - Qevap[t];

subject to Electricity{t in Time}: #the electricity consumed in the HP can be computed using the heat delivered and the COP (Reference case)
	E[t] = Qcond[t] / COP;

subject to COPerformance: #the COP can be computed using the carnot efficiency and the logarithmic mean temperatures in the condensor and in the evaporator (Reference case)
	COP = CarnotEff * ( TLMCond / (TLMCond - TLMEvapHP));

subject to dTLMCondensor: #the logarithmic mean temperature on the condenser, using inlet and outlet temperatures. Note: should be in K (Reference case)
	TLMCond = (EPFLMediumT - EPFLMediumOut) /  log( (EPFLMediumT + 273) / (EPFLMediumOut + 273) );

subject to dTLMEvaporatorHP: #the logarithmic mean temperature can be computed using the inlet and outlet temperatures, Note: should be in K (Reference case)
	TLMEvapHP = (THPhighin - THPhighout) /  log( (THPhighin + 273) / (THPhighout + 273) );

## MEETING HEATING DEMAND, ELECTRICAL CONSUMPTION

subject to QEPFLausanne{t in Time}: #the heat demand of EPFL should be supplied by the the HP.
    Qcond[t] = Qheating[t]; #equation already used! problem?

subject to OPEXcost: #the operating cost can be computed using the electricity consumed in the HP.
# Only calc for time points when Qheating > 0?
# This doesn't converge -> reaches iter limit
	OPEX = sum{t in Time} (E[t] * top[t] * Cel);
	
subject to Icost:  #the investment cost can be computed using the area of the ventilation heat exchanegr
	IC = ((INew / IRef) * aHE * (Area_Vent+eps)^bHE) * FBMHE; #[CHF]

subject to CAPEXcost:
	CAPEX = IC * (i * (1 + i)^n) / ((1 + i)^n - 1); #[CHF/year]
	
subject to TCost: #the total cost can be computed using the operating and investment cost
	TC = OPEX + CAPEX;

# # subtract savings relative to reference case from cost to give net cost(+)/benefit(-)
# # TODO: define savings (i.e. multiply Heat_Vent, which reduces required Qcond, by the cost of supplying heat in the reference case -- could take average price of heat from Part 1, or assume boiler price)
 
 let reference_cost := 796197; #796197 is the OPEX from reference case

 subject to profits:
 	savings = reference_cost - TC; # [CHF]
 
# subject to payback_time:
# 	Paybt = IC / Profit; # [year]

# payback time must be within expected lifetime
#subject to payback_limit:
#	Paybt <= n;

################################
minimize obj : TC;
