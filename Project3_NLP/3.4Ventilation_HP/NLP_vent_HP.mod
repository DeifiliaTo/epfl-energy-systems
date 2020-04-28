################################
# DTmin optimisation
################################
# Sets & Parameters
reset;
set Time default {};        				# your time set from the MILP 
set Buildings default {};					# set of buildings
set MediumTempBuildings default {};			# set of buildings heated by medium temperature loop
set LowTempBuildings default {};			# set of buildings heated by low temperature loop

param Text{Time};  		#external temperature - Part 1 [deg C]
param top{Time}; 		#your operating time from the MILP part

param Tint 				:= 21; # internal set point temperature [deg C]
param mair 				:= 2.5; # m3/m2/h ASSUMPTION: ventilation flow per unit _building floor_ area
param Cpair 			:= 1.152; # kJ/m3K
param Uvent 			:= 0.025; # air-air HEX [kW/m2K]

param EPFLMediumT 		:= 65; #[deg C]
param EPFLMediumOut 	:= 30; #[deg C]

param CarnotEff 		:= 0.55; #assumption: carnot efficiency of heating heat pumps
param Cel 				:= 0.20; #[CHF/kWh] operating cost for buying electricity from the grid

param THPhighin 		:= 7; #[deg C] temperature of water coming from lake into the evaporator of the HP
param THPhighout 		:= 3; #[deg C] temperature of water coming from lake into the evaporator of the HP
param Cpwater			:= 4.18; #[kJ/kgC]
param Tcoolant			:= -29.6; #[deg C]

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

var Text_new{t in Time} >= Text[t]; # air Temperature after air-air HEX;
var Trelease{Time}  <= Tint; #[degC]
var Qheating{Time} 	>= 0; #your heat demand from the MILP part, is now a variable.

var E{Time} 		>= 0; # [kW] electricity consumed by the reference heat pump (using pre-heated lake water)
var TLMCond 	 	>= 0.001; #[K] logarithmic mean temperature in the condensor of the heating HP (using pre-heated lake water)
var TLMEvap 		>= 0.001; # K] logarithmic mean temperature in the evaporator of the heating HP (using pre-heated lake water)
var Qevap{Time} 	>= 0; #[kW] heat extracted in the evaporator of the heating HP (using pre-heated lake water)
var Qcond{Time} 	>= 0; #[kW] heat delivered in the condensor of the heating HP (using pre-heated lake water)
var COP				>= 0.001; #coefficient of performance of the heating HP (using pre-heated lake water)

var OPEX 			>= 0.001; #[CHF/year] operating cost
var CAPEX 			>= 0.001; #[CHF/year] annualized investment cost
var TIC				>= 0.001; #[CHF] total investment cost
var TC 				>= 0.001; #[CHF/year] total cost
var Profit			>= 0.001; #[CHF/year] Annual profit
var Paybt			>= 0.001; #[year] payback time

var TLMEvapHP 		>= 0.001; #[K] logarithmic mean temperature in the evaporator of the heating HP (not using pre-heated lake water)

var TEvap 			>= 0.001; #[deg C] Unused.
var Heat_Vent{Time} >= 0; #[kW]
var DTLNVent{Time} 	>= 1; #[K]
var Area_Vent 		>= 0.001; #[m2]
var DTminVent 		>= 0.001; #[C]
var theta_1{Time};	# Temperary variables to make DTLn calculation more readable
var theta_2{Time};

var Flow{Time} 		>= 0; #lake water entering free coling HEX [kg/s]
var MassEPFL{Time} 	>= 0; # MCp of EPFL heating system [KJ/(s degC)]

var Areabuilding		>= 0.001; #defined .dat file.

## Variables and parameters Air-Air HP

param Cref_hp				:= 3400;
param beta_hp				:= 0.85;
param BM_hp					:= 2;
param MS2000				:= 400;
param MS2017				:= 562;

var Trelease_2{Time}     	>=0; #release temperature (check drawing);    
var Tair_in{Time}        	<= 40; #lets assume EPFL cannot take ventilation above 40 degrees (safety)
var Cost_HP       		 	>=0; #HP cost 

