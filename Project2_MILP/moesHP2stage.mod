/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiency of 2stagesHP
---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_carnot := 0.64;

/*---------------------------------------------------------------------------------------------------------------------------------------
Set the hot and cold temperature
---------------------------------------------------------------------------------------------------------------------------------------*/

#param Tlmc_HP2stage{t in Time}  := (Tlake[t]-3)/log((Tlake[t]+273)/(3+273)); #water is taken from the lake at Tlake and returned at 3�C

param Tlmc_HP2stage := 5.5;             # water is taken from the lake at 7C and is rejected at 4C (max 3C of difference)

/*---------------------------------------------------------------------------------------------------------------------------------------
Set the electricity output as a function of Th, Tc and Heat to supply to the buildings
---------------------------------------------------------------------------------------------------------------------------------------*/

/*?????LOOP LOW TEMPERATURE OR LOOP HIGH TEMPERATURE */
#subject to HP2stage_elecIn{t in Time}:
# FlowInUnit['Electricity','HP2stage', t] = sum{h in HeatingLevel} (Qheatingsupply['HP2stage'] * (Theating[h] - Tlmc_HP2stage[t])) / (eff_carnot * (Theating[h]+273)) ;
/* Qheatingsupply is Q+calculated or the name of de variable is not correct?*/

Flowin['Heat','HP2stage'] = Qheatingsupply['HP2stage'] - Electricity['HP2stage'] ;
# why are we trying to calculate heat supplied to the pump? we don't care about this afaik...