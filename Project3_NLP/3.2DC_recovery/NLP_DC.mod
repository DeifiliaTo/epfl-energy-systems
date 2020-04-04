reset;
################################
# DTmin optimisation
################################
# Sets & Parameters

set Time default {}; #your time set from the MILP part
param Qheating{Time}; #your heat demand from the MILP part, only Medium temperature heat (65 deg C) [kW or kWh]
param top{Time}; #your operating time from the MILP part [h]

param EPFLMediumT 	:= 65; #[degC] - desired temperature high temperature loop
param EPFLMediumOut := 30; # temperature of return low temperature loop

param TDCin 		:= 60; #[deg C] temperature of air coming from data center into the heat recovery HE
param UDC 			:= 0.15; #[kW/(m2 K)] air-water heat transfer coefficient

param CarnotEff 	:= 0.55; #assumption: carnot efficiency of heating heat pumps
param Cel 			:= 0.20; #[CHF/kWh] operating cost for buying electricity from the grid

param THPhighin 	:= 7; #[deg C] temperature of water coming from lake into the evaporator of the HP
param THPhighout 	:= 3; #[deg C] temperature of water coming from lake into the evaporator of the HP

param i 			:= 0.05 ; #interest rate
param n 			:= 20; #[y] life-time
param FBMHE 		:= 4.74; #bare module factor of the heat exchanger
param INew 			:= 605.7; #chemical engineering plant cost index (2015)
param IRef 			:= 394.1; #chemical engineering plant cost index (2000)
param aHE 			:= 800; #HE cost parameter
param bHE 			:= 0.6; #HE cost parameter

param HeatDC 		:= 574; #amount of heat to be removed from data center (kW)
param Tret 			:= 17; #temperature of air entering DC
param MassDC 		:= HeatDC/(TDCin-Tret); #[KJ/(s degC)] MCp of air in DC
param Cpwater		:= 4.18; #[kJ/kgC]
################################
##Variables

var TDCout{Time} 	>= 0.001; #[deg C] temperature of air coming from data center out of the heat recovery HE
var AHEDC 			>= 0.001; #[m2] area of heat recovery heat exchanger
var dTLMDC{Time} 	>= 0.001; #logarithmic mean temperature difference in the heat recovery heat exchanger
var TRadin{Time} 	>= 30.01; #[deg C]

var E{Time} 		>= 0.001; #[kW] electricity consumed by the heat pump (using pre-heated lake water)
var TLMCond{Time} 	>= 0.001; #[K] logarithmic mean temperature in the condensor of the heating HP (using pre-heated lake water)
var Qevap{Time} 	>= 0.001; #[kW] heat extracted in the evaporator of the heating HP (using pre-heated lake water)
var Qcond{Time} 	>= 0.001; #[kW] heat delivered in the condensor of the heating HP (using pre-heated lake water)
var COP{Time} 		>= 0.001; #coefficient of performance of the heating HP (using pre-heated lake water)

var OPEX 			>= 0.001; #[CHF/year] operating cost
var CAPEX 			>= 0.001; #[CHF/year] annualized investment cost
var TC 				>= 0.001; #[CHF/year] total cost
var Cp              >= 0.001; 
var IC              >= 0.001;

var TLMEvapHP{Time} >= 0.001; #[K] logarithmic mean temperature in the evaporator of the heating HP

var Qrad{Time} 		>= 0.001; # DC heat recovered;

var THPin{Time} 	>= 7;
var Qfree{Time} 	>= 0.001; #free cooling heat; makes sure DC air is cooled down.
var Flow{Time} 		>= 0.001; #lake water entering free cooling HEX
var MassEPFL{Time} 	>= 0.001; # MCp of EPFL heating system [KJ/(s degC)]

################################
# Constraints
####### Direct Heat Exchanger;

## TEMPERATURE CONTROL CONSTRAINS exist to be sure the temperatures in the HEX do not cross, meaning to make sure there is a certain DTmin. (3 are recommended, but you can have more or less)
# Thin-Tcout > DeltaTmin and Thout-Tcin > DeltaTmin
#DeltaTmin=2 very good HE (too expensive for us)

subject to Tcontrol1{t in Time}: 
#HE
    TDCin - TRadin[t] >= 2;

subject to Tcontrol2{t in Time}:
#HE
    TDCout[t] - EPFLMediumOut >= 2;