var E_2{Time} 				>= 0; # kW] Electricity used in the Air-Air HP
var TLMCond_2{t in Time} 	>= 0.001; #Text[t]; #[K] logarithmic mean temperature in the condensor of the new HP 
var TLMEvapHP_2{Time} 		>= 0.001; # [K] logarithmic mean temperature in the evaporator of the new HP 
var Qevap_2{Time} 			>= 0; #[kW] heat extracted in the evaporator of the new HP 
var Qcond_2{Time} 			>= 0; #[kW] heat delivered in the condensor of the new HP 
var COP_2{Time} 			>= 0.001; #coefficient of performance of the new HP 


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
		sum{b in MediumTempBuildings} (max (0, FloorArea[b]*(U_env[b]*(Tint-Text[t]) + mair/3600*Cpair*(Tint-Tair_in[t])-k_sun[b]*irradiation[t]-specQ_people[b]-share_q_e*specElec[b, t])))
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

subject to DTHX_3{t in Time}:
	Trelease[t] >= Text[t];

subject to DTHX_4{t in Time}:
	Tint >= Text_new[t];

subject to Theta_1 {t in Time}:
	theta_1[t] = Trelease[t] - Text[t];

subject to Theta_2 {t in Time}:
	theta_2[t] = Tint - Text_new[t];

subject to DTLNVent1 {t in Time}: #DTLN ventilation -> pay attention to this value: why is it special?
	DTLNVent[t] = ((eps + theta_1[t]*theta_2[t]^2 + theta_2[t]*theta_1[t]^2)^(1/3))/2;

subject to Area_Vent1: #Area of ventilation HEX
	Area_Vent = max{t in Time} (Heat_Vent[t] / (DTLNVent[t]*Uvent));

subject to DTminVent1: #DTmin needed on one end of HEX
	DTminVent <= min{t in Time} (Trelease[t] - Text[t]);

subject to DTminVent2: #DTmin needed on the other end of HEX 
    DTminVent <= min{t in Time} (Tint - Text_new[t]);

## MASS BALANCE

subject to Flows{t in Time}: #MCp of EPFL heating fluid calculation.
	MassEPFL[t] = Qheating[t] / (EPFLMediumT-EPFLMediumOut);

## MEETING HEATING DEMAND, ELECTRICAL CONSUMPTION

subject to QEvaporator{t in Time}: #water side of evaporator that takes flow from Free cooling HEX
	Qevap[t] = Flow[t] * Cpwater * (THPhighin - THPhighout);

subject to QCondensator{t in Time}: #
	Qcond[t] = MassEPFL[t] * (EPFLMediumT - EPFLMediumOut); # From previous constraints, Qcond = Qheating

subject to Electricity1{t in Time}: #the electricity consumed in the HP can be computed using the heat delivered and the heat extracted (Reference case)
	E[t] = Qcond[t] - Qevap[t];

subject to Electricity{t in Time}: #the electricity consumed in the HP can be computed using the heat delivered and the COP (Reference case)
	E[t] = Qcond[t] / COP;

subject to COPerformance{t in Time}: #the COP can be computed using the carnot efficiency and the logarithmic mean temperatures in the condensor and in the evaporator (Reference case)
	COP = CarnotEff * ( TLMCond / (TLMCond - TLMEvapHP));

subject to dTLMCondensor: #the logarithmic mean temperature on the condenser, using inlet and outlet temperatures. Note: should be in K (Reference case)
	TLMCond * log( (EPFLMediumT + 273) / (EPFLMediumOut + 273) ) = (EPFLMediumT - EPFLMediumOut);

subject to dTLMEvaporatorHP: #the logarithmic mean temperature can be computed using the inlet and outlet temperatures, Note: should be in K (Reference case)
	TLMEvapHP * log( (THPhighin + 273) / (THPhighout + 273) ) = (THPhighin - THPhighout);


## Air Air HP

subject to temperature_gap{t in Time}: #relation between Text and Text_new;
 	Text_new[t] >= Text[t];

subject to temperature_gap2{t in Time}: #relation between Trelease and Trelease2;
	Trelease[t] >= Trelease_2[t];

subject to temperature_gap3{t in Time}: # relation between Tair_in and Text_new;
	Tair_in[t] >= Text_new[t];

