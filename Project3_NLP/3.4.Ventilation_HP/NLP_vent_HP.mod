################################
# DTmin optimisation
################################
# Sets & Parameters
reset;
set Time default {};        				#your time set from the MILP 
set Buildings default {};					# set of buildings
set MediumTempBuildings default {};			# set of buildings heated by medium temperature loop
set LowTempBuildings default {};			# set of buildings heated by low temperature loop


param Text{t in Time};  #external temperature - Part 1
param top{Time}; 		#your operating time from the MILP part
param Areabuilding		>=0.001; #defined .dat file.

param Tint 				:= 21; # internal set point temperature [C]
param mair 				:= 2.5; # m3/m2/h
param Cpair 			:= 1.152; # kJ/m3K
param Uvent 			:= 0.025; # air-air HEX

param EPFLMediumT 		:= 65; #[degC]
param EPFLMediumOut 	:= 30; 

param CarnotEff 		:= 0.55; #assumption: carnot efficiency of heating heat pumps
param Cel 				:= 0.20; #[CHF/kWh] operating cost for buying electricity from the grid

param THPhighin 		:= 7; #[deg C] temperature of water coming from lake into the evaporator of the HP
param THPhighout 		:= 3; #[deg C] temperature of water coming from lake into the evaporator of the HP
param Cpwater           := 4.18; #[kJ/kgC]

param i 				:= 0.06 ; #interest rate
param n 				:= 20; #[y] life-time
param FBMHE 			:= 4.74; #bare module factor of the heat exchanger
param INew 				:= 605.7; #chemical engineering plant cost index (2015)
param IRef 				:= 394.1; #chemical engineering plant cost index (2000)
param aHE 				:= 1200; #HE cost parameter
param bHE 				:= 0.6; #HE cost parameter

################################
# Variables

var Text_new{t in Time} >= Text[t]; # air Temperature after air-air HEX;
var Trelease{Time}  >= 0; #[degC]
var Qheating{Time} 	>= 0; #your heat demand from the MILP part, will become a variable in the case of heat recovery from air ventilation

var E{Time} 		>= 0; # [kW] electricity consumed by the reference heat pump (using pre-heated lake water)
var TLMCond 	 	>= 0.001; #[K] logarithmic mean temperature in the condensor of the heating HP (using pre-heated lake water)
var TLMEvap 		>= 0.001; # K] logarithmic mean temperature in the evaporator of the heating HP (using pre-heated lake water)
var Qevap{Time} 	>= 0; #[kW] heat extracted in the evaporator of the heating HP (using pre-heated lake water)
var Qcond{Time} 	>= 0; #[kW] heat delivered in the condensor of the heating HP (using pre-heated lake water)
var COP{Time} 		>= 0.001; #coefficient of performance of the heating HP (using pre-heated lake water)

var OPEX 			>= 0.001; #[CHF/year] operating cost
var CAPEX 			>= 0.001; #[CHF/year] annualized investment cost
var TIC				>= 0.001; #[CHF] total investment cost
var TC 				>= 0.001; #[CHF/year] total cost
var Profit			>= 0.001; #[CHF/year] Annual profit
var Paybt			>= 0.001; #[year] payback time

var TLMEvapHP 		>= 0.001; #[K] logarithmic mean temperature in the evaporator of the heating HP (not using pre-heated lake water

var TEvap 			>= 0.001; #[degC]
var Heat_Vent{Time} >= 0; #[kW]
var DTLNVent{Time} 	>= 0.001; #[degC]
var Area_Vent 		>= 0.001; #[m2]
var DTminVent 		>= 2; #[degC]

var Flow{Time} 		>= 0; #lake water entering free coling HEX
var MassEPFL{Time} 	>= 0; # MCp of EPFL heating system [KJ/(s degC)]

var Uenv{Buildings} >= 0; # overall heat transfer coefficient of the building envelope 

## Variables and parameters Air-Air HP

param Cref_hp				:= 3400;
param beta_hp				:= 0.85;
param BM_hp					:= 2;
param MS2000				:= 400;
param MS2017				:= 562;

var Trelease_2{Time}     	>=0; #release temperature (check drawing);    
var Tair_in{Time}        	<= 40; #lets assume EPFL cannot take ventilation above 40 degrees (safety)
var Cost_HP       		 	>=0; #HP cost 

