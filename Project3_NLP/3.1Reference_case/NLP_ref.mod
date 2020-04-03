reset;
################################
# DTmin optimisation
################################
# Sets & Parameters

set Time default {}; #your time set from the MILP part
param Qheating{Time}; #your heat demand from the MILP part, only Medium temperature heat (65 deg C) [kW or kWh]
param top{Time}; #your operating time from the MILP part [hours]

param EPFLMediumT 	:= 65; #[degC] - desired temperature high temperature loop
param EPFLMediumOut := 30; # temperature of return low temperature loop [degC]

param CarnotEff 	:= 0.55; #assumption: carnot efficiency of heating heat pumps
param Cel 			:= 0.20; #[CHF/kWh] operating cost for buying electricity from the grid

param THPhighin 	:= 7; #[deg C] temperature of water coming from lake into the evaporator of the HP
param THPhighout 	:= 3; #[deg C] temperature of water coming from lake into the evaporator of the HP

################################
# Variables

var E{Time} 		>= 0.001; # [kW] electricity consumed by the heat pump (using pre-heated lake water)
var TLMCond{Time} 	>= 0.001; #[K] logarithmic mean temperature in the condensor of the heating HP (using pre-heated lake water)
var Qevap{Time} 	>= 0.001; #[kW] heat extracted in the evaporator of the heating HP (using pre-heated lake water)
var Qcond{Time} 	>= 0.001; #[kW] heat delivered in the condensor of the heating HP (using pre-heated lake water)
var COP{Time} 		>= 0.001; #coefficient of performance of the heating HP (using pre-heated lake water)

var OPEX 			>= 0.001; #[CHF/year] operating cost

var TLMEvapHP{Time} >= 0.001; #[K] logarithmic mean temperature in the evaporator of the heating HP

var Flow{Time} 		>= 0.001; #lake water entering free cooling HEX [kg/s]
var MassEPFL{Time} 	>= 0.001; # MCp of EPFL heating system [kJ/(s degC)]

################################
# Constraints
################################
 
## MASS BALANCE

#subject to Flows{t in Time}: #MCp of EPFL heating fluid calculation.
	#MassEPFL[t] = Qheating[t] / (EPFLMediumT - EPFLMediumOut); We don't need this equation because linear combination of others

## MEETING HEATING DEMAND, ELECTRICAL CONSUMPTION

subject to QEvaporator{t in Time}: #water side of evaporator that takes flow from lake with Cp = 4.186 kJ/kg/K
    Qevap[t] = Flow[t] * 4.186 * (THPhighin - THPhighout);

subject to QCondensator{t in Time}: #EPFL side of condenser delivering heat to EFPL
    Qcond[t] = MassEPFL[t] * (EPFLMediumT - EPFLMediumOut);

subject to Electricity1{t in Time}: #the electricity consumed in the HP (using pre-heated lake water) can be computed using the heat delivered and the heat extracted
    E[t] = Qcond[t] - Qevap[t];

subject to Electricity{t in Time}: #the electricity consumed in the HP (using pre-heated lake water) can be computed using the heat delivered and the COP
    E[t] = Qcond[t] / COP[t];

subject to COPerformance{t in Time}: #the COP can be computed using the carnot efficiency and the logarithmic mean temperatures in the condensor and in the evaporator
    COP[t] = CarnotEff * ( TLMCond[t] / (TLMCond[t] - TLMEvapHP[t]));

subject to dTLMCondensor{t in Time}: #the logarithmic mean temperature on the condenser, using inlet and outlet temperatures. Note: should be in K
    TLMCond[t] = (EPFLMediumT - EPFLMediumOut) /  log( (EPFLMediumT + 273) / (EPFLMediumOut + 273) );

subject to dTLMEvaporatorHP{t in Time}: #the logarithmic mean temperature can be computed using the inlet and outlet temperatures, Note: should be in K
    TLMEvapHP[t] = (THPhighin - THPhighout) /  log( (THPhighin + 273) / (THPhighout + 273) );

subject to QEPFLausanne{t in Time}: #the heat demand of EPFL should be supplied by the HP.
    Qheating[t] = Qcond[t]; # Qheating is in kW

subject to OPEXcost: #the operating cost can be computed using the electricity consumed in the HP;
    OPEX = sum{t in Time: Qheating[t] > 0} (E[t] * top[t] * Cel);

################################
minimize obj : OPEX;