subject to temperature_gap4{t in Time}: # relation between TLMCond_2 and TLMEvapHP_2;
	TLMCond_2[t] >= TLMEvapHP_2[t];

subject to temperature_gap5{t in Time}: # relation between TLMCond_2 and TLMEvapHP_2;
	TLMCond >= TLMEvapHP;

subject to QEvaporator_2{t in Time}: #Evaporator heat from air side
	Qevap_2[t] = mair * Cpair / 3600 * (Trelease[t] - Trelease_2[t]);

subject to QCondensator_2{t in Time}: #Condenser heat from air side
	Qcond_2[t] = mair * Cpair  / 3600 * (Tair_in[t] - Text_new[t]);

subject to Electricity_2{t in Time}: #the electricity consumed in the new HP can be computed using the heat delivered and the heat extracted
	E_2[t] = Qcond_2[t] - Qevap_2[t];

subject to Electricity_3{t in Time}: #the electricity consumed in the new HP can be computed using the heat delivered and the COP
	E_2[t] = Qcond_2[t] / COP_2[t];

subject to COPerformance_2{t in Time}: #the COP can be computed using the carnot efficiency and the logarithmic mean temperatures in the condensor and in the evaporator
	COP_2[t] * (TLMCond_2[t] - TLMEvapHP_2[t]) = CarnotEff * TLMCond_2[t];

subject to dTLMCondensor_2{t in Time}: #the logarithmic mean temperature in the new condenser. Note: should be in K
	TLMCond_2[t] * log( (Tair_in[t] + 273) / (Text_new[t] + 273)) = (Tair_in[t] - Text_new[t]);

subject to dTLMEvaporatorHP_2{t in Time}: #the logarithmic mean temperature in the new Evaporator, Note: should be in K
	TLMEvapHP_2[t] * log( (Trelease[t] + 273) / (Trelease_2[t] + 273)) = (Trelease[t] - Trelease_2[t]);


### IF SOME PROBLEMS OF COP and TEMPERATURE ARRIVE -> Remember that the log mean is always smaller than the aritmetic mean, but larger than the geometric mean. 
subject to dTLMCondensor_rule{t in Time}: # One of inequalities for Condenser
	TLMCond_2[t] <= (Tair_in[t] + Text_new[t]) / 2;

subject to dTLMCondensor_rule2{t in Time}: # The other inequality for Condenser
	TLMCond_2[t] >= ((Tair_in[t] + 273) * (Text_new[t] + 273))^(1/2) - 273;

subject to dTLMEvaporatorHP_rule{t in Time}: # One of inequalities for Evaporator
	TLMEvapHP_2[t] <= (Trelease[t] + Trelease_2[t]) / 2;

subject to dTLMEvaporatorHP_rule2{t in Time}: # The other inequality for Evaporator
	TLMEvapHP_2[t] >= ((Trelease[t] + 273) * (Trelease_2[t] + 273))^(1/2) - 273;


## COST CONSIDERATIONS

subject to Costs_HP {t in Time}: # new HP cost
	# VERIFY FORMULA! 
	Cost_HP = Cref_hp * (MS2017 / MS2000) * beta_hp;

subject to QEPFLausanne{t in Time}: #the heat demand of EPFL should be met;
	Qheating[t] + Qcond_2[t] = Qevap_2[t] + Heat_Vent[t];

subject to QEPFLausanne_2{t in Time}: #the heat demand of EPFL should be met;
	Qheating[t] = Qcond[t];

subject to OPEXcost: #the operating cost can be computed using the electricity consumed in the two heat pumps
	OPEX = sum{t in Time} ((E_2[t]+E[t]) * top[t] * Cel);
	
subject to TICost:
	TIC = Cost_HP * BM_hp + ((INew / IRef) * aHE * (Area_Vent)^bHE) * FBMHE; #[CHF]

subject to CAPEXcost: #the investment cost can be computed using the area of ventilation HEX and new HP and the annuity factor
	CAPEX = TIC *(i * (1 + i)^n) / ((1 + i)^n - 1);

subject to TCost: #the total cost can be computed using the operating and investment cost
	TC = OPEX + CAPEX;
	

################################
minimize obj : TC;