subject to Tcontrol3{t in Time}:
#Freecooling
    TDCout[t] - THPin[t] >= 2;
    #Tret - THPhighin > 2; This is already OK!


## MASS BALANCE

subject to McpEPFL{t in Time}: #MCp of EPFL heating fluid calculation.
	MassEPFL[t] = Qheating[t] / (EPFLMediumT-EPFLMediumOut);
	
## MEETING HEATING DEMAND, ELECTRICAL CONSUMPTION
subject to dTLMDataCenter {t in Time}: #the logarithmic mean temperature difference in the heat recovery HE can be computed
    dTLMDC[t] = ((TDCin - TRadin[t]) - (TDCout[t] - EPFLMediumOut)) / log( (TDCin - TRadin[t]) / (TDCout[t] - EPFLMediumOut) );#In case of a counter-current HEX!! Check equation, not sure...

subject to HeatBalance1{t in Time}: #Heat balance in DC HEX from DC side
    Qrad[t] = MassDC * (TDCin - TDCout[t]);

subject to HeatBalance2{t in Time}: # Heat balance from the other side of DC HEX
    Qrad[t] = MassEPFL[t] * (TRadin[t] - EPFLMediumOut);

subject to AreaHEDC{t in Time}: #the area of the heat recovery HE can be computed using the heat extracted from DC, the heat transfer coefficient and the logarithmic mean temperature difference 
    Qrad[t] = AHEDC * UDC * dTLMDC[t];

subject to Freecooling1{t in Time}: #Free cooling from the side of the data center
    Qfree[t] = MassDC * (TDCout[t] - Tret);

subject to Freecooling2{t in Time}: #Free cooling from the side of the lake water
    Qfree[t] = Flow[t] * Cpwater * (THPin[t] - THPhighin);

subject to QEvaporator{t in Time}: #water side of evaporator that takes flow from Free cooling HEX
    Qevap[t] = Flow[t] * Cpwater * (THPin[t] - THPhighout);

subject to QCondensator{t in Time}: #EPFL side of condenser delivering heat to EFPL
	Qcond[t] = MassEPFL[t] * (EPFLMediumT - TRadin[t]);

subject to HeatBalanceDC{t in Time}: #makes sure all HeatDC is removed;
	Qrad[t] + Qfree[t] = HeatDC;

subject to Electricity1{t in Time}: #the electricity consumed in the HP can be computed using the heat delivered and the heat extracted
    E[t] = Qcond[t] - Qevap[t];

subject to Electricity{t in Time}: #the electricity consumed in the HP can be computed using the heat delivered and the COP
    E[t] = Qcond[t] / COP[t];

subject to COPerformance{t in Time}: #the COP can be computed using the carnot efficiency and the logarithmic mean temperatures in the condensor and in the evaporator
    COP[t] = CarnotEff * ( TLMCond[t] / (TLMCond[t] - TLMEvapHP[t]));

subject to dTLMCondensor{t in Time}: #the logarithmic mean temperature on the condenser, using inlet and outlet temperatures. Note: should be in K
    TLMCond[t] = (EPFLMediumT - TRadin[t]) / log( (EPFLMediumT + 273) / (TRadin[t] + 273) );

subject to dTLMEvaporator{t in Time}: #the logarithmic mean temperature can be computed using the inlet and outlet temperatures, Note: should be in K
    TLMEvapHP[t] = (THPin[t] - THPhighout) / log( (THPin[t] + 273) / (THPhighout + 273) );

subject to QEPFLausanne{t in Time}: #the heat demand of EPFL should be the sum of the heat delivered by the 2 systems;
    Qheating[t] = Qcond[t] + Qrad[t];

## COSTS and OBJECTIVE
subject to OPEXcost: #the operating cost can be computed using the electricity consumed in the HP
    OPEX = sum{t in Time: Qheating[t] > 0} (E[t] * top[t] * Cel);

subject to CAPEXcost: #the investment cost can be computed using the area of the heat recovery heat exchanger and annuity factor
    Cp = (INew / IRef) * 10^(aHE + bHE * log(AHEDC)); #Cp = (INew/IRef) * (AHEDC/aHE)^(bHE)
    IC = Cp * FBMHE;
    CAPEX =  IC * (i * (1 + i)^n) / ((1 + i)^n - 1);

subject to TCost: #the total cost can be computed using the operating and investment cost
    TC = OPEX + CAPEX;

################################
minimize obj : TC;