var E_2{Time} 				>= 0.01; # kW] Electricity used in the Air-Air HP
var TLMCond_2{t in Time} 	>= Text[t]; #[K] logarithmic mean temperature in the condensor of the new HP 
var TLMEvapHP_2{Time} 		>= 0.001; # K] logarithmic mean temperature in the evaporator of the new HP 
var Qevap_2{Time} 			>= 0; #[kW] heat extracted in the evaporator of the new HP 
var Qcond_2{Time} 			>= 0; #[kW] heat delivered in the condensor of the new HP 
var COP_2{Time} 			>= 0; #coefficient of performance of the new HP 


#### Building dependent parameters

param irradiation{Time};# solar irradiation [kW/m2] at each time step									
param specElec{Buildings,Time} default 0;
param FloorArea{Buildings} default 0; #area [m2]
param k_th{Buildings} default 0; # thermal losses and ventilation coefficient in (kW/m2/K)
param k_sun{Buildings} default 0;# solar radiation coefficient [−]
param share_q_e default 0.8; # share of internal gains from electricity [-]
param specQ_people{Buildings} default 0;# specific average internal gains from people [kW/m2]

################################
# Constraints
################################

## VENTILATION

subject to overallHeatTransfer{b in MediumTempBuildings}: # Uenv calculation for each building based on k_th and mass of air used
	Uenv[b] = k_th[b] - mair*Cpair;

subject to VariableHeatdemand {t in Time} : #Heat demand calculated as the sum of all buildings -> medium temperature
	Qheating[t] = sum{b in MediumTempBuildings} (FloorArea[b]*(Uenv[b]*(Tint-Text[t])+mair*Cpair*(Tint-Tair_in[t])-k_sun[b]*irradiation[t]-specQ_people[b])-specElec[b, t]);
	
subject to Heat_Vent1 {t in Time}: #HEX heat load from one side;
	Heat_Vent[t] = mair*Cpair*(Tint - Trelease[t]);  

subject to Heat_Vent2 {t in Time}: #HEX heat load from the other side;
	Heat_Vent[t] = mair*Cpair*(Text_new[t] - Text[t]);

subject to DTLNVent1 {t in Time}: #DTLN ventilation -> pay attention to this value: why is it special?
	DTLNVent[t] = ((Tint-Text_new[t])-(Trelease[t]-Text[t]))/log( (Tint-Text_new[t])/(Trelease[t]-Text[t]));
	#not the good formula

subject to Area_Vent1 {t in Time}: #Area of ventilation HEX
	Area_Vent = Heat_Vent[t] / (DTLNVent[t]*Uvent);

subject to DTminVent1 {t in Time}: #DTmin needed on one side of HEX
	DTminVent = abs(Trelease[t] - Text[t]);

subject to DTminVent2 {t in Time}: #DTmin needed on the other side of HEX 
	DTminVent = abs(Tint - Text_new[t]);


################################
# Constraints
################################

## MASS BALANCE

subject to Flows{t in Time}: #MCp of EPFL heating fluid calculation.
	MassEPFL[t] = Qheating[t] / (EPFLMediumT-EPFLMediumOut);

## MEETING HEATING DEMAND, ELECTRICAL CONSUMPTION

subject to QEvaporator{t in Time}: #water side of evaporator that takes flow from Free cooling HEX
	Qevap[t] = Flow[t] * Cpwater * (THPhighin - THPhighout);

subject to QCondensator{t in Time}: #
	Qcond[t] = MassEPFL[t] * (EPFLMediumT - EPFLMediumOut);

subject to Electricity{t in Time}: #the electricity consumed in the HP can be computed using the heat delivered and the heat extracted (Reference case)
	E[t] = Qcond[t] - Qevap[t];

subject to Electricity_1{t in Time}: #the electricity consumed in the HP can be computed using the heat delivered and the COP (Reference case)
	E[t] = Qcond[t] / COP[t];

subject to COPerformance{t in Time}: #the COP can be computed using the carnot efficiency and the logarithmic mean temperatures in the condensor and in the evaporator
	COP[t] = CarnotEff * ( TLMCond / (TLMCond - TLMEvapHP));

