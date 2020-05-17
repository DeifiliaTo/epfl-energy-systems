/*---------------------------------------------------------------------------------------------------------------------------------------
Course: Modelling and optimisation of energy systems course spring semester 2018
EPFL Campus energ system optimization
IPESE, EPFL
---------------------------------------------------------------------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------------------------------------------------------------------
This is a model which will be the base of the project. It has the definition of the generic sets, parameters and variables. It also
includes equations that apply to the whole system. Depending on the modifications and additions to the model, the constraints are 
subject to change.
---------------------------------------------------------------------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------------------------------------------------------------------
Generic Sets
---------------------------------------------------------------------------------------------------------------------------------------*/
set Buildings default {};										# set of buildings
set MediumTempBuildings default {};								# set of buildings heated by medium temperature loop
set LowTempBuildings default {};								# set of buildings heated by low temperature loop
set Time default {}; 											# time segments of the problem 
set Technologies default {};									# technologies to provide heating cooling and elec
set Grids default {};											# grid units to buy resources (fuel, electricity etc.)
set Utilities := Technologies union Grids;						# combination of technologies and grids
set Layers default {};											# resources to provide fuel, elec, etc.
set HeatingLevel default {};									# low and medium temlerature levels
set UtilityType default {};										# type of the utility: heating, cooling, elec	
set UtilitiesOfType{UtilityType} default {};					# utilities assigned to their respective utility type
set UtilitiesOfLayer{Layers} default {};
set Improvements default {};

/*---------------------------------------------------------------------------------------------------------------------------------------
Generic Parameters
---------------------------------------------------------------------------------------------------------------------------------------*/
param dTmin default 5;											# minimum temperature difference in the heat exchangers
param top{Time};												# operating time [h] of each time step
param Theating{HeatingLevel};									# temperatue [C] of the heating levels
param irradiation{Time};										# solar irradiation [kW/m2] at each time step
param roofArea default 15500;									# available roof area for PV installation
param refSize default 1000;										# reference size of the utilities
param Text{t in Time};  										# ambient temperature [C]
param Tint default 21;											# internal set point temperature [C]
param specElec{Buildings,Time} default 0;						# specific  electricity consumption [kW/m2]
#param Tlake{Time}												# lake temperature [C]
param Tlake{t in Time};											# lake temperature [�C]


/*---------------------------------------------------------------------------------------------------------------------------------------
Improvement Parameters
---------------------------------------------------------------------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------------------------------------------------------------------
DC Parameters
---------------------------------------------------------------------------------------------------------------------------------------*/
param TDCin 		:= 60; #[deg C] temperature of air coming from data center into the heat recovery HE
param UDC 			:= 0.15; #[kW/(m2 K)] air-water heat transfer coefficient
param HeatDC 		:= 574; #amount of heat to be removed from data center (kW)
param Tret 			:= 17; #temperature of air entering DC
param MassDC 		:= HeatDC/(TDCin-Tret); #[KJ/(s degC)] MCp of air in DC

################################
##Variables

var TDCout{Time} 	>= 0.001; #[deg C] temperature of air coming from data center out of the heat recovery HE
var AHEDC 			>= 0.001; #[m2] area of heat recovery heat exchanger
var dTLMDC{Time} 	>= 0.001; #logarithmic mean temperature difference in the heat recovery heat exchanger
var TRadin{Time} 	>= 30.01; #[deg C]

var E{Improvements, Time} 		>= 0.001; #[kW] electricity consumed by the heat pump (using pre-heated lake water)
var TLMCond{Improvements, Time} 	>= 0.001; #[K] logarithmic mean temperature in the condensor of the heating HP (using pre-heated lake water)
var Qevap{Improvements, Time} 	>= 0.001; #[kW] heat extracted in the evaporator of the heating HP (using pre-heated lake water)
var Qcond{Improvements, Time} 	>= 0.001; #[kW] heat delivered in the condensor of the heating HP (using pre-heated lake water)
var COP{Improvements, Time} 		>= 0.001; #coefficient of performance of the heating HP (using pre-heated lake water)

