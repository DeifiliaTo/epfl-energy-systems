/*---------------------------------------------------------------------------------------------------------------------------------------
Variables
---------------------------------------------------------------------------------------------------------------------------------------*/

var f_HP{Time} >= 0.001;
var f_LP{Time} >= 0.001;

var E_HP{Time} >= 0.001;
var E_LP{Time} >= 0.001;

var Q_evap{Time} >= 0.001;

/*---------------------------------------------------------------------------------------------------------------------------------------
Parameters
---------------------------------------------------------------------------------------------------------------------------------------*/

param T_evap := 5.5;
param T_sep := 52.1919;   
param T_cond := 65;          # water is taken from the lake at 7C and is rejected at 4C (max 3C of difference)

/*---------------------------------------------------------------------------------------------------------------------------------------
Equations
---------------------------------------------------------------------------------------------------------------------------------------*/

subject to f1 {t in Time}:
    f_HP[t] = a_HP * (Text[t] + 273)^2 + b_HP * (Text[t] + 273) + c_HP;

subject to f2 {t in Time}:
    f_LP[t] = a_LP * (Text[t] + 273)^2 + b_LP * (Text[t] + 273) + c_LP;

subject to COP_HP {t in Time}:
    Qheatingsupply['HP2stage'] * mult_t['HP2stage',t] * (T_cond - T_sep) = f_HP[t] * (T_cond + 273) * E_HP[t];

subject to COP_LP {t in Time}:
    (Qheatingsupply['HP2stage'] * mult_t['HP2stage',t] - E_HP[t]) * (T_sep - T_evap) = f_LP[t] * (T_sep + 273) * E_LP[t];

subject to EnergyBalance {t in Time}:
    Qheatingsupply['HP2stage'] * mult_t['HP2stage',t] = Q_evap[t] + E_HP[t] + E_LP[t];

subject to ElecHP2 {t in Time}:
    FlowInUnit['Electricity','HP2stage',t] = E_HP[t] + E_LP[t];