subject to dTLMCondensor{t in Time}: #the logarithmic mean temperature on the condenser, using inlet and outlet temperatures. Note: should be in K (Reference case)
	TLMCond = (EPFLMediumT - EPFLMediumOut) /  log( (EPFLMediumT + 273) / (EPFLMediumOut + 273) );

subject to dTLMEvaporatorHP{t in Time}: #the logarithmic mean temperature can be computed using the inlet and outlet temperatures, Note: should be in K (Reference case)
	TLMEvapHP = (THPhighin - THPhighout) /  log( (THPhighin + 273) / (THPhighout + 273) );


## Air Air HP

subject to temperature_gap{t in Time}: #relation between Text and Text_new;
 	

subject to temperature_gap2{t in Time}: #relation between Trelease and Trelease2;


subject to temperature_gap3{t in Time}: # relation between Tair_in and Text_new;


subject to temperature_gap4{t in Time}: # relation between TLMCond_2 and TLMEvapHP_2;


 subject to QEvaporator_2{t in Time}: #Evaporator heat from air side
	Qevap_2[t] = mair * Cpair * (Trelease[t] - Trelease_2[t]);

subject to QCondensator_2{t in Time}: #Condeser heat from air side
	Qcond_2[t] = mair * Cpair * (Tair_in[t] - Tex_new[t]);

subject to Electricity_2{t in Time}: #the electricity consumed in the new HP can be computed using the heat delivered and the heat extracted
	E_2[t] = Qcond_2[t] - Qevap_2[t];

subject to Electricity_3{t in Time}: #the electricity consumed in the new HP can be computed using the heat delivered and the COP
	E_2[t] = Qcond_2[t] / COP_2[t];

subject to COPerformance_2{t in Time}: #the COP can be computed using the carnot efficiency and the logarithmic mean temperatures in the condensor and in the evaporator
	COP_2[t] = CarnotEff * ( TLMCond_2 / (TLMCond_2 - TLMEvapHP_2));

subject to dTLMCondensor_2{t in Time}: #the logarithmic mean temperature in the new condenser. Note: should be in K
	TLMCond_2 = (Tair_in[t] - Tex_new[t] ) /  log( (Tair_in[t]+ 273) / (Tex_new[t] + 273) );

subject to dTLMEvaporatorHP_2{t in Time}: #the logarithmic mean temperature in the new Evaporator, Note: should be in K
	TLMEvapHP_2 = (Trelease[t] - Trelease_2[t]) /  log( (Trelease[t] + 273) / (Trelease_2[t] + 273) );


## IF SOME PROBLEMS OF COP and TEMPERATURE ARRIVE -> Remember that the log mean is always smaller than the aritmetic mean, but larger than the geometric mean. 
subject to dTLMCondensor_rule{t in Time}: # One of inequalities for Condenser


subject to dTLMCondensor_rule2{t in Time}: # The other inequality for Condenser


subject to dTLMEvaporatorHP_rule{t in Time}: # One of inequalities for Evaporator


subject to dTLMEvaporatorHP_rule2{t in Time}: # The other inequality for Evaporator



## COST CONSIDERATIONS

subject to Costs_HP {t in Time}: # new HP cost
	# VERIFY FORMULA! Cost_HP = Cref_hp * (MS2017 / MS2000) * beta_hp;

subject to QEPFLausanne{t in Time}: #the heat demand of EPFL should be met;
	Qheating[t] = Qcond[t]; #equation already used! problem?

subject to OPEXcost: #the operating cost can be computed using the electricity consumed in the two heat pumps
	OPEX = sum{t in Time} ((E_2[t]+E[t]) * top[t] * Cel);
	
subject to TICost:
	TIC = Cost_HP * BM_hp + ((INew / IRef) * aHE * (Area_Vent)^bHE) * FBMHE; #[CHF]

subject to CAPEXcost: #the investment cost can be computed using the area of ventilation HEX and new HP and the annuity factor
	CAPEX = TIC *(i * (1 + i)^n) / ((1 + i)^n - 1);

subject to TCost: #the total cost can be computed using the operating and investment cost
	TC= OPEX + CAPEX;
	
subject to Profitcost:
	#Profit= OPEX_ref - TC ; # [CHF/year] How to express OPEX of the reference case (3.1)?

subject to Paybbacktime:	
	Paybt = TIC / Profit # [year]

################################
minimize obj : OPEX; #WHY??