var OPEX{Improvements} 			>= 0.001; #[CHF/year] operating cost
var IC{Improvements} 			>= 0.001; #[CHF] total investment cost
var CAPEX{Improvements} 		>= 0.001; #[CHF/year] annualized investment cost
var TC{Improvements} 			>= 0.001; #[CHF/year] total cost

var TLMEvapHP{Improvements, Time} >= 0.001; #[K] logarithmic mean temperature in the evaporator of the heating HP

var THPin{Time} 	>= 7;
var Qfree{Time} 	>= 0.001; #free cooling heat; makes sure DC air is cooled down.
var Flow{Improvements, Time} 	 >= 0.001; #lake water entering free cooling HEX
var MassEPFL{Improvements, Time} >= 0.001; # MCp of EPFL heating system [KJ/(s degC)]

/*---------------------------------------------------------------------------------------------------------------------------------------
Vent Parameters
---------------------------------------------------------------------------------------------------------------------------------------*/

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
param eps				:= 1e-3; #Epsilon to avoid singularities

################################
# Variables

var Text_new{Time} 	<= 21; #[degC]
var Trelease{Time}	>= 0; #[degC]


#var TLMCond 	 	>= 0.001; #[K] logarithmic mean temperature in the condensor of the heating HP (using pre-heated lake water)
var TLMEvap 		>= 0.001; # K] logarithmic mean temperature in the evaporator of the heating HP (using pre-heated lake water)


#var TLMEvapHP 		>= 0.001; #[K] logarithmic mean temperature in the evaporator of the heating HP (not using pre-heated lake water)

var TEvap 			>= 0.001; #[degC]
var Areabuilding 		>= 0.001; #defined .dat file.

var Heat_Vent{Time} := 1000 >= 0; #[kW]
var DTLNVent{Time} 	>= 0.001; #[degC]
var Area_Vent 		:=0 >= 0.001; #[m2]
var DTminVent 		>= 1; #[degC]
var theta_1{Time};	# Temperary variables to make DTLn calculation more readable
var theta_2{Time};
var Qheating_vent{Time};

/*---------------------------------------------------------------------------------------------------------------------------------------
Calculation of heating demand
---------------------------------------------------------------------------------------------------------------------------------------*/
param FloorArea{Buildings} default 0;
param k_th{Buildings} default 0;								# thermal losses and ventilation coefficient in (kW/m2/K)
param U_env{Buildings} default 0;
param k_sun{Buildings} default 0;								# solar radiation coefficient [−]
param share_q_e default 0.8; 									# share of internal gains from electricity [-]
param specQ_people{Buildings} default 0;						# specific average internal gains from people [kW/m2]
param Qheating{b in Buildings, t in Time} :=
		if Text[t] < 16  then 
			max(FloorArea[b]*(k_th[b]*(Tint-Text[t]) - k_sun[b]*irradiation[t]-specQ_people[b] - share_q_e*specElec[b,t]),0)
		else
			0
;


param Qheatingdemand{h in HeatingLevel, t in Time} :=
	if h == 'MediumT' then
		sum{b in MediumTempBuildings} Qheating[b,t]        		
	else
		sum{b in LowTempBuildings} Qheating[b,t]				
	;

/*---------------------------------------------------------------------------------------------------------------------------------------
Calculation of electricity demand
---------------------------------------------------------------------------------------------------------------------------------------*/

param Ebuilding{b in Buildings, t in Time} :=
	specElec[b,t] * FloorArea[b];
param Edemand{t in Time} :=
	sum{b in Buildings} Ebuilding[b,t];

/*---------------------------------------------------------------------------------------------------------------------------------------
Utility paremeters
---------------------------------------------------------------------------------------------------------------------------------------*/
# minimum temperature of the heating technologies [C]
param Tminheating{UtilitiesOfType['Heating']} default 0;

# reference flow of the heating and cooling [kW]
param Qheatingsupply{UtilitiesOfType['Heating']} default 0;

