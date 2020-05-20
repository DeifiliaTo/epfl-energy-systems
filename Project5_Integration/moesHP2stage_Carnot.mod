/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiency of 2stagesHP
---------------------------------------------------------------------------------------------------------------------------------------*/
#param eff_carnot := 0.64;
param E_HP{Time};
param E_LP{Time};

/*---------------------------------------------------------------------------------------------------------------------------------------
Set the hot and cold temperature
---------------------------------------------------------------------------------------------------------------------------------------*/

param T_evap := 5.5;
param T_sep;   
param T_cond := 65;          # water is taken from the lake at 7C and is rejected at 4C (max 3C of difference)

/*---------------------------------------------------------------------------------------------------------------------------------------
Set the electricity output as a function of Th, Tc and Heat to supply to the buildings
---------------------------------------------------------------------------------------------------------------------------------------*/

#let Flowin['Electricity','HP2stage'] := sum{h in HeatingLevel} ((Qheatingsupply['HP2stage'] * (Theating[h] - Tlmc_HP2stage)) / (eff_carnot * (Theating[h]+273))) ;

subject to COP_HP {t in Time}:
    Qheatingsupply['HP2stage'] * mult_t['HP2stage',t] * (T_cond - T_sep) = f_HP[t] * (T_cond + 273) * E_HP[t];

subject to COP_LP {t in Time}:
    (Qheatingsupply['HP2stage'] * mult_t['HP2stage',t] - E_HP[t]) * (T_sep - T_evap) = f_LP[t] * (T_sep + 273) * E_LP[t];

subject to EnergyBalance {t in Time}:
    Qheatingsupply['HP2stage'] * mult_t['HP2stage',t] = Q_evap[t] + E_HP[t] + E_LP[t];

subject to ElecHP2 {t in Time}:
    FlowInUnit['Electricity','HP2stage',t] = E_HP[t] + E_LP[t];
