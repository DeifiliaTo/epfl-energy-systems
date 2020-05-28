/*---------------------------------------------------------------------------------------------------------------------------------------
Add improvements from Part 3
---------------------------------------------------------------------------------------------------------------------------------------*/
set Improvements default {};

param OPEX{Improvements} 			>= 0.001; #[CHF/year] operating cost
param CAPEX{Improvements} 		>= 0.001; #[CHF/year] annualized investment cost

var use_recovery{Improvements} 		    binary;								# binary variable to decide if DC is used or not
param heat_recovery{Improvements, Time} default 0;

/*---------------------------------------------------------------------------------------------------------------------------------------
Update heat balance
---------------------------------------------------------------------------------------------------------------------------------------*/
delete MT_balance;
subject to MT_balance{t in Time}:
	Qheatingdemand['MediumT',t] - sum{u in Improvements} (heat_recovery[u,t] * use_recovery[u]) = 
		sum{u in UtilitiesOfType['Heating']: Tminheating[u] >= Theating['MediumT'] + dTmin} (Qheatingsupply[u] * mult_heating_t[u,t,'MediumT']) 
;

/*---------------------------------------------------------------------------------------------------------------------------------------
Update resource balances 
---------------------------------------------------------------------------------------------------------------------------------------*/
delete inflow_cstr;
subject to inflow_cstr {l in Layers, u in UtilitiesOfLayer[l] diff {"HP1stageLT","HP1stageMT","HP2stage"}, t in Time}:
    FlowInUnit[l, u, t] = mult_t[u,t] * Flowin[l,u];

delete outflow_cstr;
subject to outflow_cstr {l in Layers, u in UtilitiesOfLayer[l] diff {"HP1stageLT","HP1stageMT","HP2stage"}, t in Time}:
	FlowOutUnit[l, u, t] = mult_t[u,t] * Flowout[l,u]; 

/*---------------------------------------------------------------------------------------------------------------------------------------
CO2 emissions
---------------------------------------------------------------------------------------------------------------------------------------*/
# new sets: grids assigned by layer
set GridsOfLayer{Layers} default {};

# emission factors [kg-CO2/kWh]
param c_CO2{Layers} default 0;

# CO2 emissions calculations [kg-CO2eq]
var CO2;
subject to CO2_emission:
	CO2 = sum{t in Time, l in Layers, g in GridsOfLayer[l]}( c_CO2[l] * FlowOutUnit[l,g,t] * top[t] );

# energy import
var Eimport;
subject to energy_import:
	Eimport = sum{t in Time, l in Layers, g in GridsOfLayer[l]}( FlowOutUnit[l,g,t] );

/*---------------------------------------------------------------------------------------------------------------------------------------
Update cost calculations
---------------------------------------------------------------------------------------------------------------------------------------*/
delete oc_cstr;
subject to oc_cstr:
	OpCost = sum {u in Utilities, t in Time} (cop1[u] * use_t[u,t] + cop2[u] * mult_t[u,t]) * top[t]
			 + sum {u in Improvements} use_recovery[u] * OPEX[u] + sum{t in Time}(c_CO2['Natgas'] * FlowOutUnit['Natgas','NatGasGrid',t] * top[t]) * 96 * (10^-3)
;

delete ic_cstr;
subject to ic_cstr:
	InvCost = sum{tc in Technologies} (cinv1[tc] * use[tc] + cinv2[tc] * mult[tc])
			+ sum{u in Improvements} use_recovery[u] * CAPEX[u]
;