# reference flow of the resources (elec, natgas etc) [kW] [m3/s] [kg/s]
param Flowin{l in Layers,u in UtilitiesOfLayer[l]} default 0;
param Flowout{l in Layers,u in UtilitiesOfLayer[l]} default 0;

# minimum and maximum scaling factors of the utilities
param Fmin{Utilities} default 0.001;
param Fmax{Utilities} default 1000;

#emission factors [kg-CO2/kWh]
param c_ng   := 0.27;	#Emission factor of natural gas
param c_elec := 0.113;	#Emission factor of electricity

/*---------------------------------------------------------------------------------------------------------------------------------------
Utility variables
---------------------------------------------------------------------------------------------------------------------------------------*/
var use{Utilities} binary;										# binary variable to decide if a utility is used or not
var use_t{Utilities, Time} binary;								# binary variable to decide if a utility is used or not at time t
var mult{Utilities}>=0;											# continuous variable to decide the size of the utility
var mult_t{Utilities, Time}>=0;									# continuous variable to decide the size of the utility at time t

/*---------------------------------------------------------------------------------------------------------------------------------------
Resource variables
---------------------------------------------------------------------------------------------------------------------------------------*/
var FlowInUnit{Layers,Utilities,Time} >= 0;						# continuous variables to decide the size of the resource demand
var FlowOutUnit{Layers,Utilities,Time} >= 0;

/*---------------------------------------------------------------------------------------------------------------------------------------
Resource variables
---------------------------------------------------------------------------------------------------------------------------------------*/
var use_recovery{Improvements} := 0 binary;								# binary variable to decide if DC is used or not
var heat_recovery{Improvements, Time} :=0 >=0;
var op_recovery{Improvements, Time}   :=0 >=0;
var cap_recovery{Improvements} 		  :=0 >=0;

/*---------------------------------------------------------------------------------------------------------------------------------------
Utility sizing constraints
---------------------------------------------------------------------------------------------------------------------------------------*/
subject to size_cstr1{u in Utilities, t in Time}: 				# coupling the binary variable with the continuous variable 1
	Fmin[u]*use_t[u,t] <= mult_t[u, t];


subject to size_cstr2{u in Utilities, t in Time}:				# coupling the binary variable with the continuous variable 2
	mult_t[u, t] <= Fmax[u]*use_t[u, t];


subject to size_cstr3{u in Utilities, t in Time}: 				# coupling the binary variable with the continuous variable 1
	Fmin[u]*use[u] <= mult[u];


subject to size_cstr4{u in Utilities, t in Time}:				# coupling the binary variable with the continuous variable 2
	mult[u] <= Fmax[u]*use[u];


subject to size_cstr5{u in Utilities, t in Time}: 				# size in each time should be less than the nominal size
	mult_t[u, t] <= mult[u];


/*---------------------------------------------------------------------------------------------------------------------------------------
Heating balance constraints: demand = supply
---------------------------------------------------------------------------------------------------------------------------------------*/
# heating balance: demand = supply
var mult_heating_t{UtilitiesOfType['Heating'], Time, HeatingLevel} >= 0;
subject to LT_balance{t in Time}:
	Qheatingdemand['LowT',t] = sum{u in UtilitiesOfType['Heating']: Tminheating[u] >= Theating['LowT'] + dTmin} (Qheatingsupply[u] * mult_heating_t[u,t,'LowT']);
subject to MT_balance{t in Time}:
	Qheatingdemand['MediumT',t] = sum{u in UtilitiesOfType['Heating']: Tminheating[u] >= Theating['MediumT'] + dTmin} (Qheatingsupply[u] * mult_heating_t[u,t,'MediumT']) 
	- sum{u in Improvements} heat_recovery[u,t] * use_recovery[u]
	;
subject to heating_mult_cstr{u in UtilitiesOfType['Heating'], t in Time}:
	mult_t[u,t] = sum{h in HeatingLevel} mult_heating_t[u,t,h];
subject to zero_constraint1{t in Time}:
	sum{u in UtilitiesOfType['Heating']: Tminheating[u] <= Theating['MediumT'] + dTmin} mult_heating_t[u,t,'MediumT'] = 0;
subject to zero_constraint2{t in Time}:
	sum{u in UtilitiesOfType['Heating']: Tminheating[u] <= Theating['LowT'] + dTmin} mult_heating_t[u,t,'LowT'] = 0;

/*---------------------------------------------------------------------------------------------------------------------------------------
Resource balance constraints (except for electricity): flowin = flowout
---------------------------------------------------------------------------------------------------------------------------------------*/
subject to inflow_cstr {l in Layers, u in UtilitiesOfLayer[l] diff {"HP1stageLT","HP1stageMT"}, t in Time}:
    FlowInUnit[l, u, t] = mult_t[u,t] * Flowin[l,u];
subject to outflow_cstr {l in Layers, u in UtilitiesOfLayer[l] diff {"HP1stageLT","HP1stageMT"}, t in Time}:
	FlowOutUnit[l, u, t] = mult_t[u,t] * Flowout[l,u]; 
subject to balance_cstr {l in Layers, t in Time: l != 'Electricity'}:
	sum{u in UtilitiesOfLayer[l]} FlowInUnit[l,u,t] = sum{u in UtilitiesOfLayer[l]} FlowOutUnit[l,u,t];

/*---------------------------------------------------------------------------------------------------------------------------------------
Electricity balance constraints: building demand + utility cons = utility supply 
---------------------------------------------------------------------------------------------------------------------------------------*/
subject to electricity_balance{t in Time}:
	Edemand[t] + sum{u in UtilitiesOfType['ElectricityCons']} FlowInUnit['Electricity',u,t] = sum{u in UtilitiesOfType['ElectricitySup']} FlowOutUnit['Electricity',u,t];

/*---------------------------------------------------------------------------------------------------------------------------------------
Cost parameters and constraints
---------------------------------------------------------------------------------------------------------------------------------------*/
param c_spec{Grids} default 0;									# specific cost of the resource [CHF/kWh], [CHF/kg] or [CHF/m3]
param cop2g{g in Grids} = c_spec[g] * refSize;					# mult_t dependent cost of the reosurce [CHF/h]

param cop1t{Technologies} default 0;							# fixed cost of the technology [CHF/h]
param cop2t{Technologies} default 0;							# variable cost of the technology [CHF/h]

param cop1{u in Utilities} = 									# fixed cost of the utility [CHF/h]
	if (exists{g in Grids} (g = u)) then 
		0 
	else 
		cop1t[u]
	;
param cop2{u in Utilities} = 									# variable cost of the utility [CHF/h]
	if (exists{g in Grids} (g = u)) then 
		cop2g[u] 
	else 
		cop2t[u]
	;
param cinv1{t in Technologies} default 0;						# fixed investment cost of the utility [CHF/year]
param cinv2{t in Technologies} default 0;						# variable investment cost of the utility [CHF/year]

# variable and constraint for operating cost calculation [CHF/year]
var OpCost;
subject to oc_cstr:
	OpCost = sum {u in Utilities, t in Time} (cop1[u] * use_t[u,t] + cop2[u] * mult_t[u,t]) * top[t]	;

# variable and constraint for investment cost calculation [CHF/year]
var InvCost;
subject to ic_cstr:
	InvCost = sum{tc in Technologies} (cinv1[tc] * use[tc] + cinv2[tc] * mult[tc]);

# CO2 emissions calculations [kg-CO2eq]
var CO2;
subject to CO2_emission:
	CO2 = sum{t in Time}((c_ng * FlowOutUnit['Natgas','NatGasGrid',t] + c_elec * FlowOutUnit['Electricity','ElecGridBuy',t])*top[t])	;

################################
# Vent Model
################################
subject to VariableHeatdemand {t in Time: t != 5} : #Heat demand calculated as the sum of all buildings -> medium temperature
    Qheating_vent[t] = sum{b in MediumTempBuildings} max (0, FloorArea[b]*(U_env[b]*(Tint-Text[t])+mair/3600*Cpair*(Tint-Text_new[t])-k_sun[b]*irradiation[t]-specQ_people[b]-share_q_e*specElec[b, t]));

# total area of building
subject to buildingarea:
	Areabuilding = sum{b in MediumTempBuildings} (FloorArea[b]);

subject to Heat_Vent1 {t in Time}: #HEX heat load from one side;
	Heat_Vent[t] = mair/3600*1.15*Areabuilding*Cpair*(Tint - Trelease[t]); # kW

subject to Heat_Vent2 {t in Time}: #HEX heat load from the other side;
	Heat_Vent[t] = mair/3600*Areabuilding*Cpair*(Text_new[t] - Text[t]); # kW

subject to DTHX_1 {t in Time}:
	Trelease[t] + eps <= Tint;

subject to DTHX_2 {t in Time}:
	Text_new[t] >= Text[t] + eps ;

subject to Theta_1 {t in Time}:
	theta_1[t] = (Trelease[t] - Text[t]);

subject to Theta_2 {t in Time}:
	theta_2[t] = (Tint - Text_new[t]);

subject to DTLNVent1 {t in Time}: #DTLN ventilation -> pay attention to this value: why is it special?
	DTLNVent[t] * log(theta_1[t] / theta_2[t]) = (theta_1[t] - theta_2[t]);

subject to Area_Vent1max{t in Time}: #Area of ventilation HEX
	(Area_Vent + eps) * DTLNVent[t] * Uvent >= Heat_Vent[t];

subject to DTminVent1{t in Time}: #DTmin needed on one end of HEX
	DTminVent <= Trelease[t] - Text[t];

subject to DTminVent2{t in Time}: #DTmin needed on the other end of HEX 
    DTminVent <= Tint - Text_new[t];

## MAIN HEATING HEAT PUMP

subject to QEvaporator{t in Time}: #water side of evaporator that takes flow from lake (Reference case)
	Qevap['Vent', t] = Flow['Vent', t] * Cpwater * (THPhighin - THPhighout);

subject to QCondensator{t in Time}: #EPFL side of condenser delivering heat to EFPL (Reference case)
	Qcond['Vent', t] = MassEPFL['Vent', t] * (EPFLMediumT - EPFLMediumOut);

subject to Electricity1{t in Time}: #the electricity consumed in the HP can be computed using the heat delivered and the heat extracted (Reference case)
	E['Vent', t] = Qcond['Vent', t] - Qevap['Vent', t];

subject to Electricity{t in Time}: #the electricity consumed in the HP can be computed using the heat delivered and the COP (Reference case)
	E['Vent', t] * COP['Vent', t] = Qcond['Vent', t];

subject to COPerformance{t in Time}: #the COP can be computed using the carnot efficiency and the logarithmic mean temperatures in the condensor and in the evaporator (Reference case)
	COP['Vent', t] * (TLMCond['Vent', t] - TLMEvapHP['Vent', t]) = CarnotEff * TLMCond['Vent',t ];

subject to dTLMCondensor{t in Time}: #the logarithmic mean temperature on the condenser, using inlet and outlet temperatures. Note: should be in K (Reference case)
	TLMCond['Vent', t] * log( (EPFLMediumT + 273) / (EPFLMediumOut + 273) ) = (EPFLMediumT - EPFLMediumOut);

subject to dTLMEvaporatorHP{t in Time}: #the logarithmic mean temperature can be computed using the inlet and outlet temperatures, Note: should be in K (Reference case)
	TLMEvapHP['Vent', t] * log( (THPhighin + 273) / (THPhighout + 273) ) = (THPhighin - THPhighout);

## MEETING HEATING DEMAND, ELECTRICAL CONSUMPTION

subject to QEPFLausanne{t in Time: t != 5}: #the heat demand of EPFL should be supplied by the the HP.
Qcond['Vent', t] = heat_recovery['Vent', t]; #equation already used! problem?

/*---------------------------------------------------------------------------------------------------------------------------------------
Objective function
---------------------------------------------------------------------------------------------------------------------------------------*/
minimize Totalcost:InvCost + OpCost;





